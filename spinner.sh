#!/usr/bin/env bash
#
# Run a command with an animated spinner.
#
# Spinners taken from:
# https://github.com/sindresorhus/cli-spinners
#
# Author: Dave Eddy <dave@daveeddy.com>
# Date: January 05, 2026
# License: MIT

SPINNER_PID=
DEBUG=false
THEME="line"
CHARS=

usage() {
	cat <<- EOF
		Usage: ${0##*/} [options] <cmd>

		Run a command with an animated spinner.

		Options:
		  -d          enable debug output
		  -t <theme>  theme to use, default is "line"
		  -h          print this message and exit
	EOF
}

spinner() {
	local c
	while true; do
		for c in "${CHARS[@]}"; do
			printf "%s\r" "$c"
			sleep 0.2
		done
	done
}

debug() {
	if $DEBUG; then
		printf "[%d] %s\n" $$ "$*" >&2
	fi
}

cleanup() {
	printf "\e[?25h" # make cursor visible

	if [[ -n $SPINNER_PID ]]; then
		debug "killing spinner ($SPINNER_PID)"
		kill $SPINNER_PID
	fi

	debug "finished spinner"
}

load_theme() {
	case $1 in
		line) CHARS=(- \\ \| /) ;;
		dots) CHARS=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏) ;;
		pong)
			CHARS=(
				"▐⠂       ▌"
				"▐⠈       ▌"
				"▐ ⠂      ▌"
				"▐ ⠠      ▌"
				"▐  ⡀     ▌"
				"▐  ⠠     ▌"
				"▐   ⠂    ▌"
				"▐   ⠈    ▌"
				"▐    ⠂   ▌"
				"▐    ⠠   ▌"
				"▐     ⡀  ▌"
				"▐     ⠠  ▌"
				"▐      ⠂ ▌"
				"▐      ⠈ ▌"
				"▐       ⠂▌"
				"▐       ⠠▌"
				"▐       ⡀▌"
				"▐      ⠠ ▌"
				"▐      ⠂ ▌"
				"▐     ⠈  ▌"
				"▐     ⠂  ▌"
				"▐    ⠠   ▌"
				"▐    ⡀   ▌"
				"▐   ⠠    ▌"
				"▐   ⠂    ▌"
				"▐  ⠈     ▌"
				"▐  ⠂     ▌"
				"▐ ⠠      ▌"
				"▐ ⡀      ▌"
				"▐⠠       ▌"
			)
			;;
		*)
			printf "invalid theme: %s\n\n" "$THEME" >&2
			usage >&2
			exit 1
			;;
	esac
}

main() {
	if (($# == 0)); then
		usage >&2
		return 1
	fi

	local opt
	while getopts ":dht:" opt; do
		case $opt in
			d) DEBUG=true ;;
			h) usage; return 0 ;;
			t) THEME=$OPTARG ;;
			:)
				printf -- "-%s requires an argument\n\n" "$OPTARG"
				usage >&2
				return 1
				;;
			?)
				printf "invalid option: -%s\n\n" "$OPTARG"
				usage >&2
				return 1
				;;
			*) usage >&2; return 1 ;;
		esac
	done
	shift $((OPTIND - 1))

	trap cleanup EXIT
	printf "\e[?25l" # make cursor invisible

	load_theme "$THEME"
	debug "starting spinner"

	spinner &
	SPINNER_PID=$!

	debug "SPINNER_PID=$SPINNER_PID"

	"$@"
}

main "$@"
