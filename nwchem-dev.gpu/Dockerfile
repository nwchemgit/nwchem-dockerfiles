#
# Create the image with the command
# docker build -t nwchem-dev .
# 
#after successful build one should run container to calculate input.nw file placed in <host_system_dir>
#docker run -dv <host_system_dir>:/data nwchem-dev "input.nw"
#this command return container ID to read logs by
#docker logs <container ID>
#

FROM        ubuntu:20.04

MAINTAINER  Edoardo Apra <edoardo.apra@pnnl.gov>

#caching from host cache dir
COPY Dockerfile cache* /tmp/

ARG DEBIAN_FRONTEND=noninteractive
ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1
ENV         NWCHEM_TOP="/opt/nwchem" 
ARG         NWCHEM_MODULES="tce"  \
            ARMCI_NETWORK=MPI-PR  \
            USE_OPENMP=1  \
            USE_NOIO=y  \
            USE_MPI=y  \
            USE_MPIF=y  \
            USE_MPIF4=y  \
	    BUILD_OPENBLAS=1 \
	    BUILD_SCALAPACK=1 \
	    BLAS_SIZE=8 \
	    SCALAPACK_SIZE=8 \
	    EACCSD=Y \
	    IPCCSD=Y \
	    CUDA_VERSION_MAJOR=11 \
	    CUDA_VERSION_MINOR=6 \
	    PATH=/usr/bin:/bin:/usr/sbin:/sbin:/opt/nwchem/bin \
#	    PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/cuda-"$CUDA_VERSION_MAJOR"."$CUDA_VERSION_MINOR"/bin:/opt/nwchem/bin \
#	    LD_LIBRARY_PATH=/usr/local/cuda-"$CUDA_VERSION_MAJOR"."$CUDA_VERSION_MINOR"/lib64  \
#	    CUDA_LIBS="-L/usr/local/cuda/lib64 -lcudart" \
#	    CUDA_INCLUDE="-I. -I/usr/local/cuda/include" \
	    USE_HWOPT=n 
#	    TCE_CUDA=Y \
ENV         FFIELD=amber  \
            AMBER_1=${NWCHEM_TOP}/src/data/amber_s/  \
            AMBER_2=${NWCHEM_TOP}/src/data/amber_q/  \
            AMBER_3=${NWCHEM_TOP}/src/data/amber_x/  \
            AMBER_4=${NWCHEM_TOP}/src/data/amber_u/  \
            SPCE=${NWCHEM_TOP}/src/data/solvents/spce.rst  \
            CHARMM_S=${NWCHEM_TOP}/src/data/charmm_s/  \
            CHARMM_X=${NWCHEM_TOP}/src/data/charmm_x/  \
	    OMPI_MCA_btl_vader_single_copy_mechanism=none \
	    OMP_NUM_THREADS=1 \
	    COMEX_MAX_NB_OUTSTANDING=16 \
	    CUDA_VERSION_MAJOR=11 \
	    CUDA_VERSION_MINOR=6 \
#	    LD_LIBRARY_PATH=/usr/local/cuda-"$CUDA_VERSION_MAJOR"."$CUDA_VERSION_MINOR"/lib64
	    PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/cuda-"$CUDA_VERSION_MAJOR"."$CUDA_VERSION_MINOR"/bin:/opt/nwchem/bin 
#get NWCHEM_TARGET
SHELL ["/bin/bash","-c"]
RUN arch=`uname -m` ; if [[ $arch == "x86_64" ]] || [[ $arch == "aarch64" ]] || [[ $arch == "riscv64" ]] || [[ $arch == "ppc64le" ]]; then echo "export NWCHEM_TARGET=LINUX64" > /tmpfile ; fi
RUN arch=`uname -m` ; arch_123=`uname -m|cut -c 1-3`; if [[ $arch == "i686" ]] || [[ $arch == "i386" ]] || [[ $arch_123 == "arm" ]] ; then echo "export NWCHEM_TARGET=LINUX" > /tmpfile ; fi
RUN . /tmpfile; echo "NWCHEM_TARGET is " $NWCHEM_TARGET

#one single ugly command to reduce docker size
RUN         apt-get update \
            && apt-get -y upgrade \
#            && apt-get install -y  python3-dev gfortran  mpich libmpich-dev  make curl   unzip cmake ssh git file wget \
            && apt-get install -y  rsync gfortran libopenmpi-dev openmpi-bin  make curl unzip cmake git file wget tar bzip2 gnupg2  \
	    && wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin \
            && mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600 \
            && apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/7fa2af80.pub \
            && echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/ /" >> /etc/apt/sources.list \
            && apt-get update \
            && apt-get -y install cuda-nvcc-"$CUDA_VERSION_MAJOR"-"$CUDA_VERSION_MINOR" cuda-cudart-dev-"$CUDA_VERSION_MAJOR"-"$CUDA_VERSION_MINOR" \
#	    && echo "********** end  of CUDA installation *****" \
	    && env|egrep PATH \
	    && rm -f nvcc.out && nvcc -V >& nvcc.out && cat nvcc.out && rm nvcc.out \
            && echo "**** start nwchem cloning *****" \
            && cd /opt; git clone --depth 1  https://github.com/nwchemgit/nwchem.git  \
            && cd nwchem/src \
#set NWCHEM_TARGET
            &&  . /tmpfile; echo "NWCHEM_TARGET is " $NWCHEM_TARGET \
