#!/bin/bash
set -e

# Pastikan key aman
chmod 600 key.txt

# Kirim semua variabel environment langsung ke remote lewat SSH
ssh -i key.txt -T -p "${SERVER_PORT}" -o StrictHostKeyChecking=no "${SERVER_USERNAME}@${SERVER_HOST}" << EOF
set -e
cd ~/ecommerce_yahya

echo "==> Loading environment variables..."
set -a
source .env
set +a

echo "==> Docker login..."
echo "\$DOCKERHUB_TOKEN" | docker login -u "\$DOCKERHUB_USERNAME" --password-stdin

echo "==> Pulling image..."
docker pull "yahyaalamudin09/ecommerce:\$IMAGE_TAG"

if [ "\$(docker ps -qa -f name=\$CONTAINER_NAME)" ]; then
    echo "==> Container exists, removing..."
    docker stop "\$CONTAINER_NAME" || true
    docker rm "\$CONTAINER_NAME" || true
    docker system prune -af
fi

echo "==> Running new container..."
docker run -d --restart unless-stopped \
  -p "\$APP_PORT:\$APP_PORT" \
  --env-file .env \
  --name "\$CONTAINER_NAME" \
  "yahyaalamudin09/ecommerce:\$IMAGE_TAG"

docker ps
EOF
