FROM openjdk:8    AS java-8
RUN mkdir /out
RUN cp -r /usr/local/openjdk-8/bin /out
RUN cp -r /usr/local/openjdk-8/jre /out
RUN cp -r /usr/local/openjdk-8/lib /out


FROM openjdk:11   AS java-11
RUN mkdir /out
RUN cp -r /usr/local/openjdk-11/bin     /out
RUN cp -r /usr/local/openjdk-11/conf    /out
RUN cp -r /usr/local/openjdk-11/include /out
RUN cp -r /usr/local/openjdk-11/jmods   /out
RUN cp -r /usr/local/openjdk-11/legal   /out
RUN cp -r /usr/local/openjdk-11/lib     /out


FROM openjdk:13   AS java-13
RUN mkdir /out
RUN cp -r /usr/java/openjdk-13/bin     /out
RUN cp -r /usr/java/openjdk-13/conf    /out
RUN cp -r /usr/java/openjdk-13/include /out
RUN cp -r /usr/java/openjdk-13/jmods   /out
RUN cp -r /usr/java/openjdk-13/legal   /out
RUN cp -r /usr/java/openjdk-13/lib     /out


FROM maven:latest AS maven
RUN mkdir /out
RUN cp -r /usr/share/maven/bin  /out
RUN cp -r /usr/share/maven/boot /out
RUN cp -r /usr/share/maven/conf /out
RUN cp -r /usr/share/maven/lib  /out


FROM golang:latest AS golang
RUN go get -v \
      github.com/motemen/ghq \
      github.com/peco/peco/cmd/peco
RUN mkdir -p /out/go /out/pkg
RUN cp /go/bin/*           /out/pkg
RUN cp /usr/local/go/bin/* /out/go


FROM docker:latest AS docker
RUN mkdir -p /out
RUN cp /usr/local/bin/* /out


FROM oracle/graalvm-ce:20.0.0-java11 AS graal
RUN gu install native-image
RUN mkdir -p /out
RUN cp -r /opt/graalvm-ce-java11-20.0.0/* /out


FROM alpine:edge AS packer
RUN apk update \
    && apk upgrade \
    && apk --update-cache add --no-cache \
    upx

COPY --from=docker /out /out/docker
RUN upx --lzma --best /out/docker/containerd
RUN upx --lzma --best /out/docker/containerd-shim
RUN upx --lzma --best /out/docker/ctr
RUN upx --lzma --best /out/docker/docker
RUN upx --lzma --best /out/docker/docker-init
RUN upx --lzma --best /out/docker/docker-proxy
RUN upx --lzma --best /out/docker/dockerd
RUN upx --lzma --best /out/docker/runc

COPY --from=golang /out/go  /out/go/go
COPY --from=golang /out/pkg /out/go/pkg
RUN upx --lzma --best /out/go/go/*
RUN upx --lzma --best /out/go/pkg/*

COPY --from=graal /out /out/graal
RUN upx --lzma --best /out/graal/bin/polyglot
RUN upx --lzma --best /out/graal/bin/unpack200
RUN upx --lzma --best /out/graal/languages/js/bin/js
RUN upx --lzma --best /out/graal/languages/js/bin/node
RUN upx --lzma --best /out/graal/languages/llvm/bin/lli
RUN upx --lzma --best /out/graal/lib/installer/bin/gu


FROM ubuntu:latest AS base

LABEL maintainer "Keisuke Miyaushiro <miya10kei@gmail.com>"

ENV DEBIAN_FRONTEND noninteractive
ENV LANG            en_US.UTF-8
ENV LANGUAGE        en_US.UTF-8
ENV LC_ALL          en_US.UTF-8
ENV TZ              Asia/Tokyo

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
    upx \
    wget \
    zip \
    && rm -rf /var/lib/apt/lists/*

RUN ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
    && locale-gen --purge $LANG

ENV HOME        /root
ENV DOCKER_HOME /usr/lib/docker
ENV DOTFILES    $HOME/.dotfiles
ENV GOROOT      /usr/lib/go
ENV GOPATH      $HOME/go
ENV GRAAL_HOME  /usr/lib/graalvm
ENV IDEA_HOME   /usr/lib/idea
ENV JAVA_ROOT   /usr/lib/jvm
ENV JAVA_HOME   $JAVA_ROOT/openjdk-11
ENV IDEA_JDK    $JAVA_ROOT/openjdk-8
ENV MAVEN_HOME  /usr/lib/maven
ENV PATH        $PATH:$DOCKER_HOME/bin:$GOROOT/bin:$GOPATH/bin:$IDEA_HOME/bin:$JAVA_HOME/bin:$MAVEN_HOME/bin:$GRAAL_HOME/bin:

COPY --from=java-8  /out        $JAVA_ROOT/openjdk-8
COPY --from=java-11 /out        $JAVA_ROOT/openjdk-11
COPY --from=java-13 /out        $JAVA_ROOT/openjdk-13
COPY --from=maven   /out        $MAVEN_HOME
COPY --from=packer  /out/graal  $GRAAL_HOME
COPY --from=packer  /out/go/go  $GOROOT/bin
COPY --from=packer  /out/go/pkg $GOPATH/bin
COPY --from=packer  /out/docker $DOCKER_HOME/bin

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

WORKDIR /tmp

ARG IDEA_VERSION=2019.3.3
ARG IDEA_BUILD=193.6494.35

RUN wget -q https://download.jetbrains.com/idea/ideaIU-${IDEA_VERSION}-no-jbr.tar.gz -O idea.tar.gz \
    && rm -rf $HOME/.wget-hsts \
    && mkdir -p idea \
    && tar -zxf idea.tar.gz -C idea --strip-components 1 \
    && mv idea /usr/lib/ \
    && rm -rf idea.tar.gz

ENV SHELL /usr/bin/fish

WORKDIR $HOME

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["fish"]