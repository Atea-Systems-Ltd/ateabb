.PHONY: rebuild rebuildnoclean build-airgapped build-ag-1 build-ag-2

ATEABB_HOME=/opt/ateabb
ATEABB_LIVE=/opt/ateabb-live
BB_SUBDIR=hosting/scripts/bb-airgapped
BB_DIR=${ATEABB_HOME}/${BB_SUBDIR}
BB_DIR_LIVE=${ATEABB_LIVE}/${BB_SUBDIR}
FIREWALL_SCRIPT=/usr/local/sbin/docker-private-egress.sh
ATEABB_SERVICE_FILE=/etc/systemd/system/ateabb.service
DOCKER_DROPIN_SERVICE_FILE=/etc/systemd/system/docker.service.d/10-egress-block.conf

rebuild:
	systemctl stop ateabb
	yarn clean
	yarn install
	yarn build
	docker compose --env-file hosting/hosting.properties -f hosting/docker-compose.dev.yaml -f hosting/docker-compose.build.yaml create --build --remove-orphans
	systemctl start ateabb

rebuildnoclean:
	systemctl stop ateabb
	ATEA_APP_NAME="Saschas SSO Test app" ATEA_APP_UCMGROUP="ATEA_SCM_ADMIN" yarn build
	systemctl start ateabb

build-single:
	yarn clean
	yarn install
	NX_DAEMON=false yarn build
	docker pull docker.io/curlimages/curl:latest
	docker compose --env-file hosting/hosting.properties -f hosting/docker-compose.dev.yaml -f hosting/docker-compose.build.yaml create --build --remove-orphans
	docker tag hosting-worker-service budibase/worker
	docker tag hosting-app-service budibase/apps
	docker tag budibase/couchdb:v3.3.3-sqs-v2.1.1 ibmcom/couchdb3
	yarn build:docker:airgap
	yarn build:docker:single

build-airgapped: build-ag-1 build-ag-2

build-ag-1:
	systemctl stop ateabb
	yarn cache clean
	yarn clean
	yarn install

build-ag-2:
	ATEA_APP_NAME="SSO Test app" ATEA_APP_UCMGROUP="ATEA_BB_ADMIN" NX_DAEMON=false yarn build
	docker pull docker.io/curlimages/curl:latest
	docker compose --env-file hosting/hosting.properties -f hosting/docker-compose.dev.yaml -f hosting/docker-compose.build.yaml create --build --remove-orphans
	
	docker tag hosting-worker-service budibase/worker
	docker tag hosting-app-service budibase/apps
	docker tag budibase/couchdb:v3.3.3-sqs-v2.1.1 ibmcom/couchdb3
	yarn build:docker:airgap
	yarn build:docker:single
	echo "Now attempting to create the container from the loaded image. "
	docker create --name ateabb -p 10000:80 -p 15984:5984 ateabb/single
	echo "Container should be created now. You can go ahead and start the service"

build-ag-3:
	echo "Under construction -"

