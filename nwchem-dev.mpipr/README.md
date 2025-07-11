Docker  NWChem build using ARMCI_NETWORK=MPI-PR
========================================


 
### HOW TO USE

Instruction for using this image with the [docker compose](https://docs.docker.com/compose) command

1. Install docker  as described in [https://docs.docker.com/engine/install](https://docs.docker.com/engine/install)

2. Download the [compose.yaml](https://raw.githubusercontent.com/nwchemgit/nwchem-dockerfiles/refs/heads/master/nwchem-dev.mpipr/compose.yaml) file
 
```
 wget https://raw.githubusercontent.com/nwchemgit/nwchem-dockerfiles/refs/heads/master/nwchem-dev.mpipr/compose.yaml
```

3. Create the nwchem service
``` 
docker compose up -d
```

4. Run NWChem
 
``` 
 docker compose run nwchem h2o.nw
```

In the example above the input file name is `h2o.nw`.   
The default setting will run NWChem using 2 processes.
If you would like to use more processes,
then you would have to set the environment variable `MYNPROC` to the number of processes plus one.
For example, if you wish to use 4 processes, then you will execute the following (bash syntax)
```
export MYNPROC=5
```