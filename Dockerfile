ARG GOLANG_VERSION=1.20.1
ARG HASKELL_GHCUP_VERSION=0.1.19.2
ARG HASKELL_GHC_VERSION=9.2.5
ARG HASKELL_CABAL_VERSION=3.6.2.0
ARG HASKELL_STACK_VERSION=2.9.3
ARG NODEJS_VERSION=18.14.2

FROM ubuntu:latest AS builder
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        libffi-dev \
        libffi7 \
        libgmp-dev \
        libgmp10 \
        libncurses-dev \
        libncurses5 \
        libtinfo5 \
        unzip \
        upx \
        xz-utils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


FROM builder AS deno
RUN curl -fsSL https://deno.land/x/install/install.sh | sh \
    && mkdir /out \
    && mv /root/.deno/bin/deno /out/


FROM builder AS go
ARG GOLANG_VERSION
RUN curl -fsLOS https://go.dev/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz \
    && tar -zxf go${GOLANG_VERSION}.linux-amd64.tar.gz \
    && mkdir /out \
    && mv /go/bin /go/src /go/pkg /out/


FROM builder AS haskell
ARG HASKELL_GHCUP_VERSION
ARG HASKELL_GHC_VERSION
ARG HASKELL_CABAL_VERSION
ARG HASKELL_STACK_VERSION
RUN curl -fsL -o ghcup https://downloads.haskell.org/~ghcup/${HASKELL_GHCUP_VERSION}/x86_64-linux-ghcup-${HASKELL_GHCUP_VERSION} \
    && chmod +x ghcup \
    && ./ghcup install ghc ${HASKELL_GHC_VERSION} \
    && ./ghcup install cabal ${HASKELL_CABAL_VERSION} \
    && ./ghcup install stack ${HASKELL_STACK_VERSION} \
    && mkdir /out \
    && mv /root/.ghcup /out/ \
    && mv ghcup /out/.ghcup/bin/ \
    && cd /out/.ghcup/bin \
    && ln -s ghc-9.2.5 ./ghc \
    && ln -s ghci-9.2.5 ./ghci


FROM builder AS nodejs
ARG NODEJS_VERSION
RUN curl -fsLOS https://nodejs.org/dist/v${NODEJS_VERSION}/node-v${NODEJS_VERSION}-linux-x64.tar.xz \
    && tar -Jxf node-v${NODEJS_VERSION}-linux-x64.tar.xz \
    && mkdir /out \
    && mv /node-v${NODEJS_VERSION}-linux-x64/bin \
        /node-v${NODEJS_VERSION}-linux-x64/include \
        /node-v${NODEJS_VERSION}-linux-x64/lib \
        /node-v${NODEJS_VERSION}-linux-x64/share \
        /out/


FROM builder AS packer
COPY --from=deno    /out /out/deno
COPY --from=go      /out /out/go
COPY --from=haskell /out /out/haskell
COPY --from=nodejs  /out /out/nodejs
RUN upx --lzma --best /out/deno/deno \
    && upx --lzma --best /out/go/bin/* \
    && upx --lzma --best /out/go/pkg/tool/linux_amd64/* \
    && upx --lzma --best /out/haskell/.ghcup/bin/ghcup \
    && upx --lzma --best `readlink -f /out/haskell/.ghcup/bin/cabal` \
    && upx --lzma --best `readlink -f /out/haskell/.ghcup/bin/stack` \
    && upx --lzma --best /out/nodejs/bin/node


FROM ubuntu:latest
LABEL maintainer = "miya10kei <miya10kei@gmail.com>"
ENV DEBIAN_FRONTEND nointeractive
ENV HOME /root
ENV TZ Asia/Tokyo
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bat \
        build-essential \
        ca-certificates \
        curl \
        exa \
        fzf \
        git \
        init \
        libffi-dev \
        libffi7 \
        libgmp-dev \
        libgmp10 \
        libncurses-dev \
        libncurses5 \
        libtinfo5 \
        neovim \
        ripgrep \
        tmux \
        tzdata \
        unzip \
        xsel \
        zsh \
    #&& cp -f /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
    #&& apt-get remove -y \
    #    tzdata \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY --from=packer /out/deno/*  $HOME/.deno/bin/
COPY --from=packer /out/go/     /usr/local/go/
COPY --from=packer /out/haskell $HOME/
COPY --from=packer /out/nodejs/ /usr/local/nodejs/

ENV PATH "$HOME/.ghcup/bin:$PATH"
ENV PATH "/usr/local/go/bin:$PATH"
ENV PATH "/usr/local/nodejs/bin:$PATH"

ADD ./.gitconfig $HOME
ADD ./.zshrc $HOME
ADD ./nvim $HOME/.config/nvim

RUN curl -sfLOS https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.tar.gz \
    && tar -xzf nvim-linux64.tar.gz \
    && cp -r nvim-linux64/* /usr/ \
    && rm -rf nvim-linux64.tar.gz nvim-linux64 \
    && nvim --headless -c 'Lazy sync' -c 'qa' \
    && nvim --headless -c 'MasonInstall goimports gopls haskell-language-server lua-language-server pyright terraform-ls' -c 'qa' 

ENTRYPOINt ["/sbin/init"]
CMD ["/bin/zsh"]
