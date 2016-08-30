#/bin/bash

set -u
set -e

# Bonita BPM version
BONITA_BPM_VERSION=7.3.0

# Check that Maven 3.3.9 is available
MAVEN_VERSION="$(mvn --version 2>&1 | awk -F " " 'NR==1 {print $3}')"
if [[ "$MAVEN_VERSION" != "3.3.9" ]]; then
  echo Incorrect Maven version "$MAVEN_VERSION"
  exit 1
fi

# Ask for location of Maven 3.0.5 because it is required to build Bonita BPM Engine
read -p "Provide path to Maven 3.0.5 installation folder: " MAVEN_3_0_5_PATH
MAVEN_3_0_5_PATH+="/bin/mvn"
if [ ! -x $MAVEN_3_0_5_PATH ]; then
  echo Maven runtime not found or not executable: "$MAVEN_3_0_5_PATH"
  exit 1
fi

# Ask for the location of Tomcat and JBoss zip file
read -p "Provide path to folder that contains Tomcat and JBoss zip file: " AS_DIR_PATH
if [ ! -d $AS_DIR_PATH ]; then
  echo Folder not found: "$AS_DIR_PATH"
  exit 1
fi

# List of repositories on https://github.com/bonitasoft that you don't need to build:
#
# bonita-doc
# bonita-connector-rest (not yet part of Bonita BPM)
# angular-strap
# bonita-web-extensions
# bonita-migration-plugins
# bonita-migration
# restlet-framework-java
# babel-preset-bonita
# training-presentation-tool
# bonita-platform-setup
# widget-builder
# dojo
# jscs-preset-bonita
# bonita-custom-page-seed
# sandbox
# tomcat-atomikos
# bonita-connector-mongodb
# tomcat-narayana
# bonita-connectors-assembly
# bonita-connectors-packaging
# bonita-web-devtools
# bonita-examples


# https://github.com/bonitasoft/bonita-studio/blob/bos-studio-7.3.0-201607081120/bundles/plugins/org.bonitasoft.studio.connectors/pom.xml

# Version defined in https://github.com/bonitasoft/bonita-distrib/blob/7.3.0/deploy/distrib/pom.xml
git clone --branch 1.1.0 --single-branch https://github.com/bonitasoft/bonita-jboss-h2-mbean.git
mvn clean install -Dmaven.test.skip=true -f bonita-jboss-h2-mbean/pom.xml

# Version defined in https://github.com/bonitasoft/bonita-distrib/blob/7.3.0/deploy/distrib/pom.xml
git clone --branch bonita-tomcat-h2-listener-1.0.1 --single-branch https://github.com/bonitasoft/bonita-tomcat-h2-listener.git
mvn clean install -Dmaven.test.skip=true -f bonita-tomcat-h2-listener/pom.xml

# Version defined in https://github.com/bonitasoft/bonita-distrib/blob/7.3.0/pom.xml
git clone --branch 7.0.55 --single-branch https://github.com/bonitasoft/bonita-tomcat-valve.git
mvn clean install -Dmaven.test.skip=true -f bonita-tomcat-valve/pom.xml

# Note: We need to get bonita-engine repository content in order to build bonita-platform.
# Note: Checkout folder of bonita-engine project need to be named community.
git clone --branch 7.3.0 --single-branch https://github.com/bonitasoft/bonita-engine.git community
git clone --branch 7.3.0 --single-branch https://github.com/bonitasoft/bonita-platform.git
mvn clean install -Dmaven.test.skip=true -f bonita-platform/pom.xml

# FIXME: There is currently an issue with dependency management so compiling the test is requiered.
# FIXME: Maven 3.0.5 is required when compiling bonita-engine.
MAVEN_BUILD_ENGINE="$MAVEN_3_0_5_PATH clean install -DskipTests -f community/pom.xml"
eval "$MAVEN_BUILD_ENGINE"

git clone --branch 7.3.0 --single-branch https://github.com/bonitasoft/bonita-userfilters.git
mvn clean install -Dmaven.test.skip=true -f bonita-userfilters/pom.xml

