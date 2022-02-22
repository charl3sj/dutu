#!/usr/bin/env bash
set -e

echo "Installing Javascript packages..."
cd assets
npm i
cd -

echo "Building docker image..."
docker-compose build

echo "Fetching dependencies..."
./mix deps.get

echo "Initializing database..."
./mix ecto.setup

echo
