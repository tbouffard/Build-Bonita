#/bin/bash

set -u
set -e

# Bonita BPM version
BONITA_BPM_VERSION=7.4.1

# Check that Maven 3.3.9 is available
MAVEN_VERSION="$(mvn --version 2>&1 | awk -F " " 'NR==1 {print $3}')"
if [ "$MAVEN_VERSION" != "3.3.9" ]; then
  echo Incorrect Maven version "$MAVEN_VERSION"
  exit 1
fi

# Ask for the location of Tomcat and WildFly zip file
read -p "Provide path to folder that contains Tomcat and WildFly zip file: " AS_DIR_PATH
if [ ! -d $AS_DIR_PATH ]; then
  echo Folder not found: "$AS_DIR_PATH"
  exit 1
fi

# List of repositories on https://github.com/bonitasoft that you don't need to build:
#
# angular-strap
# babel-preset-bonita
# bonita-connector-drools
# bonita-connector-mongodb
# bonita-connectors-assembly
# bonita-connectors-packaging
# bonita-custom-page-seed
# bonita-doc
# bonita-developer-resources
# bonita-examples
# bonita-jboss-h2-mbean
# bonita-js-components (build by UI Designer using Bower)
# bonita-migration
# bonita-migration-plugins
# bonita-platform
# bonita-platform-setup
# bonita-simulation
# bonita-tomcat-h2-listener
# bonita-tomcat-valve
# bonita-web-devtools
# bonita-web-extensions
# dojo
# jscs-preset-bonita
# ngUpload
# restlet-framework-java
# sandbox
# tomcat-atomikos
# tomcat-narayana
# training-presentation-tool
# widget-builder


# Note: Checkout folder of bonita-engine project need to be named community.
# FIXME: allow to skip test build. Currently test build generate bonita-server-test-utils required by bonita-web.
git clone --branch $BONITA_BPM_VERSION --single-branch https://github.com/bonitasoft/bonita-engine.git community
mvn clean install -DskipTests -f community/pom.xml

git clone --branch $BONITA_BPM_VERSION --single-branch https://github.com/bonitasoft/bonita-userfilters.git
mvn clean install -Dmaven.test.skip=true -f bonita-userfilters/pom.xml

# Version defined in each connectors pom.xml (see below) as this artifact is the parent of each connectors
git clone --branch bonita-connectors-1.0.0 --single-branch https://github.com/bonitasoft/bonita-connectors.git
mvn clean install -Dmaven.test.skip=true -f bonita-connectors/pom.xml

# Each connectors implementation version is defined in https://github.com/bonitasoft/bonita-studio/blob/$BONITA_BPM_VERSION/bundles/plugins/org.bonitasoft.studio.connectors/pom.xml. You need to find connector git repository tag that provides a given connector implementation version.

git clone --branch 2.0.0 --single-branch https://github.com/bonitasoft/bonita-connector-alfresco.git
mvn clean install -Dmaven.test.skip=true -Dbonita.engine.version=$BONITA_BPM_VERSION -f bonita-connector-alfresco/pom.xml

git clone --branch 3.0.1 --single-branch https://github.com/bonitasoft/bonita-connector-cmis.git
mvn clean install -Dmaven.test.skip=true -Dbonita.engine.version=$BONITA_BPM_VERSION -f bonita-connector-cmis/pom.xml

git clone --branch bonita-connector-database-datasource-1.0.12 --single-branch https://github.com/bonitasoft/bonita-connector-database.git
mvn clean install -Dmaven.test.skip=true -Dbonita.engine.version=$BONITA_BPM_VERSION -f bonita-connector-database/pom.xml

git clone --branch bonita-connector-email-impl-1.0.15 --single-branch https://github.com/bonitasoft/bonita-connector-email.git
mvn clean install -Dmaven.test.skip=true -Dbonita.engine.version=$BONITA_BPM_VERSION -f bonita-connector-email/pom.xml

