FROM ubuntu:latest AS base

LABEL maintainer = "Keisuke Miyaushiro <miya10kei@gmail.com>"

ENV DEBIAN_FRONTEND noninteractive
ENV LANG            en_US.UTF-8
ENV LANGUAGE        $LANG
ENV LC_ALL          $LANG
ENV TZ              Asia/Tokyo
ENV SHELL           /usr/bin/fish

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y \
          apt-transport-https \
          curl \
          git \
          gnupg2 \
          gosu \
          less \
          locales \
          neovim \
          sudo \
          tree \
          tzdata \
          software-properties-common \
          wget \
    && apt-add-repository ppa:fish-shell/release-3 \
    && apt-get update \
    && apt-get install -y \
          fish \
    && rm -rf /var/lib/apt/lists/*

RUN ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
    && locale-gen --purge $LANG
