function zle-keymap-select() {
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
function mkcd() {
  mkdir $1 && cd $1
}
precmd() {
   echo -ne '\e[6 q'
}

set -o vi
setopt NO_HUP
zle -N zle-keymap-select
KEYTIMEOUT=1
path+="$HOME/.config/bin"

bindkey -M viins '^?' backward-delete-char
bindkey -M viins '^H' backward-delete-char
