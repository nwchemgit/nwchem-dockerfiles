#based on earlier work by Vladim Konjkov <Konjkov.VV@gmail.com>
#
# Create the image with the command
# docker build -t nwchem-dev .
# 
#after successful build one should run container to calculate input.nw file placed in <host_system_dir>
#docker run -dv <host_system_dir>:/data nwchem-dev "input.nw"
#this command return container ID to read logs by
#docker logs <container ID>
#
#It is possible to pause execution, and then continue.
#docker pause <container ID>
#docker unpause <container ID>

FROM        debian

MAINTAINER  Edoardo Apra <edoardo.apra@pnnl.gov>

ENV         NWCHEM_TOP="/opt/nwchem"

RUN         apt-get update \
            && apt-get -y upgrade \
            && apt-get install -y python-dev gfortran  libopenmpi-dev openmpi-bin tcsh make ssh patch curl subversion  unzip cmake perl
#get OpenBLAS using the default 32bit ints to work with Scalapack
WORKDIR     /opt
RUN         curl -L https://github.com/xianyi/OpenBLAS/archive/develop.zip -o develop.zip && unzip develop.zip
WORKDIR     OpenBLAS-develop
RUN         make -j3  NO_CBLAS=1 NO_LAPACKE=1
# build scalapack 
WORKDIR     /opt
#RUN         svn --trust-server-cert co https://icl.cs.utk.edu/svn/scalapack-dev/scalapack/trunk scalapack
#WORKDIR     scalapack
RUN         curl http://www.netlib.org/scalapack/scalapack-2.0.2.tgz -o scalapack-2.0.2.tgz
RUN         tar xzf scalapack-2.0.2.tgz
WORKDIR     scalapack-2.0.2
RUN         mkdir -p build
WORKDIR     build
RUN         cmake ../ -DCMAKE_BUILD_TYPE=MinSizeRel -DBUILD_SHARED_LIBS=ON -DUSE_OPTIMIZED_LAPACK_BLAS=ON -DBLAS_blas_LIBRARY="/opt/OpenBLAS-develop/libopenblas.so" -DLAPACK_lapack_LIBRARY="/opt/OpenBLAS-develop/libopenblas.so" && make -j3
WORKDIR     /opt
RUN         mkdir -p nwchem
WORKDIR     nwchem
RUN         svn co https://svn.pnl.gov/svn/nwchem/trunk/src 
WORKDIR     ${NWCHEM_TOP}/src/tools
RUN         ./get-tools 
WORKDIR     ${NWCHEM_TOP}/src
ENV         NWCHEM_TARGET=LINUX64
ENV         NWCHEM_MODULES="all python"
#
ENV         PYTHONVERSION=2.7
ENV         PYTHONHOME="/usr"
ENV         USE_PYTHONCONFIG=Y
ENV         BLASOPT="-L/opt/OpenBLAS-develop -lopenblas"
ENV         BLAS_SIZE=4
ENV         SCALAPACK_LIB="-L/opt/scalapack-2.0.2/build/lib -lscalapack"
ENV         SCALAPACK_SIZE=4
ENV         LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/opt/OpenBLAS-develop:/opt/scalapack-2.0.2/build/lib"
ENV         USE_OPENMP=y
ENV         USE_64TO32=y
ENV         USE_MPI=y
ENV         USE_MPIF=y
ENV         USE_MPIF4=y
ENV         MRCC_METHODS=y
#ENV         CCSDTQ=y
#ENV         CCSDTLR=y

WORKDIR     ${NWCHEM_TOP}/src
RUN         make clean && make nwchem_config && make 64_to_32;make -j3
#WORKDIR     ${NWCHEM_TOP}/contrib
#RUN         ./getmem.nwchem

ENV         NWCHEM_EXECUTABLE=${NWCHEM_TOP}/bin/LINUX64/nwchem
ENV         NWCHEM_BASIS_LIBRARY=${NWCHEM_TOP}/src/basis/libraries/
ENV         NWCHEM_NWPW_LIBRARY=${NWCHEM_TOP}/src/nwpw/libraryps/
ENV         FFIELD=amber
ENV         AMBER_1=${NWCHEM_TOP}/src/data/amber_s/
ENV         AMBER_2=${NWCHEM_TOP}/src/data/amber_q/
ENV         AMBER_3=${NWCHEM_TOP}/src/data/amber_x/
ENV         AMBER_4=${NWCHEM_TOP}/src/data/amber_u/
ENV         SPCE=${NWCHEM_TOP}/src/data/solvents/spce.rst
ENV         CHARMM_S=${NWCHEM_TOP}/src/data/charmm_s/
ENV         CHARMM_X=${NWCHEM_TOP}/src/data/charmm_x/
ENV         PATH=$PATH:${NWCHEM_TOP}/bin/LINUX64

WORKDIR     /data
ENTRYPOINT  ["nwchem"]
