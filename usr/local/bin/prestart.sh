#!/bin/bash

set -e

GUACAMOLE_HOME=$CATALINA_HOME/.guacamole
GUACAMOLE_PROPERTIES=$GUACAMOLE_HOME/guacamole.properties
GUACAMOLE_EXT=$GUACAMOLE_HOME/extensions
GUACAMOLE_LIB=$GUACAMOLE_HOME/lib

# Refresh the config file
until [[ `curl -s ${CONSUL}:8500/v1/health/state/passing | grep guacamole-server` ]]
do
    echo "guacamole-server is not healthy..."
    sleep 5
done

until [[ `curl -s ${CONSUL}:8500/v1/health/state/passing | grep mysql-primary` ]]
do
    echo "mysql-primary is not healthy..."
    sleep 5
done

# Write the guacamole-client configuration
consul-template \
    -once \
    -consul ${CONSUL}:8500 \
    -template "${GUACAMOLE_PROPERTIES}.ctmpl:${GUACAMOLE_PROPERTIES}.envsubst"
envsubst < ${GUACAMOLE_PROPERTIES}.envsubst > ${GUACAMOLE_PROPERTIES}

# Link guac to webapps
ln -sf /opt/guacamole/guacamole.war /usr/local/tomcat/webapps/

mkdir -p $GUACAMOLE_EXT
mkdir -p $GUACAMOLE_LIB
ln -sf /opt/guacamole/mysql/mysql-connector-*.jar "$GUACAMOLE_LIB"
ln -sf /opt/guacamole/mysql/guacamole-auth-*.jar "$GUACAMOLE_EXT"
