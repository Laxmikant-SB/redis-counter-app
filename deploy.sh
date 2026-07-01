#!/bin/bash
set -euo pipefail

# ── Config ─────────────────────────────────────
IMAGE="laxmikant07/redis-counter-app:latest"
APP_NAME="redis-counter-app"
REDIS_NAME="redis-server"
NETWORK_NAME="app-network"

echo "======================================"
echo " Deploying: $IMAGE"
echo " Time: $(date)"
echo "======================================"

# ── Pull latest image ─────────────────────────
echo "Pulling latest image..."
docker pull "$IMAGE"

# ── Create network if not exists ──────────────
docker network create "$NETWORK_NAME" 2>/dev/null || true

# ── Start Redis if not running ────────────────
if ! docker ps --format '{{.Names}}' | grep -q "^${REDIS_NAME}$"; then
    echo "Starting Redis..."
    docker run -d \
        --name "$REDIS_NAME" \
        --network "$NETWORK_NAME" \
        --restart unless-stopped \
        redis:7-alpine
else
    echo "Redis already running ✅"
fi

# ── Stop and remove old app container ─────────
if docker ps -a --format '{{.Names}}' | grep -q "^${APP_NAME}$"; then
    echo "Stopping old container..."
    docker stop "$APP_NAME" || true
    docker rm "$APP_NAME" || true
fi

# ── Start new container ───────────────────────
echo "Starting new container..."
docker run -d \
    --name "$APP_NAME" \
    --network "$NETWORK_NAME" \
    --restart unless-stopped \
    -e REDIS_HOST="$REDIS_NAME" \
    "$IMAGE"

# ── Verify deployment ─────────────────────────
sleep 3
if docker ps --format '{{.Names}}' | grep -q "^${APP_NAME}$"; then
    echo ""
    echo "✅ Deployment successful!"
    echo "Container: $(docker ps --filter name=$APP_NAME --format '{{.Status}}')"
else
    echo "❌ Deployment failed!"
    docker logs "$APP_NAME"
    exit 1
fi

echo "======================================"
