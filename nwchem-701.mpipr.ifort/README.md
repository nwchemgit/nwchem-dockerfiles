Based on earlier work by Vladimir Konjkov

Builds a NWChem 7.0.1 using Intel OneAPI ifort (WIP)

### Build Instructions

The file Dockerfile can be used by tying the command

docker run  --entrypoint='/bin/bash' -v /home/edo/nwchem/tests:/data -it nwchem-701.mpipr.ifortdocker build -t  nwchem-701.mpipr.ifort .


### Examples

The following command will run NWChem on 2 processors  (since one processors is set aside for communication)

docker run --entrypoint='mpirun' -v /home/edo/nwchem/tests:/data nwchem-701.mpipr.ifort -np 2 nwchem  /data/bar_lcwpbe



The following command will get shell on the Docker container

docker run  --entrypoint='/bin/bash' -v /home/edo/nwchem/tests:/data -it nwchem-701.mpipr.ifort
