Based on earlier work by Vladimir Konjkov

Builds a NWChem 7.0.2 to use with NERSC shifter  binary using all modules and ARMCI_NETWORK=MPI-PR

### Build Instructions

The file Dockerfile can be used by tying the command
```
docker build -t  nwchem-702.mpipr.nersc .
```

### Examples

The following command will run NWChem on 2 processors  (since one processors is set aside for communication)
```
docker run --entrypoint='mpirun' -v /home/edo/nwchem/tests:/data nwchem-702.mpipr.nersc -np 3 nwchem  /data/bar_lcwpbe
```


The following command will get shell on the Docker container
```
docker run  --entrypoint='/bin/bash' -v /home/edo/nwchem/tests:/data --rm -it nwchem-702.mpipr.nersc
```

### How to use on NERSC computers using the image from the Docker hub
Download the image  
```
shifterimg -v pull docker:nwchemorg/nwchem-702.mpipr.nersc
```
Interactive shell  

```
salloc -N2  -A XXYYZZ -t 29:30 -C knl

srun -v -N2 -n 128 shifter -v --image=docker:nwchemorg/nwchem-702.mpipr.nersc nwchem aabbccddeeff.nw
```
Slurm submission script  
```
#!/bin/bash
#SBATCH -A XXXYYYZZZ
#SBATCH --nodes=2
#SBATCH --qos=debug
#SBATCH -J shifter_cece
#SBATCH -t 14:30
#SBATCH --image=docker:nwchemorg/nwchem-702.mpipr.nersc
#SBATCH --constraint=haswell
PERMANENT_DIR=/dev/shm SCRATCH_DIR=/dev/shm srun -v -N2 -n 128 shifter nwchem cece.nw >& cece.out.haswell.N2.$SLURM_JOBID
```
