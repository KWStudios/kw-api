#!/bin/sh
git pull
bundle install
bundle exec passenger-config restart-app /var/www
