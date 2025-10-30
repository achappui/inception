VOLUME_FOLDER		= /home/achappui/data

WP_VOLUME_FOLDER	= $(VOLUME_FOLDER)/wordpress
DB_VOLUME_FOLDER	= $(VOLUME_FOLDER)/db
WP_VOLUME_NAME		= wordpress_data
DB_VOLUME_NAME		= db_data

PROJECT_FOLDER		= ${shell basename $${PWD}}

DOCKER_COMPOSE_FILE	= ./srcs/docker-compose.yml

SECRET_FOLDER		= secrets

MARIADB_WORDPRESS_NAME_FILE		= ${SECRET_FOLDER}/mariadb_wordpress_name.txt
WORDPRESS_ADMIN_USER_FILE		= ${SECRET_FOLDER}/wordpress_admin_user.txt
MARIADB_WORDPRESS_USER_FILE		= ${SECRET_FOLDER}/mariadb_wordpress_user.txt
WORDPRESS_USER_FILE				= ${SECRET_FOLDER}/wordpress_user.txt

MARIADB_WORDPRESS_PASSWORD_FILE	= ${SECRET_FOLDER}/mariadb_wordpress_password.txt
WORDPRESS_ADMIN_PASSWORD_FILE	= ${SECRET_FOLDER}/wordpress_admin_password.txt
WORDPRESS_PASSWORD_FILE			= ${SECRET_FOLDER}/wordpress_password.txt

WORDPRESS_ADMIN_MAIL_FILE		= ${SECRET_FOLDER}/wordpress_admin_mail.txt
WORDPRESS_MAIL_FILE				= ${SECRET_FOLDER}/wordpress_mail.txt

NGINX_SERVER_CRT_FILE			= ${SECRET_FOLDER}/nginx_server_crt.txt
NGINX_SERVER_KEY_FILE			= ${SECRET_FOLDER}/nginx_server_key.txt

up:
	echo ${WORDPRESS_PASSWORD_FILE}
#Generate Names
	mkdir -p ${SECRET_FOLDER}
	if [ ! "$$(ls ${SECRET_FOLDER} | grep -w $$(basename ${MARIADB_WORDPRESS_NAME_FILE}))" ]; then \
		cat /dev/urandom | tr -dc 'a-z' | fold -w 5 | head -n 1 > ${MARIADB_WORDPRESS_NAME_FILE}; \
	fi

	if [ ! "$$(ls ${SECRET_FOLDER} | grep -w $$(basename ${WORDPRESS_ADMIN_USER_FILE}))" ]; then \
		cat /dev/urandom | tr -dc 'a-z' | fold -w 6 | head -n 1 > ${WORDPRESS_ADMIN_USER_FILE}; \
	fi

	if [ ! "$$(ls ${SECRET_FOLDER} | grep -w $$(basename ${MARIADB_WORDPRESS_USER_FILE}))" ]; then \
		cat /dev/urandom | tr -dc 'a-z' | fold -w 7 | head -n 1 > ${MARIADB_WORDPRESS_USER_FILE}; \
	fi

	if [ ! "$$(ls ${SECRET_FOLDER} | grep -w $$(basename ${WORDPRESS_USER_FILE}))" ]; then \
		cat /dev/urandom | tr -dc 'a-z' | fold -w 8 | head -n 1 > ${WORDPRESS_USER_FILE}; \
	fi
#Generate Passwords
	if [ ! "$$(ls ${SECRET_FOLDER} | grep -w $$(basename ${MARIADB_WORDPRESS_PASSWORD_FILE}))" ]; then \
		cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 6 | head -n 1 > ${MARIADB_WORDPRESS_PASSWORD_FILE}; \
	fi

	if [ ! "$$(ls ${SECRET_FOLDER} | grep -w $$(basename ${WORDPRESS_ADMIN_PASSWORD_FILE}))" ]; then \
		cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 7 | head -n 1 > ${WORDPRESS_ADMIN_PASSWORD_FILE}; \
	fi

	if [ ! "$$(ls ${SECRET_FOLDER} | grep -w $$(basename ${WORDPRESS_PASSWORD_FILE}$$))" ]; then \
		cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1 > ${WORDPRESS_PASSWORD_FILE}; \
	fi
#Generate Mails
	if [ ! "$$(ls ${SECRET_FOLDER} | grep -w $$(basename ${WORDPRESS_ADMIN_MAIL_FILE}))" ]; then \
		echo "$$(cat /dev/urandom | tr -dc 'a-z' | fold -w 7 | head -n 1)"@webforge.ch > ${WORDPRESS_ADMIN_MAIL_FILE}; \
	fi

	if [ ! "$$(ls ${SECRET_FOLDER} | grep -w $$(basename ${WORDPRESS_MAIL_FILE}))" ]; then \
		echo "$$(cat /dev/urandom | tr -dc 'a-z' | fold -w 8 | head -n 1)"@webforge.ch > ${WORDPRESS_MAIL_FILE}; \
	fi
#Generate Certificates
	if [ ! "$$(ls ${SECRET_FOLDER} | grep nginx)" ]; then \
		openssl req -x509 -newkey rsa:2048 -noenc -keyout ${NGINX_SERVER_KEY_FILE} -out ${NGINX_SERVER_CRT_FILE} -days 3650 -subj "/C=CH/ST=Vaud/L=Lausanne/O=webforge/OU=cyber/CN=achappui.42.fr" -addext "subjectAltName=DNS:achappui.42.fr,DNS:localhost,DNS:127.0.0.1"; \
	fi

	chown -R achappui:achappui ${SECRET_FOLDER}
	chmod 744 -R ${SECRET_FOLDER}

	if [ ! "$$(docker volume ls -q -f name=$(WP_VOLUME_NAME))" ]; then \
		mkdir -p ${WP_VOLUME_FOLDER}; \
		docker volume create --name $(WP_VOLUME_NAME) --opt type=none --opt device=$(WP_VOLUME_FOLDER) --opt o=bind; \
	fi
	if [ ! "$$(docker volume ls -q -f name=$(DB_VOLUME_NAME))" ]; then \
 		mkdir -p ${DB_VOLUME_FOLDER}; \
 		docker volume create --name $(DB_VOLUME_NAME) --opt type=none --opt device=$(DB_VOLUME_FOLDER) --opt o=bind; \
	fi
	docker compose -f $(DOCKER_COMPOSE_FILE) -p ${PROJECT_FOLDER} up -d

down:
	docker compose -f $(DOCKER_COMPOSE_FILE) -p ${PROJECT_FOLDER} down

peek:
	docker container ls -a
	docker network ls
	docker volume ls

clear:
	docker compose -f $(DOCKER_COMPOSE_FILE) -p ${PROJECT_FOLDER} down --rmi all -v
	rm -rf $(DB_VOLUME_FOLDER)/* $(DB_VOLUME_FOLDER)/.* 2>/dev/null || true
	rm -rf $(WP_VOLUME_FOLDER)/* $(WP_VOLUME_FOLDER)/.* 2>/dev/null || true
	if docker volume ls -q | grep -w -q 'db_data'; then \
		docker volume rm db_data; \
	fi
	if docker volume ls -q | grep -w -q 'wordpress_data'; then \
		docker volume rm wordpress_data; \
	fi

.PHONY: up down clear peek
