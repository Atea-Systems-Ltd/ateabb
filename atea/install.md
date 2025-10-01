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
nvm install 22.16 # Not higher!
npm i -g yarn
npm i -g lerna
```

## additional dependencies

```
# as root
dnf groupinstall -y "Development Tools"
dnf install -y python3 python3-devel git
# verify
which g++ && g++ --version
```

If you're using podman:

```
sudo dnf -y install podman podman-compose
# sanity
podman --version
podman-compose --version
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
