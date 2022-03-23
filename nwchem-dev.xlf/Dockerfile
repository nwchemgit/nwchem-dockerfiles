#FROM --platform=linux/ppc64le ibmcom/xlf-ce as builder
FROM ppc64le/ubuntu:bionic
ENV XLF_REPO_URL https://public.dhe.ibm.com/software/server/POWER/Linux/xl-compiler/eval/ppc64le
ENV XLF_REPO_KEY_SHA256SUM e0eba411ed1cbf48fdab9e03dfc159a280bd728e716dd408ef321e42ac3ae552
ENV XLF_VRM 16.1.1
#caching from host cache dir
COPY Dockerfile cache* /tmp/

ARG DEBIAN_FRONTEND=noninteractive
ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1
RUN ls -lrta /tmp && \
  apt-get update && apt-get install -y wget gpg && \
  wget -q "$XLF_REPO_URL/ubuntu/public.gpg" && \
  apt-get purge -y --auto-remove wget && \
  echo "$XLF_REPO_KEY_SHA256SUM public.gpg"| sha256sum -c - && \
  apt-key add public.gpg && \
  rm public.gpg && \
  echo "deb $XLF_REPO_URL/ubuntu/ xenial main" > /etc/apt/sources.list.d/ibm-xl-compiler.list && \
  apt-get update && apt-get install -y \
    "xlf.$XLF_VRM" \
    "xlf-license-community.$XLF_VRM" && \
    rm -f /tmp/in.txt  && \
    echo 1 > /tmp/in.txt && \
   /opt/ibm/xlf/$XLF_VRM/bin/xlf_configure </tmp/in.txt 

ENV LICENSE=accept \
MPICH_FC=xlf \
         NWCHEM_TOP="/opt/nwchem" \
            NWCHEM_MODULES="nwdft driver vib solvation gwmol python tce"  \
            ARMCI_NETWORK=MPI-PT  \
            USE_NOIO=y  \
            USE_MPI=y  \
            USE_MPIF=y  \
            USE_MPIF4=y  \
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
	    BUILD_OPENBLAS=1 \
	    BUILD_SCALAPACK=1 \
	    BLAS_SIZE=8 \
	    SCALAPACK_SIZE=8 \
	    USE_OPENMP=1 \
	    USE_HWOPT=n \
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
#            && apt-get install -y  python3-dev gfortran libopenmpi-dev openmpi-bin  make curl unzip cmake git file wget tar bzip2 \
            && apt-get install -y  rsync python3-dev gfortran libmpich-dev mpich libmpich12  make curl unzip cmake git file wget tar bzip2 bc \
            && cd /opt; git clone --depth 1  https://github.com/nwchemgit/nwchem.git  \
	    && xlf -qversion \
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
	    && if [[ $arch != "x86_64" ]]; then export NWCHEM_MODULES="nwdft driver solvation python gwmol tce"; fi \
# compile libxc for amd64
	    && if [[ $arch == "x86_64" ]]; then export USE_LIBXC=1; fi \
# cache
            && if [[ -f /tmp/libext/lib/libnwc_openblas.a ]]; then rsync -av /tmp/libext/* libext/. ; fi \
            && if [[ -f /tmp/libext.tar.bz2 ]]; then cd libext ; tar xjvf /tmp/libext.tar.bz2; rm -rf /tmp/libext.tar.bz2 ; cd ..  ; fi \
            && mkdir -p ../bin/LINUX64 \
            && gcc -o ../bin/LINUX64/depend.x config/depend.c \
            && make nwchem_config     \
            && cd libext   && make FC=xlf CC=gcc V=-1  && cd .. \
            && cd tools    && make FC=xlf CC=gcc V=-1  && cd .. \
            && ( make USE_INTERNALBLAS=y deps_stamp  >& deps.log &) \
	    && sleep 15s \
            &&  make FC=xlf CC=gcc FOPTIMIZE=-g FDEBUG="-g" V=-1 -j2 || true \
	    &&  if [[ -f ../bin/LINUX64/nwchem ]]; then echo 'NWChem binary created' ; else  echo 'compilation error'; exit 1; fi \
# QA tests
#            && cd .. \
#            && if [[ $NWCHEM_TARGET == "LINUX64" ]]; then SKIP_CACHE=1 OMPI_ALLOW_RUN_AS_ROOT=1 OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1 \
#	    NWCHEM_EXECUTABLE=`pwd`/bin/$NWCHEM_TARGET/nwchem ./travis/run_qas.sh ; fi \
#	    && cd src \
#clean unnecessary source to reduce docker size
            && rm -rf tce tools nwdft NWints geom symmetry util nwxc ddscf lapack blas rism argos peigs rmdft gradients symmetry property smd lucia dplot propery hessian ccsd mp2_grad moints cafe analyz dimqm /opt/nwchem/lib libext/scalapack libext/openblas  develop ../QA ../contrib ../examples ../.git ../travis ../web nwpw/nwpwlib/nwpwxc rdmft ../doc || true \
	    &&  if [[ -f ../bin/LINUX64/nwchem ]]; then echo 'NWChem binary created' ; else  echo 'compilation error'; exit 1; fi \
	    && ls -lrt libext/libxc || true \
	    && ls -lrt libext/lib || true \
	    && strip ../bin/$NWCHEM_TARGET/nwchem \
	    && cd libext ; tar cjvf libext.tar.bz2 lib/* libxc/install/lib/* libxc/install/include/* ||true \
	    && rm -rf lib/* libxc/install/lib/* ||true \
	    && cd .. \
	    && ln -sf ../bin/$NWCHEM_TARGET/nwchem ../bin/nwchem \
#clean unnecessary packages
            && DEBIAN_FRONTEND=noninteractive apt-get -y install localepurge \
	    && echo MANDELETE >  /etc/locale.nopurge \
	    && echo DONTBOTHERNEWLOCALE >> /etc/locale.nopurge \
	    && echo en_US.UTF-8 >> /etc/locale.nopurge \
	    && localepurge \
	    && rm -rf /usr/share/doc \
            && apt-get -y purge  wget git make curl  unzip cmake cmake-data libhwloc-plugins  manpages manpages-dev iproute2 libelf1 libmnl0 libxtables12 libxau6 libxcb1 libxdmcp6 libx11-6 libx11-data libxext6 libxmuu1 xauth xz-utils localepurge g++  libstdc++-7-dev perl libpython3.6-dev  libgcc-7-dev libicu60 locales libperl5.26 cpp-7 libc6-dev perl-modules-5.26 linux-libc-dev bc || true &&  apt-get clean \
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

