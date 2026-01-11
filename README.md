### Install

1. Install [jq](https://github.com/jqlang/jq) for JSON parsing:

	```bash
	sudo pacman -S jq
	```

2. Clone the repository and run [`./install`](./install):

	```bash
	git clone https://github.com/sejjy/spinner.git && cd spinner && ./install
	```

#

### Usage

```
USAGE: spinner [OPTIONS] <command> [args...]

Run a command with an animated spinner.

OPTIONS:
  -d            enable debug output
  -f <file>     set JSON config file (default: ~/.config/spinner/spinners.json)
  -l            list available spinners
  -s <style>    set spinner style (default: line)
  -h            show this help message
```

#

### Uninstall

Run [`./uninstall`](./uninstall).

#

### References

- spinner: [original script](https://github.com/bahamas10/ysap/blob/main/code/2026-01-07-spinner/spinner) |
  [YouTube video ↗](https://www.youtube.com/watch?v=muCcQ1W33tc)
- [cli-spinners](https://github.com/sindresorhus/cli-spinners)

#

### License

All code is licensed under the MIT License
