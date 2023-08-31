FROM ubuntu:22.04

# Example image creation:
#   docker build -t k8s-devops-tools .

# Example container creation:
#   Linux: docker run -d --name k8s-devops-tools -p 50080:80 -p 50443:443 -p 50434:1433 -v $(pwd)/nginx/webroot:/var/www/html -v $(pwd)/nginx/sites-available:/etc/nginx/sites-available -v $(pwd)/nginx/sites-enabled:/etc/nginx/sites-enabled -v $(pwd)/nginx/conf.d:/etc/nginx/conf.d -v $(pwd)/nginx/stream-conf.d:/etc/nginx/stream-conf.d -v $(pwd)/nginx/certs:/etc/nginx/certs janben/k8s-devops-tools
#   Windows Powershell: docker run -d --name k8s-devops-tools -p 50080:80 -p 50443:443 -p 50434:1433 -v ${PWD}/nginx/webroot:/var/www/html -v ${PWD}/nginx/sites-enabled:/etc/nginx/sites-enabled -v ${PWD}/nginx/sites-available:/etc/nginx/sites-available -v ${PWD}/nginx/conf.d:/etc/nginx/conf.d -v ${PWD}/nginx/stream-conf.d:/etc/nginx/stream-conf.d -v ${PWD}/nginx/certs:/etc/nginx/certs janben/k8s-devops-tools

# Labels
LABEL maintainer="jan.bentzer@ascom.com"
LABEL version="1.0"
LABEL description="This is a custom Docker Image primarily for developer/operations testing & troubleshooting in an K8S environment."

# Disable Prompt During Packages Installation
ARG DEBIAN_FRONTEND=noninteractive

# Environment variables
ENV nginx_conf_dir /etc/nginx
ENV supervisor_conf /etc/supervisor/supervisord.conf
ENV nginx_sites_available /etc/nginx/sites-available
ENV nginx_sites_enabled /etc/nginx/sites-enabled
ENV nginx_stream_conf /etc/nginx/stream-conf.d
ENV nginx_webroot /var/www/html
ENV php_conf /etc/php/8.1/fpm/php.ini

# Update Ubuntu Software repository
RUN apt update

# Install
RUN apt install -y dotnet-sdk-7.0 curl nginx php-fpm supervisor nano

# MSSQL client tools
RUN curl https://packages.microsoft.com/keys/microsoft.asc | tee /etc/apt/trusted.gpg.d/microsoft.asc
RUN curl https://packages.microsoft.com/config/ubuntu/22.04/prod.list > /etc/apt/sources.list.d/mssql-release.list
RUN apt update
RUN ACCEPT_EULA='Y' apt install -y mssql-tools18 unixodbc-dev
RUN echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> /root/bash_profile

RUN rm -rf /var/lib/apt/lists/*
RUN apt clean

# nginx conf
RUN mkdir /etc/nginx/stream-conf.d
RUN echo "\nstream {\n\tinclude /etc/nginx/stream-conf.d/*.conf;\n}" >> ${nginx_conf_dir}/nginx.conf
COPY ./nginx/stream-conf.d/sqlserver.conf ${nginx_stream_conf}
COPY ./nginx/sites-available/default ${nginx_sites_available}
#RUN ln -s ${nginx_sites_available}/default ${nginx_sites_enabled}/default
COPY ./nginx/webroot/index.html ${nginx_webroot}

# PHP conf
# Enable PHP-fpm on nginx virtualhost configuration
RUN sed -i -e 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' ${php_conf} && echo "\ndaemon off;" >> ${nginx_conf_dir}/nginx.conf
RUN mkdir -p /run/php
RUN chown -R www-data:www-data /var/www/html
RUN chown -R www-data:www-data /run/php

# Copy supervisor configuration
COPY supervisord.conf ${supervisor_conf}

# Volumes
VOLUME ["/etc/nginx/sites-enabled", "/etc/nginx/sites-available", "/etc/nginx/certs", "/etc/nginx/conf.d", "/var/log/nginx", "/etc/nginx/stream-conf.d", "/var/www/html"]

# Start script entry point
RUN echo "#!/bin/sh\n/usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf" >> ./start.sh
RUN chmod +x ./start.sh
CMD ["./start.sh"]

# Expose ports
EXPOSE 80
EXPOSE 443
EXPOSE 1433