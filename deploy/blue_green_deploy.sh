#!/bin/bash

APP_NAME=blue-green-app
IMAGE_TAG=$1
BLUE_PORT=5001
GREEN_PORT=5002
HEALTH_URL="http://localhost"
NGINX_CONF="/etc/nginx/nginx.conf"

# Find which color is live
LIVE_COLOR=$(grep proxy_pass $NGINX_CONF | grep -oE 'blue|green')
IDLE_COLOR=$([ "$LIVE_COLOR" == "blue" ] && echo "green" || echo "blue")
IDLE_PORT=$([ "$IDLE_COLOR" == "blue" ] && echo $BLUE_PORT || echo $GREEN_PORT)

# Start new version on idle port
docker run -d --name ${APP_NAME}-${IDLE_COLOR} -e COLOR=${IDLE_COLOR} -p ${IDLE_PORT}:3000 myregistry/${APP_NAME}:${IMAGE_TAG}

# Health check
sleep 5
curl -f ${HEALTH_URL}:${IDLE_PORT}/health || { echo "Health check failed"; docker rm -f ${APP_NAME}-${IDLE_COLOR}; exit 1; }

# Switch NGINX
sed -i "s/proxy_pass http:\/\/${LIVE_COLOR}/proxy_pass http:\/\/${IDLE_COLOR}/" $NGINX_CONF
nginx -s reload

# Cleanup old container
docker rm -f ${APP_NAME}-${LIVE_COLOR}
