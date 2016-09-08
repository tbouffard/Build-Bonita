Build-Bonita-BPM
================

The script to build Bonita BPM Engine, Portal and Studio from official sources
------------------------------------------------------------------------------

This script has been tested on Debian GNU/Linux Jessie, with Oracle JDK 8, Maven 3.3.9 (+3.0.5 to compile Bonita Engine). Script includes check for Maven 3.3.9 availability but another version might also be compatible. Feel free to create a new issue if you have trouble to run the script with a more recent Maven version.

Around 4 GB of dependencies will be downloaded (sources, Maven dependencies, ...). A fast internet connection is recommended.
Place this script in an empty folder on a disk partition with more than 15 GB free space.

Then, run 'bash build-script-7.3.2.sh' in a terminal.

Once finished, you will find a working build of Bonita BPM in: `bonita-studio/all-in-one/target`.


Requirements
------------

This script is designed for Linux Operating System. You are of course free to fork it for Windows or Mac.
