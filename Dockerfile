ARG ARCH1=aarch64 # or x86_64
ARG ARCH2=arm64 # or amd64
ARG ARCH3=arm64 # or x64
ARG DENO_VERSION=1.36.4
ARG DOCKER_BUILDX_VERSION=0.11.2
ARG DOCKER_COMPOSE_VERSION=2.21.0
ARG DOCKER_VERSION=24.0.6
ARG GOLANG_VERSION=1.21.1
ARG HASKELL_CABAL_VERSION=3.6.2.0
ARG HASKELL_GHCUP_VERSION=0.1.19.5
ARG HASKELL_GHC_VERSION=9.2.8
ARG HASKELL_STACK_VERSION=2.9.3
ARG LUAROCKS_VERSION=3.9.2
ARG LUA_VERSION=5.4.6
ARG NODEJS_VERSION=18.17.1
ARG PYTHON2_VERSION=2.7.17
ARG PYTHON3_VERSION=3.11.4

# ------------------------------------------------------------------------------------------------------------------------
# hadolint ignore=DL3007
FROM ubuntu:latest AS builder
SHELL ["/bin/bash", "-c"]
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
        libffi7 \
        libgdbm-dev \
        libgmp-dev \
        libgmp10 \
        liblzma-dev \
        libncurses-dev \
        libncurses5 \
        libncursesw5-dev \
        libreadline-dev  \
        libsqlite3-dev \
        libssl-dev \
        libtinfo5 \
        libtool-bin \
        ninja-build \
        pkg-config \
        unzip \
        upx \
        uuid-dev \
        xz-utils \
        zlib1g-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


# ------------------------------------------------------------------------------------------------------------------------
FROM builder AS deno
SHELL ["/bin/bash", "-c"]
ARG ARCH1
ARG DENO_VERSION
RUN if [ "${ARCH1}" = "aarch64" ]; then \
        curl -s https://gist.githubusercontent.com/LukeChannings/09d53f5c364391042186518c8598b85e/raw/ac8cd8c675b985edd4b3e16df63ffef14d1f0e24/deno_install.sh | sh -s "v${DENO_VERSION}"; \
    else \
        curl -fsSL https://deno.land/x/install/install.sh | sh; \
    fi \
    && mkdir -p /out/root \
    && mv /root/.deno /out/root/


# ------------------------------------------------------------------------------------------------------------------------
FROM builder AS go
SHELL ["/bin/bash", "-c"]
ARG ARCH2
ARG GOLANG_VERSION
RUN curl -fsLOS https://go.dev/dl/go${GOLANG_VERSION}.linux-${ARCH2}.tar.gz \
    && tar -zxf go${GOLANG_VERSION}.linux-${ARCH2}.tar.gz \
    && mkdir -p /out/usr/local/go \
    && mv \
      /go/bin \
      /go/src \
      /go/pkg \
      /go/go.env \
      /out/usr/local/go


# ------------------------------------------------------------------------------------------------------------------------
FROM builder AS haskell
SHELL ["/bin/bash", "-c"]
ARG ARCH1
ARG HASKELL_GHCUP_VERSION
ARG HASKELL_GHC_VERSION
ARG HASKELL_CABAL_VERSION
ARG HASKELL_STACK_VERSION
RUN curl -fsLS -o ghcup https://downloads.haskell.org/~ghcup/${HASKELL_GHCUP_VERSION}/${ARCH1}-linux-ghcup-${HASKELL_GHCUP_VERSION} \
    && chmod +x ghcup \
    && ./ghcup install ghc ${HASKELL_GHC_VERSION} --set \
    && ./ghcup install cabal ${HASKELL_CABAL_VERSION} --set \
    && ./ghcup install stack ${HASKELL_STACK_VERSION} --set \
    && mkdir -p /out/root \
    && mv /root/.ghcup /out/root/ \
    && mv ghcup /out/root/.ghcup/bin/


# ------------------------------------------------------------------------------------------------------------------------
FROM builder AS lua
SHELL ["/bin/bash", "-c"]
ARG LUA_VERSION
RUN curl -fsLSO https://www.lua.org/ftp/lua-${LUA_VERSION}.tar.gz \
    && tar -zxf lua-${LUA_VERSION}.tar.gz \
    && cd lua-${LUA_VERSION} \
    && make all test install

ARG LUAROCKS_VERSION
RUN curl -fsLSO https://luarocks.org/releases/luarocks-${LUAROCKS_VERSION}.tar.gz \
    && tar -zxf luarocks-${LUAROCKS_VERSION}.tar.gz \
    && cd luarocks-${LUAROCKS_VERSION} \
    && ./configure && make && make install

