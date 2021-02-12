#!/usr/bin/bash

# Build Client
cd client
npm run build
cd ..

# Setup Database
cd server
docker-compose up -d db

# Build Server
go build -o mess
