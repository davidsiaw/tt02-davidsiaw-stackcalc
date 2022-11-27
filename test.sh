docker run --rm -ti  --platform linux/arm64 -v $PWD/src:/src -e GATES=yes -e PDK_ROOT=/opt/pdk -v /var/run/docker.sock:/var/run/docker.sock davidsiaw/ocs bash -c 'cd /src && make'
