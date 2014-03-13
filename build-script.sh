#!/bin/bash

#Script to build Bonita BPM from GitHub sources
# sudo apt-get install maven openjdk-7-jdk icedtea-7-jre-jamvm

#start

#test that java, git and maven are installed
for req in git java mvn unzip
do
        which $req
        if [ $? -eq 0 ]
        then
                echo "req $req ok"
        else
                echo "req $req ko, please install $req"
                exit 1
        fi
done

#Create folder for files
mkdir BonitaBPM-build-6-2-3
cd BonitaBPM-build-6-2-3

# jms.jar Needed at least for Bonita Engine
wget http://download.java.net/glassfish/4.0/release/glassfish-4.0.zip
unzip glassfish-4.0.zip
mvn install:install-file -Dfile=glassfish4/mq/lib/jms.jar -DgroupId=javax.jms -DartifactId=jms -Dversion=1.1 -Dpackaging=jar -DgeneratePom=true

#**** BUILD SIMULATION MODULE ****
git clone https://github.com/bonitasoft/bonita-simulation.git
cd bonita-simulation
# Replace 'bos-simulation-6.1.0' by the tag you want to build
git checkout bos-simulation-6.1.0
mvn clean install -DskipTests
cd ..

#**** BUILD ENGINE MODULE ****
git clone https://github.com/bonitasoft/bonita-engine.git
cd bonita-engine
# Replace '6.1.0' by the tag you want to build
git checkout 6.2.3
mvn clean install -DskipTests=true -P package
git checkout 6.1.0
mvn clean install -DskipTests=true -P package
cd ..

#**** BUILD USERFILTERS MODULE ****
git clone https://github.com/bonitasoft/bonita-userfilters.git
cd bonita-userfilters
# Replace '6.1.0' by the tag you want to build
git checkout 6.2.3
mvn clean install -DskipTests
cd ..

#**** BUILD CONNECTORS MODULE ****
git clone https://github.com/bonitasoft/bonita-connectors.git
cd bonita-connectors
# Replace 'bonita-connectors-6.1.0' by the tag you want to build
git checkout bonita-connectors-6.1.0
mvn clean install -DskipTests
#Connectors might have different version of this module as a dependency
git checkout bonita-connectors-6.1.1
mvn clean install -DskipTests
cd ..

#**** BUILD CONNECTORS ASSEMBLY MODULE ****
git clone https://github.com/bonitasoft/bonita-connectors-assembly.git
cd bonita-connectors-assembly
# Replace 'bonita-connectors-assembly-6.1.0' by the tag you want to build
git checkout bonita-connectors-assembly-6.1.0
mvn clean install -DskipTests
cd ..

#**** BUILD GOOGLE CALENDAR CONNECTOR MODULE ****
git clone https://github.com/bonitasoft/bonita-connector-googlecalendar.git
cd bonita-connector-googlecalendar
# Replace 'bonita-connector-googlecalendar-6.1.0' by the tag 
# you want to build
git checkout bonita-connector-googlecalendar-6.1.0
# add Google gdata .jar files to Maven
mvn install:install-file -Dfile=bonita-connector-googlecalendar-common/lib/gdata-calendar-2.0.jar -DgroupId=com.google.gdata -DartifactId=gdata-calendar -Dversion=2.0 -Dpackaging=jar -DgeneratePom=true
mvn install:install-file -Dfile=bonita-connector-googlecalendar-common/lib/gdata-core-1.0.jar -DgroupId=com.google.gdata -DartifactId=gdata-core -Dversion=1.0 -Dpackaging=jar -DgeneratePom=true
mvn install:install-file -Dfile=bonita-connector-googlecalendar-common/lib/gdata-client-1.0.jar -DgroupId=com.google.gdata -DartifactId=gdata-client -Dversion=1.0 -Dpackaging=jar -DgeneratePom=true
mvn install:install-file -Dfile=bonita-connector-googlecalendar-common/lib/google-collect-1.0-rc1.jar -DgroupId=com.google.common -DartifactId=google-collect -Dversion=1.0-rc1 -Dpackaging=jar -DgeneratePom=true
mvn clean install -DskipTests
cd ..

#**** BUILD ALFRESCO CONNECTOR MODULE ****
git clone https://github.com/bonitasoft/bonita-connector-alfresco.git
cd bonita-connector-alfresco
# Replace 'bonita-connector-alfresco-6.1.0' by the tag you want to build
git checkout bonita-connector-alfresco-6.1.0
mvn clean install -DskipTests
cd ..

#**** BUILD DATABASE CONNECTOR MODULE ****
git clone https://github.com/bonitasoft/bonita-connector-database.git
cd bonita-connector-database
# Replace 'bonita-connector-database-6.1.0' by the tag you want to build
git checkout bonita-connector-database-6.1.1
sed -i "s/6.1.1-rc-01/6.1.0/g" pom.xml
mvn clean install -DskipTests
cd ..

