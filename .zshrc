# The following lines were added by compinstall

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _list _expand _complete _ignored _match _correct _approximate _prefix
zstyle ':completion:*' expand prefix suffix
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' ignore-parents parent pwd ..
zstyle ':completion:*' insert-unambiguous true
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' list-suffixes true
zstyle ':completion:*' match-original both
zstyle ':completion:*' max-errors 1
zstyle ':completion:*' original true
zstyle ':completion:*' prompt 'Corrections'
zstyle ':completion:*' squeeze-slashes true
zstyle :compinstall filename '/home/sealion/.zshrc'

autoload zed
autoload -Uz compinit
compinit
# End of lines added by compinstall
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=100000
SAVEHIST=100000
setopt appendhistory autocd extendedglob nomatch notify

# End of lines configured by zsh-newuser-install
autoload -U promptinit
promptinit
prompt adam1

typeset -U PATH path
path=("$path[@]" "$HOME/.cargo/bin")
export PATH

source /usr/share/zsh-antigen/antigen.zsh #installed via debian package manager

antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-completions
antigen use oh-my-zsh

#limit aliases
export OH_ZSH="$(dirname "${ANTIGEN_CACHE}")/bundles/robbyrussell/oh-my-zsh"
mkdir -p "${OH_ZSH}/cache/"
echo 'alias grep="grep --color=auto"' > "${OH_ZSH}/cache/grep-alias"

[[ $(sed -n '/^alias .*\(ls\|dir\)/p' "${OH_ZSH}/lib/directories.zsh") ]] && sed -i '/^alias .*\(ls\|dir\)/s/^/#/' "${OH_ZSH}/lib/directories.zsh"
antigen apply
alias l='ls --color=tty --almost-all --classify -l --no-group --group-directories-first -t'

bindkey -e #emacs-based

copy-to-beginning()
{
    # bug: at the beginning perfrorms insert
    # copy from cursor to beginning to kill ring and to clipboard
    zle backward-kill-line
    print -rn -- $CUTBUFFER|clipcopy
    zle yank
}
zle -N copy-to-beginning

cut-to-beginning()
{
    # copy from cursor to beginning to kill ring and to clipboard
    zle backward-kill-line
    print -rn -- $CUTBUFFER|clipcopy
}
zle -N cut-to-beginning

### ctrl+arrows
bindkey "\e[1;5C" forward-word
bindkey "\e[1;5D" backward-word
# urxvt
bindkey "\eOc" forward-word
bindkey "\eOd" backward-word

### ctrl+delete
bindkey "\e[3;5~" kill-word
# urxvt
bindkey "\e[3^" kill-word

### ctrl+backspace
bindkey '^H' backward-kill-word

### ctrl+shift+delete
bindkey "\e[3;6~" kill-line
# urxvt
bindkey "\e[3@" kill-line

### ctrl+insert
bindkey "\e[2;5~" copy-to-beginning
### shift+del
bindkey "\e[3;2~" cut-to-beginning

