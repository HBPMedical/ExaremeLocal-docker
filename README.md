**Instructions for using the Exareme Local Docker**
-

1) Execute start.sh (set ups the enviroment and executes Exareme and Raw)<br />
        - -h for options<br />
        - exalocal starts only exareme<br />
        - localall: starts ExaremeLocal kai Raw<br />
        - raw: starts one raw instance<br />
        - distributed: start 2 Exareme workers, a master and 3 raw instances<br />

2) Use the ip:9090/exa-view/index.html web page to send queries to Exareme and view the results.


**Build Exareme Image**
Read the imageBuild/README.md

**Important Notes**
- For the distributed mode, look at the RAW-deploy/REAME.md

- datasets: add your csvs here to be loaded into RAW, when using the distributed version look at the RAW-deploy/README.md to see how to add data.

- The connection to Raw is unsecured, in local mode

