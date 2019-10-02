#!/bin/bash
cd /home/ubuntu/
rm -rf tricksvibe
git init
git clone https://hyeAkki:Akki123%40%23@github.com/hyeAkki/tricksvibe.git
cd tricksvibe
rm -rf yamls
chown -R www-data:www-data wordpress/*
find wordpress -type d -exec chmod 755 {} \;
find wordpress -type f -exec chmod 644 {} \;

