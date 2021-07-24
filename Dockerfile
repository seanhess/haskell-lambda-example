FROM fpco/stack-build:lts-17.15 as base
RUN mkdir /opt/build
WORKDIR /opt/build

# GHC dynamically links its compilation targets to lib gmp
# RUN apt-get update
# RUN apt-get download libgmp10
# RUN mv libgmp*.deb libgmp.deb

# Download GHC, install some complicated packages so future compilation is shorter
RUN stack build base --system-ghc --resolver lts-17.15
RUN stack build scotty selda record-dot-preprocessor --system-ghc --resolver lts-17.15


# -------------------------------------------------------------------------------------------


# Loosely based on https://www.fpcomplete.com/blog/2017/12/building-haskell-apps-with-docker
FROM fpco/stack-build:lts-17.15 as dependencies
COPY --from=base /root/.stack /root/.stack
RUN mkdir /opt/build
WORKDIR /opt/build


# Docker build should not use cached layer if any of these is modified
COPY stack.yaml package.yaml stack.yaml.lock /opt/build/
RUN stack build --system-ghc --only-dependencies


# -------------------------------------------------------------------------------------------
FROM fpco/stack-build:lts-17.15 as build

# Copy compiled dependencies from previous stage
COPY --from=dependencies /root/.stack /root/.stack
COPY . /opt/build/

WORKDIR /opt/build

RUN stack build --system-ghc

RUN mv "$(stack path --local-install-root --system-ghc)/bin" /opt/build/bin

# -------------------------------------------------------------------------------------------
# Base image for stack build so compiled artifact from previous
# stage should run
FROM ubuntu:18.04 as app
RUN mkdir -p /opt/app
WORKDIR /opt/app

# Install libpq for the webserver
RUN apt-get update -y
RUN apt-get install -y libpq-dev

COPY --from=build /opt/build/bin .

# EXPOSE 3000
ENTRYPOINT ["/opt/app/lambda-example"]
CMD ["handler"]