#**** BUILD EMAIL CONNECTOR MODULE ****
git clone https://github.com/bonitasoft/bonita-connector-email.git
cd bonita-connector-email
# Replace 'bonita-connector-email-6.1.0' by the tag you want to build
git checkout bonita-connector-email-6.1.0
mvn clean install -DskipTests
cd ..

#**** BUILD JASPER CONNECTOR MODULE ****
git clone https://github.com/bonitasoft/bonita-connector-jasper.git
cd bonita-connector-jasper
# Replace 'bonita-connector-jasper-6.1.0' by the tag you want to build
git checkout bonita-connector-jasper-6.1.0
mvn clean install -DskipTests
cd ..

#**** BUILD SALESFORCE CONNECTOR MODULE ****
git clone https://github.com/bonitasoft/bonita-connector-salesforce.git
cd bonita-connector-salesforce
# Replace 'bonita-connector-salesforce-6.1.0' by the tag 
# you want to build
git checkout bonita-connector-salesforce-6.1.0
mvn clean install -DskipTests
cd ..

#**** BUILD SAP CONNECTOR MODULE ****
git clone https://github.com/bonitasoft/bonita-connector-sap.git
cd bonita-connector-sap
# add sapjco.jar file to Maven
# Replace 'bonita-connector-sap-6.1.0' by the tag you want to build
git checkout bonita-connector-sap-6.1.0
cp bonita-connector-sap-jco2-impl/lib/com/sap/sapjco/1.0/sapjco-1.0.jar sapjco-1.0.jar
mvn install:install-file -Dfile=sapjco-1.0.jar  -DgroupId=com.sap -DartifactId=sapjco -Dversion=2.1.9 -Dpackaging=jar -DgeneratePom=true
mvn clean install -DskipTests
cd ..

#**** BUILD SCRIPTING CONNECTOR MODULE ****
git clone https://github.com/bonitasoft/bonita-connector-scripting.git
cd bonita-connector-scripting
# Replace 'bonita-connector-scripting-6.1.0' by the tag you want to build
git checkout bonita-connector-scripting-6.1.0
mvn clean install -DskipTests
cd ..

#**** BUILD SUGARCRM CONNECTOR MODULE ****
git clone https://github.com/bonitasoft/bonita-connector-sugarcrm.git
cd bonita-connector-sugarcrm
# Replace 'bonita-connector-sugarcrm-6.1.0' by the tag you want to build
git checkout bonita-connector-sugarcrm-6.1.0
mvn clean install -DskipTests
cd ..

#**** BUILD TALEND CONNECTOR MODULE ****
git clone https://github.com/bonitasoft/bonita-connector-talend.git
cd bonita-connector-talend
# Replace 'bonita-connector-talend-6.1.0' by the tag you want to build
git checkout bonita-connector-talend-6.1.0
mvn clean install -DskipTests
cd ..

#**** BUILD WEBSERVICE CONNECTOR MODULE ****
git clone https://github.com/bonitasoft/bonita-connector-webservice.git
cd bonita-connector-webservice
# Replace 'bonita-connector-webservice-6.1.0' by the tag 
# you want to build
git checkout bonita-connector-webservice-6.1.0
mvn clean install -DskipTests
cd ..

#**** BUILD CMIS CONNECTOR MODULE ****
git clone https://github.com/bonitasoft/bonita-connector-cmis.git
cd bonita-connector-cmis
# Replace 'bonita-connector-cmis-6.1.0' by the tag 
# you want to build
git checkout bonita-connector-cmis-6.1.0
mvn clean install -DskipTests
cd ..

#**** BUILD LDAP CONNECTOR MODULE ****
git clone https://github.com/bonitasoft/bonita-connector-ldap.git
cd bonita-connector-ldap
# Replace 'bonita-connector-ldap-6.1.0' by the tag 
# you want to build
git checkout bonita-connector-ldap-6.1.0
mvn clean install -DskipTests
cd ..

#**** BUILD TWITTER CONNECTOR MODULE ****
git clone https://github.com/bonitasoft/bonita-connector-twitter.git
cd bonita-connector-twitter
# Replace 'master' by the tag 
# you want to build
git checkout bonita-connector-twitter-6.1.0-rc-20
sed -i "s/6.1.0-rc-06/6.1.0/g" pom.xml
sed -i "s/6.1.0-rc-20/6.1.0/g" pom.xml
sed -i "s/6.1.0-rc-20/6.1.0/g" bonita-connector-twitter-common/pom.xml
sed -i "s/6.1.0-rc-20/6.1.0/g" bonita-connector-twitter-direct-def/pom.xml
sed -i "s/6.1.0-rc-20/6.1.0/g" bonita-connector-twitter-direct-impl/pom.xml
sed -i "s/6.1.0-rc-20/6.1.0/g" bonita-connector-twitter-update-def/pom.xml
sed -i "s/6.1.0-rc-20/6.1.0/g" bonita-connector-twitter-update-impl/pom.xml
mvn clean install -DskipTests
cd ..

