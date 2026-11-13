
#!/usr/bin/env bash
set -e

mkdir -p /home/jovyan/work/phpwebsite

if [ ! -f /home/jovyan/work/phpwebsite/index.php ]; then
    cat > /home/jovyan/work/phpwebsite/index.php <<'PHP'
<?php
echo "<h1>PHP Server Render Berhasil!</h1>";
echo "<p>PHP Version: " . PHP_VERSION . "</p>";
PHP
fi

php -S 127.0.0.1:8080 \
    -t /home/jovyan/work/phpwebsite &
PHP_PID=$!

start-notebook.py \
    --ServerApp.ip=127.0.0.1 \
    --ServerApp.port=8888 \
    --ServerApp.allow_remote_access=True \
    --ServerApp.root_dir=/home/jovyan/work &
JUPYTER_PID=$!

cleanup() {
    kill "$PHP_PID" "$JUPYTER_PID" 2>/dev/null || true
}
trap cleanup EXIT TERM INT

nginx -c /home/jovyan/nginx.conf \
    -g 'daemon off;'
