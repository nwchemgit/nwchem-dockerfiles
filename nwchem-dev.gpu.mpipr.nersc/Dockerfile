#based on earlier work by Vladimir Konjkov <Konjkov.VV@gmail.com>
#
# Create the image with the command
# docker build -t nwchem-dev.gpu.mpipr.nersc .
# 
#

FROM        ubuntu:20.04

MAINTAINER  Edoardo Apra <edoardo.apra@pnnl.gov>

#create user nwchem
RUN           groupadd -r nwchem -g 1994 \
              && useradd  -u 1994 -r -g nwchem -c 'NWChem user' -m -d /opt/nwchem -s /bin/bash nwchem 

#caching from host cache dir
COPY Dockerfile cache* /tmp/

ARG DEBIAN_FRONTEND=noninteractive
ARG mpich=3.3 
ARG     mpich_prefix=mpich-$mpich 
ARG	    CUDA_VERSION_MAJOR=11 \
	    CUDA_VERSION_MINOR=6 
ARG	    PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/cuda-"$CUDA_VERSION_MAJOR"."$CUDA_VERSION_MINOR"/bin:/opt/nwchem/bin:/usr/local/bin \
	    LD_LIBRARY_PATH=/usr/local/cuda-"$CUDA_VERSION_MAJOR"."$CUDA_VERSION_MINOR"/lib64:/usr/local/lib  \
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
            USE_LIBXC=1 \
            USE_NOIO=1 \
	    USE_SIMINT=1 \
	    SIMINT_MAXAM=4 \
	    SIMINT_VECTOR=AVX2 \
	    EACCSD=Y \
	    IPCCSD=Y \
	    CUDA_VERSION_MAJOR=11 \
	    CUDA_VERSION_MINOR=6 \
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
SHELL ["/bin/bash","-c"]
RUN         apt-get update \
            && apt-get -y upgrade \
            && apt-get install -y  g++ gfortran make ssh patch curl rsync wget unzip perl git file python3 python3-dev bzip2 tar gnupg2 \
	    && wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin \
            && mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600 \
            && apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/7fa2af80.pub \
            && echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/ /" >> /etc/apt/sources.list \
            && apt-get update \
            && apt-get -y install cuda-nvcc-"$CUDA_VERSION_MAJOR"-"$CUDA_VERSION_MINOR" cuda-cudart-dev-"$CUDA_VERSION_MAJOR"-"$CUDA_VERSION_MINOR" \
#	    && echo "********** end  of CUDA installation *****" \
	    && env|egrep PATH \
	    && rm -f nvcc.out && nvcc -V >& nvcc.out && cat nvcc.out && rm nvcc.out \
            && apt-get clean \
	    && echo 'checking cache #2 ' \
            && if [[ -f /tmp/mpich.tar.bz2 ]]; then cd /usr/local ; tar xjf /tmp/mpich.tar.bz2; rm -rf /tmp/mpich.tar.bz2 ; \
    else  echo 'downloading mpich source' ; \
    wget https://www.mpich.org/static/downloads/$mpich/$mpich_prefix.tar.gz ; \
    tar xzf $mpich_prefix.tar.gz                                           ; \
    cd $mpich_prefix                                                        ; \
    ./configure                                                             ; \
    echo 'redirecting output to make.log'                                   ; \
    make -j 4  >& make.log                                                  ; \
    echo 'mpich compiled' ; \
    tail make.log         ; \
    echo 'redirecting output to install.log'                                   ; \
    make install    >& install.log                                        ; \
    tail install.log ; \
    cd ..                                                                   ; \
    rm -rf $mpich_prefix ; echo 'mpich step done'; fi \
            && echo 'after mpich compilation ' \
            && rm -f mpif90.show && /usr/local/bin/mpif90 -show >& mpif90.show && cat mpif90.show && rm -f mpif90.show \
	    && echo 'cd /opt' \
            &&  cd /opt  \
	    && rm -rf nwchem \
	    && echo 'cloning nwchem source' \
            && git clone --depth 1  https://github.com/nwchemgit/nwchem.git  \
	    && echo '**** cloning done ' \
	    && rm -f pwd.out && pwd >& pwd.out && cat pwd.out && rm pwd.out \
	    && rm -f ls.out && ls -la nwchem >& ls.out && cat ls.out && rm ls.out \
	    && echo '*** ls pwd done **' || true \
	    && ls -lrta \
	    && ls -lrta nwchem  \
            && cd nwchem/src \
	    && echo 'checking cache #1 ' \
            && if [[ -f /tmp/libext.tar.bz2 ]]; then cd libext ; tar xjf /tmp/libext.tar.bz2; rm -rf /tmp/libext.tar.bz2 ; cd ..  ; fi\
	    && echo 'checking cache #3 ' \
            && if [[ -f /tmp/simint.tar.bz2 ]]; then cd NWints/simint/libsimint_source ; tar xjf /tmp/simint.tar.bz2; rm -rf /tmp/simint.tar.bz2 ; cd ../../..  ; fi\
            && cd /opt/nwchem/src && make nwchem_config && make V=-1 CUDA=nvcc -j3  ||true \
            &&  CUDA=nvcc   ../contrib/getmem.nwchem 1000  || true \
	    && ls -lrt libext/libxc \
	    && strip ../bin/$NWCHEM_TARGET/nwchem \
	    && ln -sf ../bin/$NWCHEM_TARGET/nwchem ../bin/nwchem \
	    && rm libext/libxc/install/bin/xc* || true \
	    && ls -lrt libext/libxc \
	    && cd libext ; tar cjvf libext.tar.bz2 lib/* libxc/install/lib/* libxc/install/include/* ||true \
	    && rm -rf lib/* libxc/install/lib/* libext_utils/* ||true \
	    && cd $NWCHEM_TOP/src/NWints/simint/libsimint_source/ ; tar cjvf $NWCHEM_TOP/src/libext/simint.tar.bz2 simint_install/* || true \
	    && rm -rf simint* *simint-generator* \
	    && cd $NWCHEM_TOP/src \
            && echo 'clean unnecessary source to reduce docker size' \
            && rm -rf tce tools nwdft NWints geom symmetry util nwxc ddscf lapack blas rism argos peigs rmdft gradients symmetry property smd lucia dplot property hessian ccsd mp2_grad moints cafe analyz dimqm /opt/nwchem/lib libext/scalapack libext/openblas  develop ../QA  ../contrib ../examples ../.git ../travis ../web nwpw/nwpwlib/nwpwxc rdmft ../doc libext/libxc/libxc* libext/mpich  /tmp/libext /tmp/local || true \
	    && cd /usr/local ; tar cjvf mpich.tar.bz2 lib/* include/* bin/* share/* ||true \
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
ENV         FFIELD=amber \
            AMBER_1=${NWCHEM_TOP}/src/data/amber_s/ \
            AMBER_2=${NWCHEM_TOP}/src/data/amber_q/ \
            AMBER_3=${NWCHEM_TOP}/src/data/amber_x/ \
            AMBER_4=${NWCHEM_TOP}/src/data/amber_u/ \
            SPCE=${NWCHEM_TOP}/src/data/solvents/spce.rst \
            CHARMM_S=${NWCHEM_TOP}/src/data/charmm_s/ \
            CHARMM_X=${NWCHEM_TOP}/src/data/charmm_x/ \
	    CUDA_VERSION_MAJOR=11 \
	    CUDA_VERSION_MINOR=6 \
	    LD_LIBRARY_PATH=/usr/local/cuda-"$CUDA_VERSION_MAJOR"."$CUDA_VERSION_MINOR"/lib64 \
	    PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/cuda-"$CUDA_VERSION_MAJOR"."$CUDA_VERSION_MINOR"/bin:/opt/nwchem/bin 

#clean unnecessary packages
#RUN         apt-get -y remove  make curl  unzip cmake   &&  apt-get -y autoremove && apt-get clean

USER        nwchem

WORKDIR     /data
ENTRYPOINT  ["mpirun","-np","3","nwchem"]
