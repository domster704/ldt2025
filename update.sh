#!/bin/bash

git reset --hard HEAD && git pull
git submodule update --init --remote

docker compose down &&
docker compose up --build -d