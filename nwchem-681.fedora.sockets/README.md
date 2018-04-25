Based on earlier work by Vladimir Konjkov

Builds a NWChem 6.8.1  binary using all modules and ARMCI_NETWORK=SOCKETS

The file Dockerfile can be used by tying the command

docker build -t  nwchem-681.fedora.sockets .

The following command will run on 3 processors (will remove the hardwired value later ...)

docker run -v [host_dir]:/data docker run -v nwchem-681.fedora.sockets [input.nw]

### EXAMPLES

#### Execute QA tests

docker run -v /home/edo/park/nwchem-6.8.1/QA/tests/band:/data nwchem-681.fedora.sockets band

#### Use mpirun on a given input file

docker run --entrypoint='mpirun' -v /home/edo/nwchem/tests:/data nwchem-681.fedora.sockets -np 3 nwchem  /data/bar_lcwpbe
