FROM        amazonlinux

MAINTAINER  Edoardo Apra <edoardo.apra@gmail.com>

RUN	    amazon-linux-extras install epel \
	    && yum -y update \
	    && yum install -y cmake3 python3-devel gcc-gfortran  openblas-serial openmpi-devel  openssh-clients which bzip2 patch make perl  findutils hostname git tar \
	    && ln -sf /usr/bin/cmake3 /usr/bin/cmake  \
	    && ln -sf /usr/lib64/libopenblas.so.0 /usr/lib64/libopenblas.so \
            && ldconfig -v \
            && yum clean all \ 
            && useradd -c 'NWChem user' -m -d /home/nwchem -s /bin/bash nwchem

USER        nwchem
ENV         NWCHEM_TOP="/home/nwchem/nwchem-7.0.0" \
             PATH=$PATH:/home/nwchem/nwchem-7.0.0/bin/LINUX64:/usr/lib64/openmpi/bin/:/home/nwchem/nwchem-7.0.0/QA/:PATH \
             NWCHEM_TARGET=LINUX64 \
             NWCHEM_MODULES="all python" \
	      BUILD_SCALAPACK=y \
              BLASOPT="-lopenblas " \
              LAPACK_LIB="-lopenblas " \
              BLAS_SIZE=4 \
              SCALAPACK_SIZE=4 \
              USE_64TO32=y \
              LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/lib64/openmpi/lib" \
              USE_MPI=y \
              USE_MPIF=y \
              USE_MPIF4=y \
              ARMCI_NETWORK=SOCKETS  \
              NWCHEM_EXECUTABLE=/home/nwchem/nwchem-7.0.0/bin/LINUX64/nwchem \
              NWCHEM_BASIS_LIBRARY=/home/nwchem/nwchem-7.0.0/src/basis/libraries/ \
              NWCHEM_NWPW_LIBRARY=/home/nwchem/nwchem-7.0.0/src/nwpw/libraryps/ \
              FFIELD=amber \
              AMBER_1=/home/nwchem/nwchem-7.0.0/src/data/amber_s/ \
              AMBER_2=/home/nwchem/nwchem-7.0.0/src/data/amber_q/ \
              AMBER_3=/home/nwchem/nwchem-7.0.0/src/data/amber_x/ \
              AMBER_4=/home/nwchem/nwchem-7.0.0/src/data/amber_u/ \
              SPCE=/home/nwchem/nwchem-7.0.0/src/data/solvents/spce.rst \
              CHARMM_S=/home/nwchem/nwchem-7.0.0/src/data/charmm_s/ \
              CHARMM_X=/home/nwchem/nwchem-7.0.0/src/data/charmm_x/ \
	      OMPI_MCA_btl_vader_single_copy_mechanism=none
#ENV          ELPA="-I/usr/lib64/gfortran/modules/openmpi -L/usr/lib64/openmpi/lib -lelpa"
RUN        cd /home/nwchem; curl -SL https://github.com/nwchemgit/nwchem/releases/download/v7.0.0-release/nwchem-7.0.0-release.revision-2c9a1c7c-src.2020-02-26.tar.bz2 | tar jxf - \
            && cd nwchem-7.0.0/src \
            && sed -i 's|-march=native||' config/makefile.h \
            && sed -i 's|-mtune=native|-mtune=generic|' config/makefile.h \
            && sed -i 's|-mfpmath=sse||' config/makefile.h \
            && sed -i 's|-msse3||' config/makefile.h  \
            && ls -lrt  \
            &&  make nwchem_config  \
            &&  make -j3 \
            && rm -rf tce tools nwdft NWints geom symmetry util nwxc ddscf lapack blas rism argos peigs rmdft gradients symmetry property smd lucia dplot propery hessian ccsd mp2_grad moints cafe analyz dimqm ../lib libext  develop ../QA ../contrib ../examples ../.git ../travis ../web nwpw/nwpwlib/nwpwxc rdmft ../doc

#WORKDIR     /home/nwchem/nwchem-7.0.0/QA
#ENTRYPOINT  ["runtests.mpi.unix","procs","3"]
WORKDIR     /data
ENTRYPOINT  ["/bin/bash"]
#ENTRYPOINT  ["mpirun","-np","3","nwchem"]
