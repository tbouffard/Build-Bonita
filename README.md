Build Bonita from sources
================

[![Linux build](https://img.shields.io/travis/Bonitasoft-Community/Build-Bonita/master?label=Linux%20build&logo=travis)](https://travis-ci.org/Bonitasoft-Community/Build-Bonita)


Overview
------------------------------------------------------------------------------

A bash script is provided to build the whole Bonita Community Edition solution from sources publicly available.


Requirements
------------

- Disk space: around 15 GB free space. Around 4 GB of dependencies will be downloaded (sources, Maven dependencies, ...). A fast internet connection is recommended.
- OS: this script is designed for Linux Operating System. It is not regularly tested on Windows or Mac but should work on these OS.
- Maven: 3.6.x.
- Java: Oracle/OpenJDK Java 8 (⚠ you cannot use Java 11 to build Bonita).



Instructions
------------
1. Place this script in an empty folder
1. Run `bash build-script.sh` in a terminal
1. Once finished, the following binaries are available
  - studio: `bonita-studio/all-in-one/target` (only zip archive, no installer)
  - tomcat bundle: `bonita-distrib/bundle/tomcat/target`

**Notes**
- If you want to make 100% sure that you do a clean build from scratch, run the following commands:
```bash
rm -rf ~/.m2/repository/org/bonitasoft/
rm -rf ~/.m2/repository/.cache
rm -rf ~/.m2/repository/.meta
rm -rf ~/.gradle/caches
find -type d -name ".gradle" -prune -exec rm -rf {} \;
find -type d -name target -prune -exec rm -rf {} \;
```


**Notes**
- No tests are run by the script (at least no back end tests).
- The script does not produce Studio installers (required license for proprietary software).


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
