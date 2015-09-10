#!/bin/bash
if [ -e ".hubotrc" ]; then
	set -a
	. .hubotrc
	set +a
fi

export PATH="node_modules/.bin:node_modules/hubot/node_modules/.bin:$PATH"
export FILE_BRAIN_PATH="/var/lib/hubot"

exec node_modules/.bin/hubot $HUBOT_ARGS
