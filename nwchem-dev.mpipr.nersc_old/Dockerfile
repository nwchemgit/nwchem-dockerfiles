
#based on earlier work by Vladimir Konjkov <Konjkov.VV@gmail.com>
#
# Create the image with the command
# docker build -t nwchem-702.mpipr.nersc .
# 
#after successful build one you can execute the QA tests using the command
#docker run nwchem-702.mpipr.nersc dft_he2+ h2o_dk h2o_opt
#

FROM        ubuntu

MAINTAINER  Edoardo Apra <edoardo.apra@pnnl.gov>

#create user nwchem
RUN           groupadd -r nwchem -g 1994 \
              && useradd  -u 1994 -r -g nwchem -c 'NWChem user' -m -d /opt/nwchem -s /bin/bash nwchem 

#caching from host cache dir
COPY Dockerfile cache* /tmp/

ARG DEBIAN_FRONTEND=noninteractive
ARG mpich=3.3
ARG mpich_prefix=mpich-$mpich
#get OpenBLAS and compile with 64-bit integers
WORKDIR     /opt
ENV         ARMCI_NETWORK=MPI-PR NWCHEM_TOP="/opt/nwchem" \
            NWCHEM_TARGET=LINUX64 \
            NWCHEM_MODULES="all python" \
            BUILD_OPENBLAS=1 \
            BUILD_SCALAPACK=1 \
            BLAS_SIZE=8 \
            SCALAPACK_SIZE=8 \
            USE_OPENMP=1 \
#            USE_LIBXC=1 \
            USE_NOIO=1 \
#	    USE_SIMINT=1 \
#	    SIMINT_MAXAM=4 \
#	    SIMINT_VECTOR=AVX2 \
	    EACCSD=Y \
	    IPCCSD=Y \
#	    CUDA_VERSION_MAJOR=11 \
#	    CUDA_VERSION_MINOR=5 \
#	    PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/cuda-"$CUDA_VERSION_MAJOR"."$CUDA_VERSION_MINOR"/bin:/opt/nwchem/bin:/usr/local/bin \
#	    LD_LIBRARY_PATH=/usr/local/cuda-"$CUDA_VERSION_MAJOR"."$CUDA_VERSION_MINOR"/lib64:/usr/local/lib  \
#	    TCE_CUDA=Y \
#	    CUDA_LIBS="-L/usr/local/cuda/lib64 -lcudart" \
#	    CUDA_INCLUDE="-I. -I/usr/local/cuda/include" \
	    USE_HWOPT=n  \
            USE_MPI=y \
            USE_MPIF=y \
            USE_MPIF4=y 
#ENV         MRCC_METHODS=y
#ENV         CCSDTQ=y
#ENV         CCSDTLR=y
SHELL ["/bin/bash","-c"]
RUN         apt-get update \
            && apt-get -y upgrade \
            && apt-get install -y  g++ gfortran   make ssh patch curl  wget unzip perl git file python3 python3-dev \
            && apt-get clean \
    && wget --progress=dot:giga https://www.mpich.org/static/downloads/$mpich/$mpich_prefix.tar.gz && \
    tar xvzf $mpich_prefix.tar.gz                                           && \
    cd $mpich_prefix                                                        && \
    FFLAGS=-fallow-argument-mismatch ./configure                            && \
    make FFLAGS=-fallow-argument-mismatch  -j 4                             && \
    make install                                                            && \
    make clean                                                              && \
    cd ..                                                                   && \
    rm -rf $mpich_prefix \
            &&  rm -rf /opt/nwchem || true \
            && cd /opt;git clone --depth 1  https://github.com/nwchemgit/nwchem.git  \
            && cd nwchem/src \
#strip native compiler options as Fedora does
            && make nwchem_config && make -j3  \
#clean unnecessary source to reduce docker size
            && rm -rf tce tools nwdft NWints geom symmetry util nwxc ddscf lapack blas rism argos peigs rmdft gradients symmetry property smd lucia dplot property hessian ccsd mp2_grad moints cafe analyz dimqm /opt/nwchem/lib libext/scalapack libext/openblas  develop ../QA  ../contrib ../examples ../.git ../travis ../web nwpw/nwpwlib/nwpwxc rdmft ../doc libext/libxc/libxc* libext/mpich  /tmp/libext || true \
	    && strip ../bin/$NWCHEM_TARGET/nwchem \
	    && cd libext \
	    && rm -rf lib/* libxc/install/lib/* ||true \
	    && cd .. \
#clean unnecessary packages
            && DEBIAN_FRONTEND=noninteractive apt-get -y install localepurge \
	    && echo MANDELETE >  /etc/locale.nopurge \
	    && echo DONTBOTHERNEWLOCALE >> /etc/locale.nopurge \
	    && echo en_US.UTF-8 >> /etc/locale.nopurge \
	    && localepurge \
	    && rm -rf /usr/share/doc \
            &&       apt-get -y purge   patch curl  wget unzip make git cpp-9 gfortran-9 gcc-9  \
            && apt-get -y install libgfortran5 && apt-get clean \
	    && dpkg-query -Wf '${Installed-Size}\t${Package}\n' | sort -n | tail -n 100
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
RUN         apt-get -y remove  make curl  unzip cmake   &&  apt-get -y autoremove && apt-get clean

WORKDIR     /data
ENTRYPOINT  ["mpirun","-np","3","nwchem"]
