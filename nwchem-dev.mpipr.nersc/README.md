
Builds a NWChem image from the mster branch to use with NERSC shifter  binary using all modules and ARMCI_NETWORK=MPI-PR

### Build Instructions

The file Dockerfile can be used by tying the command
```
docker build -t  nwchem-dev.mpipr.nersc .
```

### Examples

The following command will run NWChem on 2 processors  (since one processors is set aside for communication)
```
docker run --entrypoint='mpirun' -v /home/edo/nwchem/tests:/data nwchem-dev.mpipr.nersc -np 3 nwchem  /data/bar_lcwpbe
```


The following command will get shell on the Docker container
```
docker run  --entrypoint='/bin/bash' -v /home/edo/nwchem/tests:/data --rm -it nwchem-dev.mpipr.nersc
```

### How to use on NERSC computers using the image from the Docker hub

### CPU

Download the image  
```
shifterimg -v pull ghcr.io:nwchemgit/nwchem-dev.mpipr.nersc:latest
```
Interactive shell  

```
salloc -N2  -A XXYYZZ -t 29:30 -C knl

srun -v -N2 -n 128 shifter -v --image=ghcr.io:nwchemgit/nwchem-dev.mpipr.nersc nwchem aabbccddeeff.nw
```
Slurm submission script  for NERSC Cori Haswell partition
```
#!/bin/bash
#SBATCH -A XXXYYYZZZ
#SBATCH --nodes=2
#SBATCH --image=ghcr.io/nwchemgit/nwchem-dev.mpipr.nersc
#SBATCH --constraint=haswell
PERMANENT_DIR=/dev/shm SCRATCH_DIR=/dev/shm srun -v -N2 -n 128 shifter nwchem cece.nw >& cece.out.haswell.N2.$SLURM_JOBID
```

### CUDA GPU

Slurm submission script  for NERSC Perlmutter using four GPUs per node (requiring the line `cuda 4` in the `TCE` input field)

```
#!/bin/bash
#SBATCH -A XXXYYYZZZ
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=64
#SBATCH --cpus-per-task=2
#SBATCH --gpus-per-node=4                                                                 
#SBATCH --gpu-bind=none 
#SBATCH --image=ghcr.io/nwchemgit/nwchem-dev.mpipr.nersc
#SBATCH --constraint=gpu
rm -f wrap.sh
cat > wrap.sh <<EOF
#!/bin/bash
LD_PRELOAD=/opt/udiImage/modules/cuda-mpich/lib64/libmpi_gtl_cuda.so.0 \$@
EOF
cat wrap.sh
chmod +x wrap.sh
MPICH_GPU_SUPPORT_ENABLED=1 srun -N $SLURM_NNODES --cpu-bind=cores --module=cuda-mpich shifter ./wrap.sh nwchem input.nw >& input.out.$SLURM_JOB_ID
```
