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
              -v /var/run/docker.sock:/var/run/docker.sock \
              -v $HOME/.dotfiles:/root/.dotfiles \
              -v $HOME/dev:/root/dev \
              -v $HOME/Downloads:/root/Downloads \
              -v $HOME/Documents:/root/Documents \
              -v $HOME/.ssh:/tmp/.ssh:ro \
              $ARGS"
    set cmd "docker run -dit $opts $image_name"
    echo $cmd | sed "s/\s\{2,\}/ /g"
    eval $cmd
  end
  alias stopdev "docker stop $container_name; docker rm $container_name"
  alias attachdev "docker exec -it $container_name /usr/bin/fish"
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

  alias ls "ls --color -hFX"
  alias lsa "ls --color -ahFX"
  alias ll "ls --color -hlFX"
  alias lla "ls --color -ahlFX"

  alias vim "nvim"

  alias q "exit"

  alias fishconf "nvim ~/.config/fish/config.fish"
  alias fishload "source ~/.config/fish/config.fish"
end


begin # neovim
  if type -q nvim
    set -x NVIM_HOME "$HOME/.config/nvim"
  end
end


begin # key binding
  function fish_user_key_bindings
    bind \cr 'peco_select_history (commandline -b)'
  end
end
