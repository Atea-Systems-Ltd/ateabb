.PHONY: rebuild rebuildnoclean build-airgapped build-ag-1 build-ag-2
PYTHON=/usr/bin/python3.12
ATEABB_HOME=/opt/ateabb
BB_SUBDIR=hosting/scripts/bb-airgapped
ATEABB_SERVICE_FILE=ateabb.service
ARCHIVE_PATH=/atea/tmp

clean-docker:
	-docker stop $$( docker ps -a -q )
	-docker container rm $$( docker container ls -a -q )
	-docker image rm -f $$(docker image ls -q )

clean:
	yarn clean

build:
	scl enable gcc-toolset-12 'PYTHON=$(PYTHON) npm_config_python=$(PYTHON) yarn install'
	yarn build
	docker compose --env-file hosting/hosting.properties -f hosting/docker-compose.dev.yaml -f hosting/docker-compose.build.yaml create --build --remove-orphans
	yarn build:docker:single
	docker tag budibase:latest budibase/budibase
	yarn build:docker:airgap:single
	mv $(BB_SUBDIR)/budibase.tar $(ARCHIVE_PATH)/ateabb-$$(jq -r '.version' lerna.json).tar

