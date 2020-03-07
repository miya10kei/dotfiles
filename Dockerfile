FROM openjdk:8    AS java-8
FROM openjdk:11   AS java-11
FROM openjdk:13   AS java-13
FROM maven:latest AS maven

FROM oracle/graalvm-ce:20.0.0-java11 AS graal
RUN gu install native-image

FROM golang:latest AS golang
RUN go get -v \
      github.com/motemen/ghq \
      github.com/peco/peco/cmd/peco

FROM docker:latest AS docker


FROM ubuntu:latest AS base

LABEL maintainer "Keisuke Miyaushiro <miya10kei@gmail.com>"

ENV LANGUAGE        en_US.UTF-8
ENV LANG            en_US.UTF-8
ENV LC_ALL          en_US.UTF-8
ENV TZ              Asia/Tokyo
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
    && apt-get install -y \
    software-properties-common \
    && add-apt-repository ppa:neovim-ppa/stable \
    && apt update \
    && apt-get install -y \
    curl \
    fish \
    fontconfig \
    gcc \
    git \
    jq \
    less \
    libfontconfig1 \
    libfreetype6-dev \
    libgtk2.0-0 \
    libxext-dev \
    libxrender-dev \
    libxslt1.1 \
    libxtst-dev \
    libxxf86vm1 \
    locales \
    make \
    neovim \
    openssh-client \
    openssl \
    python3-dev \
    python3-pip \
    tmux \
    tree \
    ttf-mscorefonts-installer \
    tzdata \
    unzip \
    wget \
    zip \
    && rm -rf /var/lib/apt/lists/*

RUN ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
    && locale-gen --purge $LANG

ENV ANYENV_HOME   $HOME/.anyenv
ENV DOCKER_HOME   /usr/lib/docker
ENV DOTFILES      $HOME/.dotfiles
ENV FISH_HOME     $HOME/.config/fish
ENV GOROOT        /usr/lib/go
ENV GOPATH        $HOME/go
ENV GRAAL_HOME    /usr/lib/graalvm
ENV HOME          /root
ENV IDEA_HOME     /usr/lib/idea
ENV JAVA_ROOT     /usr/lib/jvm
ENV IDEA_JDK      $JAVA_ROOT/openjdk-8
ENV JAVA_HOME     $JAVA_ROOT/openjdk-11
ENV MAVEN_HOME    /usr/lib/maven
ENV PATH          $PATH:$ANYENV_HOME/bin:$DOCKER_HOME/bin:$GOROOT/bin:$GOPATH/bin:$IDEA_HOME/bin:$JAVA_HOME/bin:$MAVEN_HOME/bin:

COPY --from=java-8  --chown=root:root /usr/local/openjdk-8 $JAVA_ROOT/openjdk-8
COPY --from=java-11 --chown=root:root /usr/local/openjdk-11 $JAVA_ROOT/openjdk-11
COPY --from=java-13 --chown=root:root /usr/java/openjdk-13 $JAVA_ROOT/openjdk-13
COPY --from=maven   --chown=root:root /usr/share/maven $MAVEN_HOME
COPY --from=graal   --chown=root:root /opt/graalvm-ce-java11-20.0.0 $GRAAL_HOME
COPY --from=golang  --chown=root:root /usr/local/go $GOROOT
COPY --from=golang  --chown=root:root /go $GOPATH
COPY --from=docker  --chown=root:root /usr/local/bin $DOCKER_HOME/bin

RUN mkdir $DOTFILES
WORKDIR $DOTFILES

COPY Makefile          $DOTFILES/Makefile
COPY init.vim          $DOTFILES/init.vim
COPY coc-settings.json $DOTFILES/coc-settings.json
COPY default-packages  $DOTFILES/default-packages

RUN make deploy


WORKDIR $DOCKER_HOME/bin
RUN ["/bin/bash", "-c", "\
        tac ./docker-entrypoint.sh | sed '2i cp -r /tmp/.ssh /root/' | tac > ./_docker-entrypoint.sh \
        && rm -f ./docker-entrypoint.sh \
        && mv ./_docker-entrypoint.sh ./docker-entrypoint.sh \
        && chmod a+x ./docker-entrypoint.sh"]

WORKDIR $HOME

RUN pip3 install -U pip msgpack \
    && pip install -U neovim

RUN git clone https://github.com/riywo/anyenv $ANYENV_HOME \
    && git clone https://github.com/znz/anyenv-update $ANYENV_HOME/plugins/anyenv-update

RUN ["/bin/bash", "-c", "\
        eval \"$(anyenv init -)\" \
        && anyenv install --force-init \
        && anyenv install jenv \
        && anyenv install nodenv \
        && eval \"$(anyenv init -)\" \
        && jenv add $JAVA_ROOT/openjdk-8 \
        && jenv add $JAVA_ROOT/openjdk-11 \
        && jenv add $JAVA_ROOT/openjdk-13 \
        && jenv global 13 \
        "]

       # && ln -s $DOTFILES/default-packages $ANYENV_HOME/envs/nodenv/default-packages \
       # && nodenv install 12.16.1 \
       # && nodenv global 12.16.1 \
WORKDIR /tmp

ARG IDEA_VERSION=2019.3.3
ARG IDEA_BUILD=193.6494.35

RUN wget -q https://download.jetbrains.com/idea/ideaIU-${IDEA_VERSION}-no-jbr.tar.gz -O idea.tar.gz \
    && rm -rf $HOME/.wget-hsts
    && mkdir -p idea \
    && tar -zxvf idea.tar.gz -C idea --strip-components 1 \
    && mv idea /usr/lib/ \
    && rm -rf idea.tar.gz

ENV SHELL /usr/bin/fish

WORKDIR $HOME

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["fish"]
