# Configuration
autoload -U colors && colors

set -o vi
setopt autocd
setopt NO_HUP
setopt AUTO_CONTINUE
autoload -Uz predict-on
zle -N predict-on
bindkey '^N' end-of-line
bindkey -M viins '^?' backward-delete-char
bindkey -M viins '^H' backward-delete-char

spin-key() spin refresh
zle -N spin-key 
bindkey '^E' spin-key

export ANDROID_EMULATOR_WAIT_TIME_BEFORE_KILL=60
export FZF_DEFAULT_COMMAND='rg --files --no-ignore-vcs --hidden'
export FZF_CTRL_T_COMMAND='rg --files --no-ignore-vcs --hidden'
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
path+="$HOME/.config/bin"

# Utilities

mkcd() {
   mkdir $1
   cd $1
}

checkgitenv() {
  if ! [ -f $prompt_root/current_env.txt ]; then
      touch $prompt_root/current_env.txt
    fi
  if ! [ -f $prompt_root/new_env.txt ]; then
    touch $prompt_root/new_env.txt
  fi
  git status --short > $prompt_root/new_env.txt
  git describe --abbrev=12 --always --dirty=+ >> $prompt_root/new_env.txt
  if ! cmp --silent $prompt_root/current_env.txt $prompt_root/new_env.txt; then
    cp $prompt_root/new_env.txt $prompt_root/current_env.txt
    return 1
  fi
}

minprompt() {
  if git rev-parse --is-inside-work-tree &> /dev/null; then
    prompt_root=~/.config/.prompt/$(basename $(git rev-parse --show-toplevel))
    if [ ! -d $prompt_root ]; then
      mkdir -p $prompt_root
    fi
    if ! [ -f $prompt_root/vcs_prompt.txt ]; then
      touch $prompt_root/vcs_prompt.txt
    fi
  fi

  if ! git rev-parse --is-inside-work-tree &> /dev/null; then
  # if ! echo "$PWD" | grep -oh "$HOME" &> /dev/null || [[ ! "$PWD" = "$HOME" && "$(git rev-parse --show-toplevel)" = "$HOME" ]]; then
    PROMPT="%{$fg[green]%}%(4~|.../%8~|%~)"$'\n'"%{$fg[default]%}%# "
  elif checkgitenv; then
    PROMPT="$(cat $prompt_root/vcs_prompt.txt) %{$fg[green]%}%(4~|.../%8~|%~)"$'\n'"%{$fg[default]%}%# "
  else
    changes=$(git status --short | wc -l | xargs)
    if [ $changes -gt 0 ]; then
      if ! [ "$(git status --short | tail -n 1 | head -c 2)" = "??" ]; then
        changes="$fg[yellow]$changes "
      else
        changes="$fg[red]$changes "
      fi
    else
      changes=""
    fi
    percent='%%'
    branch_name="$(git rev-parse --abbrev-ref HEAD)"
    if ! [ -z $branch_name ]; then
      branch_name="$branch_name"
    fi
   commit_msg="$(git log -1 --pretty=%B | head -n 1)"
   vcs_prompt="$changes$fg[magenta]$branch_name $fg[blue]$commit_msg" 
   echo "$vcs_prompt" > $prompt_root/vcs_prompt.txt
   NEWLINE=$'\n'
   PROMPT="$(cat ${prompt_root}/vcs_prompt.txt) $fg[green]%~${NEWLINE}$fg[default]%# "
  fi

  echo -ne '\e[6 q'
}

function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
     [[ $1 = 'block' ]]; then
    echo -ne '\e[2 q'

  elif [[ ${KEYMAP} == main ]] ||
       [[ ${KEYMAP} == viins ]] ||
       [[ ${KEYMAP} = '' ]] ||
       [[ $1 = 'beam' ]]; then
    echo -ne '\e[6 q'
  fi
}
zle -N zle-keymap-select
precmd() {
   echo -ne '\e[6 q'
}
preexec() {
   echo -ne '\e[2 q'
}
vx() {
  commits="$(git xl | grep -Eo '\*.+' | cut -d ' ' -f2-)"
  echo $commits
  rev="$(echo $commits | fzf --layout=reverse-list | cut -d ' ' -f1)"
  echo "$rev"
}
. "$HOME/.cargo/env"
