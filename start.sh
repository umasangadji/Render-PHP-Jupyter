#!/usr/bin/env bash
set -Eeuo pipefail

echo "======================================"
echo " Render PHP + Nginx + JupyterLab"
echo " Ubuntu 24.04 LTS"
echo "======================================"

PORT="${PORT:-10000}"
JUPYTER_PORT=8888
PHP_FPM_PORT=9000

# Check Jupyter authentication token
if [[ -z "${JUPYTER_TOKEN:-}" ]]; then
    echo "ERROR: JUPYTER_TOKEN is not configured."
    echo "Set JUPYTER_TOKEN in Render Environment."
    exit 1
fi

# Prepare writable directories
mkdir -p \
    /home/jovyan/work \
    /tmp/nginx-client \
    /tmp/nginx-proxy \
    /tmp/nginx-fastcgi \
    /tmp/nginx-uwsgi \
    /tmp/nginx-scgi

echo "[1/3] Starting PHP-FPM 8.3..."

php-fpm8.3 \
    --nodaemonize \
    --fpm-config /etc/php/8.3/fpm/php-fpm.conf &

PHP_PID=$!

echo "[2/3] Starting JupyterLab..."

jupyter lab \
    --ip=127.0.0.1 \
    --port="${JUPYTER_PORT}" \
    --no-browser \
    --ServerApp.base_url=/jupyter/ \
    --ServerApp.root_dir=/home/jovyan/work \
    --ServerApp.token="${JUPYTER_TOKEN}" \
    --ServerApp.allow_remote_access=True &

JUPYTER_PID=$!

cleanup() {
    trap - EXIT TERM INT

    echo "Stopping services..."

    kill -TERM \
        "${PHP_PID}" \
        "${JUPYTER_PID}" \
        "${NGINX_PID:-}" \
        2>/dev/null || true

    wait "${PHP_PID}" 2>/dev/null || true
    wait "${JUPYTER_PID}" 2>/dev/null || true

    if [[ -n "${NGINX_PID:-}" ]]; then
        wait "${NGINX_PID}" 2>/dev/null || true
    fi
}

trap cleanup EXIT
trap 'exit 143' TERM
trap 'exit 130' INT

echo "[3/3] Starting Nginx on port ${PORT}..."

nginx \
    -c /etc/nginx/nginx.conf \
    -g "daemon off;" &

NGINX_PID=$!

echo "======================================"
echo " Services started"
echo " PHP-FPM: 127.0.0.1:${PHP_FPM_PORT}"
echo " Jupyter: 127.0.0.1:${JUPYTER_PORT}"
echo " Nginx public port: ${PORT}"
echo "======================================"

# Stop the container if any main service exits
wait -n \
    "${PHP_PID}" \
    "${JUPYTER_PID}" \
    "${NGINX_PID}"

echo "A service has stopped. Shutting down."
exit 1