#**** BUILD CONNECTORS PACKAGE MODULE ****
git clone https://github.com/bonitasoft/bonita-connectors-packaging.git
cd bonita-connectors-packaging
# Replace 'bonita-connectors-packaging-6.1.0' by the tag 
# you want to build
git checkout bonita-connectors-package-6.1.1
mvn clean install -DskipTests
cd ..

#**** BUILD THEME BUILDER MODULE ****
git clone https://github.com/bonitasoft/bonita-theme-builder.git
cd bonita-theme-builder
# Replace 'bonita-connectors-packaging-6.1.0' by the tag 
# you want to build
git checkout 6.1.0
mvn clean install -DskipTests
cd ..

#**** BUILD TOMCAT H2 LISTENER MODULE ****
git clone https://github.com/bonitasoft/bonita-tomcat-h2-listener.git
cd bonita-tomcat-h2-listener
# Replace 'bonita-tomcat-h2-listener-1.0.1' by the tag you want to build
git checkout bonita-tomcat-h2-listener-1.0.1
mvn clean install -DskipTests
cd ..

#**** BUILD JBOSS H2 BEAN LISTENER MODULE ****
git clone https://github.com/bonitasoft/bonita-jboss-h2-mbean.git
cd bonita-jboss-h2-mbean
# Replace 'bonita-jboss-h2-mbean-1.0.0' by the tag you want to build
git checkout bonita-jboss-h2-mbean-1.0.0
mvn clean install -DskipTests
cd ..

#**** BUILD TOMCAT VALVE MODULE ****
git clone https://github.com/bonitasoft/bonita-tomcat-valve.git
cd bonita-tomcat-valve
git checkout CoreProduct
mvn clean install -DskipTests
cd ..

#**** BUILD STUDIO WATCHDOG MODULE ****
git clone https://github.com/bonitasoft/bonita-studio-watchdog.git
cd bonita-studio-watchdog
git checkout studio-watchdog-6.0.1
mvn clean install -DskipTests
cd ..

#****  BUILD GWT TOOLS MODULE ****
git clone https://github.com/bonitasoft/bonita-gwt-tools.git
cd bonita-gwt-tools
git checkout master
mvn clean install -DskipTests
cd ..

#**** BUILD WEB MODULE ****
git clone https://github.com/bonitasoft/bonita-web.git
cd bonita-web
# Replace '6.1.0' by the tag you want to build
git checkout 6.2.3
sed '249s/<repository>/<!-- <repository>/' -i pom.xml
sed '262s/<\/repository>/<\/repository> -->/' -i pom.xml
mvn clean install -DskipTests
cd ..

#**** BUILD BONITA DISTRIB MODULE ****
git clone https://github.com/bonitasoft/bonita-distrib.git
cd  bonita-distrib
# Replace '6.1.0' by the tag you want to build
git checkout 6.2.3
mvn clean install -DskipTests
cd ..

#****BUILD STUDIO - COMMON ACTION ****
# Prerequisite step for building any of the Studio modules listed below

# You must have a correct target platform, available at http://download.forge.ow2.org/bonita/TargetPlatform-6.1.zip
wget http://download.forge.ow2.org/bonita/TargetPlatform-6.1.zip
unzip TargetPlatform-6.1.zip
DIR=`pwd`

# You might need to increase max perm size of maven
export MAVEN_OPTS="-XX:MaxPermSize=256m"
git clone https://github.com/bonitasoft/bonita-studio.git
cd bonita-studio
# Replace '6.1.0' by the tag you want to build
git checkout bos-studio-6.2.3-201403041305

#**** BUILD STUDIO PLATFORM MODULE ****
cd  platform
mvn clean install -Pmirrored -Dp2MirrorUrl=file://$DIR/6.1/
cd ..

#**** BUILD STUDIO PATCHED PLUGINS MODULE ****
cd patched-plugins
mvn clean install
cd ..

#**** GENERATE STUDIO MODELS SOURCES ****
cd  bundles/plugins/org.bonitasoft.studio-models/
# Replace '6.1.0' by the tag you want to build
mvn clean initialize -Pgenerate -Dp2MirrorUrl=file://$DIR/6.1/
cd ../../..

#**** BUILD STUDIO BUNDLES MODULE ****
cd bundles
mvn clean install
cd ..

#**** BUILD STUDIO I18N BUNDLES MODULE ****
cd  translations
mvn clean install
cd ..

#**** BUILD STUDIO ALL-IN-ONE MODULE ****
cd  all-in-one
# If you also want to build the installers, you need to provide a correct installation of Bitrock and 
# set the BITROCK_HOME system property
mvn clean package
cd ../..

echo '---------------------------'
echo ''
echo 'You just finished to build Bonita BPM. Congratulations !!!'
echo 'You you can find it in:'
echo ''
echo 'BonitaBPM-build/bonita-studio/all-in-one/target/BonitaBPMCommunity-6.2.1'
echo ''
echo '---------------------------'
echo ''
#end
