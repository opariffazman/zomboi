#!/bin/bash
echo "checkModsNeedUpdate" > /opt/pzserver/zomboid.control
sleep 2
if tail $HOME/Zomboid/Logs/*DebugLog-server.txt -n 1 | grep -q updated; then
  echo 'false' # Mods are up to date
else
  echo 'true' # Mods need update
  $HOME/zomboi/scripts/startModsUpdate.sh
fi
