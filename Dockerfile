# syntax=docker/dockerfile:1
ARG DKID
ARG GID
ARG GNAME
ARG UID
ARG UNAME


# ------------------------------------------------------------------------------------------------------------------------
# builderと最終ステージに共通する設定（aptのミラー、ドキュメントを入れない設定、ユーザー）
FROM ubuntu:26.04 AS base
ARG GID
ARG GNAME
ARG UID
ARG UNAME
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
COPY ./config/dpkg/01_nodoc /etc/dpkg/dpkg.cfg.d/01_nodoc
# docker-cleanはaptのキャッシュを消すため、キャッシュマウントを効かせるよう外す
RUN sed -i -E 's#http://(archive|security)\.ubuntu\.com/ubuntu/#mirror+http://mirrors.ubuntu.com/mirrors.txt#' \
        /etc/apt/sources.list.d/ubuntu.sources \
    && rm -f /etc/apt/apt.conf.d/docker-clean
# ubuntu:23.04以降のイメージにはUID/GID 1000のubuntuユーザーがいるため、ホストのUIDと衝突しないよう消す
# sudoはステージごとにaptで入れるため、ここではsudoersの置き場所だけ作る
RUN if id ubuntu > /dev/null 2>&1; then userdel --remove ubuntu 2> /dev/null; fi \
    && groupadd "${GNAME}" --gid "${GID}" \
    && useradd "${UNAME}" --uid "${UID}" --gid "${GID}" \
    && mkdir -p /etc/sudoers.d \
    && echo "${UNAME} ALL=NOPASSWD: ALL" > /etc/sudoers.d/sudoers


# ------------------------------------------------------------------------------------------------------------------------
FROM base AS builder
ARG UNAME
# hadolint ignore=DL3008
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        cmake \
        curl \
        gettext \
        git \
        libbz2-dev \
        libdb-dev \
        libffi-dev \
        libgdbm-dev \
        libgmp-dev \
        liblzma-dev \
        libncurses-dev \
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
USER ${UNAME}
ENV HOME=/home/${UNAME}
WORKDIR ${HOME}


# ------------------------------------------------------------------------------------------------------------------------
FROM builder AS mise
# builderのSHELL（pipefail付き）を引き継ぐが、hadolintはステージをまたいで追えないため明示する
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ARG GID
ARG GNAME
ARG UID
ARG UNAME

RUN curl -fsSL https://mise.run | sh
ENV PATH="${HOME}/.local/bin:${PATH}"

COPY --chown="${UNAME}:${GNAME}" ./config/mise/ ${HOME}/.config/mise/
# ~/.cache（miseのダウンロードキャッシュやuvのキャッシュ）と ~/.npm はキャッシュマウントにし、次回のビルドで再利用する
RUN --mount=type=secret,id=GITHUB_TOKEN,mode=0444 \
    --mount=type=cache,target=/home/${UNAME}/.cache,uid=${UID},gid=${GID} \
    --mount=type=cache,target=/home/${UNAME}/.npm,uid=${UID},gid=${GID} \
    GITHUB_TOKEN="$(cat /run/secrets/GITHUB_TOKEN)" && export GITHUB_TOKEN && \
    mise install

RUN --mount=type=secret,id=GITHUB_TOKEN,mode=0444 \
    --mount=type=cache,target=/home/${UNAME}/.cache,uid=${UID},gid=${GID} \
    --mount=type=cache,target=/home/${UNAME}/.npm,uid=${UID},gid=${GID} \
    GITHUB_TOKEN="$(cat /run/secrets/GITHUB_TOKEN)" && export GITHUB_TOKEN && \
    eval "$(mise activate bash)" && \
    mise run install-bins

COPY --chown="${UNAME}:${GNAME}" ./config/nvim ${HOME}/.config/nvim
RUN --mount=type=cache,target=/home/${UNAME}/.cache,uid=${UID},gid=${GID} \
    eval "$(mise activate bash)" \
    && mise run setup-nvim

RUN mise run slim \
    && mkdir -p "${HOME}/out${HOME}" \
    && mv "${HOME}/.local" "${HOME}/.config" "${HOME}/out${HOME}/"


# ------------------------------------------------------------------------------------------------------------------------
FROM base
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

# hadolint ignore=DL3008
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update \
    && apt-get install -y --no-install-recommends \
        bsdmainutils \
        bubblewrap \
        ca-certificates \
        curl \
        dnsutils \
        git \
        less \
        libgmp10 \
        libicu78 \
        libmagic1 \
        libpq5 \
        locales \
        lsof \
        make \
        openssh-client \
        pass \
        postgresql-client \
        pulseaudio-utils \
        redis-tools \
        rlwrap \
        socat \
        sudo \
        tzdata \
        unzip \
        wget \
        zip \
        zsh \
    && locale-gen --purge $LANG

RUN groupadd docker --gid "${DKID}" \
    && usermod -aG docker "${UNAME}"

USER ${UNAME}
ENV  HOME="/home/${UNAME}"

COPY --from=mise --chown="${UNAME}:${GNAME}" "${HOME}/out/" /

ENV PATH="${HOME}/.local/bin:${PATH}"
ENV MISE_DATA_DIR="${HOME}/.local/share/mise"

# 単一ファイルのbind mountはgit pull等でinodeが置き換わると追従しないため、マウントされる~/.dotfiles配下へのsymlinkにする
RUN ln -fns "${HOME}/.dotfiles/.zshrc" "${HOME}/.zshrc"

WORKDIR $HOME

CMD ["zsh"]
