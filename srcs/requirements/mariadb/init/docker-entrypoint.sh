#!/bin/bash
set -e

if [ ! -f "/var/lib/mysql/.initialized" ]; then
    mysqld --skip-networking --user=mysql &
    pid="$!"
    until mysqladmin ping --silent; do sleep 1; done

    for f in /docker-entrypoint-initdb.d/*; do
        bash "$f"
    done

    kill "$pid"
    wait "$pid"
    touch /var/lib/mysql/.initialized
fi

chown -R mysql:mysql /var/lib/mysql

exec mysqld --user=mysql