#fix openblas cross-compilation
            && if [[ -f /tmp/libext/lib/libnwc_openblas.a ]]; then rsync -av /tmp/libext/* libext/. ; fi \
	    && nvcc -V \
#            && make nwchem_config    && make  FDEBUG="-O1 -g -fbacktrace" FOPTIMIZE="-O2 -g -fbacktrace" V=-1 -j3 \
#            &&  ../contrib/getmem.nwchem 1000  || true \
            && make nwchem_config    && make  CUDA=nvcc FDEBUG="-O1 -g -fbacktrace" FOPTIMIZE="-O2 -g -fbacktrace" V=-1 -j3 \
	    && cd tools/build ;make clean; make CFLAGS="-O1 -g" -j2 \
	    && cd $NWCHEM_TOP/src \
            &&  CUDA=nvcc   ../contrib/getmem.nwchem 1000  || true \
	    && ldd ../bin/LINUX64/nwchem \
# QA tests
            && cd .. \
            && if [[ $NWCHEM_TARGET == "LINUX64" ]]; then SKIP_CACHE=1 OMPI_ALLOW_RUN_AS_ROOT=1 OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1 \
	    NWCHEM_EXECUTABLE=`pwd`/bin/$NWCHEM_TARGET/nwchem ./travis/run_qas.sh ; fi \
	    && cd src \
#clean unnecessary source to reduce docker size
            && rm -rf tce tools nwdft NWints geom symmetry util nwxc ddscf lapack blas rism argos peigs rmdft gradients symmetry property smd lucia dplot propery hessian ccsd mp2_grad moints cafe analyz dimqm /opt/nwchem/lib libext/scalapack libext/openblas  develop ../QA ../contrib ../examples ../.git ../travis ../web nwpw/nwpwlib/nwpwxc rdmft ../doc libext/libxc/libxc*  /tmp/libext || true \
	    && strip ../bin/$NWCHEM_TARGET/nwchem \
	    && ln -sf ../bin/$NWCHEM_TARGET/nwchem ../bin/nwchem \
#clean unnecessary packages
            && DEBIAN_FRONTEND=noninteractive apt-get -y install localepurge \
	    && echo MANDELETE >  /etc/locale.nopurge \
	    && echo DONTBOTHERNEWLOCALE >> /etc/locale.nopurge \
	    && echo en_US.UTF-8 >> /etc/locale.nopurge \
	    && localepurge \
	    && rm -rf /usr/share/doc \
            &&       apt-get -y purge  wget git make curl  unzip cmake cmake-data libhwloc-plugins libicu66 manpages manpages-dev iproute2 libelf1 libmnl0 libxtables12 libxau6 libxcb1 libxdmcp6 libx11-6 libx11-data libxext6 libxmuu1 xauth xz-utils localepurge  g++-8 g++ libstdc++-9-dev libopenmpi-dev perl libhwloc-dev libibverbs-dev libopenmpi-dev libcoarrays-dev libcoarrays-openmpi-dev libevent-dev libltdl-dev libnl-3-dev libnl-route-3-dev libnuma-dev autoconf automake autotools-dev libcaf-openmpi-3 libevent-extra-2.1-7 libsigsegv2 libtool &&  apt-get -y autoremove && apt-get -y install libopenmpi3 && apt-get clean \
#            &&       apt-get -y purge  wget git make curl  unzip cmake cmake-data libhwloc-plugins libicu66 manpages manpages-dev iproute2 libelf1 libmnl0 libxtables12 libxau6 libxcb1 libxdmcp6 libx11-6 libx11-data libxext6 libxmuu1 xauth xz-utils localepurge  g++-8 g++ libstdc++-9-dev libmpich-dev  &&  apt-get -y autoremove && apt-get clean \
           && if [[ $NWCHEM_TARGET == "LINUX" ]]; then apt-get -y purge libopenblas-dev; fi \
           && useradd -c 'NWChem user' -m -d /opt/nwchem -s /bin/bash nwchem \
	   && chown -R nwchem /opt/nwchem && chgrp -R nwchem /opt/nwchem \
	   && du -sh /opt/nwchem \
	   && du -sk /opt/nwchem/*|sort -n \
	   && dpkg-query -Wf '${Installed-Size}\t${Package}\n' | sort -n | tail -n 100
	   

USER        nwchem

WORKDIR     /data
ENTRYPOINT  ["nwchem"]

#CMD ["/bin/bash"]