# Version defined in each connectors pom.xml (see below) as this artifact is the parent of each connectors
git clone --branch bonita-connectors-1.0.0 --single-branch https://github.com/bonitasoft/bonita-connectors.git
mvn clean install -Dmaven.test.skip=true -f bonita-connectors/pom.xml

# Each connectors implementation version is defined in https://github.com/bonitasoft/bonita-studio/blob/bos-studio-7.3.0-201607081120/bundles/plugins/org.bonitasoft.studio.connectors/pom.xml. You need to find connector git repository tag that provides a given connector implementation version.

#FIXME: Studio depend on a mix of Alfresco connector version. Both 1.1.3 and 1.1.4 are required so 2 differents tags need to be build.
git clone --branch bonita-connector-alfresco-1.1.3 --single-branch https://github.com/bonitasoft/bonita-connector-alfresco.git
sed -i "s/<bonita.engine.version>.*<\/bonita.engine.version>/<bonita.engine.version>7.3.0<\/bonita.engine.version>/g" bonita-connector-alfresco/pom.xml
mvn clean install -Dmaven.test.skip=true -f bonita-connector-alfresco/pom.xml
rm -rf bonita-connector-alfresco
git clone --branch 1.1.4 --single-branch https://github.com/bonitasoft/bonita-connector-alfresco.git
sed -i "s/<bonita.engine.version>.*<\/bonita.engine.version>/<bonita.engine.version>7.3.0<\/bonita.engine.version>/g" bonita-connector-alfresco/pom.xml
mvn clean install -Dmaven.test.skip=true -f bonita-connector-alfresco/pom.xml

git clone --branch 2.0.1 --single-branch https://github.com/bonitasoft/bonita-connector-cmis.git
sed -i "s/<bonita.engine.version>.*<\/bonita.engine.version>/<bonita.engine.version>7.3.0<\/bonita.engine.version>/g" bonita-connector-cmis/pom.xml
mvn clean install -Dmaven.test.skip=true -f bonita-connector-cmis/pom.xml

git clone --branch bonita-connector-database-datasource-1.0.12 --single-branch https://github.com/bonitasoft/bonita-connector-database.git
sed -i "s/<bonita.engine.version>.*<\/bonita.engine.version>/<bonita.engine.version>7.3.0<\/bonita.engine.version>/g" bonita-connector-database/pom.xml
mvn clean install -Dmaven.test.skip=true -f bonita-connector-database/pom.xml

git clone --branch bonita-connector-email-impl-1.0.14 --single-branch https://github.com/bonitasoft/bonita-connector-email.git
sed -i "s/<bonita.engine.version>.*<\/bonita.engine.version>/<bonita.engine.version>7.3.0<\/bonita.engine.version>/g" bonita-connector-email/pom.xml
mvn clean install -Dmaven.test.skip=true -f bonita-connector-email/pom.xml

#FIXME: old version of the connector should be removed as old Google API can not be used anymore.
# Workaround: install missing Google Calendar library in local Maven repository.
git clone --branch bonita-connector-googlecalendar-2.0.0 --single-branch https://github.com/bonitasoft/bonita-connector-googlecalendar.git
sed -i "s/<bonita.engine.version>.*<\/bonita.engine.version>/<bonita.engine.version>7.3.0<\/bonita.engine.version>/g" bonita-connector-googlecalendar/pom.xml
wget -N -P /tmp/ http://storage.googleapis.com/gdata-java-client-binaries/gdata-src.java-1.47.1.zip
unzip -o -j /tmp/gdata-src.java-1.47.1.zip gdata/java/lib/gdata-calendar-2.0.jar gdata/java/lib/gdata-core-1.0.jar gdata/java/lib/gdata-client-1.0.jar -d /tmp/
mvn install:install-file -DgeneratePom=true -DgroupId=com.google.gdata -DartifactId=gdata-core -Dpackaging=jar -Dfile=/tmp/gdata-core-1.0.jar -Dversion=1.0
mvn install:install-file -DgeneratePom=true -DgroupId=com.google.gdata -DartifactId=gdata-client -Dpackaging=jar -Dfile=/tmp/gdata-client-1.0.jar -Dversion=1.0
mvn install:install-file -DgeneratePom=true -DgroupId=com.google.gdata -DartifactId=gdata-calendar -Dpackaging=jar -Dfile=/tmp/gdata-calendar-2.0.jar -Dversion=2.0
wget -N -P /tmp/ http://www.docjar.com/jar/google-collect-1.0-rc1.jar
mvn install:install-file -DgeneratePom=true -DgroupId=com.google.common -DartifactId=google-collect -Dpackaging=jar -Dfile=/tmp/google-collect-1.0-rc1.jar -Dversion=1.0-rc1
mvn clean install -Dmaven.test.skip=true -f bonita-connector-googlecalendar/pom.xml

