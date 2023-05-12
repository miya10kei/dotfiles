if [[ -e $HOMEBREW_PREFIX/share/antigen/antigen.zsh ]]; then
    source $HOMEBREW_PREFIX/share/antigen/antigen.zsh
elif [[ -e /usr/share/zsh-antigen/antigen.zsh ]]; then
    source /usr/share/zsh-antigen/antigen.zsh
fi

if type antigen > /dev/null 2>&1; then
    antigen bundle Tarrasch/zsh-autoenv
    antigen bundle zsh-users/zsh-autosuggestions
    antigen bundle zsh-users/zsh-completions
    antigen bundle zsh-users/zsh-syntax-highlighting

    antigen apply
fi
