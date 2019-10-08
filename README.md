Build Bonita from sources
================

The script to build Bonita Engine, Portal and Studio from official sources
------------------------------------------------------------------------------

This script is designed to build the whole Bonita Community Edition solution from sources publicly available.


Requirements
------------

- Disk space: around 15 GB free space. Around 4 GB of dependencies will be downloaded (sources, Maven dependencies, ...). A fast internet connection is recommended.
- OS: Linux. This script is designed for Linux Operating System. You are of course free to fork it for Windows or Mac.
- Maven: 3.6.x
- Java: Oracle/OpenJDK Java 8 (⚠ you cannot use Java 11 to build Bonita) and OpenJDK Java 11 (required to build Bonita Studio)
- Maven Toolchains configuration file (`~/.m2/toolchains.xml`):
  ```xml
  <?xml version="1.0" encoding="UTF8"?>
  <toolchains>
    <toolchain>
      <type>jdk</type>
      <provides>
        <version>11</version>
        <vendor>OpenJDK</vendor>
      </provides>
      <configuration>
        <!-- Set the appropriate path to your OpenJDK 11 installation folder -->
        <jdkHome>/usr/lib/jvm/java-11-openjdk-amd64</jdkHome>
      </configuration>
    </toolchain> 
  </toolchains>
  ```

Instructions
------------
1. Place this script in an empty folder
1. Run `bash build-script.sh` in a terminal
1. Once finished, you will find a working build of Bonita in: `bonita-studio/all-in-one/target`.

Test environment
----------------

This script has been tested with the following environment:
- Debian GNU/Linux Buster
- Maven 3.6.0
- Oracle Java 1.8.0_221
- openjdk 11.0.4 2019-07-16 (for the build of the Studio)

CI Build
----------------

TODO usually badge are placed on top of the README

![Travis CI](https://img.shields.io/travis/tbouffard/Build-Bonita/master?label=Travis%20build&logo=travis)

[![Build Status](https://travis-ci.org/tbouffard/Build-Bonita.svg?branch=master)](https://travis-ci.org/tbouffard/Build-Bonita)

A Travis CI build is configured to build this project, see https://travis-ci.org/tbouffard/Build-Bonita/ (TODO: link to
be updated once integrated to the original repository)


Issues
------

If you face any issue with this build script please report it on the [build-bonita GitHub issues tracker](https://github.com/Bonitasoft-Community/Build-Bonita/issues).

You can also ask for help on [Bonita Community forum](https://community.bonitasoft.com/questions-and-answers).
