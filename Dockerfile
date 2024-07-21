ARG ARCH1=aarch64 # or x86_64
ARG ARCH2=arm64 # or amd64
ARG ARCH3=arm64 # or x64
ARG DOCKER_BUILDX_VERSION=0.14.1
ARG DOCKER_COMPOSE_VERSION=2.29.0
ARG DOCKER_VERSION=27.0.3
ARG GOLANG_VERSION=1.22.5
ARG HASKELL_CABAL_VERSION=3.10.3.0
ARG HASKELL_GHCUP_VERSION=0.1.30.0
ARG HASKELL_GHC_VERSION=9.4.8
ARG HASKELL_STACK_VERSION=2.15.5
ARG LUAROCKS_VERSION=3.11.0
ARG LUA_VERSION=5.4.6
ARG NODEJS_VERSION=20.15.1
ARG PYTHON2_VERSION=2.7.18
ARG PYTHON3_VERSION=3.12.4
ARG PYTHON_VERSION=3.10.10
ARG DKID
ARG GID
ARG GNAME
ARG UID
ARG UNAME


# ------------------------------------------------------------------------------------------------------------------------
# hadolint ignore=DL3007
FROM ubuntu:latest AS builder
ARG ARCH1
ARG ARCH2
ARG ARCH3
ARG GID
ARG GNAME
ARG UID
ARG UNAME
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        cmake \
        curl \
        g++ \
        gettext \
        git \
        libbz2-dev \
        libdb-dev \
        libffi-dev \
        libgdbm-dev \
        libgmp-dev \
        libgmp10 \
        liblzma-dev \
        libncurses-dev \
        libncursesw5-dev \
        libreadline-dev  \
        libsqlite3-dev \
        libssl-dev \
        libtool-bin \
        ninja-build \
        pkg-config \
        sudo \
        unzip \
        upx \
        uuid-dev \
        xz-utils \
        zlib1g-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
RUN groupadd "${GNAME}" --gid "${GID}" \
  && useradd "${UNAME}" --uid "${UID}" --gid "${GID}" \
  && echo "${UNAME} ALL=NOPASSWD: ALL" > /etc/sudoers.d/sudoers
USER ${UNAME}
ENV HOME=/home/${UNAME}
WORKDIR ${HOME}


# ------------------------------------------------------------------------------------------------------------------------
FROM builder AS builder-rust
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN curl -fsLS https://sh.rustup.rs > rust.sh \
    && chmod +x rust.sh \
    && ./rust.sh -y --no-modify-path \
    && rm -rf rust.sh


# ------------------------------------------------------------------------------------------------------------------------
FROM builder AS deno
ARG DENO_VERSION
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN curl -fsSL https://deno.land/x/install/install.sh | sh \
    && mkdir -p "${HOME}/out/${HOME}" \
    && mv "${HOME}/.deno" "${HOME}/out/${HOME}/"


# ------------------------------------------------------------------------------------------------------------------------
FROM builder AS go
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ARG GOLANG_VERSION
RUN curl -fsLOS "https://go.dev/dl/go${GOLANG_VERSION}.linux-${ARCH2}.tar.gz" \
    && tar -zxf "go${GOLANG_VERSION}.linux-${ARCH2}.tar.gz" \
    && mkdir -p "${HOME}/out/${HOME}/.go" \
    && mv \
      "${HOME}/go/bin" \
      "${HOME}/go/src" \
      "${HOME}/go/pkg" \
      "${HOME}/go/go.env" \
      "${HOME}/out/${HOME}/.go/"


# ------------------------------------------------------------------------------------------------------------------------
FROM builder AS haskell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ARG HASKELL_GHCUP_VERSION
ARG HASKELL_GHC_VERSION
ARG HASKELL_CABAL_VERSION
ARG HASKELL_STACK_VERSION
RUN curl -fsLS -o ghcup "https://downloads.haskell.org/~ghcup/${HASKELL_GHCUP_VERSION}/${ARCH1}-linux-ghcup-${HASKELL_GHCUP_VERSION}" \
    && chmod +x ghcup \
    && ./ghcup install ghc "${HASKELL_GHC_VERSION}" --set \
    && ./ghcup install cabal "${HASKELL_CABAL_VERSION}" --set \
    && ./ghcup install stack "${HASKELL_STACK_VERSION}" --set \
    && mkdir -p "${HOME}/out/${HOME}" \
    && mv "${HOME}/.ghcup" "${HOME}/out/${HOME}/" \
    && mv "${HOME}/ghcup"  "${HOME}/out/${HOME}/.ghcup/bin/"


# ------------------------------------------------------------------------------------------------------------------------
FROM builder AS lua
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV PATH="${HOME}/out/${HOME}/.lua/bin:${PATH}"

RUN mkdir -p "${HOME}/out/${HOME}/.lua/bin"

ARG LUA_VERSION
RUN curl -fsLSO "https://www.lua.org/ftp/lua-${LUA_VERSION}.tar.gz" \
    && tar -zxf "lua-${LUA_VERSION}.tar.gz" \
    && pushd "lua-${LUA_VERSION}" \
    && make INSTALL_TOP="${HOME}/out/${HOME}/.lua" all test install

