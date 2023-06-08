ARG ARCH1=aarch64 # or x86_64
ARG ARCH2=arm64 # or amd64
ARG ARCH3=arm64 # or x64
ARG DOCKER_COMPOSE_VERSION=2.16.0
ARG DOCKER_VERSION=23.0.1
ARG GOLANG_VERSION=1.20.5
ARG HASKELL_CABAL_VERSION=3.6.2.0
ARG HASKELL_GHCUP_VERSION=0.1.19.2
ARG HASKELL_GHC_VERSION=9.2.7
ARG HASKELL_STACK_VERSION=2.9.3
ARG NODEJS_VERSION=18.16.0
ARG NVM_VERSION=0.39.3
ARG PYTHON2_VERSION=2.7.17
ARG PYTHON3_VERSION=3.11.3

# ------------------------------------------------------------------------------------------------------------------------
FROM ubuntu:latest AS builder
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
ARG ARCH1
RUN if [ "${ARCH1}" = "aarch64" ]; then \
        curl -s https://gist.githubusercontent.com/LukeChannings/09d53f5c364391042186518c8598b85e/raw/ac8cd8c675b985edd4b3e16df63ffef14d1f0e24/deno_install.sh | sh; \
    else \
        curl -fsSL https://deno.land/x/install/install.sh | sh; \
    fi \
    && mkdir -p /out/root \
    && mv /root/.deno /out/root/


# ------------------------------------------------------------------------------------------------------------------------
FROM builder AS go
ARG ARCH2
ARG GOLANG_VERSION
RUN curl -fsLOS https://go.dev/dl/go${GOLANG_VERSION}.linux-${ARCH2}.tar.gz \
    && tar -zxf go${GOLANG_VERSION}.linux-${ARCH2}.tar.gz \
    && mkdir -p /out/usr/local/go \
    && mv /go/bin /go/src /go/pkg /out/usr/local/go


# ------------------------------------------------------------------------------------------------------------------------
FROM builder AS haskell
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
FROM builder AS neovim
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
FROM rust:latest AS volta
RUN cargo install --git https://github.com/volta-cli/volta \
    && mkdir -p \
        /out/root \
        /out/usr/local/bin \
    && mv /usr/local/cargo/bin/volta* /out/usr/local/bin/

FROM builder AS nodejs
ARG NODEJS_VERSION
COPY --from=volta /out/ /
RUN volta install node@10.24.1 \
    && volta install node@15.4.0 \
    && volta install node@${NODEJS_VERSION} \
    && mkdir -p \
        /out/root \
        /out/usr/local/bin \
    && mv /usr/local/bin/volta* /out/usr/local/bin/ \
    && mv /root/.volta /out/root/


# ------------------------------------------------------------------------------------------------------------------------

FROM builder AS python2
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
ARG ARCH1
ARG ARCH2
RUN mkdir -p \
    /out/usr/local/bin \
    /out/root/.docker/cli-plugins

ARG DOCKER_VERSION
RUN curl -fsLOS https://download.docker.com/linux/static/stable/${ARCH1}/docker-${DOCKER_VERSION}.tgz \
    && tar -zxf docker-${DOCKER_VERSION}.tgz \
    && mv docker/docker /out/usr/local/bin \
    && rm -rf docker*

ARG DOCKER_COMPOSE_VERSION
RUN curl -fsLS https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-linux-${ARCH1} \
        -o /out/root/.docker/cli-plugins/docker-compose \
    && chmod +x /out/root/.docker/cli-plugins/docker-compose


# ------------------------------------------------------------------------------------------------------------------------
FROM builder AS packer
ARG ARCH2

COPY --from=deno /out /out/deno
RUN upx --lzma --best /out/deno/root/.deno/bin/deno

COPY --from=go /out /out/go
RUN upx --lzma --best /out/go/usr/local/go/bin/* \
    && upx --lzma --best /out/go/usr/local/go/pkg/tool/linux_${ARCH2}/*

COPY --from=haskell /out /out/haskell
RUN upx --lzma --best /out/haskell/root/.ghcup/bin/ghcup \
    && upx --lzma --best `readlink -f /out/haskell/root/.ghcup/bin/cabal` \
    && upx --lzma --best `readlink -f /out/haskell/root/.ghcup/bin/stack`

COPY --from=neovim /out /out/neovim
RUN upx --lzma --best /out/neovim/usr/local/bin/nvim

COPY --from=nodejs /out /out/nodejs
# Compression slows down the node command

COPY --from=python2 /out /out/python2
RUN upx --lzma --best `readlink -f /out/python2/usr/local/bin/python`

COPY --from=python3 /out /out/python3
RUN upx --lzma --best `readlink -f /out/python3/usr/local/bin/python3`

COPY --from=rust /out /out/rust
#RUN upx --lzma --best /out/rust/root/.cargo/bin/*

COPY --from=tools /out /out/tools
RUN upx --lzma --best /out/tools/root/.docker/cli-plugins/docker-compose \
    && upx --lzma --best /out/tools/usr/local/bin/docker


# ------------------------------------------------------------------------------------------------------------------------
FROM ubuntu:latest
LABEL maintainer = "miya10kei <miya10kei@gmail.com>"

ENV DEBIAN_FRONTEND nointeractive
ENV HOME            /root
ENV LANG            en_US.UTF-8
ENV LANGUAGE        $LANG
ENV LC_ALL          $LANG
ENV TZ              Asia/Tokyo

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        apache2-utils \
        build-essential \
        ca-certificates \
        cmake \
        cmigemo \
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
        zsh-antigen \
        # add temporarily
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && locale-gen --purge $LANG

COPY --from=packer /out/deno/   /
COPY --from=packer /out/go/     /
COPY --from=packer /out/haskell /
COPY --from=packer /out/neovim/ /
COPY --from=packer /out/nodejs/ /
COPY --from=packer /out/python2/ /
COPY --from=packer /out/python3/ /
COPY --from=packer /out/rust/  /
COPY --from=packer /out/tools/  /

ENV PATH       "$HOME/.deno/bin:$PATH"
ENV PATH       "$HOME/.ghcup/bin:$PATH"
ENV PATH       "/usr/local/go/bin:$PATH"
ENV VOLTA_HOME "$HOME/.volta"
ENV PATH       "$VOLTA_HOME/bin:$PATH"

COPY ./nvim $HOME/.config/nvim
COPY Makefile   $HOME/.dotfiles/Makefile
COPY Makefile.d $HOME/.dotfiles/Makefile.d

WORKDIR $HOME/.dotfiles
RUN make --jobs=4 install4d
RUN make setup-nvim

WORKDIR $HOME

CMD ["zsh"]
