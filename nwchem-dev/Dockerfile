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
            && apt-get install -y python-dev gfortran  mpich2 libmpich2-dev  make curl subversion  unzip cmake perl tcsh ssh \
            &&  apt-get clean
#get OpenBLAS using the default 32bit ints to work with Scalapack
WORKDIR     /opt
RUN         mkdir -p lib  \
            &&  curl -L https://github.com/xianyi/OpenBLAS/archive/develop.zip -o develop.zip && unzip develop.zip ; rm develop.zip
WORKDIR     OpenBLAS-develop
#TARGET=CORE2 for compatibility
RUN         make -j3  TARGET=CORE2 NO_CBLAS=1 NO_LAPACKE=1 && cp libopenblas.* /opt/lib \
            && rm -rf /opt/OpenBLAS-develop
# build scalapack 
WORKDIR     /opt
#RUN         svn --trust-server-cert co https://icl.cs.utk.edu/svn/scalapack-dev/scalapack/trunk scalapack
#WORKDIR     scalapack
RUN         curl http://www.netlib.org/scalapack/scalapack-2.0.2.tgz -o scalapack-2.0.2.tgz \ 
            &&  tar xzf scalapack-2.0.2.tgz && rm scalapack-2.0.2.tgz \
            && mkdir -p /opt/scalapack-2.0.2/build
WORKDIR     /opt/scalapack-2.0.2/build
RUN         cmake ../ -DCMAKE_BUILD_TYPE=MinSizeRel -DBUILD_TESTING=OFF -DBUILD_SHARED_LIBS=ON -DUSE_OPTIMIZED_LAPACK_BLAS=ON -DBLAS_blas_LIBRARY="/opt/lib/libopenblas.so" -DLAPACK_lapack_LIBRARY="/opt/lib/libopenblas.so" \
            && make -j3 \
            && cp /opt/scalapack-2.0.2/build/lib/libscalapack.* /opt/lib/. \
            && rm -rf /opt/scalapack-2.0.2
WORKDIR     /opt
RUN         mkdir -p nwchem 
WORKDIR     nwchem
ENV         NWCHEM_TARGET=LINUX64
ENV         NWCHEM_MODULES="all python"
ENV         PYTHONVERSION=2.7
ENV         PYTHONHOME="/usr"
ENV         USE_PYTHONCONFIG=Y
ENV         ARMCI_NETWORK=MPI-PT
ENV         BLASOPT="-L/opt/lib -lopenblas"
ENV         BLAS_SIZE=4
ENV         SCALAPACK_LIB="-L/opt/lib -lscalapack"
ENV         SCALAPACK_SIZE=4
ENV         LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/opt/lib
ENV         USE_OPENMP=y
ENV         USE_NOIO=y
ENV         USE_64TO32=y
ENV         USE_MPI=y
ENV         USE_MPIF=y
ENV         USE_MPIF4=y
ENV         MRCC_METHODS=y
#ENV         CCSDTQ=y
#ENV         CCSDTLR=y
#one single ugly command to reduce docker size
RUN         svn export https://svn.pnl.gov/svn/nwchem/trunk/src \
            && cd    ${NWCHEM_TOP}/src/tools \
            && svn export --non-interactive --username nwchem --password nwchem https://svn.pnl.gov/svn/hpctools/branches/ga-5-5  \
            && cd .. \
#strip native compiler options as Fedora does
            && sed -i 's|-march=native||' config/makefile.h \
            && sed -i 's|-mtune=native|-mtune=generic|' config/makefile.h \
            && sed -i 's|-mfpmath=sse||' config/makefile.h \
            && sed -i 's|-msse3||' config/makefile.h  \
            && make nwchem_config && make 64_to_32;make -j3 \
#clean unnecessary source to reduce docker size
            && rm -rf tce tools nwdft NWints geom symmetry util nwxc ddscf lapack blas rism argos peigs rmdft gradients symmetry property smd lucia dplot propery hessian ccsd mp2_grad moints cafe analyz dimqm /opt/nwchem/lib
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

#clean unnecessary packages
RUN         apt-get -y remove  make curl subversion  unzip cmake perl tcsh  &&  apt-get -y autoremove && apt-get clean

WORKDIR     /data
ENTRYPOINT  ["nwchem"]

#CMD ["/bin/bash"]

