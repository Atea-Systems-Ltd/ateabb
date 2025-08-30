## install ffmpeg

```
wget https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-linux64-gpl.tar.xz
```

## install nvm

```
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
```

## install node 22.16

```
nvm install 22.16
npm i -f yarn
npm i -g lerna
```

## create airgapped archive

```
zip -r /tmp/ateabb.zip \
	/opt/atea-mcr-helper \
	/opt/db-inserter \
	/opt/sip-recorder \
	/etc/atea/scripts/opidc-axl \
    /etc/atea/properties/traefik/budibase.toml \
    /etc/atea/properties/traefik/atea-mcr-helper.toml \
    /etc/atea/properties/traefik/oidcaxl.toml \
	/etc/default/oidc-axl.env \
	/etc/systemd/system/ateabb.service \
	/etc/systemd/system/iodcaxlcontroller.service \
	/etc/systemd/system/db-inserter.service \
	/etc/systemd/system/sip-recorder.service \
	/etc/systemd/system/atea-mcr-helper.service \
	/etc/systemd/system/compress-wav-files.service \
    /opt/ateabb/ateas \
	/opt/ateabb-live/bb-airgapped.tar.gz \
	/opt/ateabb-live/hosting/scripts/bb-airgapped/.env \
	/opt/ateabb-live/hosting/scripts/bb-airgapped/docker-compose.yaml
```
