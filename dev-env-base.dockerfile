# --------------------------------------------------
# docker
# --------------------------------------------------
FROM docker:latest AS docker
RUN apk update \
  && apk add --no-cache upx
RUN mkdir /out
RUN upx -9 /usr/local/bin/containerd \
  /usr/local/bin/containerd-shim \
  /usr/local/bin/containerd-shim-runc-v2 \
  /usr/local/bin/ctr \
  /usr/local/bin/docker \
  /usr/local/bin/docker-init \
  /usr/local/bin/docker-proxy \
  /usr/local/bin/dockerd \
  /usr/local/bin/runc \
  && mv /usr/local/bin/* /out


# --------------------------------------------------
# jdk
# --------------------------------------------------
FROM bellsoft/liberica-openjdk-debian:8 AS jdk8
RUN apt-get update \
  && apt-get install -y \
  upx \
  && apt-get autoclean \
  && apt-get autoremove \
  && rm -rf /var/lib/apt/lists/*
RUN mkdir /out
RUN mv /usr/lib/jvm/jdk-8u282-bellsoft-x86_64/bin \
  /usr/lib/jvm/jdk-8u282-bellsoft-x86_64/include \
  /usr/lib/jvm/jdk-8u282-bellsoft-x86_64/jre \
  /usr/lib/jvm/jdk-8u282-bellsoft-x86_64/lib \
  /out \
  && upx -9 /out/bin/unpack200

FROM bellsoft/liberica-openjdk-debian:11 AS jdk11
RUN apt-get update \
  && apt-get install -y \
  upx \
  && apt-get autoclean \
  && apt-get autoremove \
  && rm -rf /var/lib/apt/lists/*
RUN mkdir /out
RUN mv /usr/lib/jvm/jdk-11.0.11-bellsoft-x86_64/bin \
  /usr/lib/jvm/jdk-11.0.11-bellsoft-x86_64/conf \
  /usr/lib/jvm/jdk-11.0.11-bellsoft-x86_64/include \
  /usr/lib/jvm/jdk-11.0.11-bellsoft-x86_64/legal \
  /usr/lib/jvm/jdk-11.0.11-bellsoft-x86_64/lib \
  /out \
  && upx -9 /out/bin/jaotc \
  /out/bin/unpack200 \
  /out/lib/jspawnhelper

#FROM openjdk:16-slim AS jdk16
#RUN mkdir /out
#RUN cp -r /usr/local/openjdk-16/bin     /out
#RUN cp -r /usr/local/openjdk-16/conf    /out
#RUN cp -r /usr/local/openjdk-16/include /out
#RUN cp -r /usr/local/openjdk-16/jmods   /out
#RUN cp -r /usr/local/openjdk-16/legal   /out
#RUN cp -r /usr/local/openjdk-16/lib     /out


# --------------------------------------------------
# other
# --------------------------------------------------
FROM ubuntu:groovy AS other
RUN apt-get update \
  && apt-get install -y \
  curl \
  unzip \
  upx \
  xz-utils \
  && apt-get autoclean \
  && apt-get autoremove \
  && rm -rf /var/lib/apt/lists/*
RUN mkdir -p /out/bin /out/nodejs

WORKDIR /tmp

# cloudfoundry cli
RUN curl -sL "https://packages.cloudfoundry.org/stable?release=linux64-binary&version=v7&source=github" | tar -zx \
  && mv ./cf* /out/bin/ \
  && upx -9 /out/bin/cf7 \
  && rm -rf *

# docker-compose
ARG DOCKER_COMPOSE_VERSION=1.29.2
RUN curl -sL "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" \
  -o /out/bin/docker-compose \
  && chmod +x /out/bin/docker-compose \
  && upx -9 /out/bin/docker-compose

# kubectl
RUN curl -sL "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
  -o /out/bin/kubectl \
  && chmod +x /out/bin/kubectl \
  && upx -9 /out/bin/kubectl

# procs
ARG PROCS_VERSION=0.11.8
RUN curl -sLO "https://github.com/dalance/procs/releases/download/v${PROCS_VERSION}/procs-v${PROCS_VERSION}-x86_64-lnx.zip" \
  && unzip procs-v0.11.8-x86_64-lnx.zip \
  && mv procs /out/bin/ \
  && upx -9 /out/bin/procs \
  && rm -rf *

# delta
ARG DELTA_VERSION=0.8.0
RUN curl -sLO "https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/delta-${DELTA_VERSION}-x86_64-unknown-linux-gnu.tar.gz" \
  && tar -zxvf delta-${DELTA_VERSION}-x86_64-unknown-linux-gnu.tar.gz \
  && mv delta-${DELTA_VERSION}-x86_64-unknown-linux-gnu/delta /out/bin/ \
  && rm -rf *

# exa
ARG EXA_VERSION=0.10.1
RUN curl -sLO "https://github.com/ogham/exa/releases/download/v${EXA_VERSION}/exa-linux-x86_64-v${EXA_VERSION}.zip" \
  && unzip exa-linux-x86_64-v${EXA_VERSION}.zip \
  && mv bin/exa /out/bin/ \
  && rm -rf *

# fd
ARG FD_VERSION=8.2.1
RUN curl -sLO "https://github.com/sharkdp/fd/releases/download/v${FD_VERSION}/fd-v${FD_VERSION}-x86_64-unknown-linux-gnu.tar.gz" \
  && tar -zxvf fd-v${FD_VERSION}-x86_64-unknown-linux-gnu.tar.gz \
  && mv fd-v${FD_VERSION}-x86_64-unknown-linux-gnu/fd /out/bin/ \
  && rm -rf *

# ripgrep
ARG RIPGREP_VERSION=12.1.1
RUN curl -sLO "https://github.com/BurntSushi/ripgrep/releases/download/${RIPGREP_VERSION}/ripgrep-${RIPGREP_VERSION}-x86_64-unknown-linux-musl.tar.gz" \
  && tar -zxvf ripgrep-${RIPGREP_VERSION}-x86_64-unknown-linux-musl.tar.gz \
  && mv ripgrep-${RIPGREP_VERSION}-x86_64-unknown-linux-musl/rg /out/bin/ \
  && upx -9 /out/bin/rg \
  && rm -rf *

# bat
ARG BAT_VERSION=0.18.1
RUN curl -sLO "https://github.com/sharkdp/bat/releases/download/v${BAT_VERSION}/bat-v${BAT_VERSION}-x86_64-unknown-linux-gnu.tar.gz" \
  && tar -zxvf bat-v${BAT_VERSION}-x86_64-unknown-linux-gnu.tar.gz \
  && mv bat-v${BAT_VERSION}-x86_64-unknown-linux-gnu/bat /out/bin/ \
  && upx -9 /out/bin/bat \
  && rm -rf *

# ghq
ARG GHQ_VERSION=1.2.1
RUN curl -sLO "https://github.com/x-motemen/ghq/releases/download/v${GHQ_VERSION}/ghq_linux_amd64.zip" \
  && unzip ghq_linux_amd64.zip \
  && mv ghq_linux_amd64/ghq /out/bin/ \
  && upx -9 /out/bin/ghq \
  && rm -rf *

# peco
ARG PECO_VERSION=0.5.8
RUN curl -sLO "https://github.com/peco/peco/releases/download/v${PECO_VERSION}/peco_linux_amd64.tar.gz" \
  && tar -zxvf peco_linux_amd64.tar.gz \
  && mv peco_linux_amd64/peco /out/bin/ \
  && upx -9 /out/bin/peco \
  && rm -rf *

# dive
ARG DIVE_VERSION=0.10.0
RUN curl -sLO "https://github.com/wagoodman/dive/releases/download/v${DIVE_VERSION}/dive_${DIVE_VERSION}_linux_amd64.tar.gz" \
  && tar -zxvf dive_${DIVE_VERSION}_linux_amd64.tar.gz \
  && mv dive /out/bin/ \
  && upx -9 /out/bin/dive \
  && rm -rf *

# nodejs
ARG NODEJS_VERSION=14.17.0
RUN curl -sLO "https://nodejs.org/dist/v${NODEJS_VERSION}/node-v${NODEJS_VERSION}-linux-x64.tar.xz" \
  && tar -xvf node-v${NODEJS_VERSION}-linux-x64.tar.xz \
  && mv node-v${NODEJS_VERSION}-linux-x64/* /out/nodejs/ \
  && upx -9 /out/nodejs/bin/node \
  && rm -rf *

# jq
ARG JQ_VERSION=1.6
RUN curl -sL "https://github.com/stedolan/jq/releases/download/jq-${JQ_VERSION}/jq-linux64" -o jq \
  && chmod +x jq \
  && mv jq /out/bin/ \
  && upx -9 /out/bin/jq \
  && rm -rf *

# haribote
ARG HARIBOTE_VERSION=0.0.1
RUN curl -sLO "https://github.com/miya10kei/haribote/releases/download/v0.0.1/haribote-linux-amd64-v${HARIBOTE_VERSION}.tar.gz" \
  && tar -zxvf haribote-linux-amd64-v${HARIBOTE_VERSION}.tar.gz \
  && mv haribote /out/bin/ \
  && upx -9 /out/bin/haribote \
  && rm -rf *

## graalvm-ce
#ARG GRAALVM_VERSION=20.3.2
#RUN curl -sLO "https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-${GRAALVM_VERSION}/graalvm-ce-java11-linux-amd64-${GRAALVM_VERSION}.tar.gz" \
#  && tar -zxvf graalvm-ce-java11-linux-amd64-${GRAALVM_VERSION}.tar.gz \
#  && graalvm-ce-java11-${GRAALVM_VERSION}/bin/gu install native-image \
#  && mkdir -p /usr/local/graalvm \
#  && mv graalvm-ce-java11-${GRAALVM_VERSION}/* /usr/local/graalvm/ \
#  && rm -rf *

## kotlin-language-server
#ARG KOTLIN_LS_VERSION=1.1.1
#RUN curl -sLO "https://github.com/fwcd/kotlin-language-server/releases/download/${KOTLIN_LS_VERSION}/server.zip" \
#  && unzip server.zip \
#  && mkdir -p /usr/local/kotlin-ls \
#  && mv server/* /usr/local/kotlin-ls/ \
#  && ln -s /usr/local/kotlin-ls/bin/kotlin-language-server /usr/local/bin/kotlin-language-server \
#  && rm -rf *

## maven
#ARG MAVEN_VERSION=3.8.1
#RUN curl -sLO "https://ftp.yz.yamagata-u.ac.jp/pub/network/apache/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz" \
#  && tar -zxvf apache-maven-${MAVEN_VERSION}-bin.tar.gz \
#  && mkdir -p /usr/local/maven \
#  && mv apache-maven-${MAVEN_VERSION}/* /usr/local/maven/ \
#  && ln -s /usr/local/maven/bin/mvn /usr/local/bin/mvn \
#  && rm -rf *

## gradle
#ARG GRADLE_VERSION=7.0.2
#RUN curl -sLO "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" \
#  && unzip gradle-${GRADLE_VERSION}-bin.zip \
#  && mkdir -p /usr/local/gradle \
#  && mv gradle-${GRADLE_VERSION}/* /usr/local/gradle/ \
#  && ln -s /usr/local/gradle/bin/gradle /usr/local/bin/gradle \
#  && rm -rf *


# --------------------------------------------------
# main
# --------------------------------------------------
FROM ubuntu:groovy AS base

LABEL maintainer = "Keisuke Miyaushiro <miya10kei@gmail.com>"

ENV DEBIAN_FRONTEND noninteractive
ENV LANG            en_US.UTF-8
ENV LANGUAGE        en_US.UTF-8
ENV LC_ALL          en_US.UTF-8
ENV TZ              Asia/Tokyo

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  ca-certificates \
  curl \
  fish \
  fontconfig \
  git \
  jq \
  less \
  locales \
  neovim \
  openssh-client \
  sudo \
  tmux \
  tzdata \
  unzip \
  wget \
  zip \
  && apt-get autoclean \
  && apt-get autoremove \
  && rm -rf /var/lib/apt/lists/*

RUN locale-gen --purge $LANG

RUN curl https://github.com/ryanoasis/nerd-fonts/raw/2.1.0/patched-fonts/DaddyTimeMono/complete/DaddyTimeMono%20Nerd%20Font%20Complete%20Mono.ttf \
  -sLo /usr/local/share/fonts/"DaddyTimeMono Nerd Font Complete Mono.ttf" \
  && fc-cache -vf

COPY --from=docker  /out        /usr/local/bin
COPY --from=jdk8    /out        /usr/local/jvm/jdk8
COPY --from=jdk11   /out        /usr/local/jvm/jdk11
#COPY --from=jdk16  /out        /usr/local/jvm/jdk16
COPY --from=other   /out/bin    /usr/local/bin
COPY --from=other   /out/nodejs /usr/local/nodejs

RUN ln -s /usr/local/nodejs/bin/node /usr/local/bin/node \
  && ln -s /usr/local/nodejs/bin/npm /usr/local/bin/npm \
  && ln -s /usr/local/nodejs/bin/npx /usr/local/bin/npx

CMD ["/usr/bin/fish"]

