#!/bin/bash

#Script to add translations and build Bonita BPM Platform, from GitHub sources
# sudo apt-get install maven openjdk-7-jdk icedtea-7-jre-jamvm unzip

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

#Set path
cd BonitaBPM-build-6-2-3
DIR=`pwd`

#Downloading translation from Crowdin, then extract the archive
wget http://translate.bonitasoft.org/download/project/bonita-bpm-60.zip
mkdir translations
unzip bonita-bpm-60.zip -d translations

#Copying languages files in the bonita-web subfolders
cp translations/6.2.x/bonita-web/portal/* bonita-web/console/console-config/src/main/resources/platform/work/i18n/
cp translations/6.2.x/bonita-web/forms-view/* bonita-web/forms/forms-view/src/main/resources/org/bonitasoft/forms/client/i18n/
cp translations/6.2.x/bonita-web/form-server/* bonita-web/forms/forms-server/src/main/resources/locale/i18n/

Replace FormsView.gwt.xml with the list of all languages
cd translations/6.2.x/
wget https://github.com/Bonitasoft-Community/Build-Bonita-BPM/raw/master/6.2.x/FormsView.gwt.xml
cd ../..
cp translations/6.2.x/FormsView.gwt.xml bonita-web/forms/forms-view/src/main/java/org/bonitasoft/forms/

#Now that translations are available in the sources, we will build Platform
cd bonita-web
mvn clean install -DskipTests
cd ..
cd  bonita-distrib
mvn clean install -DskipTests
cd ../..

echo '---------------------------'
echo ''
echo 'You just finished to build Bonita BPM Platform with all translated languages. Congratulations !!!'
echo 'You you can find zip archives of the bundles in:'
echo ''
echo 'Tomcat: 	BonitaBPM-build-6-2-3/bonita-distrib/bundle/tomcat/target/'
echo 'Jboss: 	BonitaBPM-build-6-2-3/bonita-distrib/bundle/jboss/target/'
echo 'Deploy: 	BonitaBPM-build-6-2-3/bonita-distrib/deploy/distrib/target/'
echo ''
echo '---------------------------'
echo ''

#end
