#! /usr/bin/env bash

cd /app

until PGPASSWORD=postgres psql -h "database" -U "postgres" -c '\q'; do
    >&2 echo "Postgres is unavailable - sleeping"
    sleep 5
done

mix ecto.create
mix ecto.migrate
mix phx.server
