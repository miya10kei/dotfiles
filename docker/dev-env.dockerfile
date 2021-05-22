# --------------------------------------------------
# cloudfoundry cli
# --------------------------------------------------
FROM ubuntu:groovy AS cf-cli
RUN apt-get update && apt-get install -y curl gnupg2
RUN curl -s https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key \
  | apt-key add -
RUN echo "deb https://packages.cloudfoundry.org/debian stable main" \
  | tee /etc/apt/sources.list.d/cloudfoundry-cli.list
RUN apt-get update && apt-get install -y cf7-cli
RUN mkdir /out
RUN cp /usr/bin/cf7 /out


# --------------------------------------------------
# docker
# --------------------------------------------------
FROM docker:latest AS docker
RUN mkdir /out
RUN cp /usr/local/bin/* /out


# --------------------------------------------------
# docker-compose
# --------------------------------------------------
FROM ubuntu:groovy AS docker-compose
ARG VERSION=1.29.2
RUN apt-get update \
  && apt-get install -y curl
RUN mkdir /out
RUN curl -sL "https://github.com/docker/compose/releases/download/${VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /out/docker-compose \
  && chmod +x /out/docker-compose


# --------------------------------------------------
# golang
# --------------------------------------------------
FROM golang:latest AS golang
RUN go get \
  github.com/nektos/act \
  github.com/peco/peco/cmd/peco \
  github.com/x-motemen/ghq
RUN mkdir /out
RUN cp /usr/local/go/bin/* /out
RUN cp /go/bin/*           /out


# --------------------------------------------------
# graalvm
# --------------------------------------------------
FROM ghcr.io/graalvm/graalvm-ce:latest AS graalvm
RUN gu install native-image
RUN mkdir /out
RUN cp -r $JAVA_HOME/* /out


# --------------------------------------------------
# jdk
# --------------------------------------------------
FROM openjdk:8-slim AS jdk8
RUN mkdir /out
RUN cp -r /usr/local/openjdk-8/bin     /out
RUN cp -r /usr/local/openjdk-8/include /out
RUN cp -r /usr/local/openjdk-8/jre     /out
RUN cp -r /usr/local/openjdk-8/lib     /out

FROM openjdk:11-slim AS jdk11
RUN mkdir /out
RUN cp -r /usr/local/openjdk-11/bin     /out
RUN cp -r /usr/local/openjdk-11/conf    /out
RUN cp -r /usr/local/openjdk-11/include /out
RUN cp -r /usr/local/openjdk-11/jmods   /out
RUN cp -r /usr/local/openjdk-11/legal   /out
RUN cp -r /usr/local/openjdk-11/lib     /out

FROM openjdk:16-slim AS jdk16
RUN mkdir /out
RUN cp -r /usr/local/openjdk-16/bin     /out
RUN cp -r /usr/local/openjdk-16/conf    /out
RUN cp -r /usr/local/openjdk-16/include /out
RUN cp -r /usr/local/openjdk-16/jmods   /out
RUN cp -r /usr/local/openjdk-16/legal   /out
RUN cp -r /usr/local/openjdk-16/lib     /out

FROM maven:latest AS maven
RUN mkdir /out
RUN cp -r /usr/share/maven/* /out

FROM gradle:latest AS gradle
RUN mkdir /out
RUN cp -r /opt/gradle/* /out


# --------------------------------------------------
# kubernetes
# --------------------------------------------------
FROM ubuntu:groovy AS k8s
RUN apt-get update && apt-get install -y curl gnupg2
RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg \
  | apt-key add -
RUN echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" \
  | tee -a /etc/apt/sources.list.d/kubernetes.list
RUN apt-get update && apt-get install -y kubectl
RUN mkdir /out
RUN cp /usr/bin/kubectl /out


# --------------------------------------------------
# rust
# --------------------------------------------------
FROM rust:latest as rust
RUN cargo install \
  procs \
  git-delta
RUN mkdir /out
RUN cp -r /usr/local/cargo/bin /out
RUN cp -r /usr/local/cargo/env /out


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
ENV JAVA_HOME /usr/local/jdk11

RUN apt-get update \
  && apt-get install -y \
  bat \
  curl \
  exa \
  fd-find \
  fish \
  fontconfig \
  git \
  gosu \
  hexyl \
  jq \
  locales \
  neovim \
  nodejs \
  npm \
  ripgrep \
  sudo \
  tree \
  tzdata \
  wget \
  zip \
  && apt-get autoclean \
  && apt-get autoremove \
  && rm -rf /var/lib/apt/lists/*

RUN locale-gen --purge $LANG

RUN curl -sfLo /usr/local/share/fonts/"DaddyTimeMono Nerd Font Complete Mono.ttf" \
  https://github.com/ryanoasis/nerd-fonts/raw/2.1.0/patched-fonts/DaddyTimeMono/complete/DaddyTimeMono%20Nerd%20Font%20Complete%20Mono.ttf \
  && fc-cache -vf

COPY --from=cf-cli         /out /usr/local/bin
COPY --from=docker         /out /usr/local/bin
COPY --from=docker-compose /out /usr/local/bin
COPY --from=golang         /out /usr/local/bin
COPY --from=graalvm        /out /usr/local/graalvm
COPY --from=jdk11          /out /usr/local/jdk11
COPY --from=jdk16          /out /usr/local/jdk16
COPY --from=maven          /out /usr/local/maven
COPY --from=gradle         /out /usr/local/gradle
COPY --from=k8s            /out /usr/local/bin
COPY --from=rust           /out /usr/local/cargo

RUN ln -s /usr/local/maven/bin/mvn     /usr/local/bin/mvn
RUN ln -s /usr/local/gradle/bin/gradle /usr/local/bin/gradle
RUN ls /usr/local/cargo/bin \
  | xargs -n1 -I{} ln -s /usr/local/cargo/bin/{} /usr/local/bin/{}

COPY ./docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod 0755 /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["/usr/bin/fish"]
