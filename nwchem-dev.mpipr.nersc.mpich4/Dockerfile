#based on earlier work by Vladimir Konjkov <Konjkov.VV@gmail.com>
#
# Create the image with the command
# docker build -t nwchem-702.mpipr.nersc .
# 
#after successful build one you can execute the QA tests using the command
#docker run nwchem-702.mpipr.nersc dft_he2+ h2o_dk h2o_opt
#

FROM ubuntu:focal

LABEL maintainer="Edoardo Apra <edoardo.apra@pnnl.gov>"

LABEL org.opencontainers.image.description "NWChem Shifter image built with Mpich 4.0"

#create user nwchem
RUN           groupadd -r nwchem -g 1994 \
              && useradd  -u 1994 -r -g nwchem -c 'NWChem user' -m -d /opt/nwchem -s /bin/bash nwchem 

#caching from host cache dir
COPY Dockerfile cache* /tmp/

ARG DEBIAN_FRONTEND=noninteractive
ARG USE_OPENMP_VALUE
ARG         FC
ARG         NWCHEM_BRANCH
ARG         GITHUB_REPOSITORY_OWNER
ARG         ARMCI_NETWORK
ENV         FC=${FC}
ENV         NWCHEM_BRANCH=$NWCHEM_BRANCH
ENV         GITHUB_REPOSITORY_OWNER=$GITHUB_REPOSITORY_OWNER
ENV         ARMCI_NETWORK=$ARMCI_NETWORK
ARG mpich=4.0.2
ARG mpich_prefix=mpich-$mpich
ARG	    CUDA_VERSION_MAJOR=11 \
	    CUDA_VERSION_MINOR=8
ARG	    PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/cuda-"$CUDA_VERSION_MAJOR"."$CUDA_VERSION_MINOR"/bin:/opt/nwchem/bin:/usr/local/bin \
	    LD_LIBRARY_PATH=/usr/local/cuda-"$CUDA_VERSION_MAJOR"."$CUDA_VERSION_MINOR"/lib64:/usr/local/lib  
#get OpenBLAS and compile with 64-bit integers
WORKDIR     /opt
ENV         NWCHEM_TOP="/opt/nwchem" 
ENV	    CUDA_VERSION_MAJOR=11 
ENV	    CUDA_VERSION_MINOR=8 
ENV         NWCHEM_TARGET=LINUX64 \
            NWCHEM_MODULES="all python" \
            BUILD_OPENBLAS=1 \
            BUILD_SCALAPACK=1 \
            BLAS_SIZE=8 \
            SCALAPACK_SIZE=8 \
            USE_LIBXC=1 \
            USE_NOIO=1 \
	    USE_SIMINT=1 \
	    SIMINT_MAXAM=4 \
	    SIMINT_VECTOR=AVX2 \
	    EACCSD=Y \
	    IPCCSD=Y \
	    PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/cuda-"$CUDA_VERSION_MAJOR"."$CUDA_VERSION_MINOR"/bin:/opt/nwchem/bin:/usr/local/bin \
	    LD_LIBRARY_PATH=/usr/local/cuda-"$CUDA_VERSION_MAJOR"."$CUDA_VERSION_MINOR"/lib64:/usr/local/lib  \
	    TCE_CUDA=Y \
	    CUDA_LIBS="-L/usr/local/cuda/lib64 -lcudart" \
	    CUDA_INCLUDE="-I. -I/usr/local/cuda/include" \
	    USE_HWOPT=n  \
            USE_MPI=y \
            USE_MPIF=y \
            USE_MPIF4=y 
