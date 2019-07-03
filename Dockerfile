FROM mysql:5.7.26 AS builder

MAINTAINER zema <zlobzn@gmail.com>

# ENV MYSQL_MAJOR 5.7
# ENV MYSQL_VERSION 5.7.26-1debian9
ENV MYSQL_VERSION_SHORT 5.7.26

RUN apt-get update \
    && apt-get install -y --no-install-recommends perl psmisc \
    && apt-get install -y --no-install-recommends wget ca-certificates build-essential cmake bison debhelper po-debconf lsb-release fakeroot \
    && apt-get install -y --no-install-recommends libaio-dev libncurses5-dev zlib1g-dev libnuma-dev libmecab-dev dh-systemd \
    && apt-get install -y --no-install-recommends dpkg-dev pkg-config

RUN echo "deb-src http://repo.mysql.com/apt/debian/ stretch mysql-${MYSQL_MAJOR}" >> /etc/apt/sources.list.d/mysql.list \
    && apt-get update

RUN mkdir -p /build \
    && cd /build \
    && apt-get source mysql-server="$MYSQL_VERSION" \
    && wget https://github.com/zobzn/sphinx/archive/mysqlse-mysql-5.7.tar.gz \
    && tar xfz mysqlse-mysql-5.7.tar.gz \
    && mv mysql-community-$MYSQL_VERSION_SHORT src-mysql-server \
    && mv sphinx-mysqlse-mysql-5.7 src-sphinx-mysqlse \
    && cp -R src-sphinx-mysqlse/mysqlse src-mysql-server/storage/sphinx \
    && cd /build/src-mysql-server \
    && cmake . -DBUILD_CONFIG=mysql_release -DENABLE_DOWNLOADS=1 -DDOWNLOAD_BOOST=1 -DWITH_BOOST=/build/boost \
    && cd /build/src-mysql-server/storage/sphinx \
    && make \
    && cp /build/src-mysql-server/storage/sphinx/ha_sphinx.so /usr/lib/mysql/plugin/ \
    && chown -R mysql:mysql /usr/lib/mysql \
    && chmod -R 644 /usr/lib/mysql/plugin/*.so \
    && cd / \
    && apt-get purge -y --auto-remove wget ca-certificates build-essential cmake bison debhelper po-debconf lsb-release fakeroot \
    && apt-get purge -y --auto-remove libaio-dev libncurses5-dev zlib1g-dev libnuma-dev libmecab-dev dh-systemd \
    && rm -rf /build \
    && rm -rf /var/lib/apt/lists/*

FROM mysql:5.7.26
COPY --from=builder /usr/lib/mysql/plugin/ha_sphinx.so /usr/lib/mysql/plugin/ha_sphinx.so

# apt-cache policy mysql-server
# docker build -t estua/mysql .
# docker push estua/mysql
#
# docker build -t friendlyhello .  # Create image using this directory's Dockerfile
# docker run -p 4000:80 friendlyhello  # Run "friendlyhello" mapping port 4000 to 80
# docker run -d -p 4000:80 friendlyhello         # Same thing, but in detached mode
# docker container ls                                # List all running containers
# docker container ls -a             # List all containers, even those not running
# docker container stop <hash>           # Gracefully stop the specified container
# docker container kill <hash>         # Force shutdown of the specified container
# docker container rm <hash>        # Remove specified container from this machine
# docker container rm $(docker container ls -a -q)         # Remove all containers
# docker image ls -a                             # List all images on this machine
# docker image rm <image id>            # Remove specified image from this machine
# docker image rm $(docker image ls -a -q)   # Remove all images from this machine
# docker login             # Log in this CLI session using your Docker credentials
# docker tag <image> username/repository:tag  # Tag <image> for upload to registry
# docker push username/repository:tag            # Upload tagged image to registry
# docker run username/repository:tag                   # Run image from a registry
