#based on earlier work by Vladimir Konjkov <Konjkov.VV@gmail.com>
#
# Create the image with the command
# docker build -t nwchem-702.mpipr.nersc .
# 
#after successful build one you can execute the QA tests using the command
#docker run nwchem-702.mpipr.nersc dft_he2+ h2o_dk h2o_opt
#

FROM        ubuntu:20.04

MAINTAINER  Edoardo Apra <edoardo.apra@pnnl.gov>

ARG DEBIAN_FRONTEND=noninteractive
RUN         apt-get update \
            && apt-get -y upgrade \
            && apt-get install -y  g++ gfortran   make ssh patch curl subversion wget unzip perl git file python3 python3-dev \
            && apt-get clean
ARG mpich=3.3
ARG mpich_prefix=mpich-$mpich
RUN \
    wget https://www.mpich.org/static/downloads/$mpich/$mpich_prefix.tar.gz && \
    tar xvzf $mpich_prefix.tar.gz                                           && \
    cd $mpich_prefix                                                        && \
    ./configure                                                             && \
    make -j 4                                                               && \
    make install                                                            && \
    make clean                                                              && \
    cd ..                                                                   && \
    rm -rf $mpich_prefix
#get OpenBLAS and compile with 64-bit integers
WORKDIR     /opt
ENV         ARMCI_NETWORK=MPI-PR NWCHEM_TOP="/opt/nwchem-7.0.2" \
            NWCHEM_TARGET=LINUX64 \
            NWCHEM_MODULES="all python" \
            BUILD_OPENBLAS=1 \
            BUILD_SCALAPACK=1 \
            BLAS_SIZE=8 \
            SCALAPACK_SIZE=8 \
            USE_64TO32=y \
            USE_MPI=y \
            USE_MPIF=y \
            USE_MPIF4=y 
#ENV         MRCC_METHODS=y
#ENV         CCSDTQ=y
#ENV         CCSDTLR=y
RUN          cd /opt;curl -SL     https://github.com/nwchemgit/nwchem/releases/download/v7.0.2-release/nwchem-7.0.2-release.revision-b9985dfa-src.2020-10-12.tar.bz2 | tar xjf - \
            && cd nwchem-7.0.2/src \
#strip native compiler options as Fedora does
            && sed -i 's|-march=native||' config/makefile.h \
            && sed -i 's|-mtune=native|-mtune=generic|' config/makefile.h \
            && sed -i 's|-mfpmath=sse||' config/makefile.h \
            && sed -i 's|-msse3||' config/makefile.h  \
            && make nwchem_config && make -j3  \
#clean unnecessary source to reduce docker size
            && rm -rf tce tools nwdft NWints geom symmetry util nwxc ddscf lapack blas rism argos peigs rmdft gradients symmetry property smd lucia dplot propery hessian ccsd mp2_grad moints cafe analyz dimqm /opt/nwchem/lib

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
            PATH=$PATH:${NWCHEM_TOP}/bin/LINUX64

#clean unnecessary packages
RUN         apt-get -y remove  make curl subversion  unzip cmake perl tcsh  &&  apt-get -y autoremove && apt-get clean

WORKDIR     /data
ENTRYPOINT  ["mpirun","-np","3","nwchem"]
