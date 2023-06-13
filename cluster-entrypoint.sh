#!/bin/bash

set -e

# Get hostname from environment variable
HOSTNAME=`env hostname`

# Get erlang cookie from environment variable
ERLANG_COOKIE=`env ERLANG_COOKIE`

echo "Setting erlang cookie from ENV for host: " $HOSTNAME

echo $ERLANG_COOKIE > /var/lib/rabbitmq/.erlang.cookie

# Change .erlang.cookie permission
chmod 400 /var/lib/rabbitmq/.erlang.cookie

echo "Starting RabbitMQ Server For host: " $HOSTNAME

if [ -z "$JOIN_CLUSTER_HOST" ]; then
    /usr/local/bin/docker-entrypoint.sh rabbitmq-server &
    sleep 5
    rabbitmqctl wait /var/lib/rabbitmq/mnesia/rabbit\@$HOSTNAME.pid
else
    /usr/local/bin/docker-entrypoint.sh rabbitmq-server -detached
    sleep 5
    rabbitmqctl wait /var/lib/rabbitmq/mnesia/rabbit\@$HOSTNAME.pid
    rabbitmqctl stop_app
    rabbitmqctl join_cluster rabbit@$JOIN_CLUSTER_HOST
    rabbitmqctl start_app
fi

# Keep foreground process active ...
tail -f /dev/null
