#!/usr/bin/env bash
set -euo pipefail

echo "Starting Render PHP + Jupyter..."

mkdir -p /home/jovyan/work
mkdir -p /tmp/nginx-client
mkdir -p /tmp/nginx-proxy
mkdir -p /tmp/nginx-fastcgi

# Start PHP-FPM
php-fpm -F -y /home/jovyan/php-fpm.conf &
PHP_PID=$!

# Start JupyterLab on internal port
start-notebook.py \
  --ServerApp.ip=127.0.0.1 \
  --ServerApp.port=8888 \
  --ServerApp.allow_remote_access=True \
  --ServerApp.root_dir=/home/jovyan/work &
JUPYTER_PID=$!

cleanup() {
  echo "Stopping services..."
  kill "$PHP_PID" "$JUPYTER_PID" 2>/dev/null || true
}

trap cleanup EXIT TERM INT

# Start Nginx on Render public port
nginx -c /home/jovyan/nginx.conf -g "daemon off;"
