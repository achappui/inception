FROM debian:12.12

RUN apt-get update && \
    apt-get install -y mariadb-server && \
    rm -rf /var/lib/apt/lists/*

VOLUME /var/lib/mysql

WORKDIR /usr/local/bin

COPY init/docker-entrypoint.sh docker-entrypoint.sh

RUN chmod +x docker-entrypoint.sh

WORKDIR /docker-entrypoint-initdb.d

COPY init/init-db.sh init-db.sh

RUN chmod +x init-db.sh

WORKDIR /etc/mysql/mariadb.conf.d

COPY conf/50-server.cnf 50-server.cnf

WORKDIR /run/mysqld

RUN chown mysql:mysql /run/mysqld

EXPOSE 3306

ENTRYPOINT ["docker-entrypoint.sh"]
