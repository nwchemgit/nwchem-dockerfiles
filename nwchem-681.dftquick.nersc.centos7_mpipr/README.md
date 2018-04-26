Image for NERSC's shifter, available at 

https://hub.docker.com/r/edoapra/nwchem-681.dftquick.nersc.centos7/

Uses Centos 7 and MPICH. `ARMCI_NETWORK=MPI-PT`

Copy the Dockerfile to a local directory and create the image with the command
 
 `docker build -t nwchem-681.dftquick.nersc.centos7 .`
 
After successful build one you can run NWChem on NERSC edison as explained in the EXAMPLE section


EXAMPLE

1) On your computer were you are building NWChem using Docker:
 
 `docker build -t nwchem-681.dftquick.nersc.centos7 .`

push image to hub.docker.com

 `docker push ...`

If you need to check anything on the image, this will open a bash on the docker image

 `docker run -ti --entrypoint=/bin/bash  nwchem-681.dftquick.nersc.centos7 -s`

2) On NERSC's Edison

fetch image at NERSC with the command

 `shifterimg -v pull docker:....`

Get slurm session

 `salloc -N 2 -t 0:25:00 -p debug --image=docker:edoapra/nwchem-681.dftquick.nersc.centos7 --volume=/global/homes/a/$USER:/data`

Run from salloc shell

 `export MPICH_MAX_THREAD_SAFETY=multiple`

 `srun -v -N 2 -n 24 shifter /usr/local/src/nwchem-6.8.1/bin/LINUX64/nwchem "input file (under /global/homes/a/$USER)"`

