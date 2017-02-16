Image for NERSC's shifter

Uses Ubuntu 15.10 and MPICH

Copy the Dockerfile to a local directory and create the image with the command
 
 docker build -t nwchem-dev.dftquick.nersc .
 
After successful build one you can run NWChem on NERSC edison as explained in the EXAMPLE section


EXAMPLE

1) On your computer were you are building NWChem using Docker:
 
 docker build -t nwchem-dev.dftquick.nersc .

push image to hub.docker.com

 docker push ...

If you need to check anything on the image, this will open a bash on the docker image

 docker run  -v /tmp:/data -it nwchem-dev.dftquick.nersc 

2) On Edison's NERSC

fetch image at NERSC with the command

 shifterimg -v pull docker:....

Get slurm session

 salloc -N 1 -t 0:25:00 -p debug --image=docker:edoapra/nwchem-dev.dftquick.nersc --volume=/global/homes/a/$USER:/data

Run from salloc shell

 srun -v -N 1 -n 13 shifter /opt/nwchem/bin/LINUX64/nwchem "input file (under /global/homes/a/$USER)"

CAVEAT

 Does not work when using more than one node (issue under investigation)
 
 Always supply one extra process as mpirun argument since it used the MPI-PR ARMCI_NETWORK port
