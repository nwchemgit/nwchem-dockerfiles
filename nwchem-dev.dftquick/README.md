
Based on earlier work by Vladimir Konjkov <Konjkov.VV@gmail.com>
 
 https://nwchemgit.github.io/Special_AWCforum/st/id2181

Copy the Dockerfile to a local directory and create the image with the command
 
 docker build -t nwchem-dev.dftquick .
 
After successful build one you can run NWChem on a input file input.nw file placed in [host_system_dir]

by typing the command

docker run -dv [host_system_dir]:/data nwchem-dev.dftquick "input.nw"

This command will return [container ID] value to read logs by

docker logs [container ID]

or using the interactive command

docker run -v [host_system_dir]:/data nwchem-dev.dftquick "input.nw"

EXAMPLE

docker build -t nwchem-dev.dftquick .

docker run -v /home/edo/nwchem/tests:/data nwchem-dev.dftquick xvdw.nw
