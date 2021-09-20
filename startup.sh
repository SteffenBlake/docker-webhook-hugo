#!/bin/ash

# Webhook don't seem to currently support variables inside the json rules
# So we will string replace it in on boot before initializing webhook
sed -i -e "s;%HUGO_PUSH_SECRET%;${HUGO_PUSH_SECRET};g" /hooks/build.json

/usr/local/bin/webhook -verbose -hotreload -hooks /hooks/build.json