#ENV         MRCC_METHODS=y
#ENV         CCSDTQ=y
#ENV         CCSDTLR=y
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN         apt-get update \
            && apt-get -y upgrade \
            && apt-get install -y  g++ gfortran   make ssh patch curl rsync wget unzip perl git file python3 python3-dev bzip2 tar gnupg2 \
            && apt-get install -y  autoconf automake libtool git \
	    && echo FCFCFC is $FC \
	    && echo NWCHEM_BRANCH is $NWCHEM_BRANCH \
	    && echo GITHUB_REPOSITORY_OWNER is $GITHUB_REPOSITORY_OWNER \
	    && echo ARMCI_NETWORK is $ARMCI_NETWORK \
	    && rm -f nvcc.out && echo " Checking gfortran options "  >& nvcc.out && cat nvcc.out && rm nvcc.out \
            &&  VERSION=$(gfortran -dumpversion  | cut -f1 -d. ) \
	    && echo "VERSION is " $VERSION   >& nvcc.out && cat nvcc.out && rm nvcc.out \
	    && echo "expr is " $(which expr)  >& nvcc.out && cat nvcc.out && rm nvcc.out \
            &&  VERSIONGT9=$(/usr/bin/expr "$VERSION"  \> 9)  || true \
	    && echo "VERSIONGT9 is " $VERSIONGT9   >& nvcc.out && cat nvcc.out && rm nvcc.out \
	    && if [[ "$VERSIONGT9" == 1 ]]; then export FFLAGS_IN="fallow-argument-mismatch"; else  FFLAGS_IN=" "; fi \
	    && echo "VERSIONGT9 is " $VERSIONGT9 \
	    && echo "FFLAGS_IN is " $FFLAGS_IN \
            && echo "FFLAGS_IN is " $FFLAGS_IN 	>& nvcc.out && cat nvcc.out && rm nvcc.out \
	    && wget --progress=dot:giga https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.0-1_all.deb \
	    && dpkg -i cuda-keyring_1.0-1_all.deb \
	    && apt-get update \
            && apt-get -y install cuda-nvcc-"$CUDA_VERSION_MAJOR"-"$CUDA_VERSION_MINOR" cuda-cudart-dev-"$CUDA_VERSION_MAJOR"-"$CUDA_VERSION_MINOR" \