ARG LUAROCKS_VERSION
RUN curl -fsLSO "https://luarocks.org/releases/luarocks-${LUAROCKS_VERSION}.tar.gz" \
    && tar -zxf "luarocks-${LUAROCKS_VERSION}.tar.gz" \
    && pushd "luarocks-${LUAROCKS_VERSION}" \
    && ./configure --prefix="${HOME}/out/${HOME}/.lua" && make && make install


# ------------------------------------------------------------------------------------------------------------------------
FROM builder AS neovim
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN git clone https://github.com/neovim/neovim \
    && pushd neovim \
    && git checkout stable \
    && mkdir -p "${HOME}/out/${HOME}/.nvim" \
    && make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX="${HOME}/out/${HOME}/.nvim" \
    && make install


# ------------------------------------------------------------------------------------------------------------------------
FROM  builder-rust AS volta
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV PATH="/${HOME}/.cargo/bin:${PATH}"
ARG NODEJS_VERSION
RUN cargo install --git https://github.com/volta-cli/volta \
    && volta install "node@${NODEJS_VERSION}" \
    && mkdir -p "${HOME}/out/${HOME}" \
    && mv "${HOME}/.cargo" \
          "${HOME}/.volta" \
          "${HOME}/out/${HOME}/"


# ------------------------------------------------------------------------------------------------------------------------
FROM builder AS python
ARG PYTHON_VERSION
ARG PYTHON2_VERSION
ARG PYTHON3_VERSION
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN curl https://pyenv.run | bash \
    && export PATH="${HOME}/.pyenv/bin:$PATH" \
    && eval "$(pyenv init -)" \
    && pyenv install "${PYTHON_VERSION}"  \
    && pyenv install "${PYTHON2_VERSION}" \
    && pyenv install "${PYTHON3_VERSION}" \
    && pyenv global  "${PYTHON3_VERSION}" \
    && mkdir -p "${HOME}/out/${HOME}" \
    && mv "${HOME}/.pyenv" "${HOME}/out/${HOME}/"


# ------------------------------------------------------------------------------------------------------------------------
FROM builder-rust AS rust
RUN mkdir -p "${HOME}/out/${HOME}" \
    && mv "${HOME}/.cargo" \
          "${HOME}/.rustup" \
          "${HOME}/out/${HOME}/"


# ------------------------------------------------------------------------------------------------------------------------
FROM builder AS tools
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN mkdir -p \
    "${HOME}/out/${HOME}/.docker/bin" \
    "${HOME}/out/${HOME}/.docker/cli-plugins"

ARG DOCKER_VERSION
RUN curl -fsLOS "https://download.docker.com/linux/static/stable/${ARCH1}/docker-${DOCKER_VERSION}.tgz" \
    && tar -zxf "docker-${DOCKER_VERSION}.tgz" \
    && mv "${HOME}/docker/docker" "${HOME}/out/${HOME}/.docker/bin" \
    && rm -rf docker*

ARG DOCKER_COMPOSE_VERSION
RUN curl -fsLS "https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-linux-${ARCH1}" \
        -o "${HOME}/out/${HOME}/.docker/cli-plugins/docker-compose" \
    && chmod +x "${HOME}/out/${HOME}/.docker/cli-plugins/docker-compose"

ARG DOCKER_BUILDX_VERSION
RUN curl -fsLS "https://github.com/docker/buildx/releases/download/v${DOCKER_BUILDX_VERSION}/buildx-v${DOCKER_BUILDX_VERSION}.linux-${ARCH2}" \
        -o "${HOME}/out/${HOME}/.docker/cli-plugins/docker-buildx" \
    && chmod +x "${HOME}/out/${HOME}/.docker/cli-plugins/docker-buildx"


# ------------------------------------------------------------------------------------------------------------------------
FROM builder AS packer
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY --from=deno    "${HOME}/out" /out/deno
COPY --from=go      "${HOME}/out" /out/go
COPY --from=haskell "${HOME}/out" /out/haskell
COPY --from=lua     "${HOME}/out" /out/lua
COPY --from=neovim  "${HOME}/out" /out/neovim
COPY --from=python  "${HOME}/out" /out/python
COPY --from=rust    "${HOME}/out" /out/rust
COPY --from=tools   "${HOME}/out" /out/tools
COPY --from=volta   "${HOME}/out" /out/volta

