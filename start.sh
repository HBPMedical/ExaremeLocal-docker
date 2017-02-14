#!/bin/sh
usage() {
cat <<EOT
usage: $0 [-h|--help] <docker-compose command>
	-h, --help: show this message and exit
	<docker-compose command>:
	- all: start ExaremeLocal and Raw
	- exalocal: start only ExaremeLocal

EOT
}

if [ $# -lt 1 ]; then
    usage
    exit 1
fi
cd RAW-deploy;
case $1 in
    -h|--help)
    usage
    exit 0
    ;;
    all)
    shift
    ./start.sh unsecured up
    ;;
    exalocal)
    shift
    ./start.sh unsecured up exalocal
    ;;
    *)
    usage
    exit 2
    ;;
esac

	

