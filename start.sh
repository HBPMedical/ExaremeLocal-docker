#!/bin/sh
usage() {
cat <<EOT
usage: $0 [-h|--help] <docker-compose command>
	-h, --help: show this message and exit
	<docker-compose command>:
	- localall: start ExaremeLocal and Raw
	- exalocal: start only ExaremeLocal
	- raw: starts one raw instance
	- dis: create the VMs used to simulate the distributed environment
	- startdis: start 2 Exareme workers, a master and 3 raw instances
	- stopdis: stop distributed 
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
    localall)
    shift
    docker stop exaremelocal 1>&- 2>&-
    docker stop raw-engine 1>&- 2>&-
    docker stop raw-ui 1>&- 2>&-
    docker rm exaremelocal 1>&- 2>&-
    docker rm raw-engine 1>&- 2>&-
    docker rm raw-ui 1>&- 2>&-
    ./start.sh unsecured up
    ;;
    exalocal)
    shift
    docker stop exaremelocal 1>&- 2>&-
    docker rm exaremelocal 1>&- 2>&-
    ./start.sh unsecured up exalocal
    ;;
    raw)
    shift
    docker stop raw-engine 1>&- 2>&-
    docker stop raw-ui 1>&- 2>&-
    docker rm raw-engine 1>&- 2>&-
    docker rm raw-ui 1>&- 2>&-
    ./start.sh unsecured up RawUI RawEngine
    ;;
    dis)
    shift   
    keystore=true
    managers=true
    shipyard=true
    ./vm-destroy.sh;
    ./vm-create.sh;
    eval $(docker-machine env --swarm m0)
    docker pull hbpmip/mipexareme
    #./start.sh swarm n0 up -d
    #./start.sh swarm n1 up -d
    #./start.sh swarm n2 up -d
    ;;
    startdis)
    shift   
    ./start.sh swarm n0 up -d
    ./start.sh swarm n1 up -d
    ./start.sh swarm n2 up -d
    ;;
    stopdis)
    shift   
    ./start.sh swarm n0 down 
    ./start.sh swarm n1 down 
    ./start.sh swarm n2 down 
    ;;
    *)
    usage
    exit 2
    ;;
esac

	

