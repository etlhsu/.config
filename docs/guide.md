# Technical Guide

### Commands
- `command &` launch a command in the background
- `grep -rl matchstring somedir/` - returns files matching a certain `matchstring`
- `| grep -o matchstring` - returns *o*nly matched parts from piped-in input
- `| xargs sed -i 's/string1/string2/g'` - Performs find and replace on piped-in files
- `sed 'x!d' file` - Returns line x of a file

### Tmux
`Ctrl+B` is the prefix key which can be combined with other keys to perform actions:
- `?` - see of all of the actions
- `%` - split pane vertically
- `"` - split pane horizontally
- `w` - select window
- `s` - select session
- `D` - select client

Use `Ctrl+B`+`:` to enter commands:
- `:new` - Create a new session

### Neovim
- `gq_` - Reformat text to fit
- `Ctrl+G` - print file path
- `1``Ctrl+G` - print absolute file path
- `2``Ctrl+G` - print absolute file path with buffer number
- `<c-r>"` - paste from unnamed buffer in telescope prompt

### Folds
- `zM` - Close all folds
- `zR` - Open all folds

### Spelling
- `set spell`/`nospell` - Enable/disable spelling for a buffer
- `[s`/`]s` - Go to previous/next misspelled word
- `z=` Find suggestions for the misspelled word under the cursor

### Substitution
- `\r`- Used to add a newline in the second part of a substitution

### Miscellaneous
- `redir @">|command` - Redirects command output to the unnamed register
- `helptags ALL` - Generate help tags files for all plugins

### Zsh

```shell
# Choose from a list
select out in a b c d; do
  echo "char: $out option: $REPLY"
  break # If single shot
done
```
