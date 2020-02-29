set -l OS (uname -s)
if string match -qr ".*Microsoft" (uname -r)
  set OS "wsl"
end

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
if test $OS = "wsl"
  set -x DOCKER_HOST tcp://localhost:2375
end

# ---------------
# --- Any env ---
# ---------------
if test -e $HOME/.anyenv
  set -Ux fish_user_paths $HOME/.anyenv/bin $fish_user_paths
  status --is-interactive; and source (anyenv init -|psub)
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
