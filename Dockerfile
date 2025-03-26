ARG TARGET_IMAGE=ubuntu:24.04

FROM ${TARGET_IMAGE}

RUN \
  apt-get -y update \
  && apt-get -y upgrade \
  && apt-get -y install \
    dpkg-dev \
    nginx \
    apt-utils \
    apt-rdepends

WORKDIR /var/www/html/apt-repo/packages

RUN \
  apt-rdepends \
    vim \
    cmake \
    build-essential \
    gdal-bin \
    libproj-dev \
    libproj25 \
    osmosis \
    | grep -v "^ " > /tmp/package_list.txt

RUN \
  for pkg in $(cat /tmp/package_list.txt); do \
    if apt-cache show "$pkg" > /dev/null 2>&1; then \
      apt-get download -o=dir::cache=./ "$pkg"; \
    else \
      echo "$pkg not found. Skip..."; \
      sleep 10; \
    fi; \
  done \
  && rm -rf /tmp/package_list.txt

RUN \
  dpkg-scanpackages . /dev/null | gzip -9 > Packages.gz

RUN \
  echo 'server { \
  listen 8080; \
  server_name localhost; \
  root /var/www/html/apt-repo; \
  autoindex on; \
}' > /etc/nginx/sites-available/default

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
