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

FROM        ubuntu

MAINTAINER  Edoardo Apra <edoardo.apra@pnnl.gov>

#caching from host cache dir
COPY Dockerfile cache* /tmp/

ARG DEBIAN_FRONTEND=noninteractive
ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1
ENV         NWCHEM_TOP="/opt/nwchem" 
ARG         NWCHEM_MODULES="all python"  \
            ARMCI_NETWORK=MPI-PT  \
            USE_OPENMP=1  \
            USE_NOIO=y  \
            USE_MPI=y  \
            USE_MPIF=y  \
            USE_MPIF4=y  \
	    BUILD_OPENBLAS=1 \
	    BUILD_SCALAPACK=1 \
	    BLAS_SIZE=8 \
	    SCALAPACK_SIZE=8 \
	    USE_HWOPT=n 
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
            PATH=$PATH:/opt/nwchem/bin
#get NWCHEM_TARGET
SHELL ["/bin/bash","-c"]
RUN arch=`uname -m` ; if [[ $arch == "x86_64" ]] || [[ $arch == "aarch64" ]] || [[ $arch == "riscv64" ]] || [[ $arch == "ppc64le" ]]; then echo "export NWCHEM_TARGET=LINUX64" > /tmpfile ; fi
RUN arch=`uname -m` ; arch_123=`uname -m|cut -c 1-3`; if [[ $arch == "i686" ]] || [[ $arch == "i386" ]] || [[ $arch_123 == "arm" ]] ; then echo "export NWCHEM_TARGET=LINUX" > /tmpfile ; fi
RUN . /tmpfile; echo "NWCHEM_TARGET is " $NWCHEM_TARGET

#one single ugly command to reduce docker size
RUN         apt-get update \
            && apt-get -y upgrade \
#            && apt-get install -y  python3-dev gfortran  mpich libmpich-dev  make curl   unzip cmake ssh git file wget \
            && apt-get install -y  rsync python3-dev gfortran libopenmpi-dev openmpi-bin  make curl unzip cmake git file wget tar bzip2\
            && cd /opt; git clone --depth 1  https://github.com/nwchemgit/nwchem.git  \
            && cd nwchem/src \
#set NWCHEM_TARGET
            &&  . /tmpfile; echo "NWCHEM_TARGET is " $NWCHEM_TARGET \
#fix openblas cross-compilation
            && arch=`uname -m` \
            && arch3=`uname -m|cut -c 1-3` \
            && arch5=`uname -m|cut -c 1-5` \
	    && if [[ $arch == "aarch64" ]]; then export FORCETARGET=" TARGET=ARMV8 "; fi \
	    && if [[ $arch == "ppc64le" ]]; then export FORCETARGET=" TARGET=POWER8 "; fi \
	    && if [[ $arch == "riscv64" ]]; then export FORCETARGET=" TARGET=RISCV64_GENERIC "; export ARMCI_NETWORK=MPI-TS; fi \
	    && if [[ $arch5 == "armv6" ]]; then export FORCETARGET=" TARGET=ARMV6 "; fi \
	    && if [[ $arch5 == "armv7" ]]; then export FORCETARGET=" TARGET=ARMV7 "; export ARMCI_NETWORK=MPI-TS; fi \
# _SIZE=4 and openblas pkg for 32bit archs
	    && if [[ $NWCHEM_TARGET == "LINUX" ]]; then export BLAS_SIZE=4; unset SCALAPACK_SIZE; unset BUILD_SCALAPACK; unset  BUILD_OPENBLAS; export BLASOPT=-lopenblas ; export LAPACK_LIB=-lopenblas;  apt-get install -y openmpi-bin libopenblas-dev; fi \
# smaller build on qemu emulated archs
	    && if [[ $arch != "x86_64" ]]; then export NWCHEM_MODULES="nwdft driver solvation python"; fi \
# compile libxc for amd64
	    && if [[ $arch == "x86_64" ]]; then export USE_LIBXC=1; fi \
            && if [[ -f /tmp/libext/lib/libnwc_openblas.a ]]; then rsync -av /tmp/libext/* libext/. ; fi \
            && make nwchem_config    && make V=-1 -j3 \
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
            &&       apt-get -y purge  wget git make curl  unzip cmake cmake-data libhwloc-plugins libicu66 manpages manpages-dev iproute2 libelf1 libmnl0 libxtables12 libxau6 libxcb1 libxdmcp6 libx11-6 libx11-data libxext6 libxmuu1 xauth xz-utils localepurge  g++-8 g++ libstdc++-9-dev libopenmpi-dev perl &&  apt-get -y autoremove && apt-get -y install libopenmpi3 && apt-get clean \
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