#FIXME: old version of the connector should be removed as old Google API can not be used anymore.
# Workaround: install missing Google Calendar library in local Maven repository.
git clone --branch bonita-connector-googlecalendar-2.0.0 --single-branch https://github.com/bonitasoft/bonita-connector-googlecalendar.git
wget -N -P /tmp/ http://storage.googleapis.com/gdata-java-client-binaries/gdata-src.java-1.47.1.zip
unzip -o -j /tmp/gdata-src.java-1.47.1.zip gdata/java/lib/gdata-calendar-2.0.jar gdata/java/lib/gdata-core-1.0.jar gdata/java/lib/gdata-client-1.0.jar -d /tmp/
mvn install:install-file -DgeneratePom=true -DgroupId=com.google.gdata -DartifactId=gdata-core -Dpackaging=jar -Dfile=/tmp/gdata-core-1.0.jar -Dversion=1.0
mvn install:install-file -DgeneratePom=true -DgroupId=com.google.gdata -DartifactId=gdata-client -Dpackaging=jar -Dfile=/tmp/gdata-client-1.0.jar -Dversion=1.0
mvn install:install-file -DgeneratePom=true -DgroupId=com.google.gdata -DartifactId=gdata-calendar -Dpackaging=jar -Dfile=/tmp/gdata-calendar-2.0.jar -Dversion=2.0
wget -N -P /tmp/ http://www.docjar.com/jar/google-collect-1.0-rc1.jar
mvn install:install-file -DgeneratePom=true -DgroupId=com.google.common -DartifactId=google-collect -Dpackaging=jar -Dfile=/tmp/google-collect-1.0-rc1.jar -Dversion=1.0-rc1
mvn clean install -Dmaven.test.skip=true -Dbonita.engine.version=$BONITA_BPM_VERSION -f bonita-connector-googlecalendar/pom.xml

git clone --branch bonita-connector-google-calendar-v3-1.0.0 --single-branch https://github.com/bonitasoft/bonita-connector-googlecalendar-V3.git
mvn clean install -Dmaven.test.skip=true -Dbonita.engine.version=$BONITA_BPM_VERSION -f bonita-connector-googlecalendar-V3/pom.xml

git clone --branch bonita-connector-jasper-1.0.5 --single-branch https://github.com/bonitasoft/bonita-connector-jasper.git
mvn clean install -Dmaven.test.skip=true -Dbonita.engine.version=$BONITA_BPM_VERSION -f bonita-connector-jasper/pom.xml

#FIXME: mismatch beetwen artifacts version for git tag bonita-connector-ldap-1.0.1: bonita-connector-ldap=1.0.1, whereas bonita-connector-ldap-impl and bonita-connector-ldap-def have a reference to a parent in version 1.0.0.
git clone --branch bonita-connector-ldap-1.0.0 --single-branch https://github.com/bonitasoft/bonita-connector-ldap.git
mvn clean install -Dmaven.test.skip=true -Dbonita.engine.version=$BONITA_BPM_VERSION -f bonita-connector-ldap/pom.xml
rm -rf bonita-connector-ldap
git clone --branch bonita-connector-ldap-1.0.1 --single-branch https://github.com/bonitasoft/bonita-connector-ldap.git
mvn clean install -Dmaven.test.skip=true -Dbonita.engine.version=$BONITA_BPM_VERSION -f bonita-connector-ldap/pom.xml

git clone --branch 1.0.1 --single-branch https://github.com/bonitasoft/bonita-connector-rest.git
mvn clean install -Dmaven.test.skip=true -Dbonita.engine.version=$BONITA_BPM_VERSION -f bonita-connector-rest/pom.xml

git clone --branch 1.0.14 --single-branch https://github.com/bonitasoft/bonita-connector-salesforce.git
mvn clean install -Dmaven.test.skip=true -Dbonita.engine.version=$BONITA_BPM_VERSION -f bonita-connector-salesforce/pom.xml

#TODO: could not compile without SAP proprietary jar file
#git clone --branch jco2-callfunction-update-1.0.3 --single-branch https://github.com/bonitasoft/bonita-connector-sap.git
#mvn clean install -Dmaven.test.skip=true -Dbonita.engine.version=$BONITA_BPM_VERSION -f bonita-connector-sap/pom.xml

git clone --branch bonita-connector-scripting-20151015 --single-branch https://github.com/bonitasoft/bonita-connector-scripting.git
mvn clean install -Dmaven.test.skip=true -Dbonita.engine.version=$BONITA_BPM_VERSION -f bonita-connector-scripting/pom.xml

git clone --branch delete-several-1.0.3 --single-branch https://github.com/bonitasoft/bonita-connector-sugarcrm.git
mvn clean install -Dmaven.test.skip=true -Dbonita.engine.version=$BONITA_BPM_VERSION -f bonita-connector-sugarcrm/pom.xml

git clone --branch update-joblauncher-impl-1.0.3 --single-branch https://github.com/bonitasoft/bonita-connector-talend.git
mvn clean install -Dmaven.test.skip=true -Dbonita.engine.version=$BONITA_BPM_VERSION -f bonita-connector-talend/pom.xml

