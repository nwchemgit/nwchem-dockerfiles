#based on earlier work by Vladimir Konjkov <Konjkov.VV@gmail.com>
#
# Create the image with the command
# docker build -t nwchem-dev .
# 
#

FROM        ubuntu:15.10

MAINTAINER  Edoardo Apra <edoardo.apra@pnnl.gov>

RUN         apt-get update \
            && apt-get -y upgrade \
            && apt-get install -y   gfortran   tcsh make ssh  subversion unzip gdb strace\
            && apt-get clean
#get OpenBLAS and compile with 64-bit integers
ADD         https://github.com/xianyi/OpenBLAS/archive/develop.zip /usr/local/src
RUN         mkdir -p /opt/lib/ \
            && cd /usr/local/src \
            && unzip develop.zip \
            && rm develop.zip \
            && cd  OpenBLAS-develop \
            && make -j3 TARGET=CORE2 INTERFACE64=1 NO_CBLAS=1 NO_LAPACK=1 NO_LAPACKE=1 USE_THREAD=0 libs shared \
            &&  cp libopenblas.* /opt/lib \
            && rm -rf /usr/local/src/OpenBLAS-develop
#mpich user-space install
ADD         http://www.mpich.org/static/downloads/3.2/mpich-3.2.tar.gz /usr/local/src
RUN         cd /usr/local/src \
            && tar xzf mpich-3.2.tar.gz \
            && cd mpich-3.2 \
            && ./configure  -q --enable-fortran=all --disable-cxx --with-pm=hydra --disable-romio --disable-strict --disable-dependency-tracking  --enable-silent-rules \
            && make -j4 ;make install \
            && cd .. ; rm -rf mpich-3.2.*
ENV         ARMCI_NETWORK=MPI-PT NWCHEM_TOP="/usr/local/src/nwchem" \
            NWCHEM_TARGET=LINUX64 \
            NWCHEM_MODULES="nwdft driver stepper" \
            BLASOPT="-L/opt/lib -lopenblas" \
            BLAS_SIZE=8 \
            LD_LIBRARY_PATH=/opt/lib/:"$LD_LIBRARY_PATH" \
            USE_MPI=y \
            USE_MPIF=y \
            USE_MPIF4=y 
#ENV         MRCC_METHODS=y
#ENV         CCSDTQ=y
#ENV         CCSDTLR=y
RUN         cd /usr/local/src;mkdir -p nwchem \
            && cd nwchem \
            && svn co --depth empty https://svn.pnl.gov/svn/nwchem/trunk/src \
            && cd src \
            && svn update GNUmakefile nwchem.F config \
            tools include basis geom inp input  \
	    pstat rtdb task symmetry util peigs perfm bq cons blas lapack \
            NWints atomscf cphf ddscf driver gradients hessian nwdft optim property stepper symmetry vib \
            && rm -rf /usr/local/src/nwchem/.svn /usr/local/src/nwchem/src/.svn \
            && cd tools \
            && svn export --non-interactive --username nwchem --password nwchem https://svn.pnl.gov/svn/hpctools/branches/ga-5-5  \
            && cd .. \
#strip native compiler options as Fedora does
            && sed -i 's|-march=native||' config/makefile.h \
            && sed -i 's|-mtune=native|-mtune=generic|' config/makefile.h \
            && sed -i 's|-mfpmath=sse||' config/makefile.h \
            && sed -i 's|-msse3||' config/makefile.h  \
            && sed -i 's|child = fork();|/*child = fork();*/|' util/util_debug.c \
            && sed -i 's|#define PAUSE_ON_ERROR 0|#define PAUSE_ON_ERROR 1|' tools/ga-5-5/comex/src-mpi-pr/comex.c \
            && sed -i 's|pause();|abort();|' tools/ga-5-5/comex/src-mpi-pr/comex.c \
            && sed -i 's|#define PAUSE_ON_ERROR 0|#define PAUSE_ON_ERROR 1|' tools/ga-5-5/comex/src-mpi-pt/comex.c \
            && sed -i 's|pause();|abort();|' tools/ga-5-5/comex/src-mpi-pt/comex.c \
            && make nwchem_config && make  -j3  \
            && cd tools/build && make clean && make CFLAGS=-O0\ -g && cd ../.. && make FDEBUG=-O0\ -g link \
#clean unnecessary source to reduce docker size
            && rm -rf tce tools nwdft NWints geom symmetry util nwxc ddscf lapack blas rism argos peigs rmdft gradients symmetry property smd lucia dplot propery hessian ccsd mp2_grad moints cafe analyz dimqm /usr/local/src/nwchem/lib

#ENV         NWCHEM_EXECUTABLE=${NWCHEM_TOP}/bin/LINUX64/nwchem
#ENV         NWCHEM_BASIS_LIBRARY=${NWCHEM_TOP}/src/basis/libraries/
#ENV         NWCHEM_NWPW_LIBRARY=${NWCHEM_TOP}/src/nwpw/libraryps/
ENV         FFIELD=amber \
            AMBER_1=${NWCHEM_TOP}/src/data/amber_s/ \
            AMBER_2=${NWCHEM_TOP}/src/data/amber_q/ \
            AMBER_3=${NWCHEM_TOP}/src/data/amber_x/ \
            AMBER_4=${NWCHEM_TOP}/src/data/amber_u/ \
            SPCE=${NWCHEM_TOP}/src/data/solvents/spce.rst \
            CHARMM_S=${NWCHEM_TOP}/src/data/charmm_s/ \
            CHARMM_X=${NWCHEM_TOP}/src/data/charmm_x/ \
            LD_LIBRARY_PATH=/opt/lib/  \
            PATH=${NWCHEM_TOP}/bin/LINUX64:/usr/bin:/bin:/usr/sbin:/sbin
#clean unnecessary packages
RUN         apt-get -y remove  make  subversion  unzip tcsh  &&  apt-get -y autoremove && apt-get clean

WORKDIR     /data
ENTRYPOINT  ["/bin/bash"]
