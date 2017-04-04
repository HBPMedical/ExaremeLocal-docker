**Building the MipExareme Image**
-

1) Execute build.sh <br />
        - -h for options<br />
        - -algorithms=local used the algorithms from exareme-tools/algorithms-dev<br />
        - -algorithms=repo to download form the mip-algorithms repo at github<br />
        - -version=<version hash> specifies which version to include, default: HEAD<br />
        
2) (optional) execute pushToDockerHub.sh <image ID> to push the docker image with <image ID> to hbpmip/mipexareme dockerhub.



**Running the MipExareme Container**
-
To start this image you need to specify the following variables:
1. MASTER_FLAG=(master,worker)          specifies the role of the container
2. MODE=(global,local)                  specifies if Exareme is in local (one container) or global mode
3. CONSULURL=(consulURL)                necessary only in global mode              
4. EXA_WORKERS_WAIT=(# workers)         necessary to the master in global mode
5. RAWUSERNAME=
6. RAWPASSWORD=
7. RAWHOST=
8. RAWPORT=
9. RAWENDPOINT=(query,query-start)
10.RAWDATAKEY=(output,data) #query used with output, query-start with data
11.RAWRESULTS=all

and the port 9090 needs to be exposed.
