# ATEABB - Build-single

Use `make build-airgapped` to build the multi-image version, then

```bash
yarn build:docker:single
```

This will create a docker image `ateabb/single`. You can start it with `docker run --name ateabb -p 10000:80 -p 15984:5984 ateabb/single`

## Export

```bash
docker save -o /tmp/ateabb-single.tar ateabb/single
zip /tmp/ateabb-single.zip -j /tmp/ateabb-single.tar ./atea/single/ateabb.service`
```

## Import

```bash
#you only have to create the volume on a new install..
docker volume create ateabb_data
unzip ateabb-single.zip -d /tmp
docker load -i /tmp/ateabb-single.tar && rm -f /tmp/ateabb-single.tar
mv /tmp/ateabb.service /etc/systemd/system
/usr/bin/docker create --name ateabb --mount type=volume,src=ateabb_data,dst=/data -p 10000:80 -p 15984:5984 -e ATEA_APP_MAP="ATEA_CFE_USER:BASIC:TEST,ATEA_CFE_POWER:POWER:TEST,ATEA_CFE_ADMIN:ADMIN:TEST" ateabb/single
```

Confirm ateabb is up and running, then...

```bash
docker down ateabb
systemctl enable ateabb
systemctl start ateabb
```
