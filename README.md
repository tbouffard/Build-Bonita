Build-Bonita-BPM
================

The script to build Bonita BPM Engine, Portal and Studio from official sources
------------------------------------------------------------------------------

This script has been tested on Ubuntu 12.04 and 13.10, with Open JDk 7, and latest available version of Git and Maven. At the beginning, it tests that java, mvn, git, and unzip are installed.

Around 4 Gb of dependencies will be downloaded (sources, target sources archive, maven, ...). You will need a good Internet connection.

Place this script in a disk partition with more than 15 Gb free space. Of course, you can build Bonita BPM in your /home.

Then, run 'bash build-script.sh' in a terminal.

Once finished, you will find a working build of Bonita BPM in:

BonitaBPM-build/bonita-studio/all-in-one/target/BonitaBPMCommunity-6.2.1


Translation
-----------

Translation script is still a work in progress at that stage.


Support
-------

This script is not designed to work on an other platform than Linux. You are of course free to fork it for Windows or Mac. However, no support will be done.
