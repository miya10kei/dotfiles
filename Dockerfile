# syntax=docker/dockerfile:1
ARG ARCH1=aarch64 # or x86_64
ARG ARCH2=arm64 # or amd64
ARG ARCH3=arm64 # or x64
ARG ARCH4=arm64 # or x86_64 (for Neovim)
ARG DOCKER_BUILDX_VERSION=0.30.1
ARG DOCKER_COMPOSE_VERSION=5.0.0
ARG DOCKER_VERSION=29.1.2
ARG HASKELL_CABAL_VERSION=3.16.0.0
ARG HASKELL_GHCUP_VERSION=0.1.50.2
ARG HASKELL_GHC_VERSION=9.6.7
ARG HASKELL_STACK_VERSION=3.7.1
ARG DKID
ARG GID
ARG GNAME
ARG UID
ARG UNAME


# ------------------------------------------------------------------------------------------------------------------------
# hadolint ignore=DL3007
FROM ubuntu:24.04 AS builder
ARG ARCH1
ARG ARCH2
ARG ARCH3
ARG GID
ARG GNAME
ARG UID
ARG UNAME
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# hadolint ignore=DL3008
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    rm -f /etc/apt/apt.conf.d/docker-clean \
    && apt-get update \
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
        zlib1g-dev
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
FROM builder AS mise
ARG UNAME
ARG GNAME
ARG UID
ARG GID
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# mise install
RUN curl https://mise.run | sh

ENV PATH="${HOME}/.local/bin:${PATH}"

# Copy mise config (languages + CLI tools)
COPY --chown="${UNAME}:${GNAME}" ./config/mise/config.toml ${HOME}/.config/mise/config.toml

# Lua plugin (Luarocks support)
RUN mise plugins install lua https://github.com/mise-plugins/mise-lua.git

# Install all tools (languages + CLI tools from config.toml)
RUN --mount=type=secret,id=GITHUB_TOKEN,mode=0444 \
    export GITHUB_TOKEN=$(cat /run/secrets/GITHUB_TOKEN) && \
    mise install

# Output directory
RUN mkdir -p "${HOME}/out/${HOME}/.local/bin" "${HOME}/out/${HOME}/.local/share" "${HOME}/out/${HOME}/.config" \
    && cp "${HOME}/.local/bin/mise" "${HOME}/out/${HOME}/.local/bin/" \
    && mv "${HOME}/.local/share/mise" "${HOME}/out/${HOME}/.local/share/" \
    && mv "${HOME}/.config/mise" "${HOME}/out/${HOME}/.config/"


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
FROM builder AS neovim
ARG ARCH4
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN mkdir -p "${HOME}/out/${HOME}/.nvim" \
    && curl -fsSL "https://github.com/neovim/neovim/releases/download/stable/nvim-linux-${ARCH4}.tar.gz" \
    | tar -xz -C "${HOME}/out/${HOME}/.nvim" --strip-components=1


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
# hadolint ignore=DL3007
FROM ubuntu:24.04
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
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    rm -f /etc/apt/apt.conf.d/docker-clean \
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
        ffmpeg \
        git \
        less \
        libbz2-dev \
        libclang-dev \
        libffi-dev \
        libgl1 \
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
        pulseaudio \
        python3-tk \
        redis-tools \
        rlwrap \
        sudo \
        tk-dev \
        tmux \
        tzdata \
        unzip \
        wget \
        xsel \
        zip \
        zsh \
        gdal-bin \
        libcairo2 \
        libglib2.0-dev \
        libmagic1 \
        libpango-1.0-0 \
        libpangocairo-1.0-0 \
        libpq-dev \
        libxslt-dev \
        swig \
        zlib1g-dev \
    && locale-gen --purge $LANG

RUN groupadd "${GNAME}" --gid "${GID}" \
  && useradd "${UNAME}" --uid "${UID}" --gid "${GID}" \
  && echo "${UNAME} ALL=NOPASSWD: ALL" > /etc/sudoers.d/sudoers \
  && groupadd docker --gid "${DKID}" \
  && usermod -aG docker "${UNAME}"

USER ${UNAME}
ENV  HOME="/home/${UNAME}"

COPY --from=haskell --chown="${UNAME}:${GNAME}" "${HOME}/out/" /
COPY --from=mise    --chown="${UNAME}:${GNAME}" "${HOME}/out/" /
COPY --from=neovim  --chown="${UNAME}:${GNAME}" "${HOME}/out/" /
COPY --from=rust    --chown="${UNAME}:${GNAME}" "${HOME}/out/" /
COPY --from=tools   --chown="${UNAME}:${GNAME}" "${HOME}/out/" /

ENV CARGO_HOME="${HOME}/.cargo"
ENV PATH="${CARGO_HOME}/bin:${PATH}"
ENV PATH="${HOME}/.ghcup/bin:${PATH}"
ENV PATH="${HOME}/.local/bin:${PATH}"
ENV PATH="${HOME}/.nvim/bin:${PATH}"
ENV MISE_DATA_DIR="${HOME}/.local/share/mise"

COPY --chown="${UNAME}:${GNAME}" ./config/nvim  $HOME/.config/nvim
COPY --chown="${UNAME}:${GNAME}" ./Makefile      $HOME/.dotfiles/Makefile
COPY --chown="${UNAME}:${GNAME}" ./Makefile.d    $HOME/.dotfiles/Makefile.d


WORKDIR $HOME/.dotfiles

RUN eval "$(mise activate bash)" \
  && pip --version

RUN eval "$(mise activate bash)" \
  && make --jobs=4 install4d \
  && make setup-nvim

WORKDIR $HOME

CMD ["zsh"]
