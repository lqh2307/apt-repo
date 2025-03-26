ARG TARGET_IMAGE=ubuntu:24.04

FROM ${TARGET_IMAGE}

RUN \
  apt-get -y update \
  && apt-get -y upgrade \
  && apt-get -y update \
  && apt-get -y install 
    dpkg-dev \
    nginx \
    apt-utils \
    apt-rdepends \
    && apt-get -y --purge autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html/apt-repo/packages

RUN apt-rdepends vim git wget htop cmake build-essential libproj-dev libproj25 osmosis | \
  grep -v "^ " | xargs apt download -o=dir::cache=./ && \
  dpkg-scanpackages . /dev/null | gzip -9 > Packages.gz

RUN \
  echo 'server { \
  listen 80; \
  server_name localhost; \
  root /var/www/html/apt-repo; \
  autoindex on; \
}' > /etc/nginx/sites-available/default

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
