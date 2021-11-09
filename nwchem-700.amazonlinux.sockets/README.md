Based on earlier work by Vladimir Konjkov

Builds a NWChem 7.0.0  binary using all modules and ARMCI_NETWORK=SOCKETS

### Build Instructions

The file Dockerfile can be used by tying the command

docker build -t  nwchem-700.amazonlinux.sockets .

### Usage

The following command will run NWChem on 1 processor (will remove the hardwired value later ...)

docker run --entrypoint='mpirun' -v [host_dir]:/data  nwchem-700.amazonlinux.sockets nwchem [input.nw]

### Examples

#### Modifiy  mpirun options

The following command will run NWChem on 3 processors 

docker run --entrypoint='mpirun' -v /home/edo/nwchem/tests:/data nwchem-700.amazonlinux.sockets -np 3 nwchem  /data/bar_lcwpbe

Get shell on the Docker container

docker run   -v /home/edo/nwchem/tests:/data -it nwchem-700.amazonlinux.sockets
