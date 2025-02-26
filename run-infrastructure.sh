#!/bin/bash

# Script to run modular infrastructure components

# Create shared network first
echo "Setting up network..."
docker-compose -f network.docker-compose.yml up -d

# Start components in the correct order
echo "Starting database services..."
docker-compose -f databases.docker-compose.yml up -d

echo "Starting Kafka and messaging services..."
docker-compose -f kafka.docker-compose.yml up -d

echo "Starting logging and monitoring services..."
docker-compose -f logging.docker-compose.yml up -d

echo "Starting application services and API gateway..."
docker-compose -f application.docker-compose.yml up -d

echo "Infrastructure startup complete!"
echo "You can access:"
echo "- Grafana at http://localhost:3000 (admin/master123)"
echo "- Kafka UI at http://localhost:9090"
echo "- Kong Admin API at http://localhost:8001"
echo "- Application API Gateway at http://localhost:8000"