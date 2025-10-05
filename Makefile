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

build-airgapped: build-ag-1 build-ag-2

build-ag-1:
	systemctl stop ateabb || true
	systemctl stop firewalld || true
#	need to disable the container filewall rules to enable the build process to fetch files
	firewall-cmd --permanent --direct --remove-rules ipv4 filter DOCKER-USER || true
	firewall-cmd --reload || true
#	[ -e "$(FIREWALL_SCRIPT)" ] || install -m 0755 ./atea/firewall.sh "$(FIREWALL_SCRIPT)"
	[ -e "$(ATEABB_SERVICE_FILE)" ] || { cp ./atea/ateabb.service "$(ATEABB_SERVICE_FILE)"; systemctl enable "$(notdir $(ATEABB_SERVICE_FILE))" || systemctl enable "$(ATEABB_SERVICE_FILE)"; }

	install -d "$(dir $(DOCKER_DROPIN_SERVICE_FILE))"
	[ -e "$(DOCKER_DROPIN_SERVICE_FILE)" ] || cp "./atea/$(notdir $(DOCKER_DROPIN_SERVICE_FILE))" "$(DOCKER_DROPIN_SERVICE_FILE)"
	[ -e "$(DOCKER_DROPIN_SERVICE_FILE)" ] && mv "$(DOCKER_DROPIN_SERVICE_FILE)" "$(DOCKER_DROPIN_SERVICE_FILE).disabled" && systemctl daemon-reload || true

	systemctl daemon-reload
#	docker system prune -a --volumes --force
#	systemctl restart docker
	yarn cache clean
	yarn clean
	yarn install

build-ag-2:
	yarn build
	docker pull docker.io/curlimages/curl:latest
#	systemctl restart docker
	docker compose --env-file hosting/hosting.properties -f hosting/docker-compose.dev.yaml -f hosting/docker-compose.build.yaml create --build --remove-orphans
#	podman-compose --env-file hosting/hosting.properties -f hosting/docker-compose.dev.yaml -f hosting/docker-compose.build.yaml up --build --remove-orphans
	
	docker tag hosting-worker-service budibase/worker
	docker tag hosting-app-service budibase/apps
	docker tag budibase/couchdb:v3.3.3-sqs-v2.1.1 ibmcom/couchdb3
	# Restore drop-in if we had disabled it
	[ -e "$(DOCKER_DROPIN_SERVICE_FILE).disabled" ] && mv "$(DOCKER_DROPIN_SERVICE_FILE).disabled" "$(DOCKER_DROPIN_SERVICE_FILE)" && systemctl daemon-reload || true
	# systemctl start firewalld  # shouldn't need this
#	systemctl restart docker

	mkdir -p "$(BB_DIR)" || true
	yarn build:docker:airgap
	yarn build:docker:single

build-ag-3:
	mkdir -p "$(BB_DIR_LIVE)/bin" || true
	mv bb-airgapped.tar.gz "$(ATEABB_LIVE)"
	cp ./atea/*.sh "$(BB_DIR_LIVE)/bin" || true
	chmod 755 "$(BB_DIR_LIVE)/bin"/*.sh

	rm -rf "$(ATEABB_LIVE)/hosting"
	cd "$(ATEABB_LIVE)" && tar -xf bb-airgapped.tar.gz
	cd "$(BB_DIR_LIVE)" && echo "TZ=$$(timedatectl status | grep 'Time zone:' | awk '{print $$3}')" >> .env
	

	systemctl restart docker
	cd "$(BB_DIR_LIVE)" && for e in ./*.tar; do [ -e "$$e" ] || continue; docker load -i "$$e"; done

