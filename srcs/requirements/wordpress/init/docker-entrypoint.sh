#!/bin/bash
set -e

for f in /docker-entrypoint-initwp.d/*; do
    bash "$f"
done

exec php-fpm8.2 -F
