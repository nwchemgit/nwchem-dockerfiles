#based on earlier work by Vladimir Konjkov <Konjkov.VV@gmail.com>
#
# Create the image with the command
# docker build -t nwchem-dev .
# 
#

FROM        ubuntu:15.10

MAINTAINER  Edoardo Apra <edoardo.apra@pnnl.gov>

ENV         INTELROOT=/opt/intel/compilers_and_libraries_2017.1.132 
ENV         MKLROOT=$INTELROOT/linux/mkl \
            INTEL_LICENSE_FILE=/opt/intel/licenses \
            LIBRARY_PATH=$INTELROOT/linux/compiler/lib/intel64_lin:$INTELROOT/linux/mkl/lib/intel64_lin:$LIBRARY_PATH \
            LD_LIBRARY_PATH=/usr/local/lib:$INTELROOT/linux/compiler/lib/intel64:$INTELROOT/linux/compiler/lib/intel64_lin:$INTELROOT/linux/mkl/lib/intel64_lin \
            CPATH=$INTELROOT/linux/mkl/include \
            NLSPATH=$INTELROOT/linux/compiler/lib/intel64/locale/%l_%t/%N:$INTELROOT/linux/mkl/lib/intel64_lin/locale/%l_%t/%N \
            PATH=$INTELROOT/linux/bin/intel64:$INTELROOT/linux/mpi/intel64/bin:$PATH \
            I_MPI_ROOT=$INTELROOT/linux/mpi \
            ARMCI_NETWORK=MPI-PT NWCHEM_TOP=/usr/local/src/nwchem \
            NWCHEM_TARGET=LINUX64 \
            NWCHEM_MODULES="nwdft driver stepper property" \
            BLASOPT=-L$MKLROOT/lib/intel64\ -lmkl_intel_ilp64\ -lmkl_sequential\ -lmkl_core\ -lpthread\ -lm\ -ldl \
            BLAS_SIZE=8 \
            SCALAPACK=-L$MKLROOT/lib/intel64\ -lmkl_scalapack_ilp64\ -lmkl_intel_ilp64\ -lmkl_sequential\ -lmkl_core\ -lmkl_blacs_intelmpi_ilp64\ -lpthread\ -lm\ -ldl \
            SCALAPACK_SIZE=8 \
            USE_MPI=y \
            USE_MPIF=y \
            USE_MPIF4=y 
RUN         env|grep compi
RUN         mkdir -p "$INTELROOT"
COPY        licenses /opt/intel/licenses
COPY        compilers_and_libraries_2017.1.132 $INTELROOT
#force ifort
RUN         sed -i 's|gfortran|ifort|' $INTELROOT/linux/mpi/intel64/bin/mpif90 \
            &&    sed -i 's|archive.ubuntu.com|mirrors.us.kernel.org|' /etc/apt/sources.list \
            && apt -qq update \
            && apt -qq -y upgrade \
            && apt -qq install -y   gcc   tcsh make ssh  subversion  gdb strace libstdc++6  g++ curl \
            && apt-get clean \\
#mpich user-space install
            &&    cd /usr/local/src \
            && curl         http://www.mpich.org/static/downloads/3.2/mpich-3.2.tar.gz | tar xzf  - \
            && cd mpich-3.2 \
            && ./configure  -q --enable-fortran=all --disable-cxx --with-pm=hydra --disable-romio --disable-strict --disable-dependency-tracking  --enable-silent-rules FC=ifort \
            && make -j4 ;make install \
            && cd .. ; rm -rf mpich-3.2.* \
            &&         cd /usr/local/src;mkdir -p nwchem \
            && cd nwchem \
            && svn co --depth empty https://svn.pnl.gov/svn/nwchem/trunk/src \
            && cd src \
            && svn update GNUmakefile nwchem.F config \
            tools include basis geom inp input  \
	    pstat rtdb task symmetry util peigs perfm bq cons blas lapack 64to32blas \
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
            && make nwchem_config && make FC=ifort -j3  \
#clean unnecessary source to reduce docker size
            && rm -rf tce tools nwdft NWints geom symmetry util nwxc ddscf lapack blas rism argos peigs rmdft gradients symmetry property smd lucia dplot property hessian ccsd mp2_grad moints cafe analyz dimqm /usr/local/src/nwchem/lib \
#clean unnecessary packages
            && apt-get -y remove  make  subversion   tcsh  &&  apt-get -y autoremove && apt-get clean \
            && rm -rf /opt/intel/licenses \
            && rm -rf "$INTELROOT"/linux/bin \
            && rm -rf "$INTELROOT"/linux/compiler \
            && rm -rf "$INTELROOT"/linux/mpirt \
            && rm -rf "$INTELROOT"/linux/mkl/bin \
            && rm -rf "$INTELROOT"/linux/mkl/interfaces \
            && rm -rf "$INTELROOT"/linux/mkl/tools \
            && rm -rf "$INTELROOT"/linux/mkl/include \
            && rm -rf "$INTELROOT"/linux/mpi/bin64 \
            && rm -rf "$INTELROOT"/linux/mpi/binding \
            && rm -rf "$INTELROOT"/linux/mpi/etc64 \
            && rm -rf "$INTELROOT"/linux/mpi/binding \
            && rm -rf "$INTELROOT"/linux/mpi/man \
            && rm -rf "$INTELROOT"/linux/mpi/test \
            && ldd /usr/local/src/nwchem/bin/LINUX64/nwchem

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
            PATH=${NWCHEM_TOP}/bin/LINUX64:/usr/bin:/bin:/usr/sbin:/sbin
#delete compiler and keep just libs
WORKDIR     /data
ENTRYPOINT  ["/bin/bash"]
