ATEABB_HOME=/opt/ateabb

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
	docker tag budibase/couchdb:v3.3.3-sqs-v2.1.1 ibmcom/couchdb
	systemctl start firewalld
	yarn build:docker:airgap
	mv bb-airgapped.tar.gz "${ATEABB_HOME}" && cd "${ATEABB_HOME}"
	rm -rf hosting/scripts/bb-airgapped
	tar -xf bb-airgapped.tar.gz
	cd hosting/scripts/bb-airgapped
	sed -i '/image:/a\    pull_policy: never' docker-compose.yaml
	sed -i 's|.*budibase/couchdb.*|    image: ibmcom/couchdb:|g' docker-compose.yaml
	sed -i 's/BB_ADMIN_USER_EMAIL=/BB_ADMIN_USER_EMAIL=support@ateasystems.com/g' .env
	sed -i 's/BB_ADMIN_USER_PASSWORD=/BB_ADMIN_USER_PASSWORD=4734_Systems/g' .env
	sed -i 's/REDIS_PORT=6379/REDIS_PORT=6380/g' .env
	cat >> .env <<EOF
ENCRYPTION_KEY=4734_Systems
SELF_HOSTED=1
DISABLE_ACCOUNT_PORTAL=1
OFFLINE_MODE=1
ACCOUNT_PORTAL_URL=
BUDICLOUD_URL=
DEFAULT_LICENSE=""
EOF
	for e in *.tar; do docker load -i $e ; done





