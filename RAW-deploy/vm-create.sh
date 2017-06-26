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

set -e
: ${CONSULPORT:=8500}
: ${SHIPYARDPORT:=9000}
: ${SLAVEPORT:=2376}
: ${MASTERPORT:=3376}

: ${KEYSTORE:=ks}
: ${MANAGER:=m0}

: ${keystore:=false}
: ${masters:=false}
: ${shipyard:=false}

# Keystore
if $keystore
then
(
	docker-machine create -d virtualbox \
	    --virtualbox-memory 512 \
	    --virtualbox-disk-size 8192 \
	    --engine-label "eu.hbp.name=$KEYSTORE" \
	    --engine-label "eu.hbp.function=keystore" \
	    $KEYSTORE
	eval $(docker-machine env $KEYSTORE)
	docker run --restart=unless-stopped -d --name swarm-keystore -p $CONSULPORT:$CONSULPORT progrium/consul -server -bootstrap
	curl $(docker-machine ip $KEYSTORE):$CONSULPORT/v1/catalog/nodes
    ####ΕΧΑΡΕΜΕ####    
    echo "$(docker-machine ip $KEYSTORE):$CONSULPORT" > consul_url.conf
    ###############    
)
fi

#	    --swarm-addr $(docker-machine ip $NODENAME):$MASTERPORT \
# Manager HA
if $masters
then
	for NODENAME in $MANAGER m1
	do
	    (
		docker-machine create -d virtualbox \
		    --virtualbox-memory 512 \
		    --virtualbox-disk-size 8192 \
		    --swarm \
		    --swarm-master \
		    --swarm-host "tcp://0.0.0.0:$MASTERPORT" \
		    --swarm-opt replication \
		    --swarm-discovery "consul://$(docker-machine ip $KEYSTORE):$CONSULPORT" \
		    --engine-label "eu.hbp.name=$NODENAME" \
		    --engine-label "eu.hbp.function=manager" \
		    --engine-opt="cluster-store=consul://$(docker-machine ip $KEYSTORE):$CONSULPORT" \
		    --engine-opt="cluster-advertise=eth1:$MASTERPORT" $NODENAME
#		VBoxManage controlvm $v natpf1 "Consul,tcp,,$CONSULPORT,,$CONSULPORT"

# This is when manually starting the docker-swarm container
	if false
	then
		eval $(docker-machine env $NODENAME)
		docker run --restart=unless-stopped -d -p $MASTERPORT:$MASTERPORT \
			--name swarm-controller \
			-v /var/lib/boot2docker:/certs:ro \
			swarm manage -H 0.0.0.0:$MASTERPORT \
			--tlsverify \
			--tlscacert=/certs/ca.pem \
			--tlscert=/certs/server.pem \
			--tlskey=/certs/server-key.pem \
			--replication --advertise $(docker-machine ip $NODENAME):$MASTERPORT \
			consul://$(docker-machine ip $KEYSTORE):$CONSULPORT
	fi
	    )
done
fi

# Start Shipyard (Web UI)
if ${shipyard}
then
    (
	# This has to run on a node of the Swarm Cluster, so put it on
	# the main master by default
	eval $(docker-machine env $MANAGER)

	# Add Shipyard controller here as well
	docker run -d --restart=unless-stopped -d \
	    --name shipyard-rethinkdb \
	    rethinkdb
	# Add Shipyard Proxy, required for TLS-enabled installation
	docker run -d --restart=unless-stopped -d \
	    --name shipyard-proxy \
	    --hostname=$KEYSTORE \
	    -v /var/run/docker.sock:/var/run/docker.sock \
	    -p 2375:2375 \
	    -e PORT=2375 \
	    shipyard/docker-proxy:latest

	docker run --restart=unless-stopped -d \
	    --name shipyard-controller \
	    --link shipyard-rethinkdb:rethinkdb \
	    -v /var/lib/boot2docker:/certs:ro \
	    -p 8080:8080 \
	    shipyard/shipyard:latest \
	    server \
	    --tls-ca-cert=/certs/ca.pem \
	    --tls-cert=/certs/server.pem \
	    --tls-key=/certs/server-key.pem \
	    -d tcp://$(docker-machine ip $MANAGER):$MASTERPORT

	VBoxManage controlvm $MANAGER natpf1 "Shipyard,tcp,,$SHIPYARDPORT,,8080"
    )
fi

# Slaves
for NODENAME in n0 n1 n2
do
    (
	docker-machine create -d virtualbox \
	    --virtualbox-memory 512 \
	    --virtualbox-disk-size 8192 \
	    --swarm \
	    --swarm-discovery "consul://$(docker-machine ip $KEYSTORE):$CONSULPORT" \
	    --engine-label "eu.hbp.name=$NODENAME" \
	    --engine-label "eu.hbp.function=worker" \
	    --engine-opt="cluster-store=consul://$(docker-machine ip $KEYSTORE):$CONSULPORT" \
	    --engine-opt="cluster-advertise=eth1:$SLAVEPORT" $NODENAME

	# / is mounted from a tmpfs, and PostgreSQL seems not like it for its
	# log files. The only partition mounted in the VM is /mnt/sda1.
	docker-machine ssh $NODENAME 'mkdir -p shared/data \
		 && sudo chown 999 shared/data \
		 && sudo mv shared /mnt/sda1/shared'

	# Copy the proxy config, and create files for the logs with
	# appropriate rights & owner.
	docker-machine scp -r shared/raw-admin-$NODENAME $NODENAME:/mnt/sda1/shared/raw-admin
	docker-machine ssh $NODENAME 'mkdir /mnt/sda1/shared/raw-admin/logs \
		&& touch /mnt/sda1/shared/raw-admin/logs/access.log \
		&& touch /mnt/sda1/shared/raw-admin/logs/error.log \
		&& sudo chmod 666 /mnt/sda1/shared/raw-admin/logs/*.log'

	# Copy the datasets which are accessible  and exposed by the node.
	docker-machine scp -r shared/datasets-$NODENAME $NODENAME:/mnt/sda1/shared/datasets

	VBoxManage controlvm $NODENAME natpf1 "Raw Admin,tcp,,901$(echo $NODENAME|tr -d '[a-zA-Z-_]'),,9010"

if false
then
	eval $(docker-machine env $NODENAME)
	docker run -d --name swarm-agent swarm join --addr=$(docker-machine ip $NODENAME):$SLAVEPORT \
	    consul://$(docker-machine ip $KEYSTORE):$CONSULPORT
fi
    )
done
