set -l OS (uname -s)

# --------------
# --- fisher ---
# --------------
if not functions -q fisher
  set -q XDG_CONFIG_HOME; or set XDG_CONFIG_HOME ~/.config
  curl https://git.io/fisher --create-dirs -sLo $XDG_CONFIG_HOME/fish/functions/fisher.fish
  fish -c fisher
end

# --------------
# --- docker ---
# --------------
begin
  set image_name "devenv"
  set container_name "miya10kei-devenv"
  function startdev
    set opts "\
              --cap-add=ALL \
              --name $container_name \
              -v $HOME/.dotfiles:/root/.dotfiles \
              $ARGS"
    set cmd "docker run -dit $opts $image_name"
    echo $cmd | sed "s/\s\{2,\}/ /g"
    eval $cmd
  end
  alias stopdev "docker stop $container_name; docker rm $container_name"
  alias attachdev "docker exec -it $container_name /usr/bin/fish"
end


# ---------------
# --- aliases ---
# ---------------
begin
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
end


# ----------------
# --- key bind ---
# ----------------
function fish_user_key_bindings
  bind \cr 'peco_select_history (commandline -b)'
end
