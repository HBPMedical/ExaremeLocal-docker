#!/bin/sh
#                    Copyright (c) 2016-2017
#   Data Intensive Applications and Systems Labaratory (DIAS)
#            Ecole Polytechnique Federale de Lausanne
#
#                      All Rights Reserved.
#
# Permission to use, copy, modify and distribute this software and its
# documentation is hereby granted, provided that both the copyright notice
# and this permission notice appear in all copies of the software, derivative
# works or modified versions, and any portions thereof, and that both notices
# appear in supporting documentation.
#
# This code is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. THE AUTHORS AND ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE
# DISCLAIM ANY LIABILITY OF ANY KIND FOR ANY DAMAGES WHATSOEVER RESULTING FROM THE
# USE OF THIS SOFTWARE.

usage() {
cat <<EOT
usage: $0 [-h|--help] (single|swarm target-node) <docker-compose command>
	-h, --help: show this message and exit
	single:	deploy on the local machine
	unsecured: deploy on the local machine without user credential checks
	swarm:	deploy on the node 'target-node' of the swarm cluster.
		docker-compose uses the environment to contact the appropriate
		docker daemon, so it must be correctly set.
	<docker-compose command>: This is forwarded as is to docker-compose

The following environment variables can be set to override defaults:
 - pg_data_root		Folder containing the PostgreSQL data
 - raw_data_root	Folder containing the raw data
 - raw_admin_root	Folder containing the administration configuration

Errors: This script will exit with the following error codes:
 1	No arguments provided
 2	First arguments is incorrect
 3	Missing arguments for Swarm invocation
EOT
}

if [ $# -lt 1 ]; then
    usage
    exit 1
fi

. ./env.sh

prepare_local_start() {
	# If default value, make sure the container can write.
	if [ "x${pg_data_root}" = "x${PWD}/data" ] ; then
		sudo chmod 777 data
	fi
	# Make sure the container has access to the log files
	test -d raw-admin/logs || mkdir raw-admin/logs
	touch raw-admin/logs/access.log
	touch raw-admin/logs/error.log
	chmod 666 raw-admin/logs/access.log
	chmod 666 raw-admin/logs/error.log
}

case $1 in
    -h|--help)
	usage
	exit 0
	;;

    [sS][wW][aA][rR][mM])
	shift
	if [ $# -lt 2 ]; then
		usage
		exit 3
	fi
	(
		export swarm_node=$1
		shift

		######EXAREME######
		CONSUL_URL=$(cat consul_url.conf)
		examaster=""
		NODENAME=n0
		if [ ${swarm_node} = "$NODENAME" ] ; then
			examaster="-examaster"
			VBoxManage controlvm $NODENAME natpf1 "Exareme Master,tcp,,9090,,9090" || true;
		fi
		sed -e "s,SWARMNODE,${swarm_node},g" docker-compose-swarm${examaster}.yml | sed -e "s,SET_CONSULURL,${CONSUL_URL},g" > docker-compose-node-${swarm_node}.yml
		##################

		# Adapt the environment variables which points to directories for data
		raw_data_root=/mnt/sda1/shared/datasets
		pg_data_root=/mnt/sda1/shared/data
		raw_admin_root=/mnt/sda1/shared/raw-admin
		raw_admin_conf=${raw_admin_root}/conf/nginx.conf
		raw_admin_htpasswd=${raw_admin_root}/conf/.htpasswd
		raw_admin_log=${raw_admin_root}/logs

		# If the node-only network doesn't exists, create it.
		# Start the services from the master node, so that overlay network definition are cluster wide.
		eval $(docker-machine env --swarm ${swarm_master})
		docker network ls | grep -q mip_net-federation || \
			docker network create -d overlay mip_net-federation
		#Workaround as placement constraints are not supported from docker-compose with docker swarm mode.
		eval $(docker-machine env ${swarm_node})
		docker-compose -f "docker-compose-node-${swarm_node}.yml" $@
	)
	;;

    single)
	shift
	prepare_local_start
	docker-compose -f docker-compose-single.yml $@
	;;

    unsecured)
	shift
	prepare_local_start
	docker-compose -f docker-compose.yml $@
	;;

    *)
	usage
	exit 2
	;;
esac
