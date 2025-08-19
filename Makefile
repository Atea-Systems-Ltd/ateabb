rebuild:
	systemctl stop ateabb
	yarn clean
	yarn install
	ATEA_APP_NAME="Saschas SSO Test app" ATEA_APP_UCMGROUP="ATEA_SCM_ADMIN" yarn build
	docker compose --env-file hosting/hosting.properties -f hosting/docker-compose.dev.yaml -f hosting/docker-compose.build.yaml create --build --remove-orphans
	systemctl start ateabb

rebuildnoclean:
	systemctl stop ateabb
	ATEA_APP_NAME="Saschas SSO Test app" ATEA_APP_UCMGROUP="ATEA_SCM_ADMIN" yarn build
	systemctl start ateabb
