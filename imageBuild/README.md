**Instructions for building the Exareme Docker Image**
-

1) Execute build.sh <br />
        - -h for options<br />
        - -algorithms=local used the algorithms from exareme-tools/algorithms-dev<br />
        - -algorithms=repo to download form the mip-algorithms repo at github<br />
        - -version=<version hash> specifies which version to include, default: HEAD<br />
        
2) (optional) execute pushToDockerHub.sh <image ID> to push the docker image with <image ID> to hbpmip/mipexareme dockerhub.
