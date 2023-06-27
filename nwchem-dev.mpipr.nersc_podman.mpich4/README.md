
Builds a NWChem image from the master branch to use with NERSC podman-hpc  binary using all modules and ARMCI_NETWORK=MPI-PR

### Build Instructions

The file Dockerfile can be used by tying the command
```
docker build -t  nwchem-dev.mpipr.nersc_podman .
```

### Examples

The following command will run NWChem on 2 processors  (since one processors is set aside for communication)
```
docker run --entrypoint='mpirun' -v /home/edo/nwchem/tests:/data nwchem-dev.mpipr.nersc_podman -np 3 nwchem  /data/bar_lcwpbe
```


The following command will get shell on the Docker container
```
docker run  --entrypoint='/bin/bash' -v /home/edo/nwchem/tests:/data --rm -it nwchem-dev.mpipr.nersc_podman
```

### How to use on NERSC computers using the image from ghcr.io

### CPU

Download the image  
```
shifterimg -v pull ghcr.io:nwchemgit/nwchem-dev.mpipr.nersc_podman:latest
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


# podman-hpc at nersc

https://docs.nersc.gov/development/podman-hpc/overview/
```
#!/bin/bash
#SBATCH -C cpu
#SBATCH -t 0:29:00
#SBATCH -q debug
#SBATCH -N 2
#SBATCH -A XXXXXX
#SBATCH --cpus-per-task=2
#SBATCH --ntasks-per-node=64
#SBATCH -J pod
#SBATCH -o pod.%j.out
#SBATCH -e pod.%j.out
export OMP_NUM_THREADS=1
export COMEX_MAX_NB_OUTSTANDING=6
export FI_CXI_RX_MATCH_MODE=hybrid
export COMEX_EAGER_THRESHOLD=16384
export FI_CXI_RDZV_THRESHOLD=16384
export FI_CXI_OFLOW_BUF_COUNT=6
export MPICH_SMP_SINGLE_COPY_MODE=CMA
export SCRATCH_DIR=/tmp
export PERMANENT_DIR=/tmp
MYIMAGE=ghcr.io/edoapra/nwchem-dev.nersc_podman.mpich4.mpi-pr:latest
podman-hpc pull $MYIMAGE
srun -N $SLURM_NNODES --cpu-bind=cores podman-hpc shared-run --shm-size 500g -v `pwd`:/data --mpi --env 'FI*' --env "OMP*" --env "COMEX*" --env "MPICH*" --env "*DIR" $MYIMAGE nwchem /data/dpert.nw
```
