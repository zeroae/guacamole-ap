#!/bin/bash

GUACAMOLE_PROPERTIES=~/.guacamole/guacamole.properties
GUACAMOLE_EXT=~/.guacamole/extensions
GUACAMOLE_LIB=~/.guacamole/lib

# Link guac to webapps
ln -sf /opt/guacamole/guacamole.war /usr/local/tomcat/webapps/


# Refresh the config file
until [[ `curl -s ${CONSUL}:8500/v1/health/state/passing | grep guacd` ]]
do
    echo "guacd is not healthy..."
    sleep 5
done


# Write the guacd configuration
consul-template \
    -once \
    -consul localhost:8500 \
    -template "${GUACAMOLE_PROPERTIES}.ctmpl:${GUACAMOLE_PROPERTIES}"
