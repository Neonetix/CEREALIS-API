GREEN='\033[0;32m'
ORANGE='\033[0;33m'
NC='\033[0m'

envfile=".env"
if [ ! -e $envfile ]
then
  cp .env.dist .env
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i "" -e "s/HOST_UID=/HOST_UID=$(id -u)/" .env
    sed -i "" -e "s/HOST_GID=/HOST_GID=$(id -g)/" .env
  else
    sed -i "s/HOST_UID=/HOST_UID=$(id -u)/" .env
    sed -i "s/HOST_GID=/HOST_GID=$(id -g)/" .env
  fi
  echo -e "${ORANGE}Please take a look to the docker/dev/.env file.${NC}"
else
  echo -e "${GREEN}.env file does already exist.${NC}"
fi