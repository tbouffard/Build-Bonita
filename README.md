Build Bonita from sources
================

[![Linux build](https://img.shields.io/travis/Bonitasoft-Community/Build-Bonita/master?label=Linux%20build&logo=travis)](https://travis-ci.org/Bonitasoft-Community/Build-Bonita)

[![MacOS and Windows build](https://github.com/Bonitasoft-Community/Build-Bonita/workflows/MacOS%20and%20Windows%20Build/badge.svg)](https://github.com/Bonitasoft-Community/Build-Bonita/actions)


Overview
------------------------------------------------------------------------------

A bash script is provided to build the whole Bonita Community Edition solution from sources publicly available.


Requirements
------------

- Disk space: around 15 GB free space. Around 4 GB of dependencies will be downloaded (sources, Maven dependencies, ...). A fast internet connection is recommended.
- OS: Linux, MacOS and Windows (see test environments list below)
- Maven: 3.6.x.
- Java: Oracle/OpenJDK Java 8 (⚠ you cannot use Java 11 to build Bonita).



Instructions
------------
1. Clone this repository
1. Checkout the tag/branch related to the Bonita version you want to build
    1. build from the `master` branch which contains latest build improvements for the latest Bonita version available
    1. alternatively, you can checkout a tag, if you want to build past version for instance
    1. if you want to give a try to the development version of Bonita, build from the `dev` branch
1. Run `bash build-script.sh` in a terminal (on Windows, use git-bash as terminal i.e. the bash shell included with Git for Windows)
1. Once finished, the following binaries are available
    1. studio: `bonita-studio/all-in-one/target` (only zip archive, no installer)
    1. tomcat bundle: `bonita-distrib/tomcat/target`

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


Test environments
----------------

This script has been manually tested with the following environment:
- Debian GNU/Linux Buster
- Maven 3.6.0
- Oracle Java 1.8.0_221


In addition, CI builds are run on master/dev branch push and Pull Requests (see badges on top of this page)
- Linux: Ubuntu Xenial (Travis CI)
- MacOS: Catalina (Github Actions)
- Windows: Windows Server 2019 Datacenter (Github Actions)


Issues
------

If you face any issue with this build script please report it on the [build-bonita GitHub issues tracker](https://github.com/Bonitasoft-Community/Build-Bonita/issues).

You can also ask for help on [Bonita Community forum](https://community.bonitasoft.com/questions-and-answers).
