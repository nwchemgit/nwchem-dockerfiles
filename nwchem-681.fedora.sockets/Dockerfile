FROM        fedora:27

MAINTAINER  Edoardo Apra <edoardo.apra@gmail.com>

RUN         dnf -y update \  
            && dnf -y upgrade \
            && dnf install -y python-devel gcc-gfortran  openblas openmpi-devel scalapack-openmpi-devel  tcsh openssh-clients which bzip2 patch make perl subversion  findutils hostname git \
            && dnf clean all \ 
            && useradd -c 'NWChem user' -m -d /home/nwchem -s /bin/bash nwchem

USER        nwchem
ENV         NWCHEM_TOP="/home/nwchem/nwchem-6.8.1" \
             PATH=$PATH:/home/nwchem/nwchem-6.8.1/bin/LINUX64:/usr/lib64/openmpi/bin/:/home/nwchem/nwchem-6.8.1/QA/:PATH \
             NWCHEM_TARGET=LINUX64 \
             NWCHEM_MODULES="all python" \
              PYTHONVERSION=2.7 \
              PYTHONHOME="/usr" \
              USE_PYTHONCONFIG=Y \
              BLASOPT="/usr/lib64/libopenblas.so.0 -lpthread -lrt" \
              BLAS_SIZE=4 \
              USE_64TO32=y \
              LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/lib64/openmpi/lib" \
              SCALAPACK="-L/usr/lib64/openmpi/lib -lscalapack " \
              USE_MPI=y \
              USE_MPIF=y \
              USE_MPIF4=y \
              ARMCI_NETWORK=SOCKETS  \
              NWCHEM_EXECUTABLE=/home/nwchem/nwchem-6.8.1/bin/LINUX64/nwchem \
              NWCHEM_BASIS_LIBRARY=/home/nwchem/nwchem-6.8.1/src/basis/libraries/ \
              NWCHEM_NWPW_LIBRARY=/home/nwchem/nwchem-6.8.1/src/nwpw/libraryps/ \
              FFIELD=amber \
              AMBER_1=/home/nwchem/nwchem-6.8.1/src/data/amber_s/ \
              AMBER_2=/home/nwchem/nwchem-6.8.1/src/data/amber_q/ \
              AMBER_3=/home/nwchem/nwchem-6.8.1/src/data/amber_x/ \
              AMBER_4=/home/nwchem/nwchem-6.8.1/src/data/amber_u/ \
              SPCE=/home/nwchem/nwchem-6.8.1/src/data/solvents/spce.rst \
              CHARMM_S=/home/nwchem/nwchem-6.8.1/src/data/charmm_s/ \
              CHARMM_X=/home/nwchem/nwchem-6.8.1/src/data/charmm_x/ 
#ENV          ELPA="-I/usr/lib64/gfortran/modules/openmpi -L/usr/lib64/openmpi/lib -lelpa"
RUN        cd /home/nwchem; git clone -b hotfix/release-6-8 https://github.com/nwchemgit/nwchem.git nwchem-6.8.1 \
            && cd nwchem-6.8.1/src \
            && ls -lrt  \
            &&  make nwchem_config && (make 64_to_32 > make.6log  2>&1 &)  \
            &&  make -j3
#old            &&  make GA_BRANCH=hotfix/5.6.5 -j3


WORKDIR     /home/nwchem/nwchem-6.8.1/QA
ENTRYPOINT  ["runtests.mpi.unix","procs","3"]
#WORKDIR     /data
#ENTRYPOINT  ["mpirun","-np","3","nwchem"]
