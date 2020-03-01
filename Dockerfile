FROM openjdk:8    AS java-8
FROM openjdk:11   AS java-11
FROM openjdk:13   AS java-13
FROM maven:latest AS maven

FROM oracle/graalvm-ce:20.0.0-java11 AS graal
RUN gu install native-image

FROM golang:latest AS golang
RUN go get -v \
      github.com/github/hub \
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
    curl \
    fish \
    git \
    jq \
    less \
    locales \
    make \
    neovim \
    openssh-client \
    openssl \
    tmux \
    tree \
    tzdata \
    unzip \
    wget \
    zip \
    && rm -rf /var/lib/apt/lists/*

RUN ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
    && locale-gen --purge $LANG

ENV HOME        /root
ENV SHELL       /usr/bin/fish
ENV DOTFILES    $HOME/.dotfiles
ENV JAVA_ROOT   /usr/lib/jvm
ENV MAVEN_HOME  /usr/lib/maven
ENV GRAAL_HOME  /usr/lib/graalvm
ENV GOROOT      /usr/lib/go
ENV GOPATH      $HOME/go
ENV DOCKER_HOME /usr/lib/docker
ENV PATH        $PATH:$DOCKER_HOME/bin:$GOROOT/bin:$GOPATH/bin:$MAVEN_HOME/bin:

COPY --from=java-8  /usr/local/openjdk-8 $JAVA_ROOT/openjdk-8
COPY --from=java-11 /usr/local/openjdk-11 $JAVA_ROOT/openjdk-11
COPY --from=java-13 /usr/java/openjdk-13 $JAVA_ROOT/openjdk-13
COPY --from=maven   /usr/share/maven $MAVEN_HOME
COPY --from=graal   /opt/graalvm-ce-java11-20.0.0 $GRAAL_HOME
COPY --from=golang  /usr/local/go $GOROOT
COPY --from=golang  /go $GOPATH
COPY --from=docker  /usr/local/bin $DOCKER_HOME/bin

RUN mkdir $DOTFILES
WORKDIR $DOTFILES

COPY Makefile $DOTFILES/Makefile
COPY init.vim $DOTFILES/init.vim
COPY coc-settings.json $DOTFILES/coc-settings.json

RUN make deploy

RUN tac $DOCKER_HOME/bin/docker-entrypoint.sh | sed "2i cp -R /tmp/.ssh /root/" | tac > $DOCKER_HOME/bin/docker-entrypoint.sh

WORKDIR $HOME

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["fish"]
