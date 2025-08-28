ATEABB_HOME=/opt/ateabb
BB_DIR=${ATEABB_HOME}/hosting/scripts/bb-airgapped

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

build-airgapped:
	systemctl stop ateabb
	systemctl stop firewalld
	docker system prune -a --volumes --force
	systemctl restart docker
	yarn cache clean
	yarn clean
	yarn install
	yarn build
	docker pull curlimages/curl
	systemctl restart docker
	docker compose --env-file hosting/hosting.properties -f hosting/docker-compose.dev.yaml -f hosting/docker-compose.build.yaml create --build --remove-orphans
	docker tag hosting-worker-service budibase/worker
	docker tag hosting-app-service budibase/apps
	docker tag budibase/couchdb:v3.3.3-sqs-v2.1.1 ibmcom/couchdb3
	systemctl start firewalld
	systemctl restart docker
	mkdir -p "${BB_DIR}"
	yarn build:docker:airgap
	mv bb-airgapped.tar.gz "${ATEABB_HOME}"
	rm -rf "${ATEABB_HOME}/hosting"
	cd "${ATEABB_HOME}" && tar -xf bb-airgapped.tar.gz
	cd "${BB_DIR}" && sed -i '/LOG_LEVEL: trace/a\      ATEA_APP_MAP: "ATEA_FTR_USER:BASIC:ftr,ATEA_FTR_POWER:POWER:ftr,ATEA_FTR_ADMIN:ADMIN:ftr"' docker-compose.yaml 
	cd "${BB_DIR}" && sed -i '/image:/a\    pull_policy: never' docker-compose.yaml
	cd "${BB_DIR}" && sed -i 's|.*budibase/couchdb.*|    image: ibmcom/couchdb3|g' docker-compose.yaml
	cd "${BB_DIR}" && sed -i 's/BB_ADMIN_USER_EMAIL=/BB_ADMIN_USER_EMAIL=support@ateasystems.com/g' .env
	cd "${BB_DIR}" && sed -i 's/BB_ADMIN_USER_PASSWORD=/BB_ADMIN_USER_PASSWORD=4734_Systems/g' .env
	cd "${BB_DIR}" && sed -i 's/REDIS_PORT=6379/REDIS_PORT=6380/g' .env
	cd "${BB_DIR}" && echo "ENCRYPTION_KEY=4734_Systems" >> .env
	cd "${BB_DIR}" && echo "SELF_HOSTED=1" >> .env
	cd "${BB_DIR}" && echo "DISABLE_ACCOUNT_PORTAL=1" >> .env
	cd "${BB_DIR}" && echo "OFFLINE_MODE=1" >> .env
	cd "${BB_DIR}" && echo "ACCOUNT_PORTAL_URL=" >> .env
	cd "${BB_DIR}" && echo "BUDICLOUD_URL=" >> .env
	cd "${BB_DIR}" && echo "DEFAULT_LICENSE=" >> .env
	systemctl restart docker
	cd "${BB_DIR}" && for e in ./*.tar; do [ -e "$$e" ] || continue; docker load -i "$$e"; done
