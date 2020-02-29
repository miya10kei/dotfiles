FROM openjdk:8 as java-8
FROM openjdk:11 as java-11
FROM openjdk:13 as java-13
FROM maven:latest as maven

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

COPY --from=java-8 /usr/local/openjdk-8 /usr/lib/jvm/openjdk-8
COPY --from=java-11 /usr/local/openjdk-11 /usr/lib/jvm/openjdk-11
COPY --from=java-13 /usr/java/openjdk-13 /usr/lib/jvm/openjdk-13
COPY --from=maven /usr/share/maven /usr/lib/maven

RUN mkdir $DOTFILES

RUN ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
    && locale-gen --purge $LANG

WORKDIR $HOME

CMD ["fish"]
