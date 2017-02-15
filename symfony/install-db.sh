#!/usr/bin/env bash



php bin/console -q doctrine:database:create

php bin/console -q doctrine:generate:entities Ribase

php bin/console doctrine:schema:update --force

php bin/console cache:clear --env=prod
php bin/console cache:clear --env=dev