git clone --branch bonita-connector-google-calendar-v3-1.0.0 --single-branch https://github.com/bonitasoft/bonita-connector-googlecalendar-V3.git
sed -i "s/<bonita.engine.version>.*<\/bonita.engine.version>/<bonita.engine.version>7.3.0<\/bonita.engine.version>/g" bonita-connector-googlecalendar-V3/pom.xml
mvn clean install -Dmaven.test.skip=true -f bonita-connector-googlecalendar-V3/pom.xml

#FIXME: issue with bonita-connector-jasper tag 1.0.4: bonita-connector-jasper project version is 1.0.1 whereas bonita-connector-jasper-def and bonita-connector-jasper-impl define there parent has beeing in version 1.0.0. Workaround is to build tag 1.0.0 that provide bonita-connector-jasper in version 1.0.0.
git clone --branch bonita-connector-jasper-1.0.0 --single-branch https://github.com/bonitasoft/bonita-connector-jasper.git
sed -i "s/<bonita.engine.version>.*<\/bonita.engine.version>/<bonita.engine.version>7.3.0<\/bonita.engine.version>/g" bonita-connector-jasper/pom.xml
mvn clean install -Dmaven.test.skip=true -f bonita-connector-jasper/pom.xml
rm -rf bonita-connector-jasper
git clone --branch bonita-connector-jasper-1.0.4 --single-branch https://github.com/bonitasoft/bonita-connector-jasper.git
sed -i "s/<bonita.engine.version>.*<\/bonita.engine.version>/<bonita.engine.version>7.3.0<\/bonita.engine.version>/g" bonita-connector-jasper/pom.xml
mvn clean install -Dmaven.test.skip=true -f bonita-connector-jasper/pom.xml

#FIXME: same as bonita-connector-jasper
git clone --branch bonita-connector-ldap-1.0.0 --single-branch https://github.com/bonitasoft/bonita-connector-ldap.git
sed -i "s/<bonita.engine.version>.*<\/bonita.engine.version>/<bonita.engine.version>7.3.0<\/bonita.engine.version>/g" bonita-connector-ldap/pom.xml
mvn clean install -Dmaven.test.skip=true -f bonita-connector-ldap/pom.xml
rm -rf bonita-connector-ldap
git clone --branch bonita-connector-ldap-1.0.1 --single-branch https://github.com/bonitasoft/bonita-connector-ldap.git
sed -i "s/<bonita.engine.version>.*<\/bonita.engine.version>/<bonita.engine.version>7.3.0<\/bonita.engine.version>/g" bonita-connector-ldap/pom.xml
mvn clean install -Dmaven.test.skip=true -f bonita-connector-ldap/pom.xml

git clone --branch 1.0.14 --single-branch https://github.com/bonitasoft/bonita-connector-salesforce.git
sed -i "s/<bonita.engine.version>.*<\/bonita.engine.version>/<bonita.engine.version>7.3.0<\/bonita.engine.version>/g" bonita-connector-salesforce/pom.xml
mvn clean install -Dmaven.test.skip=true -f bonita-connector-salesforce/pom.xml

#TODO: could not compile without SAP proprietary jar file
#git clone --branch jco2-callfunction-update-1.0.3 --single-branch https://github.com/bonitasoft/bonita-connector-sap.git
#mvn clean install -Dmaven.test.skip=true -f bonita-connector-sap/pom.xml

