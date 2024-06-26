<div align="center">

# `tang`

![GitHub Version](https://img.shields.io/github/v/release/LVala/tang)
![GitHub License](https://img.shields.io/github/license/LVala/tang)

### Dead simple [tmux](https://github.com/tmux/tmux) session picker for [fish](https://fishshell.com/) 🐟

![tang demo](tang.gif)
</div>

## Installation

Install dependencies:

```shell
brew install fish tmux fzf  # for MacOS
sudo pacman -S fish tmux fzf  # for Arch Linux
```

Install `tang` with [Fisher](https://github.com/jorgebucaran/fisher):

```shell
fisher install LVala/tang
```

or copy the contents of directories in this repository
to corresponding directories in your `$__fish_config_dir`.

## Usage

Let's start with the concept of *tang sessions*, which is a list of strings
created based on the `tang_paths` environment variable:

```shell
set tang_paths ~/notes ~/projects/
```

`$tang_paths` must be a list of directory paths. If the path
ends with a trailing slash '/', `tang` expands it to all of its subdirectories.
So the variable above would generate these paths:

```shell
~/notes
~/projects/cool_project
~/projects/awesome_project
# and all of the other directories in ~/projects...
```

and then generate session names based on these paths:

```shell
notes
cool_project
awesome_project
...
```

Let's call this the *tang sessions* (**warning!** duplicate session names currently not supported).

You can use the `tang some_session` command to create and/or attach
to a tmux session named `some_session`. If the session does not exist,
`tang` will create it and set the initial directory to:

* the output of `pwd`, if the session doesn't belong to *tang sessions*,
* directory corresponding to the name, if the session belongs to *tang sessions*.

If the `--editor` flag is used, a window with `$EDITOR` will be additionally opened and selected.
Otherwise, if the session exists, `tang` will attach to it.

If called without arguments, `tang` will make you choose the session
name from the *tang sessions* list, together with other existing tmux sessions
using a fuzzy picker.

### Example

This is my personal config:

```shell
# in config.fish
set -g tang_paths ~/repos/

if status is-interactive
    # in TTY or already in tmux? don't run tang
    string match -q '/dev/tty*' (tty)
    or set -q TMUX || tang misc
end
```

```shell
# in tmux.conf
bind-key j display-popup -E "fish -c 'tang -e'"
```

This way:
- when I open my terminal, I'll always jump to the `misc` session.
- when already in tmux, I can press `prefix + j` to open a
popup window with a fuzzy picker (thanks to this I don't need to stop
currently running command, like `nvim`). There, I can choose
another session out of the list of my repos (subdirectories
of the `~/repos` directory set in `$tang_paths`) or the `misc` session,
because it already (most likely) exists.
