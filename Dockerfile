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
COPY ./config/dpkg/01_nodoc /etc/dpkg/dpkg.cfg.d/01_nodoc
RUN sed -i -E 's#http://(archive|security)\.ubuntu\.com/ubuntu/#mirror+http://mirrors.ubuntu.com/mirrors.txt#' \
        /etc/apt/sources.list.d/ubuntu.sources
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
        python3 \
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

RUN curl https://mise.run | sh
ENV PATH="${HOME}/.local/bin:${PATH}"

COPY --chown="${UNAME}:${GNAME}" ./config/mise/ ${HOME}/.config/mise/
RUN --mount=type=secret,id=GITHUB_TOKEN,mode=0444 \
    export GITHUB_TOKEN=$(cat /run/secrets/GITHUB_TOKEN) && \
    mise install

RUN --mount=type=secret,id=GITHUB_TOKEN,mode=0444 \
    export GITHUB_TOKEN=$(cat /run/secrets/GITHUB_TOKEN) && \
    eval "$(mise activate bash)" && \
    mise run install-bins

COPY --chown="${UNAME}:${GNAME}" ./config/nvim ${HOME}/.config/nvim
RUN eval "$(mise activate bash)" \
    && mise run setup-nvim

RUN mise run slim \
    && mkdir -p "${HOME}/out${HOME}" \
    && mv "${HOME}/.local" "${HOME}/.config" "${HOME}/out${HOME}/"


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

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8
ENV LANGUAGE=$LANG
ENV LC_ALL=$LANG
ENV TZ=Asia/Tokyo

COPY ./config/dpkg/01_nodoc /etc/dpkg/dpkg.cfg.d/01_nodoc
RUN sed -i -E 's#http://(archive|security)\.ubuntu\.com/ubuntu/#mirror+http://mirrors.ubuntu.com/mirrors.txt#' \
        /etc/apt/sources.list.d/ubuntu.sources

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
        bsdmainutils \
        bubblewrap \
        ca-certificates \
        cloc \
        curl \
        dnsutils \
        git \
        less \
        libgmp10 \
        libmagic1 \
        libpq5 \
        locales \
        lsof \
        make \
        openssh-client \
        pass \
        pulseaudio \
        python3-tk \
        redis-tools \
        rlwrap \
        socat \
        sudo \
        tmux \
        tzdata \
        unzip \
        wget \
        xsel \
        zip \
        zsh \
    && apt-get purge -y --auto-remove software-properties-common \
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


WORKDIR $HOME

CMD ["zsh"]
