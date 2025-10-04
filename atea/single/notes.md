# ATEABB - Build-single

1. Install docker, node(v22.16), yarn, lerna
2. If the firewall is blocking outbound connections rom containers it needs to be disabled

   ```bash
   firewall-cmd --permanent --direct --remove-rules ipv4 filter DOCKER-USER || true
   firewall-cmd --reload
   ```

3. git clone <https://github.com/Atea-Systems-Ltd/ateabb.git> && cd ateabb
4. node ./hosting/scripts/setup.js && yarn && yarn build
5. yarn build:docker:single

At this point you should see an image in docker:

```text
docker image ls
REPOSITORY      TAG       IMAGE ID       CREATED          SIZE
ateabb/single   latest    6836611821e5   25 minutes ago   1.72GB
```

You can start it with `docker run -p 10000:80 ateabb/single`

Configure the proxy to map to port 10000
