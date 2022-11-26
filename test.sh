docker run --rm -ti  --platform linux/arm64 -v $PWD/src:/src -e GATES=yes -e PDK_ROOT=/root/pdk davidsiaw/ocs sh -c 'cd /src && make'
