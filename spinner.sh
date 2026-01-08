#!/usr/bin/env bash
#
# spinner.sh: Run a command with an animated spinner. (extended)
#
# Dependencies:
# 	- jq
#
# Spinners taken from:
# https://github.com/sindresorhus/cli-spinners
#
# Author:      Dave Eddy <dave@daveeddy.com>
# Extended by: Jesse Mirabel <sejjymvm@gmail.com>
# Date:        January 08, 2026
# License:     MIT

DEFAULT_SPINNER="line"
SPINNERS_FILE=spinners.json

DEBUG=false
FRAMES=()
SPINNER_PID=

usage() {
	cat <<- EOF
		USAGE: ${0##*/} [OPTIONS] <command>

		Run a command with an animated spinner.

		OPTIONS:
		  -d            Enable debug mode.
		  -s <spinner>  Specify a spinner to use. Default is "$DEFAULT_SPINNER".
		                See $SPINNERS_FILE for a list of available spinners.
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

load_spinner() {
	local spinner=${1:-$DEFAULT_SPINNER}

	local line
	while IFS= read -r line; do
		FRAMES+=("$line")
	done < <(jq -r ".$spinner.frames[]" $SPINNERS_FILE 2> /dev/null)

	if ((${#FRAMES[@]} == 0)); then
		error "unknown spinner: $spinner"
		usage >&2
		DEBUG=false
		exit 1
	fi
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

	local opt spinner
	while getopts ":dhs:" opt; do
		case $opt in
			d) DEBUG=true ;;
			h) usage; return 0 ;;
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

	load_spinner "$spinner"
	debug "starting spinner"

	start_spinner &
	SPINNER_PID=$!

	debug "SPINNER_PID=$SPINNER_PID"

	"$@"
}

main "$@"
