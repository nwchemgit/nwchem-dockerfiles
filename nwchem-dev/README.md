Docker build of the current NWChem master branch
========================================


Based on earlier work by Vladimir Konjkov Konjkov.VV@gmail.com

https://nwchemgit.github.io/Special_AWCforum/st/id2181

### INSTRUCTIONS

Copy the Dockerfile to a local directory and create the image with the command
```
 docker build -t nwchem-dev .
```
This will build a NWChem executable using the current master branch within a Debian image. OpenBLAS and Scalapack are used.


After successful build one you can run NWChem using the input file `input.nw` file placed in `[host_system_dir]`

by typing the command
```
 docker run -dv [host_system_dir]:/data nwchem-dev "input.nw"
```
This command will return [container ID] value to read logs by
```
 docker logs [container ID]
``` 
 or using the interactive command
``` 
 docker run -v [host_system_dir]:/data nwchem-dev "input.nw"
``` 

 
### EXAMPLES
 
```
 docker run --rm -v /home/edo/nwchem/tests:/data nwchem-dev xvdw.nw
```
 
``` 
 docker run --rm -e OMP_NUM_THREADS=1 -v /tmp:/data  --entrypoint='/usr/bin/mpirun'  nwchem-dev -np 2 nwchem small.nw
```
 
``` 
 docker run  --rm  --entrypoint='/bin/bash' -v /home/edo/nwchem/tests:/data -it nwchem-dev
```
 
### EXAMPLES using the hub.docker.com image

After pulling the hub.docker.com image with the command
```
docker pull nwchemorg/nwchem-dev
```
you can execute the following commands

```
 docker run --rm -v /home/edo/nwchem/tests:/data nwchemorg/nwchem-dev xvdw.nw
```
 
``` 
 docker run --rm -e OMP_NUM_THREADS=1 -v /tmp:/data  --entrypoint='/usr/bin/mpirun'  nwchemorg/nwchem-dev -np 2 nwchem small.nw
```
 
``` 
 docker run  --rm  --entrypoint='/bin/bash' -v /home/edo/nwchem/tests:/data -it nwchemorg/nwchem-dev
```

### EXAMPLES using the ghcr.io image

You can pull the image from the ghcr.io GitHub Container Registry with the command  
  
`docker pull ghcr.io/nwchemgit/nwchem-dev/`*arch*`:latest`
  
were *arch* corresponds to the hardware platform on the host. The following *arch* values are available: 
* amd64
* arm64
* armv7
* ppc64le

You can execute the following commands

```
 docker run --rm -v /home/edo/nwchem/tests:/data ghcr.io/nwchemgit/nwchem-dev/amd64:latest xvdw.nw
```
 
``` 
 docker run --rm -e OMP_NUM_THREADS=1 -v /tmp:/data  --entrypoint='/usr/bin/mpirun'  ghcr.io/nwchemgit/nwchem-dev/amd64:latest -np 2 nwchem small.nw
```
 
``` 
 docker run  --rm  --entrypoint='/bin/bash' -v /home/edo/nwchem/tests:/data -it ghcr.io/nwchemgit/nwchem-dev/amd64:latest
```
