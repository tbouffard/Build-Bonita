#/bin/bash

set -u
set -e
set +o nounset


# If you want to make 100% sure that you do a clean build from scratch:
# rm -rf ~/.m2/repository/org/bonitasoft/
# rm -rf ~/.gradle/caches
# find -type d -name ".gradle" -prune -exec rm -rf {} \;
# find -type d -name target -prune -exec rm -rf {} \;

# Workaround for at least Debian Buster
# Require to build bonita-portal-js due to issue with PhantomJS launched by Karma
# See https://github.com/ariya/phantomjs/issues/14520
export OPENSSL_CONF=/etc/ssl

# Script configuration
# You can set the following environment variables
BONITA_BUILD_NO_CLEAN=${BONITA_BUILD_NO_CLEAN:-false}
BONITA_BUILD_QUIET=${BONITA_BUILD_QUIET:-false}
BONITA_BUILD_STUDIO_ONLY=${BONITA_BUILD_STUDIO_ONLY:-false}
BONITA_BUILD_STUDIO_SKIP=${BONITA_BUILD_STUDIO_SKIP:-false}

# Bonita version
BONITA_BPM_VERSION=7.9.4

# Bonita Studio p2 public repository
STUDIO_P2_URL=http://update-site.bonitasoft.com/p2/4.10

# FIXME: remove when temporary workaround become useless
STUDIO_P2_URL_INTERNAL_TO_REPLACE=http://repositories.rd.lan/p2/4.10.1


########################################################################################################################
# SCM AND BUILD FUNCTIONS
########################################################################################################################

# params:
# - Git repository name
# - Tag name (optional)
# - Checkout folder name (optional)
checkout() {
	# We need at least one parameter (the repository name) and no more than three (repository name, tag name and checkout folder name)
	if [ "$#" -lt 1 ] || [ "$#" -gt 3 ]; then
		echo "Incorrect number of parameters: $@"
		exit 1
	fi

	repository_name="$1"

	if [ "$#" -ge 2 ]; then
		tag_name="$2"
	else
		# If we don't have a tag name assume that the tag is named with the Bonita version
		tag_name=$BONITA_BPM_VERSION
	fi
	echo "============================================================"
	echo "Processing ${repository_name} ${tag_name}"
	echo "============================================================"

	if [ "$#" -eq 3 ]; then
		checkout_folder_name="$3"
	else
		# If no checkout folder path is provided use the repository name as destination folder name
		checkout_folder_name="$repository_name"
	fi

  # If we don't already clone the repository do it
  if [ ! -d "$checkout_folder_name/.git" ]; then
	  git clone "https://github.com/bonitasoft/$repository_name.git" $checkout_folder_name
	fi
	# Ensure we fetch all the tags and that we are on the appropriate one
	git -C $checkout_folder_name fetch --tags
	git -C $checkout_folder_name reset --hard tags/$tag_name

	# Move to the repository clone folder (required to run Maven/Gradle wrapper)
	cd $checkout_folder_name

	# Workarounds
	# FIXME: remove temporary workaround added to make sure that we use public repository (Bonita internal tracker issue id: BST-463)
	# Issue is related to Tycho target-platform-configuration plugin that rely on the artifact org.bonitasoft.studio:platform.
	# The artifact include Ant Maven plugin to update the platform.target file but it is not executed before Tycho is executed and read the incorrect URL.
	if [[ "$repository_name" == "bonita-studio" ]]; then
		echo "WARN: workaround on $repository_name - fix platform.target URL"
		sed -i "s,${STUDIO_P2_URL_INTERNAL_TO_REPLACE},${STUDIO_P2_URL},g" platform/platform.target
	fi
}

run_maven_with_standard_system_properties() {
	build_command="$build_command -Dbonita.engine.version=$BONITA_BPM_VERSION -Dp2MirrorUrl=${STUDIO_P2_URL}"
	echo "[DEBUG] Running build command: $build_command"
	eval "$build_command"
	# Go back to script folder (checkout move current directory to project checkout folder.
	cd ..
}

run_gradle_with_standard_system_properties() {
	echo "[DEBUG] Running build command: $build_command"
	eval "$build_command"
	# Go back to script folder (checkout move current directory to project checkout folder.
	cd ..
}