RUN mkdir -p /out/usr/local/share \
    && mv \
      /usr/local/bin \
      /usr/local/etc \
      /usr/local/include \
      /usr/local/lib \
      /usr/local/man \
      /usr/local/share \
      /out/usr/local


# ------------------------------------------------------------------------------------------------------------------------
FROM builder AS neovim
SHELL ["/bin/bash", "-c"]
RUN git clone https://github.com/neovim/neovim \
    && cd neovim \
    && git checkout stable \
    && make CMAKE_BUILD_TYPE=RelWithDebInfo \
    && make install \
    && mkdir -p \
        /out/usr/local/bin \
        /out/usr/local/lib \
        /out/usr/local/share \
    && mv /usr/local/bin/nvim /out/usr/local/bin/ \
    && mv /usr/local/lib/nvim /out/usr/local/lib/ \
    && mv /usr/local/share/man /usr/local/share/nvim /out/usr/local/share/


# ------------------------------------------------------------------------------------------------------------------------
# hadolint ignore=DL3007
FROM rust:latest AS volta
SHELL ["/bin/bash", "-c"]
RUN cargo install --git https://github.com/volta-cli/volta \
    && mkdir -p \
        /out/root \
        /out/usr/local/bin \
    && mv /usr/local/cargo/bin/volta* /out/usr/local/bin/

FROM builder AS nodejs
SHELL ["/bin/bash", "-c"]
ARG NODEJS_VERSION
COPY --from=volta /out/ /
RUN volta install node@${NODEJS_VERSION} \
    && mkdir -p \
        /out/root \
        /out/usr/local/bin \
    && mv /usr/local/bin/volta* /out/usr/local/bin/ \
    && mv /root/.volta /out/root/


# ------------------------------------------------------------------------------------------------------------------------
FROM builder AS python
SHELL ["/bin/bash", "-c"]
RUN curl -sSf https://rye-up.com/get | RYE_INSTALL_OPTION='--yes' bash \
    && . "$HOME/.rye/env" \
    && rye install pip \
    && mkdir -p /out/root \
    && mv /root/.rye /out/root/


# ------------------------------------------------------------------------------------------------------------------------
FROM builder AS python2
SHELL ["/bin/bash", "-c"]
ARG PYTHON2_VERSION=2.7.17
RUN curl -fsLOS https://www.python.org/ftp/python/${PYTHON2_VERSION}/Python-${PYTHON2_VERSION}.tar.xz \
    && tar -Jxf Python-${PYTHON2_VERSION}.tar.xz \
    && cd Python-${PYTHON2_VERSION} \
    && ./configure \
    && make \
    && make install \
    && mkdir -p /out/usr/local \
    && mv /usr/local/bin/ \
        /usr/local/lib \
        /usr/local/include \
        /out/usr/local


# ------------------------------------------------------------------------------------------------------------------------
FROM builder AS python3
SHELL ["/bin/bash", "-c"]
ARG PYTHON3_VERSION
RUN curl -fsLOS https://www.python.org/ftp/python/${PYTHON3_VERSION}/Python-${PYTHON3_VERSION}.tar.xz \
    && tar -Jxf Python-${PYTHON3_VERSION}.tar.xz \
    && cd Python-${PYTHON3_VERSION} \
    && ./configure \
    && make \
    && make install \
    && mkdir -p /out/usr/local \
    && mv /usr/local/bin/ \
        /usr/local/lib \
        /usr/local/include \
        /out/usr/local


# ------------------------------------------------------------------------------------------------------------------------
FROM builder AS rust
SHELL ["/bin/bash", "-c"]
RUN curl -fsLS https://sh.rustup.rs > rust.sh \
    && chmod +x rust.sh \
    && ./rust.sh -y --no-modify-path \
    && mkdir -p /out/root \
    && mv /root/.cargo \
        /root/.rustup \
        /out/root/ \
    && rm -rf rust.sh


# ------------------------------------------------------------------------------------------------------------------------
FROM builder AS tools
SHELL ["/bin/bash", "-c"]
ARG ARCH1
ARG ARCH2
RUN mkdir -p \
    /out/usr/local/bin \
    /out/root/.docker/cli-plugins

ARG DOCKER_VERSION
RUN curl -fsLOS https://download.docker.com/linux/static/stable/${ARCH1}/docker-${DOCKER_VERSION}.tgz \
    && tar -zxf docker-${DOCKER_VERSION}.tgz \
    && mv docker/docker /out/usr/local/bin \
    && chown "$(whoami)":"$(groups)" /out/usr/local/bin/docker \
    && rm -rf docker*

ARG DOCKER_COMPOSE_VERSION
RUN curl -fsLS https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-linux-${ARCH1} \
        -o /out/root/.docker/cli-plugins/docker-compose \
    && chmod +x /out/root/.docker/cli-plugins/docker-compose

