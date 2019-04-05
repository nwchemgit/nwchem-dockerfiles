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

RUN         apt-get update \
            && apt-get -y upgrade \
            && apt-get install -y python-dev gfortran  mpich libmpich-dev  make curl subversion  unzip cmake perl tcsh ssh git file \
            &&  apt-get clean \
#get OpenBLAS using the default 32bit ints to work with Scalapack
            && mkdir -p /opt \
            && cd /opt \
            &&  mkdir -p lib  \
            &&  curl -L https://github.com/xianyi/OpenBLAS/archive/develop.zip -o develop.zip && unzip develop.zip ; rm develop.zip \
            && cd     OpenBLAS-develop \
#TARGET=CORE2 for compatibility
            && make -j3  INTERFACE64=0 NO_CBLAS=1 NO_LAPACKE=1 NUM_THREADS=1  USE_THREAD=0 all      && cp libopenblas.* /opt/lib \
            && rm -rf /opt/OpenBLAS-develop \
# build scalapack 
            && cd     /opt \
#RUN         svn --trust-server-cert co https://icl.cs.utk.edu/svn/scalapack-dev/scalapack/trunk scalapack
#WORKDIR     scalapack
            &&         curl http://www.netlib.org/scalapack/scalapack-2.0.2.tgz -o scalapack-2.0.2.tgz \ 
            &&  tar xzf scalapack-2.0.2.tgz && rm scalapack-2.0.2.tgz \
            && mkdir -p /opt/scalapack-2.0.2/build \
            && cd   /opt/scalapack-2.0.2/build \
            &&      cmake ../ -DCMAKE_BUILD_TYPE=MinSizeRel -DBUILD_TESTING=OFF -DBUILD_SHARED_LIBS=ON -DUSE_OPTIMIZED_LAPACK_BLAS=ON -DBLAS_blas_LIBRARY="/opt/lib/libopenblas.so" -DLAPACK_lapack_LIBRARY="/opt/lib/libopenblas.so" \
            && make -j3 \
            && cp /opt/scalapack-2.0.2/build/lib/libscalapack.* /opt/lib/. \
            && rm -rf /opt/scalapack-2.0.2
ENV         NWCHEM_TOP="/opt/nwchem" \
            NWCHEM_TARGET=LINUX64  \
            NWCHEM_MODULES="all python"  \
            PYTHONVERSION=2.7  \
            PYTHONHOME="/usr"  \
            USE_PYTHONCONFIG=Y  \
            ARMCI_NETWORK=MPI-PT  \
            BLASOPT="-L/opt/lib -lopenblas"  \
            LAPACK_LIB="-L/opt/lib -lopenblas"  \
            BLAS_SIZE=4  \
            SCALAPACK_LIB="-L/opt/lib -lscalapack"  \
            SCALAPACK_SIZE=4  \
            LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/lib  \
            USE_OPENMP=y  \
            USE_NOIO=y  \
            USE_64TO32=y  \
            USE_MPI=y  \
            USE_MPIF=y  \
            USE_MPIF4=y  \
            NWCHEM_EXECUTABLE=${NWCHEM_TOP}/bin/LINUX64/nwchem \
            NWCHEM_BASIS_LIBRARY=${NWCHEM_TOP}/src/basis/libraries/ \
            NWCHEM_NWPW_LIBRARY=${NWCHEM_TOP}/src/nwpw/libraryps/  \
            FFIELD=amber  \
            AMBER_1=${NWCHEM_TOP}/src/data/amber_s/  \
            AMBER_2=${NWCHEM_TOP}/src/data/amber_q/  \
            AMBER_3=${NWCHEM_TOP}/src/data/amber_x/  \
            AMBER_4=${NWCHEM_TOP}/src/data/amber_u/  \
            SPCE=${NWCHEM_TOP}/src/data/solvents/spce.rst  \
            CHARMM_S=${NWCHEM_TOP}/src/data/charmm_s/  \
            CHARMM_X=${NWCHEM_TOP}/src/data/charmm_x/  \
            PATH=$PATH:/opt/nwchem/bin/LINUX64 
#one single ugly command to reduce docker size
RUN        cd /opt; git clone --depth 1  https://github.com/nwchemgit/nwchem.git  \
            && cd nwchem/src \
#strip native compiler options as Fedora does
            && sed -i 's|-march=native||' config/makefile.h \
            && sed -i 's|-mtune=native|-mtune=generic|' config/makefile.h \
            && sed -i 's|-mfpmath=sse||' config/makefile.h \
            && sed -i 's|-msse3||' config/makefile.h  \
            && make nwchem_config && make 64_to_32   && make -j3 \
#clean unnecessary source to reduce docker size
            && rm -rf tce tools nwdft NWints geom symmetry util nwxc ddscf lapack blas rism argos peigs rmdft gradients symmetry property smd lucia dplot propery hessian ccsd mp2_grad moints cafe analyz dimqm /opt/nwchem/lib \
#clean unnecessary packages
            &&       apt-get -y remove  make curl subversion  unzip cmake perl tcsh  &&  apt-get -y autoremove && apt-get clean

WORKDIR     /data
ENTRYPOINT  ["nwchem"]

#CMD ["/bin/bash"]

