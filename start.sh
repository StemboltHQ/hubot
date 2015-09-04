#!/bin/bash
if [ -e ".hubotrc" ]; then
	set -a
	. .hubotrc
	set +a
fi

exec bin/hubot $HUBOT_ARGS
