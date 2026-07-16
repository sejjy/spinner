<div align="center">

## spinner

A command-line spinner

| ![Demo](./screenshot.svg) |
| :-----------------------: |

<sup><i>Source: https://github.com/sindresorhus/cli-spinners/blob/main/screenshot.svg</i></sup>

</div>

#

### Requirements

- [jq](https://archlinux.org/packages/extra/x86_64/jq/): Command-line JSON processor

#

### Installation

Clone the repository and run `./install`:

```bash
git clone https://github.com/sejjy/spinner.git
cd spinner
./install
```

Or:

```bash
git clone https://github.com/sejjy/spinner.git && cd spinner && ./install
```

#

### Usage

```
NAME
  spinner - a command-line spinner

SYNOPSIS
  spinner [OPTIONS] <command> [args...]

OPTIONS
  -d             enable debug mode
  -f <file>      set config file (default: ~/.config/spinner/spinners.json)
  -i <interval>  set frame interval in milliseconds
  -l             list all spinner styles
  -s <style>     set spinner style (default: line)
  -h             show usage
```

#

### References

- [Creating a Terminal Spinner in Bash! (video) ↗](https://www.youtube.com/watch?v=muCcQ1W33tc)
- [spinner](https://github.com/bahamas10/ysap/blob/main/code/2026-01-07-spinner/spinner)
- [cli-spinners](https://github.com/sindresorhus/cli-spinners)
