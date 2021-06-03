ARG TAG=latest
FROM ghcr.io/miya10kei/dev-env-base:$TAG

ARG UID
ARG LOGIN
ARG GID
ARG GROUP
ARG DOCKER_GID
ARG HOME=/home/$LOGIN
ARG DOTFILES=$HOME/.dotfiles

RUN groupadd -g $GID $GROUP
RUN groupadd -g $DOCKER_GID docker
RUN useradd  -g $GID -G docker -u $UID -m $LOGIN
RUN echo "$LOGIN ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers

USER $LOGIN
WORKDIR $HOME

COPY --chown=$LOGIN:$GROUP .npmrc             $HOME/.npmrc
COPY --chown=$LOGIN:$GROUP coc-package.json   $HOME/.config/coc/extensions/package.json
COPY --chown=$LOGIN:$GROUP fishfile           $HOME/.config/fish/fishfile
COPY --chown=$LOGIN:$GROUP init.vim           $HOME/.config/nvim/init.vim
COPY --chown=$LOGIN:$GROUP package.json       $HOME/package.json

# tpm
RUN git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm

# fisher
RUN /usr/bin/fish -c "curl -sL https://git.io/fisher | source \
  && fisher install jorgebucaran/fisher \
  && fisher install < $HOME/.config/fish/fishfile"

# global npm pakcage
RUN npm install --global-style \
  --ignore-scripts \
  --no-package-lock \
  --only=prod \
  --loglevel=error

# neovim
RUN NVIM_HOME=$HOME/.config/nvim nvim --headless +PlugInstall +qa

# coc.vim
RUN npm install --global-style \
  --ignore-scripts \
  --loglevel=error \
  --no-bin-links \
  --no-package-lock \
  --only=prod \
  --prefix $HOME/.config/coc/extensions