# FIXME: should be replaced in all project by Maven wrapper
build_maven() {
	build_command="mvn"
}

build_maven_wrapper() {
	build_command="./mvnw"
}

build_gradle_wrapper() {
	build_command="./gradlew"
}

build_quiet_if_requested() {
	if [[ "${BONITA_BUILD_QUIET}" == "true" ]]; then
		echo "Configure quiet build"
		build_command="$build_command --quiet"
	fi
}

build() {
	build_command="$build_command build"
}

publishToMavenLocal() {
	build_command="$build_command publishToMavenLocal"
}

clean() {
	if [[ "${BONITA_BUILD_NO_CLEAN}" == "true" ]]; then
		echo "Configure build to skip clean task"
	else
		build_command="$build_command clean"
	fi
}

install() {
	build_command="$build_command install"
}

verify() {
	build_command="$build_command verify"
}

skiptest() {
	build_command="$build_command -DskipTests"
}

gradle_test_skip() {
	build_command="$build_command -x test"
}

profile() {
	build_command="$build_command -P$1"
}

#FIXME: should be replaced in all projects by Maven wrapper
# params:
# - Git repository name
# - Branch name (optional)
build_maven_install_skiptest() {
	checkout "$@"
	build_maven
	build_quiet_if_requested
	clean
	install
	skiptest
	run_maven_with_standard_system_properties
}

# params:
# - Git repository name
# - Profile name
build_maven_wrapper_verify_skiptest_with_profile()
{
	checkout $1
	build_maven_wrapper
	build_quiet_if_requested
	clean
	verify
	skiptest
	profile $2
	run_maven_with_standard_system_properties
}

# params:
# - Git repository name
build_maven_wrapper_install_skiptest()
{
	checkout "$@"
	# FIXME: required to build UID
	# This has been fixed in UID 1.9.56, see https://github.com/bonitasoft/bonita-ui-designer/commit/edf0a0c7f943e8f215890550247d61eba14932c6
	# To be removed when we will build newest UID versions
	chmod u+x mvnw
	build_maven_wrapper
	build_quiet_if_requested
	clean
	install
	skiptest
	run_maven_with_standard_system_properties
}

build_gradle_wrapper_test_skip_publishToMavenLocal() {
	checkout "$@"
	build_gradle_wrapper
	build_quiet_if_requested
	clean
	gradle_test_skip
	publishToMavenLocal
	run_gradle_with_standard_system_properties
}

########################################################################################################################
# PARAMETERS PARSING AND VALIDATIONS
########################################################################################################################

logBuildSettings() {
    echo "Build settings"
    echo "  > BONITA_BUILD_NO_CLEAN: ${BONITA_BUILD_NO_CLEAN}"
    echo "  > BONITA_BUILD_QUIET: ${BONITA_BUILD_QUIET}"
    echo "  > BONITA_BUILD_STUDIO_ONLY: ${BONITA_BUILD_STUDIO_ONLY}"
    echo "  > BONITA_BUILD_STUDIO_SKIP: ${BONITA_BUILD_STUDIO_SKIP}"
}

checkPrerequisites() {
    # Test that x server is running. Required to generate Bonita Studio models
    # Can be ignored if Studio is build without the "generate" Maven profile
    if ! xset q &>/dev/null; then
        echo "No X server at \$DISPLAY [$DISPLAY]" >&2
        exit 1
    fi

    # Test that Maven exists
    # FIXME: remove once all projects includes Maven wrapper
    if hash mvn 2>/dev/null; then
        MAVEN_VERSION="$(mvn --version 2>&1 | awk -F " " 'NR==1 {print $3}')"
        echo Using Maven version: "$MAVEN_VERSION"
    else
        echo Maven not found. Exiting.
        exit 1
    fi

    # Test if Curl exists
    if hash curl 2>/dev/null; then
        CURL_VERSION="$(curl --version 2>&1  | awk -F " " 'NR==1 {print $2}')"
        echo Using curl version: "$CURL_VERSION"
    else
        echo curl not found. Exiting.
        exit 1
    fi

    checkJavaVersion
}