git clone --branch 1.1.0-pomfixed --single-branch https://github.com/bonitasoft/bonita-connector-twitter.git
mvn clean install -Dmaven.test.skip=true -Dbonita.engine.version=$BONITA_BPM_VERSION -f bonita-connector-twitter/pom.xml

git clone --branch 1.0.13 --single-branch https://github.com/bonitasoft/bonita-connector-webservice.git
mvn clean install -Dmaven.test.skip=true -Dbonita.engine.version=$BONITA_BPM_VERSION -f bonita-connector-webservice/pom.xml

# Version is defined in https://github.com/bonitasoft/bonita-studio/blob/$BONITA_BPM_VERSION/pom.xml.
git clone --branch 1.1.0 --single-branch https://github.com/bonitasoft/bonita-theme-builder.git
mvn clean install -Dmaven.test.skip=true -f bonita-theme-builder/pom.xml

# Version is defined in https://github.com/bonitasoft/bonita-studio/blob/$BONITA_BPM_VERSION/pom.xml.
git clone --branch studio-watchdog-7.2.0 --single-branch https://github.com/bonitasoft/bonita-studio-watchdog.git
mvn clean install -Dmaven.test.skip=true -f bonita-studio-watchdog/pom.xml

# Version is defined in https://github.com/bonitasoft/bonita-studio/blob/$BONITA_BPM_VERSION/bundles/plugins/org.bonitasoft.studio.dependencies/src-test/resources/tomcat/webapps/bonita/META-INF/maven/org.bonitasoft.console/console-war-sp/pom.xml has beeing the same one as gwt.version defined in
git clone --branch gwt-tools-2.5.0-20130521 --single-branch https://github.com/bonitasoft/bonita-gwt-tools.git
mvn clean install -Dmaven.test.skip=true -f bonita-gwt-tools/pom.xml

# FIXME: allow to skip compilation of test. Currently building console-server requires console-common tests jar.
git clone --branch $BONITA_BPM_VERSION --single-branch https://github.com/bonitasoft/bonita-web.git
mvn clean install -DskipTests -f bonita-web/pom.xml

git clone --branch $BONITA_BPM_VERSION --single-branch https://github.com/bonitasoft/bonita-portal-js.git
mvn clean install -Dmaven.test.skip=true -f bonita-portal-js/pom.xml

# Version is defined in https://github.com/bonitasoft/bonita-studio/blob/$BONITA_BPM_VERSION/pom.xml
# FIXME: allow to skip compilation of test. Currently 'npm run test' is executed even if -Dmaven.test.skip=true option is provided.
git clone --branch 1.4.26 --single-branch https://github.com/bonitasoft/bonita-ui-designer.git
mvn clean install -DskipTests -f bonita-ui-designer/pom.xml

git clone --branch $BONITA_BPM_VERSION --single-branch https://github.com/bonitasoft/bonita-distrib.git
mvn clean install -Dmaven.test.skip=true -Dwildfly.zip.parent.folder=$AS_DIR_PATH -Dtomcat.zip.parent.folder=$AS_DIR_PATH -f bonita-distrib/pom.xml

# Version is defined in https://github.com/bonitasoft/bonita-studio/blob/$BONITA_BPM_VERSION/pom.xml
git clone --branch image-overlay-plugin-1.0.2 --single-branch https://github.com/bonitasoft/image-overlay-plugin.git
mvn clean install -Dmaven.test.skip=true -f image-overlay-plugin/pom.xml

git clone --branch $BONITA_BPM_VERSION --single-branch https://github.com/bonitasoft/bonita-studio.git
# FIXME find a solution to avoid dependency on SAP connector
rm bonita-studio/bundles/plugins/org.bonitasoft.studio.importer.bar/src/org/bonitasoft/studio/importer/bar/custom/migration/connector/mapper/SapConnectorMapper.java
printf "You need to edit bonita-studio/bundles/plugins/org.bonitasoft.studio.connectors/pom.xml line 331 to remove bonita-connector-sap-jco2-impl dependency.\nYou need to edit bonita-studio/bundles/plugins/org.bonitasoft.studio.importer.bar/plugin.xml line 71 to remove SAP connector definition mapper.\nPress any key to continue..."
read -n 1
mvn clean verify -Dmaven.test.skip=true -f bonita-studio/pom.xml -Pmirrored,generate -Dp2MirrorUrl=http://update-site.bonitasoft.com/p2/7.2
