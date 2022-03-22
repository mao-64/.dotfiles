autoload -U colors && colors
#PS1="%B%{$fg[white]%}%{$fg[black]%}%{$bg[white]%}%n%{$reset_color%}%{$bg[blue]%}%{$fg[white]%}%{$fg_bold[black]%}%M %~%{$reset_color%}%{$fg[blue]%}%b "
#PS1="%B%{$fg[white]%}%{$fg[black]%}%{$bg[white]%}%n%{$reset_color%}%{$bg[cyan]%}%{$fg[white]%}%{$fg_bold[black]%}%M %~%{$reset_color%}%{$fg[cyan]%}%b "
#PROMPT="%{$fg[#8be9fd]%}%{$BG[#f8f8f2]%}%B%n"
PROMPT="%{$fg[blue]%}[%n@%M%~]$ "

HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.cache/zHistory

# Basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)               # Include hidden files.

# Custom ZSH Binds
#bindkey '^ ' autosuggest-accept

# Load aliases and shortcuts if existent.
#[ -f "$HOME/.zsh/aliasrc" ] && source "$HOME/.zsh/aliasrc"
source ~/.dotfiles/aliasrc

# Load ; should be last.
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null

# Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'j' vi-up-line-or-history
bindkey -M menuselect 'k' vi-forward-char
bindkey -M menuselect 'l' vi-down-line-or-history

# Change cursor shape for different vi modes.
function zle-keymap-select () {
    case $KEYMAP in
        vicmd) echo -ne '\e[1 q';;      # block
        viins|main) echo -ne '\e[5 q';; # beam
    esac
}
zle -N zle-keymap-select
zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.


JAVA_HOME="/usr/lib/jvm/java-8-openjdk"
export JAVA_HOME
export PATH=$PATH:JAVA_HOME/bin
export PATH=$PATH:~/apps/testing

export EDITOR="nvim"


# Created by `pipx` on 2021-04-10 21:20:11
export PATH="$PATH:/home/mao/.local/bin"

# Edit line in vim with ctrl-e:
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line

#alias luamake=/home/mao/lua-language-server/3rd/luamake/luamake
#source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme

## To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
#[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

#eval "$(starship init zsh)"
#eval "$(starship init zsh)"

#export MANPAGER="nvim -c 'set ft=man' -"
export MANPAGER="/bin/sh -c \"col -b | nvim -c 'set ft=man ts=8 nomod nolist nonu noma' -\""

export LF_ICONS="\
*.md=:\
"
