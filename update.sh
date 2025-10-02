#!/bin/bash

git reset --hard HEAD && git pull
git submodule update --init --remote

sudo docker compose down &&
sudo docker compose up --build -d

cd lct2025-backend
sudo docker compose -f ./run/docker-compose.yml down && sudo docker compose -f ./run/docker-compose.yml up --build -d