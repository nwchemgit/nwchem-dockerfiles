#
#based on earlier work by Vladimir Konjkov <Konjkov.VV@gmail.com>
#
# Create the image with the command
# docker build -t nwchem-702.mpipr.nersc .
# 
#after successful build one you can execute the QA tests using the command
#docker run nwchem-702.mpipr.nersc dft_he2+ h2o_dk h2o_opt

FROM ubuntu:jammy

LABEL maintainer="Edoardo Apra <edoardo.apra@pnnl.gov>"

LABEL org.opencontainers.image.description "TAMM CC Shifter image built with Mpich 4.0"

#create user nwchem
RUN           groupadd -r nwchem -g 1994 \
              && useradd  -u 1994 -r -g nwchem -c 'NWChem user' -m -d /opt/nwchem -s /bin/bash nwchem 

#caching from host cache dir
COPY Dockerfile cache* /tmp/

ARG DEBIAN_FRONTEND=noninteractive
ARG USE_OPENMP_VALUE
ARG         FC
ENV         FC=${FC}
ENV         GITHUB_REPOSITORY_OWNER=$GITHUB_REPOSITORY_OWNER
ARG mpich=4.0.2
ARG mpich_prefix=mpich-$mpich
ARG	    CUDA_VERSION_MAJOR=11 \
	    CUDA_VERSION_MINOR=7
ARG	    PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/cuda-"$CUDA_VERSION_MAJOR"."$CUDA_VERSION_MINOR"/bin:/opt/nwchem/bin:/usr/local/bin \
	    LD_LIBRARY_PATH=/usr/local/cuda-"$CUDA_VERSION_MAJOR"."$CUDA_VERSION_MINOR"/lib64:/usr/local/lib  
