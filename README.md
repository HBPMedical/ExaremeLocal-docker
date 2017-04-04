**MipExareme docker deployment and build scripts**
-
This repository contains the scripts to build and deploy the mipexareme docker image, hosted on [dockerhub](https://hub.docker.com/r/hbpmip/mipexareme/).
The scripts can deploy mipexareme locally and in a distributed setting. The query engine (RAW) can be deployed with mipexareme.

**Instructions for starting and using the MipExareme docker**
-

1) Execute start.sh (set ups the enviroment and executes Exareme and Raw)<br />
        - -h for options<br />
        - exalocal starts only exareme<br />
        - localall: starts ExaremeLocal kai Raw<br />
        - raw: starts one raw instance<br />
        - distributed: start 2 Exareme workers, a master and 3 raw instances<br />
        - stopdis: stops the vms of the distributed enviroment<br />

2) Use the ip:9090/exa-view/index.html web page to send queries to Exareme and view the results.
(The ip is the ip of the docker container that the master node of Exareme runs on. In the distributed mode the master runs on the "n2" virtual machine. The n2 ip can be found by executing docker-machine ip n2)


**Build mipexareme**
-
Read the [imageBuild/README.md](https://github.com/HBPMedical/MipExareme-Docker/blob/master/imageBuild/README.md)

**Important Notes**
-
- For the distributed mode, look at the [RAW-deploy/README.md](https://github.com/HBPMedical/MipExareme-Docker/blob/master/RAW-deploy/README.md)

- datasets: add your csvs here to be loaded into RAW, when using the distributed version look at the RAW-deploy/README.md to see how to add data (LOCAL mode only)

- The connection to RAW is unsecured, in local mode