git clone --branch bonita-connector-scripting-20151015 --single-branch https://github.com/bonitasoft/bonita-connector-scripting.git
sed -i "s/<bonita.engine.version>.*<\/bonita.engine.version>/<bonita.engine.version>7.3.0<\/bonita.engine.version>/g" bonita-connector-scripting/pom.xml
mvn clean install -Dmaven.test.skip=true -f bonita-connector-scripting/pom.xml

git clone --branch delete-several-1.0.3 --single-branch https://github.com/bonitasoft/bonita-connector-sugarcrm.git
sed -i "s/<bonita.engine.version>.*<\/bonita.engine.version>/<bonita.engine.version>7.3.0<\/bonita.engine.version>/g" bonita-connector-sugarcrm/pom.xml
mvn clean install -Dmaven.test.skip=true -f bonita-connector-sugarcrm/pom.xml

git clone --branch update-joblauncher-impl-1.0.3 --single-branch https://github.com/bonitasoft/bonita-connector-talend.git
sed -i "s/<bonita.engine.version>.*<\/bonita.engine.version>/<bonita.engine.version>7.3.0<\/bonita.engine.version>/g" bonita-connector-talend/pom.xml
mvn clean install -Dmaven.test.skip=true -f bonita-connector-talend/pom.xml

git clone --branch 1.1.0-pomfixed --single-branch https://github.com/bonitasoft/bonita-connector-twitter.git
sed -i "s/<bonita.engine.version>.*<\/bonita.engine.version>/<bonita.engine.version>7.3.0<\/bonita.engine.version>/g" bonita-connector-twitter/pom.xml
mvn clean install -Dmaven.test.skip=true -f bonita-connector-twitter/pom.xml

git clone --branch 1.0.13 --single-branch https://github.com/bonitasoft/bonita-connector-webservice.git
sed -i "s/<bonita.engine.version>.*<\/bonita.engine.version>/<bonita.engine.version>7.3.0<\/bonita.engine.version>/g" bonita-connector-webservice/pom.xml
mvn clean install -Dmaven.test.skip=true -f bonita-connector-webservice/pom.xml

# FIXME: csv4j is not available in a public repository.
# Version is defined in https://github.com/bonitasoft/bonita-studio/blob/bos-studio-7.3.0-201607081120/pom.xml.
wget -N -P /tmp/ http://csvobjectmapper.sourceforge.net/maven2/net/sf/csv4j/0.4.0/csv4j-0.4.0.jar
mvn install:install-file -Dfile=/tmp/csv4j-0.4.0.jar -DgroupId=net.sf.csv4j -DartifactId=csv4j -Dversion=0.4.0 -Dpackaging=jar -DgeneratePom=true
git clone --branch bos-simulation-6.1.0 --single-branch https://github.com/bonitasoft/bonita-simulation.git
mvn clean install -Dmaven.test.skip=true -f bonita-simulation/pom.xml

# Version is defined in https://github.com/bonitasoft/bonita-studio/blob/bos-studio-7.3.0-201607081120/pom.xml.
git clone --branch 1.1.0 --single-branch https://github.com/bonitasoft/bonita-theme-builder.git
mvn clean install -Dmaven.test.skip=true -f bonita-theme-builder/pom.xml

# Version is defined in https://github.com/bonitasoft/bonita-studio/blob/bos-studio-7.3.0-201607081120/pom.xml.
git clone --branch studio-watchdog-7.2.0 --single-branch https://github.com/bonitasoft/bonita-studio-watchdog.git
mvn clean install -Dmaven.test.skip=true -f bonita-studio-watchdog/pom.xml

# Version is defined in https://github.com/bonitasoft/bonita-studio/blob/bos-studio-7.3.0-201607081120/bundles/plugins/org.bonitasoft.studio.dependencies/src-test/resources/tomcat/webapps/bonita/META-INF/maven/org.bonitasoft.console/console-war-sp/pom.xml has beeing the same one as gwt.version defined in
git clone --branch gwt-tools-2.5.0-20130521 --single-branch https://github.com/bonitasoft/bonita-gwt-tools.git
mvn clean install -Dmaven.test.skip=true -f bonita-gwt-tools/pom.xml

