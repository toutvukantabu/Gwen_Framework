# Parameters
SHELL               	= bash
PROJECT             	= gwen_framework_app_1
SERVER                  = nginx
MYSQL  					= db
MAKEFILE_AUTHOR     	= Gwendal Bescont
HTTP_PORT               = 80

# Executables
EXEC_PHP      = php
COMPOSER      = composer
GIT           = git

# Alias
PHP			  = $(EXEC_PHP) bin/console
# if you use php you can replace "with: $(EXEC_PHP) bin/console"

# Executables: local only
apt-get       = sudo apt-get
DOCKER        = docker
DOCKER_COMP   = docker-compose

# Misc
.DEFAULT_GOAL = help
.PHONY       = 

# Help message bash
define message-bash-mysql = 

 ——————————————————————————————————————————————————————————————————————————————
						 INFOS DE CONNEXION :
 ——————————————————————————————————————————————————————————————————————————————

 pour se connecter à mysql en root :  1-> GWEN_FRAMEWORK:     mysql -u root -p db_GWEN_FRAMEWORK
			
 password : pattern

endef

message-mysql:; @ $(info $(message-bash-mysql)) :

##——————————————————————————————————————————————————————————————————————————————
##                 **  VIEW FULL COMMAND  ** 
##——————————————————————————————————————————————————————————————————————————————

help: ## Outputs this help screen (viw full commands tape: make help )
	@grep -E '(^[a-zA-Z0-9_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}{printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'
##——————————————————————————————————————————————————————————————————————————————
##                    **   DOCKER  ** 
##——————————————————————————————————————————————————————————————————————————————

up: ## Starting docker hub 
	$(DOCKER_COMP) up -d

docker-build: ## Building docker images
	$(DOCKER_COMP) build 

down: ## Down docker hub
	$(DOCKER_COMP) down

restart: ## restarting docker containers 
	$(DOCKER_COMP) restart $$(docker  -l -c )	

##——————————————————————————————————————————————————————————————————————————————
##                  **    Deleting container|volume|image commands **  
##——————————————————————————————————————————————————————————————————————————————

destroy: ## destroying  docker containers
	$(DOCKER_COMP) rm -v --force --stop || true

prune: ## removing all stopped containers 
	@docker system prune -a --volumes

delete-containers: ## deleting docker container
	$(Docker) rm -vf --force

big-daddy:  destroy prune delete-containers  ## delete all container, image, environment

	
##——————————————————————————————————————————————————————————————————————————————
##                       **  MYSQL  **
##——————————————————————————————————————————————————————————————————————————————A

dump:delete  ## Dump db and remove old_bdd.sql
	${DOCKER} exec -i ${EXTRANET} mysqldump -u root -pexample db_GWEN_FRAMEWORK.sql > .config/Database/db_GWEN_FRAMEWORK.sql

delete: 
	@rm  .config/Database/db_GWEN_FRAMEWORK.sql

##——————————————————————————————————————————————————————————————————————————————
##                        **  LOGS  **
##——————————————————————————————————————————————————————————————————————————————

logs-project: ##   container logs
	@docker logs $(PROJECT) 

logs-mysql: ##  MYSQL container logs
	@docker logs $(MYSQL)
##——————————————————————————————————————————————————————————————————————————————
##                       **   BASH ** 
##——————————————————————————————————————————————————————————————————————————————

project: ## Connecting to GWEN_FRAMEWORK container
	$(DOCKER) exec -it  -w  /var/www/html $(PROJECT)  sh

mysql:message-mysql ## Connecting to  MYSQL MYSQL_container
	$(DOCKER) exec -it  $(MYSQL) mysql -u root -pexample db_extranet

##——————————————————————————————————————————————————————————————————————————————
##         **   STARTING // RE-BUILD // STOPPING // DUMP-AUTOLOAD ** 
##——————————————————————————————————————————————————————————————————————————————


build: docker-build up  ## Build project, Install vendors according to the current composer.lock file, create  environment

stop:  down   ## , delete-environment, stop docker

hard-reset: stop big-daddy  build  ## , stop, delete all docker files , restart project , create environment

autoload: ## dump-autoload all containers
	@docker exec -it -w /app/ $(PROJECT) $(COMPOSER) dump-autoload -o

cc: ## Clear the cache. DID YOU CLEAR YOUR CACHE????
	$(DOCKER) exec -i $(PROJECT) $(PHP) c:c

