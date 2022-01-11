DOCKER_DIR = docker/dev
DOCKER_ENV_FILE = ${DOCKER_DIR}/.env
-include .env
-include .env.local
-include ${DOCKER_DIR}/.env.dist
-include ${DOCKER_ENV_FILE}

IT = -it

PWD = $PWD
D = docker
DC = docker-compose -f ${DOCKER_DIR}/docker-compose.yml --project-directory ${DOCKER_DIR} -p ${DOMAIN_NAME}
CONSOLE_PHP = $(D) exec $(IT) $(APP_DOCKER_PHP_NAME) /bin/sh

.PHONY: show-help
show-help:
	@echo "$$(tput bold)Available tasks:$$(tput sgr0)";echo;sed -ne"/^## /{h;s/.*//;:d" -e"H;n;s/^## //;td" -e"s/:.*//;G;s/\\n## /---/;s/\\n/ /g;p;}" ${MAKEFILE_LIST}|LC_ALL='C' sort -f|awk -F --- -v n=$$(tput cols) -v i=29 -v a="$$(tput setaf 6)" -v z="$$(tput sgr0)" '{printf"%s%*s%s ",a,-i,$$1,z;m=split($$2,w," ");l=n-i;for(j=1;j<=m;j++){l-=length(w[j])+1;if(l<= 0){l=n-i-length(w[j])-1;printf"\n%*s ",-i," ";}printf"%s ",w[j];}printf"\n";}'

.PHONY: all
all: show-help

env: ${DOCKER_DIR}/.env.dist
	cd docker/dev && bash init.sh

.PHONY: ps
## docker-composer ps wrapper.
ps:
	$(DC) ps

.PHONY: install
## Install all the application dependencies across all the containers
install: start
	$(D) exec $(IT) $(APP_DOCKER_PHP_NAME) composer install --prefer-dist -o

.PHONY: logs
## docker-composer logs wrapper. Tails all containers logs
logs:
	$(DC) logs -f

.PHONY: start
## Starts the containers
start: env
	$(DC) up -d --build

.PHONY: exec
## Bash shell on the PHP and NODE container
exec: start
	$(CONSOLE_PHP)

.PHONY: stop
## Stops all containers
stop:
	$(DC) stop

.PHONY: tests
pt: tests
## Run phpunit test through app container
tests:
	$(D) exec $(IT) $(APP_DOCKER_PHP_NAME) sh -c " \
		rm -rf var/cache/test \
		; bin/console cache:warm -e test \
		&& vendor/bin/phpunit $(PHPUNIT_ARGS)"

.PHONY: opcache-dev
opcache-dev: env
	$(D) cp docker/common/php/opcache.ini $(APP_DOCKER_PHP_NAME):/usr/local/etc/php/conf.d/opcache.ini
	sed -i '/APP_ENV/c\APP_ENV=dev' .env.local
	sed -i '/APP_DEBUG/c\APP_DEBUG=1' .env.local
	rm .env.local.php
	$(D) exec $(IT) $(APP_DOCKER_PHP_NAME) rm var/cache/* -rf
	$(D) exec $(IT) $(APP_DOCKER_PHP_NAME) composer install
	$(D) exec $(IT) $(APP_DOCKER_PHP_NAME) cachetool.phar opcache:reset
	$(DC) restart php

.PHONY: opcache-reset
opcache-reset: env
	$(D) exec $(IT) $(APP_DOCKER_PHP_NAME) cachetool.phar opcache:reset