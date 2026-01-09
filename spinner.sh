#!/usr/bin/env bash
#
# spinner.sh: Run a command with an animated spinner (extended).
#
# Requires `jq` to extract spinners from spinners.json
#
# Spinners taken from:
# https://github.com/sindresorhus/cli-spinners
#
# Author:      Dave Eddy <dave@daveeddy.com>
# Extended by: Jesse Mirabel <sejjymvm@gmail.com>
# Date:        January 08, 2026
# License:     MIT

DEFAULT_FILE=./spinners.json
DEFAULT_SPINNER="line"

DEBUG=false
FRAMES=()
SPINNER_PID=

usage() {
	cat <<- EOF
		USAGE: ${0##*/} [OPTIONS] <command>

		Run a command with an animated spinner.

		OPTIONS:
		  -d            Enable debug output.
		  -f <file>     Spinner JSON file to use (default: $DEFAULT_FILE).
		  -l            List all spinners.
		  -s <spinner>  Spinner to use (default: $DEFAULT_SPINNER).
		  -h            Print this message and exit.
	EOF
}

error() {
	printf "\e[31m" # red
	printf "error: %b\n\n" "$*" >&2
	printf "\e[39m" # reset fg
}

debug() {
	if $DEBUG; then
		printf "[%d] %s\n" $$ "$*" >&2
	fi
}

list_spinners() {
	local file=${1:-$DEFAULT_FILE}
	debug "listing spinners from $file"
	jq -r 'keys[]' "$file"
}

load_spinner() {
	local spinner=${1:-$DEFAULT_SPINNER}
	local file=${2:-$DEFAULT_FILE}

	debug "using $spinner spinner from $file"

	local frames
	frames=$(jq -r ".$spinner.frames[]" "$file" 2> /dev/null)

	local status=$?
	if ((status == 2)); then
		error "invalid JSON file: $file"
		usage >&2
		exit 1
	elif ((status == 5)); then
		error "unknown spinner: $spinner"
		usage >&2
		exit 1
	fi

	local line
	while IFS= read -r line; do
		FRAMES+=("$line")
	done <<< "$frames"
}

start_spinner() {
	local c
	while true; do
		for c in "${FRAMES[@]}"; do
			printf "%s\r" "$c"
			sleep 0.2
		done
	done
}

stop_spinner() {
	printf "\e[?25h" # make cursor visible
	stty echo        # turn on echoing

	if [[ -n $SPINNER_PID ]]; then
		debug "killing spinner ($SPINNER_PID)"
		kill $SPINNER_PID
	fi

	debug "finished spinner"
}

main() {
	if (($# == 0)); then
		usage >&2
		return 1
	fi

	local opt file spinner
	while getopts ":hdf:ls:" opt; do
		case $opt in
			h) usage; return 0 ;;
			d) DEBUG=true ;;
			f) file=$OPTARG ;;
			l) list_spinners "$file"; return 0 ;;
			s) spinner=$OPTARG ;;
			:)
				error "-$OPTARG requires an argument"
				usage >&2
				return 1
				;;
			?)
				error "invalid option: -$OPTARG"
				usage >&2
				return 1
				;;
			*) usage >&2; return 1 ;;
		esac
	done
	shift $((OPTIND - 1))

	trap stop_spinner EXIT

	printf "\e[?25l" # make cursor invisible
	stty -echo       # turn off echoing

	load_spinner "$spinner" "$file"
	debug "starting spinner"

	start_spinner &
	SPINNER_PID=$!

	debug "SPINNER_PID=$SPINNER_PID"

	"$@"
}

main "$@"
