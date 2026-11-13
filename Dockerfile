FROM quay.io/jupyter/base-notebook:latest

# Install system packages as root during image build
USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        curl \
        wget \
        unzip \
        nano \
        ca-certificates \
        zip \
        nginx \
        php-cli \
        php-fpm \
        php-common \
        php-curl \
        php-mbstring \
        php-xml \
        php-zip \
        php-sqlite3 \
        php-mysql \
        php-pgsql \
        php-gd \
        php-intl \
        php-bcmath \
        php-opcache \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Verify PHP and Nginx are installed during build
RUN php -v && nginx -v

# Return to the normal Jupyter user
USER ${NB_UID}

# Set working directory
WORKDIR /home/jovyan

# Render web service port
EXPOSE 10000

# Start Jupyter Notebook
CMD ["start-notebook.py", \
     "--ServerApp.ip=0.0.0.0", \
     "--ServerApp.port=10000", \
     "--ServerApp.allow_remote_access=True", \
     "--ServerApp.root_dir=/home/jovyan/work"]
