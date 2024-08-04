#!/bin/bash

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to prompt for input if variable is not set
prompt_if_empty() {
    local var_name="$1"
    local prompt_message="$2"
    if [ -z "${!var_name}" ]; then
        read -p "$prompt_message: " $var_name
    fi
}

# Check and prompt for AWS credentials
prompt_if_empty AWS_ACCESS_KEY_ID "Enter your AWS Access Key ID"
prompt_if_empty AWS_SECRET_ACCESS_KEY "Enter your AWS Secret Access Key"
prompt_if_empty AWS_REGION "Enter your AWS Region"
prompt_if_empty AWS_ACCOUNT_ID "Enter your AWS Account ID"

# Export AWS credentials
export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_REGION

# Function to log in to AWS ECR
aws_ecr_login() {
    echo -e "${YELLOW}>>> Logging into AWS ECR${NC}"
    aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"
    if [ $? -ne 0 ]; then
        echo -e "${RED}>>> AWS ECR login failed${NC}" >&2
        exit 1
    fi
}

# Function to build and push the Docker image
build_and_push_image() {
    local service_name="$1"
    local image_name="nestjs_${service_name}:latest"
    local ecr_image_uri="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/${service_name}:latest"

    echo -e "${YELLOW}>>> Building ${image_name}${NC}"
    docker build -t "$image_name" -f "${service_name}/Dockerfile" "$service_name"
    if [ $? -ne 0 ]; then
        echo -e "${RED}>>> Failed to build image ${image_name}${NC}" >&2
        return 1
    fi

    echo -e "${YELLOW}>>> Tagging ${image_name}${NC}"
    docker tag "$image_name" "$ecr_image_uri"

    echo -e "${YELLOW}>>> Pushing ${image_name}${NC}"
    docker push "$ecr_image_uri"
    if [ $? -ne 0 ]; then
        echo -e "${RED}>>> Failed to push image ${image_name}${NC}" >&2
        return 1
    fi

    echo -e "${GREEN}>>> Deployment completed for ${service_name}${NC}"
}

# Get list of services
services=($(ls -d */ | cut -f1 -d'/'))

# Remove 'fluent-bit' from the list if it exists
services=(${services[@]/fluent-bit})

# Prompt the user to select services
echo "Please select services to deploy (space-separated numbers, or 'all'):"
select service in "${services[@]}" "all"; do
    if [[ "$service" == "all" ]]; then
        selected_services=("${services[@]}")
        break
    elif [[ -n "$service" ]]; then
        selected_services+=("$service")
    fi
    if [[ "${#selected_services[@]}" -eq 0 ]]; then
        echo "No valid selection. Please try again."
    else
        break
    fi
done

# Log in to AWS ECR
aws_ecr_login

# Deploy selected services
for service in "${selected_services[@]}"; do
    if [ ! -e "${service}/Dockerfile" ]; then
        echo -e "${RED}>>> Dockerfile not found for service ${service}${NC}" >&2
        continue
    fi
    echo -e "${YELLOW}>>> Deploying service ${service}...${NC}"
    build_and_push_image "$service"
done

echo -e "${GREEN}>>> All selected services have been processed${NC}"