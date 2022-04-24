#!/bin/sh

# edit slack_webhook_url to the one provided by your slack app
slack_webhook_url="https://your.slack.webhook.url.com"

curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"${1}\"}" $slack_webhook_url
