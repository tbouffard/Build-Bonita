Build Bonita from sources
================

[![Linux build](https://img.shields.io/travis/Bonitasoft-Community/Build-Bonita/master?label=Linux%20build&logo=travis)](https://travis-ci.org/Bonitasoft-Community/Build-Bonita)


The script to build Bonita Engine, Portal and Studio from official sources
------------------------------------------------------------------------------

This script is designed to build the whole Bonita Community Edition solution from sources publicly available.


Requirements
------------

- Disk space: around 15 GB free space. Around 4 GB of dependencies will be downloaded (sources, Maven dependencies, ...). A fast internet connection is recommended.
- OS: Linux. This script is designed for Linux Operating System. You are of course free to fork it for Windows or Mac.
- Maven: 3.6.x
- Java: Oracle/OpenJDK Java 8 (⚠ you cannot use Java 11 to build Bonita)


Instructions
------------
1. Clone this repository
1. Checkout the tag/branch related to the Bonita version you want to build
    1. build from the `master` branch which contains latest build improvements for the latest Bonita version available
    1. alternatively, you can checkout a tag, if you want to build past version for instance
    1. if you want to give a try to the development version of Bonita, build from the `dev` branch
1. Run `bash build-script.sh` in a terminal
1. Once finished, you will find a working build of Bonita in: `bonita-studio/all-in-one/target`.

**Notes**
- no tests are run by the script (at least no backend tests)
- the script does not produce Studio installers


Test environment
----------------

This script has been manually tested with the following environment:
- Debian GNU/Linux Buster
- Maven 3.6.0
- Oracle Java 1.8.0_221

In addition, a Travis CI Ubuntu Xenial build runs on master branch push and PR creation/update

Issues
------

If you face any issue with this build script please report it on the [build-bonita GitHub issues tracker](https://github.com/Bonitasoft-Community/Build-Bonita/issues).

You can also ask for help on [Bonita Community forum](https://community.bonitasoft.com/questions-and-answers).