checkJavaVersion() {
    local JAVA_CMD=
    echo "Check if Java version is compatible with Bonita"

    if [[ "x$JAVA" = "x" ]]; then
        if [[ "x$JAVA_HOME" != "x" ]]; then
            echo "  > JAVA_HOME is set"
            JAVA_CMD="$JAVA_HOME/bin/java"
        else
            echo "  > JAVA_HOME is not set. Use java in path"
            JAVA_CMD="java"
        fi
    else
        JAVA_CMD=$JAVA
    fi
    echo "  > Java command path is $JAVA_CMD"

    java_full_version=$("$JAVA_CMD" -version 2>&1 | grep -i version | sed 's/.*version "\(.*\)".*$/\1/g')
    echo "  > Java full version: $java_full_version"
    if [[ "x$java_full_version" = "x" ]]; then
      echo "No Java command could be found. Please set JAVA_HOME variable to a JDK and/or add the java executable to your PATH"
      exit 1
    fi

    java_version_1st_digit=$(echo "$java_full_version" | sed 's/\(.*\)\..*\..*$/\1/g')
    java_version_expected=8
    # pre Java 9 versions, get minor version
    if [[ "$java_version_1st_digit" -eq "1" ]]; then
      java_version=$(echo "$java_full_version" | sed 's/.*\.\(.*\)\..*$/\1/g')
    else
      java_version=${java_version_1st_digit}
    fi
    echo "  > Java version: $java_version"

    if [[ "$java_version" -ne "$java_version_expected" ]]; then
      echo "Invalid Java version $java_version not $java_version_expected. Please set JAVA_HOME environment variable to a valid JDK version, and/or add the java executable to your PATH"
      exit 1
    fi
    echo "Java version is compatible"
}


########################################################################################################################
# TOOLING
########################################################################################################################

detectStudioDependenciesVersions() {
	echo "Detecting Studio dependencies versions"
	local studioPom=`curl -sS -X GET https://raw.githubusercontent.com/bonitasoft/bonita-studio/${BONITA_BPM_VERSION}/pom.xml`

	STUDIO_IMAGE_OVERLAY_PLUGIN_VERSION=`echo "${studioPom}" | grep image-overlay-plugin.version | grep -v '<version>' | sed 's@.*>\(.*\)<.*@\1@g'`
	STUDIO_UID_VERSION=`echo "${studioPom}" | grep ui.designer.version | sed 's@.*>\(.*\)<.*@\1@g'`
	STUDIO_WATCHDOG_VERSION=`echo "${studioPom}" | grep watchdog.version | sed 's@.*>\(.*\)<.*@\1@g'`

	echo "STUDIO_IMAGE_OVERLAY_PLUGIN_VERSION: ${STUDIO_IMAGE_OVERLAY_PLUGIN_VERSION}"
	echo "STUDIO_UID_VERSION: ${STUDIO_UID_VERSION}"
	echo "STUDIO_WATCHDOG_VERSION: ${STUDIO_WATCHDOG_VERSION}"
}

