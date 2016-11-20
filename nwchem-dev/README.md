Docker build of the current NWChem trunk
========================================


Based on earlier work by Vladimir Konjkov Konjkov.VV@gmail.com

 http://www.nwchem-sw.org/index.php/Special:AWCforum/st/id2181

INSTRUCTIONS

Copy the Dockerfile to a local directory and create the image with the command

 docker build -t nwchem-dev .

This will build a NWChem executable using the current SVN trunk within a Debian image. OpenBLAS and Scalapack are used.


After successful build one you can run NWChem on a input file input.nw file placed in [host_system_dir]

by typing the command

 docker run -dv [host_system_dir]:/data nwchem-dev "input.nw"

This command will return [container ID] value to read logs by

 docker logs [container ID]
 
 or using the interactive command
 
 docker run -v [host_system_dir]:/data nwchem-dev "input.nw"
 
 
 
EXAMPLES
 
 docker build -t nwchem-dev .

 docker run -v /home/edo/nwchem/tests:/data nwchem-dev xvdw.nw
 
 docker run  -v /tmp:/data  --entrypoint='/usr/bin/mpirun'  nwchem-dev -np 2 nwchem small.nw

