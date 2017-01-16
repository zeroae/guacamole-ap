#!/bin/bash

GUACAMOLE_PROPERTIES=~/.guacamole/guacamole.properties
GUACAMOLE_EXT=~/.guacamole/extensions
GUACAMOLE_LIB=~/.guacamole/lib

# Link guac to webapps
ln -sf /opt/guacamole/guacamole.war /usr/local/tomcat/webapps/


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
    -consul localhost:8500 \
    -template "${GUACAMOLE_PROPERTIES}.ctmpl:${GUACAMOLE_PROPERTIES}"

ln -sf /opt/guacamole/mysql/mysql-connector-*.jar "$GUACAMOLE_LIB"
ln -sf /opt/guacamole/mysql/guacamole-auth-*.jar "$GUACAMOLE_EXT"


