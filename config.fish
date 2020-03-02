set -l OS (uname -s)

if test -z $SSH_AGENT_PID
  eval (ssh-agent -c) > /dev/null
  ssh-add $HOME/.ssh/id_rsa > /dev/null 2>&1
end

begin # fisher
  if not functions -q fisher
    set -q XDG_CONFIG_HOME; or set XDG_CONFIG_HOME ~/.config
    curl https://git.io/fisher --create-dirs -sLo $XDG_CONFIG_HOME/fish/functions/fisher.fish
    fish -c fisher
  end
end

begin # docker
  set image_name "devenv"
  set container_name "miya10kei-devenv"
  function startdev
    set opts "\
              --cap-add=ALL \
              --name $container_name \
              -v $HOME/.dotfiles:/root/.dotfiles \
              -v $HOME/.local/share/fish/fish_history:/root/.local/share/fish/fish_history \
              -v $HOME/.ssh:/tmp/.ssh:ro \
              -v $HOME/Documents:/root/Documents \
              -v $HOME/Downloads:/root/Downloads \
              -v $HOME/dev:/root/dev \
              -v /var/run/docker.sock:/var/run/docker.sock \
              $ARGS"
    set cmd "docker run -dit $opts $image_name"
    echo $cmd | sed "s/\s\{2,\}/ /g"
    eval $cmd
  end
  alias stopdev "docker stop $container_name; docker rm $container_name"
  alias attachdev "docker exec -it $container_name /usr/bin/fish"
  alias dk "docker"
end

begin # anyenv
  if test -e $HOME/.anyenv
    set -Ux fish_user_paths $HOME/.anyenv/bin $fish_user_paths
    status --is-interactive; and source (anyenv init -|psub)
  end
end

begin # alias
  alias rm "rm -i"
  alias mv "mv -i"
  alias rr "rm -ri"
  alias rrf "rm -rf"

  alias u "cd ../"
  alias uu "cd ../../"
  alias uuu "cd ../../../"
  alias uuuu "cd ../../../../"
  alias cdr "cd -"
  if ls --color > /dev/null 2>&1
    alias ls "ls --color -hF"
    alias lsa "ls --color -ahF"
    alias ll "ls --color -hlF"
    alias lla "ls --color -ahlF"
  else
    alias ls "ls -hFG"
    alias lsa "ls -a"
    alias ll "ls -l"
    alias lla "ll -a"
  end
  alias q "exit"
  alias fishconf "vim ~/.config/fish/config.fish"
  alias fishload "source ~/.config/fish/config.fish"
end


begin # neovim
  if type -q nvim
    set -x NVIM_HOME "$HOME/.config/nvim"
    alias vim "nvim"
  end
end


begin # key binding
  function fish_user_key_bindings
    bind \cr 'peco_select_history (commandline -b)'
  end
end
