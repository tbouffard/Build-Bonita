#/bin/bash

set -u
set -e
set +o nounset

# TODO remove this file and use the travis apt addon https://docs.travis-ci.com/user/installing-dependencies/#installing-packages-with-the-apt-addon

# TODO do we need this?
#sudo apt-get update
# TODO: we may install too many packages
sudo apt-get install -y --no-install-recommends \
    procps \
    ratpoison \
    xterm \
    xfonts-base \
    x11vnc \
    gtk2.0 \
    build-essential \
    libgtk2.0-dev \
    libgtk-3-dev
