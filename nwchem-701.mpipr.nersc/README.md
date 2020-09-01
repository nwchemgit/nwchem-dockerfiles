Based on earlier work by Vladimir Konjkov

Builds a NWChem 7.0.1 to use sith NERSC shifter  binary using all modules and ARMCI_NETWORK=MPI-PR

### Build Instructions

The file Dockerfile can be used by tying the command

docker build -t  nwchem-701.mpipr.nersc .


### Examples

The following command will run NWChem on 2 processors  (since one processors is set aside for communication)

docker run --entrypoint='mpirun' -v /home/edo/nwchem/tests:/data nwchem-701.mpipr.nersc -np 2 nwchem  /data/bar_lcwpbe



The following command will get shell on the Docker container

docker run  --entrypoint='/bin/bash' -v /home/edo/nwchem/tests:/data -it nwchem-701.mpipr.nersc
