#!/bin/bash

git reset --hard HEAD && git pull
git submodule update --init --remote

sudo docker compose -f ./docker-compose.yml down &&
sudo docker compose -f ./docker-compose.yml up --build -d

cd lct2025-backend
sudo docker compose -f ./run/docker-compose.yml down &&
 sudo docker compose -f ./run/docker-compose.yml up --build -d