detectConnectorsVersions() {
  echo "Detecting Connectors versions"
  local studioPom=`curl -sS -X GET https://raw.githubusercontent.com/bonitasoft/bonita-studio/${BONITA_BPM_VERSION}/bundles/plugins/org.bonitasoft.studio.connectors/pom.xml`
  CONNECTOR_VERSION_ALFRESCO=`echo "${studioPom}" | grep connector.version.alfresco | grep -v '<version>' | sed 's@.*>\(.*\)<.*@\1@g'`
  echo "CONNECTOR_VERSION_ALFRESCO: ${CONNECTOR_VERSION_ALFRESCO}"

  CONNECTOR_VERSION_CMIS=`echo "${studioPom}" | grep connector.version.cmis | grep -v '<version>' | sed 's@.*>\(.*\)<.*@\1@g'`
  echo "CONNECTOR_VERSION_CMIS: ${CONNECTOR_VERSION_CMIS}"

  CONNECTOR_VERSION_DATABASE=`echo "${studioPom}" | grep connector.version.database | grep -v '<version>' | sed 's@.*>\(.*\)<.*@\1@g'`
  echo "CONNECTOR_VERSION_DATABASE: ${CONNECTOR_VERSION_DATABASE}"

  CONNECTOR_VERSION_EMAIL=`echo "${studioPom}" | grep connector.version.email | grep -v '<version>' | sed 's@.*>\(.*\)<.*@\1@g'`
  echo "CONNECTOR_VERSION_EMAIL: ${CONNECTOR_VERSION_EMAIL}"

  CONNECTOR_VERSION_GOOGLE_CALENDAR_V3=`echo "${studioPom}" | grep google-calendar-v3 | grep -v '<version>' | grep -v 'impl' | sed 's@.*>\(.*\)<.*@\1@g'`
  echo "CONNECTOR_VERSION_GOOGLE_CALENDAR_V3: ${CONNECTOR_VERSION_GOOGLE_CALENDAR_V3}"

  CONNECTOR_VERSION_LDAP=`echo "${studioPom}" | grep connector.version.ldap | grep -v '<version>' | sed 's@.*>\(.*\)<.*@\1@g'`
  echo "CONNECTOR_VERSION_LDAP: ${CONNECTOR_VERSION_LDAP}"

  CONNECTOR_VERSION_REST=`echo "${studioPom}" | grep connector.version.rest | grep -v '<version>' | sed 's@.*>\(.*\)<.*@\1@g'`
  echo "CONNECTOR_VERSION_REST: ${CONNECTOR_VERSION_REST}"

  CONNECTOR_VERSION_SALESFORCE=`echo "${studioPom}" | grep connector.version.salesforce | grep -v '<version>' | sed 's@.*>\(.*\)<.*@\1@g'`
  echo "CONNECTOR_VERSION_SALESFORCE: ${CONNECTOR_VERSION_SALESFORCE}"

  CONNECTOR_VERSION_SCRIPTING=`echo "${studioPom}" | grep connector.version.scripting | grep -v '<version>' | sed 's@.*>\(.*\)<.*@\1@g'`
  echo "CONNECTOR_VERSION_SCRIPTING: ${CONNECTOR_VERSION_SCRIPTING}"

  CONNECTOR_VERSION_TWITTER=`echo "${studioPom}" | grep connector.version.twitter | grep -v '<version>' | sed 's@.*>\(.*\)<.*@\1@g'`
  echo "CONNECTOR_VERSION_TWITTER: ${CONNECTOR_VERSION_TWITTER}"

  CONNECTOR_VERSION_WEBSERVICE=`echo "${studioPom}" | grep connector.version.webservice | grep -v '<version>' | sed 's@.*>\(.*\)<.*@\1@g'`
  echo "CONNECTOR_VERSION_WEBSERVICE: ${CONNECTOR_VERSION_WEBSERVICE}"
}

detectWebPagesDependenciesVersions() {
	echo "Detecting web-pages dependencies versions"
	local webPagesGradleBuild=`curl -sS -X GET https://raw.githubusercontent.com/bonitasoft/bonita-web-pages/${BONITA_BPM_VERSION}/build.gradle`

	WEB_PAGES_UID_VERSION=`echo "${webPagesGradleBuild}" | tr --squeeze-repeats "[:blank:]" | tr --delete "\n" | sed 's@.*UIDesigner {\(.*\)"}.*@\1@g' | sed 's@.*version "\(.*\)@\1@g'`
	echo "WEB_PAGES_UID_VERSION: ${WEB_PAGES_UID_VERSION}"
}


########################################################################################################################
# MAIN
########################################################################################################################
logBuildSettings
checkPrerequisites

