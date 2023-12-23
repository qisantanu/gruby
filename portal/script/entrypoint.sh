#!/bin/sh

# Prepare PostgreSQL

if [ "$CONTAINER_ROLE" == "application" ]
then

  mkdir -p ./tmp/pids
  bundle exec puma -C /opt/app/portal/config/puma.rb
else
  echo "Error: unknown CONTAINER_ROLE"
  exit 125
fi
