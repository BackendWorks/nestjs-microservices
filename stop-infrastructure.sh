#!/bin/bash

# Script to stop modular infrastructure components in reverse order

# Stop components in the reverse order
echo "Stopping application services and API gateway..."
docker-compose -f application.docker-compose.yml down

echo "Stopping logging and monitoring services..."
docker-compose -f logging.docker-compose.yml down

echo "Stopping Kafka and messaging services..."
docker-compose -f kafka.docker-compose.yml down

echo "Stopping database services..."
docker-compose -f databases.docker-compose.yml down

# Optionally remove the network
read -p "Remove the shared network too? (y/n) " answer
if [ "$answer" = "y" ]; then
  echo "Removing network..."
  docker-compose -f network.docker-compose.yml down
fi

echo "Infrastructure shutdown complete!"