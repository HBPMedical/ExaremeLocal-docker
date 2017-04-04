#!/bin/bash

VersionOfMipAlgorithms="HEAD"

for i in "$@"
do
case $i in
    -m=*|-mode=*)
    LOCALORMIPALGORITHMS="${i#*=}"
    shift # past argument=value
    ;;
    -v=*|-version=*)
    VersionOfMipAlgorithms="${i#*=}"
    shift # past argument=value
    ;;
    -h|-help)
    echo "use -mode=local to use the algorithms in exareme-tools/algorithms-dev or -mode= repo to download form the mip-algorithms repo at github"
     echo " -version=<version hash> specifies which version to include, default: HEAD";
     exit;
    shift # past argument=value
    ;;
    *)
    ;;
esac
done
if [[ -z "$LOCALORMIPALGORITHMS" ]];then
    echo "mode not set, use -h flag for instructions";exit;
fi



rm Dockerfile 1>&- 2>&-

if [ $LOCALORMIPALGORITHMS = "local" ]; then

    sed  "s/MIPALGORITHMSCONFIGURATION/ \
    RUN cp -R \/root\/exareme\/lib\/algorithms-dev \/root\/mip-algorithms    \
    /" ./Dockerfile.notready > Dockerfile

else
     sed  "s/MIPALGORITHMSCONFIGURATION/ \
        RUN  git clone https:\/\/github.com\/madgik\/mip-algorithms.git \/root\/mip-algorithms  #dd ;   \
        WORKDIR \/root\/mip-algorithms         ;     \
        RUN git reset --hard $VersionOfMipAlgorithms ;  \
        /" ./Dockerfile.notready > DockerTEMP

      tr ';' '\n' < DockerTEMP > Dockerfile

      rm DockerTEMP
fi



docker build  -t exaremelocal .

rm Dockerfile 1>&- 2>&-

#uncomment to use the algorithms from the repo
#RUN  git clone https://github.com/madgik/mip-algorithms.git /root/mip-algorithms
#RUN rm /root/mip-algorithms/properties.json
#ADD properties.json /root/mip-algorithms/
