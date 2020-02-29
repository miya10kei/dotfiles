FROM openjdk:8 AS java-8
FROM openjdk:11 AS java-11
FROM openjdk:13 AS java-13
FROM maven:latest AS maven

FROM golang:alpine AS go
RUN apk update \
    && apk upgrade \
    && apk --update-cache add --no-cache \
    && git

RUN go get -v \
      github.com/github/hub \
      github.com/motemen/ghq \
      github.com/peco/peco/cmd/peco



FROM oracle/graalvm-ce:20.0.0-java11 AS graal
RUN gu install native-image


FROM ubuntu:latest AS base

LABEL maintainer "Keisuke Miyaushiro <miya10kei@gmail.com>"

ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV TZ Asia/Tokyo
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
    && apt-get install -y \
    curl \
    fish \
    git \
    jq \
    less \
    locales \
    neovim \
    openssh-client \
    openssl \
    peco \
    tmux \
    tzdata \
    unzip \
    wget \
    zip \
    && rm -rf /var/lib/apt/lists/*

ENV HOME /root
ENV SHELL /usr/bin/fish
ENV DOTFILES $HOME/.dotfiles
ENV GRAAL_HOME /usr/lib/graalvm

COPY --from=java-8 /usr/local/openjdk-8 /usr/lib/jvm/openjdk-8
COPY --from=java-11 /usr/local/openjdk-11 /usr/lib/jvm/openjdk-11
COPY --from=java-13 /usr/java/openjdk-13 /usr/lib/jvm/openjdk-13
COPY --from=maven /usr/share/maven /usr/lib/maven
COPY --from=graal /opt/graalvm-ce-java11-20.0.0 $GRAAL_HOME

RUN mkdir $DOTFILES

RUN ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
    && locale-gen --purge $LANG

WORKDIR $HOME

CMD ["fish"]
