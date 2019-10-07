#/bin/bash

set -u
set -e
set +o nounset

# openjdk11 should be installed
# https://docs.travis-ci.com/user/reference/xenial/#jvm-clojure-groovy-java-scala-support
/usr/local/lib/jvm/openjdk11/bin/java --version

# install requirements for Studio
# TODO: may be too much
apt-get update && apt-get install -y --no-install-recommends \
    procps \
    ratpoison \
    xterm \
    xfonts-base \
    x11vnc \
    gtk2.0 \
    build-essential \
    libgtk2.0-dev \
    libgtk-3-dev
