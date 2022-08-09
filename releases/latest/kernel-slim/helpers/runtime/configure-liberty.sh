#!/bin/bash

# If the Liberty server name is not defaultServer and defaultServer still exists migrate the contents
if [ "$SERVER_NAME" != "defaultServer" ] && [ -d "/opt/ol/wlp/usr/servers/defaultServer" ] && [ ! -d "/opt/ol/wlp/usr/servers/$SERVER_NAME" ]; then
  # Create new Liberty server
  /opt/ol/wlp/bin/server create $SERVER_NAME

  # Delete old symlinks
  rm /opt/ol/links/output
  rm /opt/ol/links/config

  # Delete old output folder
  rm -rf /opt/ol/wlp/output/defaultServer
  
  # Add new output folder symlink
  mkdir -p /opt/ol/wlp/output/$SERVER_NAME
  ln -s $WLP_OUTPUT_DIR/$SERVER_NAME /opt/ol/links/output
  
  # Add new server symlink and populate folder
  ln -s /opt/ol/wlp/usr/servers/$SERVER_NAME /opt/ol/links/config
  mkdir -p /config/configDropins/defaults
  mkdir -p /config/configDropins/overrides
  # mkdir -p /config/dropins
  # mkdir -p /config/apps
  cp /opt/ol/wlp/usr/servers/defaultServer/configDropins/defaults/open-default-port.xml /config/configDropins/defaults 
  rm -rf /opt/ol/wlp/usr/servers/defaultServer
fi
