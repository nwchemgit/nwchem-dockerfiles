Based on earlier work by Vladimir Konjkov

Builds a NWChem 7.0.0  binary using all modules and ARMCI_NETWORK=MPI-PR

### Build Instructions

The file Dockerfile can be used by tying the command

docker build -t  nwchem-700.mpipr .


### Examples

The following command will run NWChem on 2 processors  (since one processors is set aside for communication)

docker run --entrypoint='mpirun' -v /home/edo/nwchem/tests:/data nwchem-700.mpipr -np 2 nwchem  /data/bar_lcwpbe



The following command will get shell on the Docker container

docker run  --entrypoint='/bin/bash' -v /home/edo/nwchem/tests:/data -it nwchem-700.mpipr