ARG DOCKER_BUILDX_VERSION
RUN curl -fsLS https://github.com/docker/buildx/releases/download/v${DOCKER_BUILDX_VERSION}/buildx-v${DOCKER_BUILDX_VERSION}.linux-${ARCH2} \
        -o /out/root/.docker/cli-plugins/docker-buildx \
    && chmod +x /out/root/.docker/cli-plugins/docker-buildx

# ------------------------------------------------------------------------------------------------------------------------
FROM builder AS packer
SHELL ["/bin/bash", "-c"]
ARG ARCH2

COPY --from=deno /out /out/deno
RUN upx --lzma --best /out/deno/root/.deno/bin/deno

COPY --from=go /out /out/go
RUN upx --lzma --best /out/go/usr/local/go/bin/* \
    && upx --lzma --best /out/go/usr/local/go/pkg/tool/linux_${ARCH2}/*

COPY --from=haskell /out /out/haskell
RUN upx --lzma --best /out/haskell/root/.ghcup/bin/ghcup \
    && upx --lzma --best "$(readlink -f /out/haskell/root/.ghcup/bin/cabal)" \
    && upx --lzma --best "$(readlink -f /out/haskell/root/.ghcup/bin/stack)"

COPY --from=lua /out /out/lua
RUN upx --lzma --best /out/lua/usr/local/bin/lua \
    && upx --lzma --best /out/lua/usr/local/bin/luac

COPY --from=neovim /out /out/neovim
RUN upx --lzma --best /out/neovim/usr/local/bin/nvim

COPY --from=nodejs /out /out/nodejs
# Compression slows down the node command

COPY --from=python /out /out/python
RUN upx --lzma --best "$(readlink -f /out/python/root/.rye/shims/python)"
RUN upx --lzma --best "$(readlink -f /out/python/root/.rye/shims/python3)"

COPY --from=python2 /out /out/python2
RUN upx --lzma --best "$(readlink -f /out/python2/usr/local/bin/python)"

COPY --from=python3 /out /out/python3
RUN upx --lzma --best "$(readlink -f /out/python3/usr/local/bin/python3)"

COPY --from=rust /out /out/rust
#RUN upx --lzma --best /out/rust/root/.cargo/bin/*

COPY --from=tools /out /out/tools
RUN upx --lzma --best /out/tools/root/.docker/cli-plugins/docker-compose \
    && upx --lzma --best /out/tools/usr/local/bin/docker


# ------------------------------------------------------------------------------------------------------------------------
# hadolint ignore=DL3007
FROM ubuntu:latest
SHELL ["/bin/bash", "-c"]
LABEL maintainer = "miya10kei <miya10kei@gmail.com>"

ENV DEBIAN_FRONTEND nointeractive
ENV HOME            /root
ENV LANG            en_US.UTF-8
ENV LANGUAGE        $LANG
ENV LC_ALL          $LANG
ENV TZ              Asia/Tokyo

# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        apache2-utils \
        build-essential \
        ca-certificates \
        cmake \
        curl \
        git \
        less \
        libffi-dev \
        libffi7 \
        libgmp-dev \
        libgmp10 \
        libncurses-dev \
        libncurses5 \
        libtinfo5 \
        locales \
        openssh-client \
        pass \
        redis-tools \
        postgresql-client \
        mysql-client \
        rlwrap \
        tmux \
        tzdata \
        unzip \
        wget \
        xsel \
        zsh \
        # add temporarily
        libpq-dev \
        libxslt-dev \
        swig \
        zlib1g-dev \
        # add temporarily
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && locale-gen --purge $LANG

COPY --from=packer /out/deno/    /
COPY --from=packer /out/go/      /
COPY --from=packer /out/haskell  /
COPY --from=packer /out/lua      /
COPY --from=packer /out/neovim/  /
COPY --from=packer /out/nodejs/  /
COPY --from=packer /out/python2/ /
COPY --from=packer /out/python3/ /
COPY --from=packer /out/python/  /
COPY --from=packer /out/rust/    /
COPY --from=packer /out/tools/   /

ENV PATH       "$HOME/.deno/bin:$PATH"
ENV PATH       "$HOME/.ghcup/bin:$PATH"
ENV PATH       "/usr/local/go/bin:$PATH"
ENV VOLTA_HOME "$HOME/.volta"
ENV PATH       "$VOLTA_HOME/bin:$PATH"

COPY ./nvim $HOME/.config/nvim
COPY Makefile   $HOME/.dotfiles/Makefile
COPY Makefile.d $HOME/.dotfiles/Makefile.d

WORKDIR $HOME/.dotfiles
RUN make --jobs=4 install4d \
    && make setup-nvim

WORKDIR $HOME

CMD ["zsh"]
