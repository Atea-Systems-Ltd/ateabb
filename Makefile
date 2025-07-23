rebuild:
	systemctl stop ateabb
	yarn clean
	yarn install
	yarn build
	systemctl start ateabb


