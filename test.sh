docker run --rm -ti  --platform linux/arm64 -v $PWD/src:/src -e GATES=no -e PDK_ROOT=/opt/pdk davidsiaw/ocs bash -c 'cd /src && make'
