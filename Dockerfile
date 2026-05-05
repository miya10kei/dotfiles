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
RUN sed -i 's|http://archive.ubuntu.com/ubuntu/|http://jp.archive.ubuntu.com/ubuntu/|g; \
            s|http://security.ubuntu.com/ubuntu/|http://jp.archive.ubuntu.com/ubuntu/|g' \
        /etc/apt/sources.list.d/ubuntu.sources \
    && printf '%s\n' \
        'path-exclude=/usr/share/doc/*' \
        'path-include=/usr/share/doc/*/copyright' \
        'path-exclude=/usr/share/man/*' \
        'path-exclude=/usr/share/info/*' \
        'path-exclude=/usr/share/groff/*' \
        'path-exclude=/usr/share/lintian/*' \
        'path-exclude=/usr/share/locale/*' \
        'path-include=/usr/share/locale/en*' \
        'path-include=/usr/share/locale/ja*' \
        'path-include=/usr/share/locale/locale.alias' \
        > /etc/dpkg/dpkg.cfg.d/01_nodoc
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

RUN curl https://mise.run | sh
ENV PATH="${HOME}/.local/bin:${PATH}"

COPY --chown="${UNAME}:${GNAME}" ./config/mise/ ${HOME}/.config/mise/
RUN --mount=type=secret,id=GITHUB_TOKEN,mode=0444 \
    export GITHUB_TOKEN=$(cat /run/secrets/GITHUB_TOKEN) && \
    mise install

RUN rm -rf "${HOME}/.local/share/mise/downloads" \
    && mkdir -p "${HOME}/out/${HOME}/.local/bin" "${HOME}/out/${HOME}/.local/share" "${HOME}/out/${HOME}/.config" \
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

RUN sed -i 's|http://archive.ubuntu.com/ubuntu/|http://jp.archive.ubuntu.com/ubuntu/|g; \
            s|http://security.ubuntu.com/ubuntu/|http://jp.archive.ubuntu.com/ubuntu/|g' \
        /etc/apt/sources.list.d/ubuntu.sources \
    && printf '%s\n' \
        'path-exclude=/usr/share/doc/*' \
        'path-include=/usr/share/doc/*/copyright' \
        'path-exclude=/usr/share/man/*' \
        'path-exclude=/usr/share/info/*' \
        'path-exclude=/usr/share/groff/*' \
        'path-exclude=/usr/share/lintian/*' \
        'path-exclude=/usr/share/locale/*' \
        'path-include=/usr/share/locale/en*' \
        'path-include=/usr/share/locale/ja*' \
        'path-include=/usr/share/locale/locale.alias' \
        > /etc/dpkg/dpkg.cfg.d/01_nodoc

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
        bubblewrap \
        build-essential \
        ca-certificates \
        cloc \
        cmake \
        curl \
        dnsutils \
        git \
        less \
        libbz2-dev \
        libffi-dev \
        libglib2.0-dev \
        libgmp-dev \
        libgmp10 \
        libmagic1 \
        libncurses-dev \
        libpq-dev \
        libreadline-dev \
        libsqlite3-dev \
        libtool \
        libxslt-dev \
        locales \
        lsof \
        lzma-dev \
        openssh-client \
        pass \
        pulseaudio \
        python3-tk \
        redis-tools \
        rlwrap \
        socat \
        sudo \
        tk-dev \
        tmux \
        tzdata \
        unzip \
        wget \
        xsel \
        zip \
        zlib1g-dev \
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


WORKDIR $HOME/.dotfiles

RUN --mount=type=secret,id=GITHUB_TOKEN,mode=0444 \
    export GITHUB_TOKEN=$(cat /run/secrets/GITHUB_TOKEN) && \
    eval "$(mise activate bash)" && \
    mise run install-bins

RUN eval "$(mise activate bash)" \
  && make setup-nvim

WORKDIR $HOME

CMD ["zsh"]
