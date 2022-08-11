#!/bin/bash

# If the Liberty server name is not defaultServer and defaultServer still exists migrate the contents
if [ "$SERVER_NAME" != "defaultServer" ] && [ -d "/opt/ol/wlp/usr/servers/defaultServer" ]; then
  # Create new Liberty server
  /opt/ol/wlp/bin/server create --template=javaee8 >/tmp/serverOutput 
  ret=$?
  if [ $ret -ne 0 ]; then
    cat /tmp/serverOutput
    rm /tmp/serverOutput
    exit $ret
  fi
  rm /tmp/serverOutput

  # Verify server creation
  if [ ! -d "/opt/ol/wlp/usr/servers/$SERVER_NAME" ]; then
    echo "The server name contains a character that is not valid."
    exit 1
  fi

  # Delete old symlinks
  rm /opt/ol/links/output
  rm /opt/ol/links/config

  # Delete old output folder
  rm -rf /opt/ol/wlp/output/defaultServer
  
  # Add new output folder symlink
  mkdir -p $WLP_OUTPUT_DIR/$SERVER_NAME
  ln -s $WLP_OUTPUT_DIR/$SERVER_NAME /opt/ol/links/output
 
  # Add new server symlink and populate folder
  ln -s /opt/ol/wlp/usr/servers/$SERVER_NAME /opt/ol/links/config
  mkdir -p /config/configDropins/defaults
  mkdir -p /config/configDropins/overrides
  cp /opt/ol/wlp/usr/servers/defaultServer/configDropins/defaults/open-default-port.xml /config/configDropins/defaults 
  rm -rf /opt/ol/wlp/usr/servers/defaultServer
fi

exit 0
