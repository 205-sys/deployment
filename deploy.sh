#!/bin/bash
set -euo pipefail

APP_DIR="/home/ubuntu/app"
ECR_REGION="ap-southeast-1"
ECR_REPO="654654304243.dkr.ecr.ap-southeast-1.amazonaws.com"
DEPLOY_LOG="$APP_DIR/deployment_logs.txt"

cd "$APP_DIR"

aws ecr get-login-password --region "$ECR_REGION" | \
    docker login --username AWS --password-stdin "$ECR_REPO"

if [[ -z "${IMAGE:-}" ]]; then
    echo "Error: IMAGE variable is not set"
    exit 1
fi

yq e ".services.\"$SERVICE_NAME\".image = \"$IMAGE\"" -i docker-compose.yml

docker compose pull "$SERVICE_NAME"
docker compose up -d "$SERVICE_NAME"

datetime=$(date "+%Y-%m-%d %H:%M:%S")
echo "$datetime, Service: $SERVICE_NAME, Image: $IMAGE" >> "$DEPLOY_LOG"