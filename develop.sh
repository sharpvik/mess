#!/usr/bin/bash



# Setup

if [ ! -f ".env" ]; then
	./setup.sh
fi



# Build the client

cd client
./build.sh
cd ..



# Start the database in detached (background) mode

docker-compose up -d db



# Start the server

go run main.go --dev

# Use Ctrl + C to kill the process and proceed to the next step



# Stop the database

docker stop mess_db
