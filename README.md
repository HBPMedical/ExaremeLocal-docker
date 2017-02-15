**Instructions for using the Exareme Local Docker**
-

1) Execute start.sh (set ups the enviroment and executes Exareme and Raw)<br />
        - -h for options<br />
        - exalocal starts only exareme<br />
        - all starts Exareme kai Raw<br />
2) Use the ip:9090/exa-view/index.html web page to send queries to Exareme and view the results.

**Important Notes**
-
- datasets: add your csvs here to be loaded into RAW

- No changes should be done inside of the RAW-deploy folder except to change the credentials that the exalocal service is using to connect to Raw (in the docker-compose.yml)

- The connection to Raw is unsecured
