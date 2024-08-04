#!/bin/bash

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Stopping all BackendWorks Microservices...${NC}"

# Function to stop services from a specific docker-compose file
stop_services() {
    local compose_file="$1"
    local stack_name="$2"
    echo -e "${YELLOW}Stopping $stack_name services...${NC}"
    if docker compose -f "$compose_file" ps --services | grep -q .; then
        docker compose -f "$compose_file" stop
        echo -e "${GREEN}$stack_name services stopped successfully.${NC}"
    else
        echo -e "${YELLOW}No running services found for $stack_name.${NC}"
    fi
}

# Stop main services
stop_services "docker-compose.yml" "Main"

# Stop Grafana stack
stop_services "docker-compose.grafana.yml" "Grafana"

# Stop Local stack
stop_services "docker-compose.local.yml" "Local"

echo -e "${GREEN}All BackendWorks Microservices have been stopped.${NC}"
echo -e "${GREEN}Containers and data are preserved.${NC}"
echo -e "${GREEN}To start the services again, use 'sh scripts/start.sh'${NC}"