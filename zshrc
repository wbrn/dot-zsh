#
# Zshrc by Jason Wang
#

autoload -Uz is-at-least && if ! is-at-least 5.2; then
    print "ERROR: Zshrc didn't start." >&2
    print "You're using unsupported version ${ZSH_VERSION} < 5.2." >&2
    print "Update your zsh." >&2
    return 1
fi

# Returns whether the given command is executable or aliased.
_has() { return $( whence $1 >/dev/null ) }

# Functions which modify the path given a directory, but only if the directory
# exists and is not already in the path.
_prepend_to_path() { [ -d $1 -a -z ${path[(r)$1]} ] && path=($1 $path) }

_append_to_path() { [ -d $1 -a -z ${path[(r)$1]} ] && path=($path $1) }

_force_prepend_to_path() { path=($1 ${(@)path:#$1}) }

_append_paths_if_nonexist() {
    for p in $@; do
        [[ ! -L $p ]] && _prepend_to_path $p
    done
}

# keep things unique
typeset -U path PATH cdpath CDPATH fpath FPATH manpath MANPATH PYTHONPATH
# initial aliases
unalias -a

# Set ZSH var to ~/.zsh if it is empty
ZSH=${ZSH:-~/.zsh}

# setup interactive comments
setopt interactivecomments

export FZF_BASE=$ZSH/external/fzf
fpath=($ZSH/functions $ZSH/plugins
    ${ZSH}/external/zsh-completions/src $fpath)
autoload -Uz compaudit compinit &&
    compinit -C -d "${ZDOTDIR:-${HOME}}/${zcompdump_file:-.zcompdump}"

# Overridable locale support.
export LC_ALL=${LC_ALL:-C}
export LANG=${LANG:-en_US.UTF-8}

# THEME
# If we have a screen, we can try a colored screen
[[ "$TERM" == "screen" ]] && export TERM="screen-256color"
# Otherwise, for colored terminal
[[ "$TERM" == "xterm" ]] && export TERM="xterm-256color"

# Activate ls colors, (private if possible)
export ZSH_DIRCOLORS="$ZSH/external/dircolors-solarized/dircolors.256dark"
[[ -a $ZSH_DIRCOLORS ]] && {
    [[ "$TERM" == *256* ]] && {
        _has dircolors && eval "$(dircolors -b $ZSH_DIRCOLORS 2>/dev/null)"
    } || {
        # standard colors for non-256-color terms
        _has dircolors && eval "$(dircolors -b)"
    }
} || { _has dircolors && eval "$(dircolors -b)" }

# Support colors in less
export LESS_TERMCAP_mb=$'\e[01;31m'
export LESS_TERMCAP_md=$'\e[01;31m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;44;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[01;32m'

[[ ! -r ~/.zcompdump.zwc ]] && zcompile ~/.zcompdump
[[ ! -r ~/.zshrc.zwc ]] && zcompile ~/.zshrc

for dir (lib plugins custom); do
    for f ($ZSH/$dir/**/*.zsh(N)); do
        [[ ! -r $f.zwc ]] && zcompile $f
        . $f
    done
done

# PATH
_append_paths_if_nonexist /bin /sbin /usr/bin /usr/sbin \
    /usr/local/bin /usr/local/sbin ~/.local/bin ~/bin

# EDITOR
if _has nvim; then
    export EDITOR=nvim VISUAL=nvim
elif _has vim; then
    export EDITOR=vim VISUAL=vim
else 
    export EDITOR=vi VISUAL=vi
fi

#. $ZSH/themes/spaceship-prompt/spaceship.zsh
_has starship && eval "$(starship init zsh)" ||
    . $ZSH/themes/soimort/soimort.zsh

. $ZSH/external/z.lua/z.lua.plugin.zsh

[[ -r ~/.zshrc.local ]] && {
    [[ ! -r ~/.zshrc.local.zwc ]] && zcompile ~/.zshrc.local
    . ~/.zshrc.local
}
