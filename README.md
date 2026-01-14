### Prerequisite

**spinner** requires [`jq`](https://github.com/jqlang/jq) to extract spinners from [`spinners.json`](./spinners.json):

```bash
sudo pacman -S jq
```

#

### Install

Clone the repository and run [`./install`](./install):

```bash
git clone https://github.com/sejjy/spinner.git && cd spinner && ./install
```

#

### Usage

```
USAGE: spinner [OPTIONS] <command> [args...]

Run a command with an animated spinner.

OPTIONS:
  -d             enable debug output
  -f <file>      set JSON config file (default: ~/.config/spinner/spinners.json)
  -i <interval>  set frame interval in milliseconds
  -l             list available spinners
  -s <style>     set spinner style (default: line)
  -h             show this help message
```

#

### Uninstall

Run [`./uninstall`](./uninstall).

#

### References

- [spinner](https://github.com/bahamas10/ysap/blob/main/code/2026-01-07-spinner/spinner)
- [Creating a Terminal Spinner in Bash! ↗](https://www.youtube.com/watch?v=muCcQ1W33tc)
- [cli-spinners](https://github.com/sindresorhus/cli-spinners)

#

### License

All code is licensed under the MIT License
