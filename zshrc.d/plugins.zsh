if [[ -e $HOMEBREW_PREFIX/share/antigen/antigen.zsh ]]; then
    source $HOMEBREW_PREFIX/share/antigen/antigen.zsh
elif [[ -e /usr/share/zsh-antigen/antigen.zsh ]]; then
    source /usr/share/zsh-antigen/antigen.zsh
fi

if type antigen > /dev/null 2>&1; then
    antigen use oh-my-zsh

    antigen bundle zsh-users/zsh-autosuggestions
    antigen bundle zsh-users/zsh-completions
    antigen bundle zsh-users/zsh-syntax-highlighting

    #antigen theme agnoster

    antigen apply
fi
