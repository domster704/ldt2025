#!/bin/bash

git reset --hard HEAD && git pull
git submodule update --init --remote

docker compose down &&
docker compose up --build -d

cd lct2025-backend
docker compose -f ./run/docker-compose.yml down && docker compose -f ./run/docker-compose.yml up --build -d