VOLUME_FOLDER		= /home/user/Desktop/inception/srcs/data

WP_VOLUME_FOLDER	= $(VOLUME_FOLDER)/wordpress
DB_VOLUME_FOLDER	= $(VOLUME_FOLDER)/db
WP_VOLUME_NAME		= wordpress_data
DB_VOLUME_NAME		= db_data

DOCKER_COMPOSE_FILE	= ./srcs/docker-compose.yml

up:
	if [ ! "$$(docker volume ls -q -f name=^$(WP_VOLUME_NAME)$$)" ]; then \
		docker volume create --name $(WP_VOLUME_NAME) --opt type=none --opt device=$(WP_VOLUME_FOLDER) --opt o=bind; \
	fi
	if [ ! "$$(docker volume ls -q -f name=^$(DB_VOLUME_NAME)$$)" ]; then \
		docker volume create --name $(DB_VOLUME_NAME) --opt type=none --opt device=$(DB_VOLUME_FOLDER) --opt o=bind; \
	fi
	docker compose -f $(DOCKER_COMPOSE_FILE) -p "inception" up -d

down:
	docker compose -f $(DOCKER_COMPOSE_FILE) -p "inception" down

peek:
	docker container ls -a
	docker network ls
	docker volume ls

clear:
	docker compose -f $(DOCKER_COMPOSE_FILE) -p "inception" down --rmi all -v
	rm -rf $(DB_VOLUME_FOLDER)/* $(DB_VOLUME_FOLDER)/.* 2>/dev/null || true
	rm -rf $(WP_VOLUME_FOLDER)/* $(WP_VOLUME_FOLDER)/.* 2>/dev/null || true
	if docker volume ls -q | grep -q '^db_data$$'; then \
		docker volume rm db_data; \
	fi
	if docker volume ls -q | grep -q '^wordpress_data$$'; then \
		docker volume rm wordpress_data; \
	fi

.PHONY: up down clear peek