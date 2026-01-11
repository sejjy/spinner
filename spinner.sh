#!/usr/bin/env bash
#
# spinner: Run a command with an animated spinner (extended).
#
# Requires `jq` to extract spinners from a JSON config file.
#
# Original script:
# https://github.com/bahamas10/ysap/blob/main/code/2026-01-07-spinner/spinner
#
# Spinners:
# https://github.com/sindresorhus/cli-spinners
#
# Author:      Dave Eddy <dave@daveeddy.com>
# Extended by: Jesse Mirabel <sejjymvm@gmail.com>
# Date:        January 08, 2026
# License:     MIT

XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
DEFAULT_JSON=$XDG_CONFIG_HOME/spinner/spinners.json

DEFAULT_MS=130
DEFAULT_STYLE="line"
DEBUG_OUTPUT=false

SPINNER_FRAMES=()
SPINNER_PID=

usage() {
	cat <<- EOF
		USAGE: ${0##*/} [OPTIONS] <command> [args...]

		Run a command with an animated spinner.

		OPTIONS:
		  -d             enable debug output
		  -f <file>      set JSON config file (default: ${DEFAULT_JSON/$HOME/'~'})
		  -i <interval>  set frame interval in milliseconds (default: $DEFAULT_MS)
		  -l             list available spinners
		  -s <style>     set spinner style (default: $DEFAULT_STYLE)
		  -h             show this help message
	EOF
}

error() {
	printf "\e[31m" # red
	printf "error: %b\n\n" "$*" >&2
	printf "\e[39m" # reset FG
}

debug() {
	if $DEBUG_OUTPUT; then
		printf "[debug] %s\n" "$*" >&2
	fi
}

check_status() {
	case $? in
		0) return 0 ;;
		2) error "config file not found" ;;
		4) error "invalid JSON config file" ;;
		5) error "unknown spinner" ;;
		*) error "unknown error" ;;
	esac

	usage >&2
	exit 1
}

list_spinners() {
	local file=${1:-$DEFAULT_JSON}

	debug "listing spinners from $file"

	jq -re "keys[]" "$file" 2> /dev/null
	check_status
}

load_spinner() {
	local style=${1:-$DEFAULT_STYLE}
	local file=${2:-$DEFAULT_JSON}

	debug "loading $style spinner from $file"

	local output
	output=$(jq -re ".$style.frames[]" "$file" 2> /dev/null)
	check_status

	local line
	while IFS= read -r line; do
		SPINNER_FRAMES+=("$line")
	done <<< "$output"
}

start_spinner() {
	local interval=${1:-$DEFAULT_MS}

	local _s _ms secs
	_s=$((interval / 1000))
	_ms=$((interval % 1000))
	secs=$_s.$(printf "%03d" $_ms)

	debug "frame interval: ${interval}ms (${secs}s)"

	local c
	while true; do
		for c in "${SPINNER_FRAMES[@]}"; do
			printf "%s\r" "$c"
			sleep "$secs"
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
	if ! command -v jq > /dev/null; then
		error "command not found: jq"
		return 1
	fi

	if (($# == 0)); then
		usage >&2
		return 1
	fi

	local opt file interval style
	while getopts ":hdf:i:ls:" opt; do
		case $opt in
			h) usage; return 0 ;;
			d) DEBUG_OUTPUT=true ;;
			f) file=$OPTARG ;;
			i) interval=$OPTARG ;;
			l) list_spinners "$file"; return 0 ;;
			s) style=$OPTARG ;;
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

	load_spinner "$style" "$file"

	debug "starting spinner"
	start_spinner "$interval" &

	SPINNER_PID=$!
	debug "spinner PID: $SPINNER_PID"

	"$@"
}

main "$@"