#	    && echo "********** end  of CUDA installation *****"  || true\
	    && env|egrep PATH \
	    && rm -f nvcc.out && nvcc -V >& nvcc.out && cat nvcc.out && rm nvcc.out \
            && apt-get clean \
	    && echo 'checking cache #2 ' \
            && if [[ -f /tmp/mpich.tar.bz2 ]]; then cd /usr/local ; tar xjf /tmp/mpich.tar.bz2; rm -rf /tmp/mpich.tar.bz2 ; \
    else  echo 'downloading mpich source' ; \
    wget --progress=dot:giga https://www.mpich.org/static/downloads/$mpich/$mpich_prefix.tar.gz -O - | tar xzf - ; \
    cd $mpich_prefix || { echo "Failure"; exit 1; } ;\
    FFLAGS=$FFLAGS_IN  ./configure    ; \
    echo 'redirecting output to make.log'                                   ; \
    make -j 4 FFLAGS=$FFLAGS_IN  >& make.log                 ; \
    echo 'mpich compiled' ; \
    tail -300 make.log         ; \
    echo 'redirecting output to install.log'                                   ; \
    make install    >& install.log                                        ; \
    tail install.log ; \
    cd ..                                                                   ; \
    rm -rf $mpich_prefix ; echo 'mpich step done'; fi \
            && echo 'after mpich compilation ' \
	    && ln -sf /bin/bash /usr/bin/bash \
            && rm -f mpif90.show && /usr/local/bin/mpif90 -show >& mpif90.show && cat mpif90.show && rm -f mpif90.show \
	    && echo 'cloning nwchem source *** ' || true \
            && cd /opt || { echo "Failure"; exit 1; } \
            &&  rm -rf nwchem || true \
            && git clone -b $NWCHEM_BRANCH --depth 1  https://github.com/nwchemgit/nwchem.git  \
            && if [[ "$USE_OPENMP_VALUE" != "N" ]]; then export USE_OPENMP="$USE_OPENMP_VALUE" ; fi	   \
            && echo " USE_OPENMP value is "  $USE_OPENMP  \
            && cd nwchem/src || { echo "Failure"; exit 1; } \
	    && echo 'checking cache #1 ' \
            && if [[ -f /tmp/libext.tar.bz2 ]]; then cd libext ; tar xjf /tmp/libext.tar.bz2; rm -rf /tmp/libext.tar.bz2 ; cd ..  ; fi\
	    && echo 'checking cache #3 ' \
            && if [[ -f /tmp/simint.tar.bz2 ]]; then cd NWints/simint/libsimint_source ; tar xjf /tmp/simint.tar.bz2; rm -rf /tmp/simint.tar.bz2 ; cd ../../..  ; fi\
	    && cd /opt/nwchem \
	    && wget -q https://github.com/edoapra/nwchem/commit/83a7d7d4b0a2d1cdefc9152cffee758278edb332.patch \
	    && patch -p1 -s -N < 83a7d7d4b0a2d1cdefc9152cffee758278edb332.patch ||true \
            && cd /opt/nwchem/src || { echo "Failure"; exit 1; } && make nwchem_config && make -j3  CUDA=nvcc ||true \
            &&  CUDA=nvcc   ../contrib/getmem.nwchem 1000  || true \
	    && ls -lrt libext/libxc \
	    && strip ../bin/$NWCHEM_TARGET/nwchem \
	    && rm libext/libxc/install/bin/xc* || true \
	    && ls -lrt libext/libxc \
	    && cd libext ; tar cjvf libext.tar.bz2 lib/* libxc/install/lib/* libxc/install/include/* ||true \
	    && rm -rf lib/* libxc/install/lib/* libext_utils/* ||true \
	    && cd $NWCHEM_TOP/src/NWints/simint/libsimint_source/ ; tar cjvf $NWCHEM_TOP/src/libext/simint.tar.bz2 simint_install/* || true \
	    && rm -rf simint* *simint-generator* \
	    && cd $NWCHEM_TOP/src || { echo "Failure"; exit 1; } \
            && echo 'clean unnecessary source to reduce docker size' \
            && rm -rf tce tools nwdft NWints geom symmetry util nwxc ddscf lapack blas rism argos peigs rmdft gradients symmetry property smd lucia dplot property hessian ccsd mp2_grad moints cafe analyz dimqm /opt/nwchem/lib libext/scalapack libext/openblas  develop ../QA  ../contrib ../examples ../.git ../travis ../web nwpw/nwpwlib/nwpwxc rdmft ../doc libext/libxc/libxc* libext/mpich  /tmp/libext /tmp/local || true \
	    && cd /usr/local || { echo "Failure"; exit 1; } ; tar cjvf mpich.tar.bz2 lib/* include/* bin/* share/* ||true \
            && echo 'clean unnecessary packages ' \
            && DEBIAN_FRONTEND=noninteractive apt-get -y install localepurge \
	    && echo MANDELETE >  /etc/locale.nopurge \
	    && echo DONTBOTHERNEWLOCALE >> /etc/locale.nopurge \
	    && echo en_US.UTF-8 >> /etc/locale.nopurge \
	    && localepurge \
	    && rm -rf /usr/share/doc \
            &&       apt-get -y purge   patch curl  wget unzip make git cpp-9 gfortran-9 gcc-9 libicu66 libpython3.8-dev libstdc++-9-dev libc6-dev libgcc-9-dev* libgfortran-9-dev   \
            && apt-get -y install libgfortran5 libgomp1 && apt-get clean \
            && chown -R nwchem /opt/nwchem && chgrp -R nwchem /opt/nwchem \
	    && dpkg-query -Wf '${Installed-Size}\t${Package}\n' | sort -n | tail -n 100
#ENV         NWCHEM_EXECUTABLE=${NWCHEM_TOP}/bin/LINUX64/nwchem
#ENV         NWCHEM_BASIS_LIBRARY=${NWCHEM_TOP}/src/basis/libraries/
#ENV         NWCHEM_NWPW_LIBRARY=${NWCHEM_TOP}/src/nwpw/libraryps/
ENV	    CUDA_VERSION_MAJOR=11 
ENV	    CUDA_VERSION_MINOR=8 
ENV         FFIELD=amber \
            AMBER_1=${NWCHEM_TOP}/src/data/amber_s/ \
            AMBER_2=${NWCHEM_TOP}/src/data/amber_q/ \
            AMBER_3=${NWCHEM_TOP}/src/data/amber_x/ \
            AMBER_4=${NWCHEM_TOP}/src/data/amber_u/ \
            SPCE=${NWCHEM_TOP}/src/data/solvents/spce.rst \
            CHARMM_S=${NWCHEM_TOP}/src/data/charmm_s/ \
            CHARMM_X=${NWCHEM_TOP}/src/data/charmm_x/ \
	    LD_LIBRARY_PATH=/usr/local/cuda-"$CUDA_VERSION_MAJOR"."$CUDA_VERSION_MINOR"/lib64 \
	    PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/cuda-"$CUDA_VERSION_MAJOR"."$CUDA_VERSION_MINOR"/bin:${NWCHEM_TOP}/bin/LINUX64:/usr/local/bin

#clean unnecessary packages
#RUN         apt-get -y remove  make curl  unzip cmake   &&  apt-get -y autoremove && apt-get clean

USER        nwchem

WORKDIR     /data
ENTRYPOINT  ["mpirun","-np","3","nwchem"]
