set -o vi
KEYTIMEOUT=1
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
bindkey -M viins '^?' backward-delete-char
bindkey -M viins '^H' backward-delete-char

setopt NO_HUP
path+="$HOME/.config/bin"
