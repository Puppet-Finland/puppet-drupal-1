#!/usr/bin/env bash
#
# Drupal Install: https://www.drupal.org/docs/develop/local-server-setup/linux-development-environments/set-up-a-local-development-drupal-0-4

composer create-project drupal/recommended-project example.localhost -n
cd example.localhost
composer require drush/drush
composer require --dev drupal/core-dev
cd web
../vendor/bin/drush site-install --db-url=mysql://vagrant:vagrant@localhost/drupal
