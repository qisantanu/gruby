#!/bin/sh

# Prepare PostgreSQL
until nc -z -v -w30 $DB_HOST $DB_PORT
do
  echo 'Waiting for PostgreSQL...'
  sleep 1
done
echo "PostgreSQL is up and running"

if [ "$CONTAINER_ROLE" == "worker" ]
then
  # Run background worker
  bundle exec shoryuken -r ./app/jobs -R -C ./config/shoryuken.yml -v
elif [ "$CONTAINER_ROLE" == "application" ]
then
  if [ "$RUN_DB_MIGRATIONS" == "true" ]
  then
    echo "Setup db..."
    bundle exec rails db:create db:migrate 2>/dev/null
    echo "Database is ready!"
  fi

  if [ "$RUN_SEED" == "true" ]
  then
    echo "Run seeds..."
    bundle exec rails db:seed
    echo "Seed is done!"
  fi

  mkdir -p ./tmp/pids
  bundle exec puma -C /opt/app/portal/config/puma.rb
else
  echo "Error: unknown CONTAINER_ROLE"
  exit 125
fi