#git clone --branch 0.5.7 --single-branch https://github.com/bonitasoft/bonita-js-components.git
#mvn clean install -Dmaven.test.skip=true -f bonita-js-components/pom.xml
#rm -rf bonita-js-components
#git clone --branch 0.5.3 --single-branch https://github.com/bonitasoft/bonita-js-components.git
#mvn clean install -Dmaven.test.skip=true -f bonita-js-components/pom.xml

# FIXME: need to add extra Maven repository to get Restlet dependencies.
git clone --branch 7.3.0 --single-branch https://github.com/bonitasoft/bonita-web.git
sed -i "350i <repository><id>maven-restlet</id><name>Public online Restlet repository</name><url>http://maven.restlet.com</url></repository>" bonita-web/pom.xml
mvn clean install -DskipTests -f bonita-web/pom.xml

git clone --branch 7.3.0 --single-branch https://github.com/bonitasoft/bonita-portal-js.git
mvn clean install -Dmaven.test.skip=true -f bonita-portal-js/pom.xml

# Version is defined in https://github.com/bonitasoft/bonita-studio/blob/bos-studio-7.3.0-201607081120/pom.xml
git clone --branch 1.3.12 --single-branch https://github.com/bonitasoft/bonita-ui-designer.git
mvn clean install -DskipTests -f bonita-ui-designer/pom.xml

git clone --branch 7.3.0 --single-branch https://github.com/bonitasoft/bonita-distrib.git
mvn clean install -DskipTests -Djboss.zip.parent.folder=$AS_DIR_PATH -Dtomcat.zip.parent.folder=$AS_DIR_PATH -f bonita-distrib/pom.xml

# Version is defined in https://github.com/bonitasoft/bonita-studio/blob/bos-studio-7.3.0-201607081120/pom.xml
git clone --branch image-overlay-plugin-1.0.1 --single-branch https://github.com/bonitasoft/image-overlay-plugin.git
mvn clean install -Dmaven.test.skip=true -f image-overlay-plugin/pom.xml

git clone --branch bos-studio-7.3.0-201607081120 --single-branch https://github.com/bonitasoft/bonita-studio.git
# FIXME find a solution to avoid depency on SAP connector
rm bonita-studio/bundles/plugins/org.bonitasoft.studio.importer.bar/src/org/bonitasoft/studio/importer/bar/custom/migration/connector/mapper/SapConnectorMapper.java
printf "You need to edit bonita-studio/bundles/plugins/org.bonitasoft.studio.connectors/pom.xml line 423 to remove bonita-connector-sap-jco2-impl dependency.\nYou need to edit bonita-studio/bundles/plugins/org.bonitasoft.studio.importer.bar/plugin.xml line 71 to remove SAP connector definition mapper.\nPress any key to continue..."
read -n 1
mvn clean install -Dmaven.test.skip=true -f bonita-studio/platform/pom.xml -Pmirrored -Dp2MirrorUrl=http://update-site.bonitasoft.com/p2/7.2
mvn clean install -Dmaven.test.skip=true -f bonita-studio/patched-plugins/pom.xml
mvn clean install -Dmaven.test.skip=true -f bonita-studio/tests-dependencies/pom.xml
mvn clean tycho-eclipserun:eclipse-run -Dtycho.mode=maven -Dmaven.test.skip=true -Dp2MirrorUrl=http://update-site.bonitasoft.com/p2/7.2 -Pgenerate -f bonita-studio/bundles/plugins/org.bonitasoft.studio-models/pom.xml
mvn clean install -Dmaven.test.skip=true -f bonita-studio/bundles/pom.xml -Dp2MirrorUrl=http://update-site.bonitasoft.com/p2/7.2
mvn clean install -Dmaven.test.skip=true -f bonita-studio/translations/pom.xml -Dp2MirrorUrl=http://update-site.bonitasoft.com/p2/7.2
mvn clean install -Dmaven.test.skip=true -f bonita-studio/all-in-one/pom.xml -Dp2MirrorUrl=http://update-site.bonitasoft.com/p2/7.2
