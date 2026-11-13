FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Etc/UTC \
    PYTHONUNBUFFERED=1 \
    PORT=10000
# Install system packages, PHP 8.3, Nginx and Python
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        wget \
        git \
        unzip \
        zip \
        nano \
        bash \
        tini \
        nginx \
        python3 \
        python3-pip \
        python3-venv \
        php8.3-cli \
        php8.3-fpm \
        php8.3-common \
        php8.3-curl \
        php8.3-mbstring \
        php8.3-xml \
        php8.3-zip \
        php8.3-sqlite3 \
        php8.3-mysql \
        php8.3-pgsql \
        php8.3-gd \
        php8.3-intl \
        php8.3-bcmath \
        php8.3-opcache \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install JupyterLab in an isolated Python environment
RUN python3 -m venv /opt/jupyter && \
    /opt/jupyter/bin/pip install --no-cache-dir \
        jupyterlab \
        jupyter-server \
        ipykernel

ENV PATH="/opt/jupyter/bin:${PATH}"

# Create non-root user and directories
RUN useradd -m -s /bin/bash jovyan && \
    mkdir -p \
        /home/jovyan/work \
        /var/www/html \
        /tmp/nginx-client \
        /tmp/nginx-proxy \
        /tmp/nginx-fastcgi \
        /tmp/nginx-uwsgi \
        /tmp/nginx-scgi \
        /run/php \
    && chown -R jovyan:jovyan \
        /home/jovyan \
        /var/www/html \
        /run/php \
        /tmp/nginx-client \
        /tmp/nginx-proxy \
        /tmp/nginx-fastcgi \
        /tmp/nginx-uwsgi \
        /tmp/nginx-scgi

# Configure PHP-FPM to run without root privileges
RUN sed -i \
        's|^listen = .*|listen = 127.0.0.1:9000|' \
        /etc/php/8.3/fpm/pool.d/www.conf && \
    sed -i \
        's|^user = .*|user = jovyan|' \
        /etc/php/8.3/fpm/pool.d/www.conf && \
    sed -i \
        's|^group = .*|group = jovyan|' \
        /etc/php/8.3/fpm/pool.d/www.conf && \
    sed -i \
        's|^;*daemonize = .*|daemonize = no|' \
        /etc/php/8.3/fpm/php-fpm.conf && \
    sed -i 's|^;*pid = .*|pid = /tmp/php-fpm.pid|' /etc/php/8.3/fpm/php-fpm.conf && \
    sed -i 's|^pm.max_children = .*|pm.max_children = 2|' /etc/php/8.3/fpm/pool.d/www.conf && \
    sed -i 's|^pm.start_servers = .*|pm.start_servers = 1|' /etc/php/8.3/fpm/pool.d/www.conf && \
    sed -i 's|^pm.min_spare_servers = .*|pm.min_spare_servers = 1|' /etc/php/8.3/fpm/pool.d/www.conf && \
    sed -i 's|^pm.max_spare_servers = .*|pm.max_spare_servers = 1|' /etc/php/8.3/fpm/pool.d/www.conf

# Copy Nginx configuration and website files
COPY nginx.conf /etc/nginx/nginx.conf
COPY website/ /var/www/html/

# Copy startup script
COPY start.sh /usr/local/bin/start.sh

RUN chmod +x /usr/local/bin/start.sh && \
    chown -R jovyan:jovyan /var/www/html

# Use non-root user
USER jovyan

WORKDIR /home/jovyan/work

EXPOSE 10000

ENTRYPOINT ["/usr/bin/tini", "--"]

CMD ["/usr/local/bin/start.sh"]