# List of repositories on https://github.com/bonitasoft that you don't need to build
# Note that archived repositories are not listed here, as they are only required to build old Bonita versions
#
# angular-strap: automatically downloaded in the build of bonita-web project.
# babel-preset-bonita: automatically downloaded in the build of bonita-ui-designer project.
# bonita-codesign-windows: use to sign Windows binaries when building using Bonita Continuous Integration.
# bonita-connector-talend: deprecated.
# bonita-continuous-delivery-doc: Bonita Enterprise Edition Continuous Delivery module documentation.
# bonita-custom-page-seed: a project to start building a custom page. Deprecated in favor of UI Designer page + REST API extension.
# bonita-doc: Bonita documentation.
# bonita-developer-resources: guidelines for contributing to Bonita, contributor license agreement, code style...
# bonita-examples: Bonita usage code examples.
# bonita-ici-doc: Bonita Enterprise Edition AI module documentation.
# bonita-js-components: automatically downloaded in the build of projects that require it.
# bonita-migration: migration tool to update a server from a previous Bonita release.
# bonita-page-authorization-rules: documentation project to provide an example for page mapping authorization rule.
# bonita-connector-sap: deprecated. Use REST connector instead.
# bonita-vacation-management-example: an example for Bonita Enterprise Edition Continuous Delivery module.
# bonita-web-devtools: Bonitasoft internal development tools.
# bonita-widget-contrib: project to start building custom widgets outside UI Designer.
# create-react-app: required for Bonita Subscription Intelligent Continuous Improvement module.
# dojo: Bonitasoft R&D coding dojos.
# jscs-preset-bonita: Bonita JavaScript code guidelines.
# ngUpload: automatically downloaded in the build of bonita-ui-designer project.
# preact-chartjs-2: required for Bonita Subscription Intelligent Continuous Improvement module.
# preact-content-loader: required for Bonita Subscription Intelligent Continuous Improvement module.
# restlet-framework-java: /!\
# swt-repo: legacy repository required by Bonita Studio. Deprecated.
# training-presentation-tool: fork of reveal.js with custom look and feel.
# widget-builder: automatically downloaded in the build of bonita-ui-designer project.


if [[ "${BONITA_BUILD_STUDIO_ONLY}" == "false" ]]; then
    build_gradle_wrapper_test_skip_publishToMavenLocal bonita-engine

    build_maven_wrapper_install_skiptest bonita-userfilters

    build_maven_wrapper_install_skiptest bonita-web-extensions

    build_maven_wrapper_install_skiptest bonita-web
    # TODO with Bonita 7.10, we should be able to use the maven wrapper
    build_maven_install_skiptest bonita-portal-js

    # bonita-web-pages is build using a specific version of UI Designer.
    detectWebPagesDependenciesVersions
    build_maven_wrapper_install_skiptest bonita-ui-designer ${WEB_PAGES_UID_VERSION}
    build_gradle_wrapper_test_skip_publishToMavenLocal bonita-web-pages

    build_maven_wrapper_install_skiptest bonita-distrib

    # Connectors
    detectConnectorsVersions

    build_maven_wrapper_install_skiptest bonita-connector-cmis ${CONNECTOR_VERSION_CMIS}
    build_maven_wrapper_install_skiptest bonita-connector-database ${CONNECTOR_VERSION_DATABASE}
    build_maven_wrapper_install_skiptest bonita-connector-email ${CONNECTOR_VERSION_EMAIL}
    build_maven_wrapper_install_skiptest bonita-connector-rest ${CONNECTOR_VERSION_REST}
    build_maven_wrapper_install_skiptest bonita-connector-salesforce ${CONNECTOR_VERSION_SALESFORCE}
    build_maven_wrapper_install_skiptest bonita-connector-scripting ${CONNECTOR_VERSION_SCRIPTING}
    build_maven_wrapper_install_skiptest bonita-connector-twitter ${CONNECTOR_VERSION_TWITTER}
    build_maven_wrapper_install_skiptest bonita-connector-webservice ${CONNECTOR_VERSION_WEBSERVICE}
    # connectors using legacy way of building
    build_maven_install_skiptest bonita-connector-alfresco ${CONNECTOR_VERSION_ALFRESCO}
    build_maven_install_skiptest bonita-connector-googlecalendar-V3 bonita-connector-google-calendar-v3-${CONNECTOR_VERSION_GOOGLE_CALENDAR_V3}
    build_maven_install_skiptest bonita-connector-ldap bonita-connector-ldap-${CONNECTOR_VERSION_LDAP}

    detectStudioDependenciesVersions
    build_maven_install_skiptest bonita-studio-watchdog studio-watchdog-${STUDIO_WATCHDOG_VERSION}
    build_maven_wrapper_install_skiptest image-overlay-plugin image-overlay-plugin-${STUDIO_IMAGE_OVERLAY_PLUGIN_VERSION}
    build_maven_wrapper_install_skiptest bonita-ui-designer ${STUDIO_UID_VERSION}
else
    echo "Skipping all build prior the Studio part"
fi

if [[ "${BONITA_BUILD_STUDIO_SKIP}" == "false" ]]; then
    build_maven_wrapper_verify_skiptest_with_profile bonita-studio mirrored,generate
else
    echo "Skipping the Studio build"
fi