# syntax=docker/dockerfile:1
ARG DKID
ARG GID
ARG GNAME
ARG UID
ARG UNAME


# ------------------------------------------------------------------------------------------------------------------------
# hadolint ignore=DL3007
FROM ubuntu:24.04 AS builder
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
FROM builder AS mise
ARG UNAME
ARG GNAME
ARG UID
ARG GID
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# mise install
RUN curl https://mise.run | sh

ENV PATH="${HOME}/.local/bin:${PATH}"

# Copy mise config and tasks
COPY --chown="${UNAME}:${GNAME}" ./config/mise/ ${HOME}/.config/mise/

# Lua plugin (Luarocks support)
RUN mise plugins install lua https://github.com/mise-plugins/mise-lua.git

# ghcup plugin (for ghc, cabal, stack)
RUN mise plugins install ghc https://github.com/mise-plugins/mise-ghcup.git \
    && mise plugins install cabal https://github.com/mise-plugins/mise-ghcup.git \
    && mise plugins install stack https://github.com/mise-plugins/mise-ghcup.git

# Install all tools (languages + CLI tools from config.toml)
RUN --mount=type=secret,id=GITHUB_TOKEN,mode=0444 \
    export GITHUB_TOKEN=$(cat /run/secrets/GITHUB_TOKEN) && \
    mise install && \
    mise run install-bins

# Output directory
RUN mkdir -p "${HOME}/out/${HOME}/.local/bin" "${HOME}/out/${HOME}/.local/share" "${HOME}/out/${HOME}/.config" \
    && cp "${HOME}/.local/bin/mise" "${HOME}/out/${HOME}/.local/bin/" \
    && mv "${HOME}/.local/share/mise" "${HOME}/out/${HOME}/.local/share/" \
    && mv "${HOME}/.config/mise" "${HOME}/out/${HOME}/.config/"


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

COPY --from=mise --chown="${UNAME}:${GNAME}" "${HOME}/out/" /

ENV PATH="${HOME}/.local/bin:${PATH}"
ENV MISE_DATA_DIR="${HOME}/.local/share/mise"

COPY --chown="${UNAME}:${GNAME}" ./config/nvim  $HOME/.config/nvim
COPY --chown="${UNAME}:${GNAME}" ./Makefile      $HOME/.dotfiles/Makefile
COPY --chown="${UNAME}:${GNAME}" ./Makefile.d    $HOME/.dotfiles/Makefile.d


WORKDIR $HOME/.dotfiles

RUN eval "$(mise activate bash)" \
  && pip --version

RUN eval "$(mise activate bash)" \
  && make setup-nvim

WORKDIR $HOME

CMD ["zsh"]
