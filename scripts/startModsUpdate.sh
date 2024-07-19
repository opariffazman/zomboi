#!/bin/bash

# Load environment variables from .env file
source $HOME/zomboi/scripts/.env

send_discord_message() {
    local message="$1"
    local webhook_url="$2"
    local payload="{
        \"content\": \"$message\"
    }"

    echo "webhook url: $webhook_url"
    echo "message: $message"
    echo "sending discord message: $message to webhook"

    curl -H "Content-Type: application/json" -d "$payload" "$webhook_url"
}

# Notify users that the server will be shutting down in 60 seconds
echo "server will be shutting down in 60 seconds"
send_discord_message "$NOTICE_MESSAGE" "$NOTICE_WEBHOOK"
echo "servermsg 60-secs-remaining" > /opt/pzserver/zomboid.control
sleep 60

# Notify users that the server is shutting down
echo "server is shutting down"
send_discord_message "$QUIT_MESSAGE" "$QUIT_WEBHOOK"
echo "quit" > /opt/pzserver/zomboid.control
ZPID=$(pidof ProjectZomboid64)
while [ -e /proc/$ZPID ]; do
    sleep 1
done

# Notify users that the server is updating
echo "server is updating"
send_discord_message "$UPDATE_MESSAGE" "$UPDATE_WEBHOOK"
steamcmd +runscript $HOME/update_zomboid.txt

# Notify users that the server is starting up
echo "server is starting up"
send_discord_message "$START_MESSAGE" "$START_WEBHOOK"
systemctl start zomboid.socket
LOGS="RCON: listening on port 27015."
LOG_TRUE=$(grep "$LOGS" $HOME/Zomboid/Logs/*DebugLog-server.txt)

while [ -z "$LOG_TRUE" ]; do
    sleep 1
    LOG_TRUE=$(grep "$LOGS" $HOME/Zomboid/Logs/*DebugLog-server.txt)
done

# Notify users that the server is up and running
echo "server is up and running"
send_discord_message "$READY_MESSAGE" "$READY_WEBHOOK"
