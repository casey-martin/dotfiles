# A (futile) exercise in attempt to never rewrite another dotfile
GNU Stow is a godsend. No more `git --bare` nonsense. No more chasing errant symlinks.

A handy tutorial for using stow to manage dotfiles can be found [here](https://dr563105.github.io/blog/manage-dotfiles-with-gnu-stow/).

## For Debian-derived operating systems
```bash
sudo apt-get install stow
```

## For MacOS
```bash
sudo brew install stow
```

I wanted a simple and relatively portable Unix environment so I avoid fancy vim and tmux plugins.

## tmux cheatsheet
Backtick \` is the meta key.

| Action | Macro |
| --- | --- |
| split pane vertically | <code>` + |</code> |
| split pane horizontally | <code>` + -</code> |
| tmux history | <code>` + esc</code> |

vim-like movement keys enabled.

## vim cheatsheet
Relative numbering is on.
`-` toggles line numbers on and off.

