Docker build of the current NWChem trunk
========================================

Based on earlier work by Vladimir Konjkov <Konjkov.VV@gmail.com>
 
 http://www.nwchem-sw.org/index.php/Special:AWCforum/st/id2181

Copy the Dockerfile to a local directory and create the image with the command
 
 docker build -t nwchem-dev.dftquick.mpipr .
 
After successful build one you can run NWChem on a input file input.nw file placed in [host_system_dir]

by typing the command

docker run -dv [host_system_dir]:/data nwchem-dev.dftquick.mpipr "input.nw"

This command will return [container ID] value to read logs by

 docker logs [container ID]

or using the interactive command

 docker run -v [host_system_dir]:/data nwchem-dev.dftquick.mpipr "input.nw"

EXAMPLE

 docker build -t nwchem-dev.dftquick.mpipr .

 docker run  -v /tmp:/data  --entrypoint='/usr/bin/mpirun'  nwchem-dev.dftquick.mpipr -np 2 nwchem small.nw

CAVEAT
 
 Always supply one extra process as mpirun argument since it used the MPI-PR ARMCI_NETWORK port