#get OpenBLAS and compile with 64-bit integers
WORKDIR     /opt
#ENV CRAYPE_LINK_TYPE=dynamic
ENV	    CUDA_VERSION_MAJOR=11 
ENV	    CUDA_VERSION_MINOR=7
ENV         GCC_VERSION=11
ENV         PY_VERSION=3.11
ENV	    PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/cuda-"$CUDA_VERSION_MAJOR"."$CUDA_VERSION_MINOR"/bin:/opt/nwchem/bin:/usr/local/bin \
	    LD_LIBRARY_PATH=/usr/local/cuda-"$CUDA_VERSION_MAJOR"."$CUDA_VERSION_MINOR"/lib64:/usr/local/lib  
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN         apt-get -q=2 update \
            && apt-get -q=2 -y upgrade \
            && apt-get install -q=2 -y  gcc-"$GCC_VERSION"  g++-"$GCC_VERSION" gfortran-"$GCC_VERSION"   make ssh patch curl rsync wget git file python"$PY_VERSION" libpython"$PY_VERSION"-dev python"$PY_VERSION"-dev bzip2 tar gnupg2 cmake \
            && apt-get install  -q=2 -y  autoconf automake libtool git \
	    && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-"$GCC_VERSION" 100 \
	    && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-"$GCC_VERSION" 100 \
	    && update-alternatives --install /usr/bin/gfortran gfortran /usr/bin/gfortran-"$GCC_VERSION" 100 \
	    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 100 \
	    && update-alternatives --install /usr/bin/python3-config python3-config /usr/bin/python3.11-config 100 \
	    && echo FCFCFC is $FC \
	    && [[ -z "${FC}" ]] && FC=gfortran \
            &&  VERSION=$(gfortran -dumpversion  | cut -f1 -d. ) \
	    && echo "VERSION is " $VERSION   >& nvcc.out && cat nvcc.out && rm nvcc.out \
	    && echo "expr is " $(which expr)  >& nvcc.out && cat nvcc.out && rm nvcc.out \
            &&  VERSIONGT9=$(/usr/bin/expr "$VERSION"  \> 9)  || true \
	    && echo "VERSIONGT9 is " $VERSIONGT9   >& nvcc.out && cat nvcc.out && rm nvcc.out \
	    && if [[ "$FC" == gfortran ]] && [[ "$VERSIONGT9" == 1 ]]; then export FFLAGS_IN="-fallow-argument-mismatch"; else  FFLAGS_IN=" "; fi \
	    && echo "VERSIONGT9 is " $VERSIONGT9 \
	    && echo "FFLAGS_IN is " $FFLAGS_IN \
            && echo "FFLAGS_IN is " $FFLAGS_IN 	>& nvcc.out && cat nvcc.out && rm nvcc.out \
	    && echo GITHUB_REPOSITORY_OWNER is $GITHUB_REPOSITORY_OWNER \
	    && curl -LJO https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-archive-keyring.gpg \
            && cp cuda-archive-keyring.gpg /usr/share/keyrings/cuda-archive-keyring.gpg \
            && echo "deb [signed-by=/usr/share/keyrings/cuda-archive-keyring.gpg] https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/ /" |  tee /etc/apt/sources.list.d/cuda-ubuntu2204-x86_64.list \
            &&  curl -LJO https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-ubuntu2204.pin \
            && mv cuda-*.pin /etc/apt/preferences.d/cuda-repository-pin-600 \
	    && apt-get -q=2 update \
            && apt-get -q=2 -y install cuda-nvcc-"$CUDA_VERSION_MAJOR"-"$CUDA_VERSION_MINOR" cuda-cudart-dev-"$CUDA_VERSION_MAJOR"-"$CUDA_VERSION_MINOR" libcublas-dev-"$CUDA_VERSION_MAJOR"-"$CUDA_VERSION_MINOR"  \
	    && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-"$GCC_VERSION" 1000 \
	    && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-"$GCC_VERSION" 1000 \
	    && update-alternatives --install /usr/bin/gfortran gfortran /usr/bin/gfortran-"$GCC_VERSION" 1000 \
	    && env|egrep PATH \
            && arch=$(uname -m) \
	    && echo arch is "$arch" \
	    && arch_dpkg=$(dpkg --print-architecture)  \
	    && echo 'FC -v ' $("$FC" -v) \
	    && rm -f nvcc.out && nvcc -V >& nvcc.out && cat nvcc.out && rm nvcc.out \
            && apt-get clean \
	    && echo 'checking cache #2 ' \
            && if [[ -f /tmp/mpich.tar.bz2 ]]; then cd /usr/local ; tar xjf /tmp/mpich.tar.bz2; rm -rf /tmp/mpich.tar.bz2 ; \
    else  echo 'downloading mpich source' ; \
    wget --progress=dot:giga https://www.mpich.org/static/downloads/$mpich/$mpich_prefix.tar.gz -O - | tar xzf - ; \
    cd $mpich_prefix || { echo "Failure"; exit 1; } ;\
    FFLAGS=$FFLAGS_IN FCFLAGS=$FFLAGS_IN ./configure --silent --enable-silent-rules ; \
    echo 'redirecting output to make.log'                                   ; \
    make -j 4 FFLAGS=$FFLAGS_IN  >& make.log                 ; \
    echo executing "make -j 4 FFLAGS=$FFLAGS_IN  "                 ; \
    echo 'mpich compiled' ; \
    tail -300 make.log         ; \
    echo 'redirecting output to install.log'                                   ; \
    make install    >& install.log                                        ; \
    tail install.log ; \
    cd ..                                                                   ; \
    rm -rf $mpich_prefix ; echo 'mpich step done'; fi \
            && echo 'after mpich compilation ' \
            && rm -f mpicc.show && /usr/local/bin/mpicc -show >& mpicc.show && echo "mpicc show" `cat mpicc.show` && rm -f mpicc.show \
	    && echo 'cloning tamm source *** ' || true \
            && cd /opt || { echo "Failure"; exit 1; } \
            && git clone --depth 1  https://github.com/NWChemEx-Project/CoupledCluster.git CoupledCluster  \
	    && cd CoupledCluster && mkdir build && cd build \
	    && old_ifs="$IFS" && echo old ifs "$IFS" | cat -et && IFS=":" \
            && export CMAKE_OPTIONS="-DCMAKE_CXX_FLAGS='-march=znver3 -O3':-DCMAKE_C_FLAGS='-march=znver3 -O3':-DCMAKE_Fortran_FLAGS='-march=znver3 -O3':-DCMAKE_CXX_FLAGS_RELEASE='-march=znver3 -O3':-DCMAKE_C_FLAGS_RELEASE='-march=znver3 -O3':-DCMAKE_Fortran_FLAGS_RELEASE='-march=znver3 -O3':-DCMAKE_INSTALL_PREFIX=$SCRATCH/install/CC:-DUSE_CUDA=ON:-DBLIS_CONFIG=generic:-DMARCH_FLAGS='-march=znver3 -O3'" \
	    && FC=gfortran cmake  $CMAKE_OPTIONS .. \
	    && IFS="$oldifs" \
            && make -j3 CFLAGS="-march=znver3 -O3" CXXFLAGS="-march=znver3 -O3" FCFLAGS="-march=znver3 -O3" \
            && make install \
            && echo 'clean unnecessary source to reduce docker size' \
            && cd /opt && rm  -rf CoupledCluster \
	    && cd /opt/install/CC/share/libint/2.7.2/basis/ \
	    && wget -O aug-cc-pvdz.g94 "https://www.basissetexchange.org/download_basis/basis/aug-cc-pvdz/format/gaussian94/?version=1&elements=1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36&optimize_general=true&uncontract_general=true" \
	    && wget -O aug-cc-pvtz.g94 "https://www.basissetexchange.org/download_basis/basis/aug-cc-pvtz/format/gaussian94/?version=1&elements=1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36&optimize_general=true&uncontract_general=true" \
	    && wget -O aug-cc-pvqz.g94 "https://www.basissetexchange.org/download_basis/basis/aug-cc-pvqz/format/gaussian94/?version=1&elements=1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36&optimize_general=true&uncontract_general=true" \
	    && cd /usr/local || { echo "Failure"; exit 1; } ; tar cjvf mpich.tar.bz2 lib/* include/* bin/* share/* ||true \
            && echo 'clean unnecessary packages ' \
            && DEBIAN_FRONTEND=noninteractive apt-get -q=2 -y install localepurge \
	    && echo MANDELETE >  /etc/locale.nopurge \
	    && echo DONTBOTHERNEWLOCALE >> /etc/locale.nopurge \
	    && echo en_US.UTF-8 >> /etc/locale.nopurge \
	    && localepurge \
	    && rm -rf /usr/share/doc \
            &&  apt-get -q=2 -y purge   patch curl  wget  make git cpp-"$GCC_VERSION" gfortran-"$GCC_VERSION" gcc-"$GCC_VERSION" libicu-dev libpython"$PY_VERSION"-dev libstdc++-"$GCC_VERSION"-dev libc6-dev libgcc-"$GCC_VERSION"-dev libgfortran-"$GCC_VERSION"-dev  || true \
            && apt-get -q=2 -y install libgfortran5 libgomp1 && apt-get clean \
	    && apt-get purge -y cuda-cccl-"$CUDA_VERSION_MAJOR"-"$CUDA_VERSION_MINOR" libcublas-dev-"$CUDA_VERSION_MAJOR"-"$CUDA_VERSION_MINOR" \
            && chown -R nwchem /opt/nwchem && chgrp -R nwchem /opt/nwchem \
	    && echo '*** ls -l nwchem **' \
	    && ls -l /opt/install/CC/bin/ || true \
	    && echo '*** ldd ***'  \
	    && LD_LIBRARY_PATH=/usr/local/lib:/opt/lib ldd /opt/install/CC/bin/CCSD_T || true \
	    && dpkg-query -Wf '${Installed-Size}\t${Package}\n' | sort -n | tail -n 100
#ENV         NWCHEM_EXECUTABLE=${NWCHEM_TOP}/bin/LINUX64/nwchem
#ENV         NWCHEM_BASIS_LIBRARY=${NWCHEM_TOP}/src/basis/libraries/
#ENV         NWCHEM_NWPW_LIBRARY=${NWCHEM_TOP}/src/nwpw/libraryps/
ENV	    CUDA_VERSION_MAJOR=11 
ENV	    CUDA_VERSION_MINOR=7
ENV	    LD_LIBRARY_PATH=/usr/local/cuda-"$CUDA_VERSION_MAJOR"."$CUDA_VERSION_MINOR"/lib64:/opt/lib \
	    PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/cuda-"$CUDA_VERSION_MAJOR"."$CUDA_VERSION_MINOR"/bin:${NWCHEM_TOP}/bin/LINUX64:/usr/local/bin

#clean unnecessary packages
#RUN         apt-get -y remove  make curl  unzip cmake   &&  apt-get -y autoremove && apt-get clean

USER        nwchem

WORKDIR     /data
ENTRYPOINT  ["mpirun","-np","3","nwchem"]
