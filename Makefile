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

buildonly:
	systemctl stop ateabb
	systemctl stop firewalld
	docker system prune -a --volumes --force
	yarn cache clean
	yarn clean
	yarn install
	ATEA_APP_NAME="Saschas SSO Test app" ATEA_APP_UCMGROUP="ATEA_SCM_ADMIN" yarn build
	docker pull curlimages/curl
	docker compose --env-file hosting/hosting.properties -f hosting/docker-compose.dev.yaml -f hosting/docker-compose.build.yaml create --build --remove-orphans
	docker tag hosting-worker-service budibase/worker
	docker tag hosting-app-service budibase/apps
	docker tag budibase/couchdb:v3.3.3-sqs-v2.1.1 ibmcom/couchdb3
	systemctl start firewalld
	yarn build:docker:airgap