RUN    upx --lzma --best "/out/deno${HOME}/.deno/bin/deno" \
    && upx --lzma --best "/out/go/${HOME}/.go/bin/"* \
    && upx --lzma --best "/out/go${HOME}/.go/pkg/tool/linux_${ARCH2}/"* \
    && upx --lzma --best "/out/haskell${HOME}/.ghcup/bin/ghcup" \
    && upx --lzma --best "$(readlink -f "/out/haskell${HOME}/.ghcup/bin/cabal")" \
    && upx --lzma --best "$(readlink -f "/out/haskell${HOME}/.ghcup/bin/stack")" \
    && upx --lzma --best "/out/lua${HOME}/.lua/bin/lua" \
    && upx --lzma --best "/out/lua${HOME}/.lua/bin/luac" \
    && upx --lzma --best "/out/neovim${HOME}/.nvim/bin/nvim" \
    && upx --lzma --best "/out/tools${HOME}/.docker/cli-plugins/docker-compose" \
    && upx --lzma --best "/out/tools${HOME}/.docker/bin/docker"


# ------------------------------------------------------------------------------------------------------------------------
# hadolint ignore=DL3007
FROM ubuntu:latest
SHELL ["/bin/bash", "-c"]
LABEL maintainer="miya10kei <miya10kei@gmail.com>"

ARG DKID
ARG GID
ARG GNAME
ARG UID
ARG UNAME

ENV DEBIAN_FRONTEND=nointeractive
ENV LANG=en_US.UTF-8
ENV LANGUAGE=$LANG
ENV LC_ALL=$LANG
ENV TZ=Asia/Tokyo

# hadolint ignore=DL3008
RUN yes | unminimize \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        software-properties-common \
    && add-apt-repository -y ppa:git-core/ppa \
    && apt-get install -y --no-install-recommends \
        apache2-utils \
        autoconf \
        automake \
        bsdmainutils \
        build-essential \
        ca-certificates \
        cloc \
        cmake \
        curl \
        dnsutils \
        git \
        less \
        libbz2-dev \
        libclang-dev \
        libffi-dev \
        libgmp-dev \
        libgmp10 \
        libncurses-dev \
        libreadline-dev \
        libsqlite3-dev \
        libtool \
        locales \
        lzma-dev \
        mandoc \
        mysql-client \
        openssh-client \
        pass \
        postgresql-client \
        python3-tk \
        redis-tools \
        rlwrap \
        tk-dev \
        tmux \
        tzdata \
        unzip \
        wget \
        xsel \
        zsh \
        # add temporarily
        gdal-bin \
        libcairo2 \
        libglib2.0-dev \
        libmagic1 \
        libpango-1.0-0 \
        libpangocairo-1.0-0 \
        libpq-dev \
        libxslt-dev \
        swig \
        sudo \
        zlib1g-dev \
        # add temporarily
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && locale-gen --purge $LANG

RUN groupadd "${GNAME}" --gid "${GID}" \
  && useradd "${UNAME}" --uid "${UID}" --gid "${GID}" \
  && echo "${UNAME} ALL=NOPASSWD: ALL" > /etc/sudoers.d/sudoers \
  && groupadd docker --gid "${DKID}" \
  && usermod -aG docker "${UNAME}"

USER ${UNAME}
ENV  HOME="/home/${UNAME}"

COPY --from=packer --chown="${UNAME}:${GNAME}" /out/deno/   /
COPY --from=packer --chown="${UNAME}:${GNAME}" /out/go/     /
COPY --from=packer --chown="${UNAME}:${GNAME}" /out/haskell /
COPY --from=packer --chown="${UNAME}:${GNAME}" /out/lua     /
COPY --from=packer --chown="${UNAME}:${GNAME}" /out/neovim/ /
COPY --from=packer --chown="${UNAME}:${GNAME}" /out/volta/  /
COPY --from=packer --chown="${UNAME}:${GNAME}" /out/python/ /
COPY --from=packer --chown="${UNAME}:${GNAME}" /out/rust/   /
COPY --from=packer --chown="${UNAME}:${GNAME}" /out/tools/  /

ENV CARGO_HOME="${HOME}/.cargo"
ENV CARGO_TARGET_DIR="${CARGO_HOME}/target"
ENV PATH="${CARGO_HOME}/bin:${PATH}"
ENV PATH="${HOME}/.deno/bin:${PATH}"
ENV PATH="${HOME}/.ghcup/bin:${PATH}"
ENV GOPATH="${HOME}/.go"
ENV PATH="${GOPATH}/bin:${PATH}"
ENV PATH="${HOME}/.lua/bin:${PATH}"
ENV PATH="${HOME}/.nvim/bin:${PATH}"
ENV PATH="${HOME}/.pyenv/bin:${PATH}"
ENV VOLTA_HOME="${HOME}/.volta"
ENV PATH="${VOLTA_HOME}/bin:${PATH}"

COPY --chown="${UNAME}:${GNAME}" ./nvim     $HOME/.config/nvim
COPY --chown="${UNAME}:${GNAME}" Makefile   $HOME/.dotfiles/Makefile
COPY --chown="${UNAME}:${GNAME}" Makefile.d $HOME/.dotfiles/Makefile.d

WORKDIR $HOME/.dotfiles

RUN eval "$(pyenv init -)" \
  && pip --version

RUN eval "$(pyenv init -)" \
  && make --jobs=4 install4d \
  && make setup-nvim

WORKDIR $HOME

CMD ["zsh"]
