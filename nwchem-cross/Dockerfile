FROM --platform=$BUILDPLATFORM tonistiigi/xx AS xx

FROM --platform=$BUILDPLATFORM ubuntu:jammy AS build
LABEL maintainer="Edoardo Apra <edoardo.apra@pnnl.gov>"

LABEL org.opencontainers.image.description="NWChem image built from the master branch"
LABEL org.opencontainers.image.source "https://github.com/nwchemgit/nwchem"
LABEL org.opencontainers.image.documentation="https://nwchemgit.github.io/Containers.html"


#caching from host cache dir
COPY Dockerfile cache* /tmp/

ARG TARGETPLATFORM
ARG DEBIAN_FRONTEND=noninteractive
ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1
ARG         FC
ARG         NWCHEM_BRANCH
ARG         GITHUB_REPOSITORY_OWNER
ARG CACHE_HIT
ENV         NWCHEM_TOP="/opt/nwchem"
ENV         FC=${FC}
ENV         NWCHEM_BRANCH=${NWCHEM_BRANCH}
ENV         GITHUB_REPOSITORY_OWNER=${GITHUB_REPOSITORY_OWNER}
ARG         NWCHEM_MODULES="all  "  \
            ARMCI_NETWORK=MPI-PT  \
            USE_OPENMP=1  \
            USE_NOIO=y  \
            USE_MPI=y  \
            USE_MPIF=y  \
            USE_MPIF4=y  \
	    BUILD_MPICH=1 \
	    BUILD_OPENBLAS=1 \
	    BUILD_SCALAPACK=1 \
	    BLAS_SIZE=8 \
	    SCALAPACK_SIZE=8 \
	    USE_HWOPT=n 
#get NWCHEM_TARGET
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# copy xx scripts to your build stage
RUN uname -a
COPY --from=xx / /
# export TARGETPLATFORM (or other TARGET*)
ARG TARGETPLATFORM
COPY build_scalapa.sh /tmp/.
COPY build_openblas.sh /tmp/.
COPY build_mpich.sh /tmp/.
COPY cross.txt /tmp/.
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# you can now call xx-* commands
RUN xx-info env && \
    env|grep PLATF && \
    xx-apt -q=2 install -y libc6-dev  binutils gcc gfortran  &&\
    apt-get -q=2 install -y make file gcc && \
    $(xx-info)-gcc -v && \
    ls -lrta /tmp && \
    if [[ -f /tmp/libext.tar.bz2 ]]; then echo "analyzing libext" ; apt-get install -y bzip2 tar;  tar tjvf /tmp/libext.tar.bz2;  fi &&\
XX_MARCH=$(xx-info march) &&\
arch=${XX_MARCH} ; echo " xx arch is " $arch ;if [[ "$arch" == "x86_64" ]] || [[ "$arch" == "aarch64" ]] || [[ "$arch" == "riscv64" ]] || [[ "$arch" == "ppc64le" ]]|| [[ "$arch" == "s390x" ]]; then echo "export NWCHEM_TARGET=LINUX64" > /tmpfile ; fi && \
arch_123=$(echo $arch |cut -c 1-3); if [[ "$arch" == "i686" ]] || [[ "$arch" == "i386" ]] || [[ "$arch_123" == "arm" ]] ; then echo "export NWCHEM_TARGET=LINUX" > /tmpfile ; fi  &&\
. /tmpfile; echo "NWCHEM_TARGET is " ${NWCHEM_TARGET}  && \
     echo ' defining modules according to CACHE_HIT=' "$CACHE_HIT" && \
     if [[ "$arch" != "x86_64" ]] && [[ "$CACHE_HIT" == "N" ]]; then export NWCHEM_MODULES="nwdft"; echo 'smaller build without cache. CACHE_HIT='$CACHE_HIT ; else echo 'large build with cache. CACHE_HIT='$CACHE_HIT ; export NWCHEM_MODULES="all"  ; fi &&\
#one single ugly command to reduce docker size
            tries=0 ; until [ "$tries" -ge 10 ] ; do \
             xx-apt  install -y  g++ gfortran libssl-dev \
             && apt-get -q=2 install -y --no-install-recommends rsync  make curl unzip cmake git file wget tar bzip2 bc ca-certificates patch pkg-config python3-dev openssh-client \
	    && break; \
	    tries=$((tries+1)) ; echo attempt no.  $tries    ; sleep 30 ;  done \
	    && echo FCFCFC is ${FC} \
	    && echo NWCHEM_BRANCH is ${NWCHEM_BRANCH} \
	    && echo GITHUB_REPOSITORY_OWNER is ${GITHUB_REPOSITORY_OWNER} \
#	    && arch=$(uname -m) \
	    && arch=$XX_MARCH \
	    && echo arch is "$arch" \
	    && arch_dpkg=$(dpkg --print-architecture)  \
	    && if [[ "$arch" == "aarch64" ]]; then arch_dpkg="arm64"; fi \
	    && if [[ "$arch" == "x86_64" ]]; then arch_dpkg="amd64"; fi \
	    && echo "URL for cloning"  https://github.com/${GITHUB_REPOSITORY_OWNER}/nwchem.git \
	    && echo ca_certificate=/etc/ssl/certs/ca-certificates.crt >  ~/.wgetrc \
            && cd /opt; rm -rf nwchem||true; wget -q https://github.com/${GITHUB_REPOSITORY_OWNER}/nwchem/tarball/"$NWCHEM_BRANCH" -O - | tar -xz  --exclude=web --exclude=examples --exclude=doc --exclude="nwxc*"  --exclude="chem-library-tests" \
	    &&    mv ${GITHUB_REPOSITORY_OWNER}-nwchem-* nwchem \
            && cd nwchem/src \
#set NWCHEM_TARGET 
            &&  . /tmpfile; echo "NWCHEM_TARGET is " ${NWCHEM_TARGET} \
#fix openblas cross-compilation
            && arch=$XX_MARCH \
	    && echo 'openblas arch is ' $arch \
	    && cp /tmp/build_openblas.sh /opt/nwchem/src/libext/openblas/. \
	    && cp /tmp/build_mpich.sh /opt/nwchem/src/libext/mpich/. \
	    && cp /tmp/cross.txt /opt/nwchem/src/libext/mpich/. \
	    && cp /tmp/build_scalapa.sh /opt/nwchem/src/libext/scalapack/. \
	    && if [[ "$arch" == "aarch64" ]]; then export FORCETARGET=" TARGET=ARMV8 "; fi \
	    && if [[ "$arch" == "ppc64le" ]]; then export FORCETARGET=" TARGET=POWER8 "; fi \
	    && if [[ "$arch" == "riscv64" ]]; then export FORCETARGET=" TARGET=RISCV64_GENERIC "; export ARMCI_NETWORK=MPI-TS; unset USE_OPENMP; fi \
	    && if [[ "$arch" == "armv7l" ]]; then export FORCETARGET=" TARGET=ARMV7 "; export ARMCI_NETWORK=MPI-TS; fi \
	    && if [[ "$arch" == "s390x" ]]; then export FORCETARGET=" TARGET=ZARCH_GENERIC "; export ARMCI_NETWORK=MPI-TS; fi \
# _SIZE=4 and openblas pkg for 32bit archs
            && echo 'FORCETARGET is ' $FORCETARGET \
	    && if [[ ${NWCHEM_TARGET} == "LINUX" ]]; then export BLAS_SIZE=4; unset SCALAPACK_SIZE; unset BUILD_SCALAPACK;  fi  \
# smaller build on qemu emulated archs
# compile libxc for amd64 
	    && if [[ "$arch" == "x86_64" ]]; then export USE_LIBXC=1;  \
	    export USE_SIMINT=1; export SIMINT_MAXAM=5; export SIMINT_VECTOR=avx2 ; fi \
            && if [[ -f /tmp/libext.tar.bz2 ]]; then echo "fetching libext" ; cd libext ; tar xjvf /tmp/libext.tar.bz2; rm -rf /tmp/libext.tar.bz2 ; ./bin/mpif90 -show; mkdir -p mpich/mpich ; ls -l /opt/nwchem/src/libext/mpich/mpich/../../include ;cd ..  ; fi \
            && if [[ -f /tmp/simint.tar.bz2 ]]; then cd NWints/simint/libsimint_source ; tar xjf /tmp/simint.tar.bz2; rm -rf /tmp/simint.tar.bz2 ; cd ../../..  ; fi\
	    && df -h /dev/shm \
            && mkdir -p ../bin/${NWCHEM_TARGET} \
            && gcc -o ../bin/"$NWCHEM_TARGET/depend.x" config/depend.c \
	    && MY_FFLAG_INT="-fdefault-integer-8" \
	    && I4I8=" --enable-i8 " \
	    && MYCPU=${XX_MARCH} \
	    && if [  $MYCPU == "armv7l" ]; then MYCPU="arm"; MY_FFLAG_INT="-fdefault-integer-4" ; I4I8=" --enable-i4 "; fi \
	    && echo "MYCPU is " $MYCPU \
	    && echo "MY_FFLAG_INT is " $MY_FFLAG_INT \
	    && echo "I4I8 is " $I4I8 \
            && make DEPEND_CC=gcc CC=$(xx-info)-gcc  FC=$(xx-info)-gfortran   _CPU=${MYCPU}  nwchem_config  \
            && make DEPEND_CC=gcc CC=$(xx-info)-gcc  FC=$(xx-info)-gfortran  FFLAG_INT=${MY_FFLAG_INT} _CPU=${MYCPU} MAYBE_HOST="--host=$(xx-info triple)"  MAYBE_OFFLOAD="$I4I8" V=-1 \
	    &&  if [[ -f ../bin/${NWCHEM_TARGET}/nwchem ]]; then echo 'NWChem binary created' ; else  cat tools/build/config.log ;  echo 'compilation error1'; exit 1; fi \
            &&    CC=$(xx-info)-gcc _CC=gcc FC=$(xx-info)-gfortran _FC=gfortran _CPU=${MYCPU} ../contrib/getmem.nwchem 1000  || true \
	    &&  if [[ -f ../bin/${NWCHEM_TARGET}/nwchem ]]; then echo 'NWChem binary created' ; else cat tools/build/config.log ;  echo 'compilation error2'; exit 1; fi \
#clean unnecessary source to reduce docker size
            && cp -rp ../QA/tests/dft_he2+ /tmp/. \
            && rm -rf tce tools/build tools/ga-* nwdft geom symmetry util nwxc ddscf lapack blas rism argos peigs rmdft gradients symmetry property smd lucia dplot propery hessian ccsd mp2_grad moints cafe analyz dimqm  libext/scalapack libext/openblas  develop ../QA/tests ../QA/chem_library_tests ../QA/Nightly_Jobscripts QA/amber-tests ../contrib ../examples ../.git ../travis ../web nwpw/nwpwlib/nwpwxc rdmft ../doc libext/libxc/libxc* libext/mpich  /tmp/libext || true \
	    && mkdir -p ../QA/tests \
	    && mv /tmp/dft_he2+ ../QA/tests/. \
	    && ls -lrt libext/libxc || true \
	    && ls -lrt libext/lib || true \
	    && $(xx-info)-strip ../bin/${NWCHEM_TARGET}/nwchem \
	    && rm libext/libxc/install/bin/xc* || true \
	    && cd libext ; tar cjvf libext.tar.bz2 bin/* lib/* include/*  libxc/install/lib/* libxc/install/include/* ||true \
	    && cd $NWCHEM_TOP/src/NWints/simint/libsimint_source/ ; tar cjvf $NWCHEM_TOP/src/libext/simint.tar.bz2 simint_install/* || true \
	    && cd $NWCHEM_TOP/src || { echo "Failure"; exit 1; } \
	    && cd $NWCHEM_TOP \
#clean unnecessary packages
            && DEBIAN_FRONTEND=noninteractive apt-get -q=2 -y install --no-install-recommends localepurge \
	    && echo MANDELETE >  /etc/locale.nopurge \
	    && echo DONTBOTHERNEWLOCALE >> /etc/locale.nopurge \
	    && echo en_US.UTF-8 >> /etc/locale.nopurge \
	    && localepurge \
	    && rm -rf /usr/share/doc \
            &&       apt-get  -y purge  wget git make curl  unzip cmake cmake-data libhwloc-plugins manpages manpages-dev iproute2 libelf1 libmnl0 libxtables12 libxau6 libxcb1 libxdmcp6 libx11-6 libx11-data libxext6 libxmuu1 xauth xz-utils localepurge  g++-8 g++ libstdc++-9-dev  perl libltdl-dev autoconf automake autotools-dev libevent-extra-2.1-7 libsigsegv2 libtool ibverbs-providers bc &&  apt-get -y autoremove  && apt-get clean \
           && apt-get -y purge   autotools-dev libevent-dev libc6-dev linux-libc-dev libexpat1-dev zlib1g-dev libcrypt-dev   || true \
	   && apt-get clean \
	   && rm -rf /opt/nwchem/src/libext/libext_utils || true \
	   && chown -R nwchem /opt/nwchem && chgrp -R nwchem /opt/nwchem \
	   && du -sh /opt/nwchem \
	   && du -sh /opt/nwchem/src/libext/lib || true \
	   && ls -lrt /opt/lib || true \
	   && du -sh /opt/nvidia || true \
	   && dpkg-query -Wf '${Installed-Size}\t${Package}\n' | sort -n | tail -n 100

FROM ubuntu:jammy AS relink_push

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG CACHE_HIT
ARG         NWCHEM_MODULES="all  "  \
            ARMCI_NETWORK=MPI-PT  \
            USE_OPENMP=1  \
            USE_NOIO=y  \
            USE_MPI=y  \
            USE_MPIF=y  \
            USE_MPIF4=y  \
	    BUILD_MPICH=1 \
	    BUILD_OPENBLAS=1 \
	    BUILD_SCALAPACK=1 \
	    BLAS_SIZE=8 \
	    SCALAPACK_SIZE=8 \
	    USE_HWOPT=n 

RUN mkdir -p /opt

COPY --from=build /opt/nwchem /opt/nwchem
	      
RUN           groupadd -r nwchem -g 1994 \
              && useradd  -u 1994 -r -g nwchem -c 'NWChem user' -M -d /opt/nwchem -s /bin/bash nwchem \
 && apt-get update \
             && apt-get -q=2   install -y make  gfortran python3-dev libssl-dev \
             && apt-get -q=2 install -y --no-install-recommends file  ca-certificates  pkg-config python3-dev openssh-client perl \
	     && echo " CACHE_HIT is "  "$CACHE_HIT"  \
	     && if [[ "$CACHE_HIT" == "Y" ]]; then \
             export NWCHEM_MODULES="all python " ;\
	     arch=$(uname -m) ; \
	     if [[ "$arch" == "x86_64" ]]; then export USE_LIBXC=1; export USE_SIMINT=1;fi ; \
	     echo "uname -m is " $(uname -m) ;\
	     MYCPU=$(uname -m) ; \
    	     echo "MYCPU is " ${MYCPU} ;\ 
	    cd /opt/nwchem/src ;\
	    mkdir -p /opt/nwchem/src/libext/mpich/mpich ;\
	    mkdir -p /opt/nwchem/src/NWints/simint/libsimint_source ;\
	    cd NWints/simint/libsimint_source ; tar xjf /opt/nwchem/src/libext/simint.tar.bz2 ;\
	    cd /opt/nwchem/src ;\
            make DEPEND_CC=gcc CC=gcc  FC=gfortran _CPU=${MYCPU}   nwchem_config ;\
	    cd python ;\
            make DEPEND_CC=gcc CC=gcc  FC=gfortran _CPU=${MYCPU}    V=1 ;\
            cd .. ;\
            make DEPEND_CC=gcc CC=gcc  FC=gfortran _CPU=${MYCPU}    V=1 link ; fi \
	     && ln -sf /opt/nwchem/src/libext/bin/mpiexec /opt/nwchem/bin/LINUX64/. \
	     && ln -sf /opt/nwchem/src/libext/bin/mpiexec /opt/nwchem/bin/LINUX64/mpirun \
	     && ls -l /opt/nwchem/bin/LINUX64/nwchem \
	     && file /opt/nwchem/bin/LINUX64/nwchem \
	     && uname -a \
	     && ldd /opt/nwchem/bin/LINUX64/nwchem|| true \
	     && cd /opt/nwchem/QA \
	     && ls -l \
	     && export NWCHEM_EXECUTABLE=/opt/nwchem/bin/nwchem \
	     && ./runtests.mpi.unix dft_he2+  || true \
	     && rm -rf /opt/nwchem/src/NWints || true \
	     && rm -rf /opt/nwchem/lib /opt/nwchem/src/tools || true \
 	     && rm -rf /opt/nwchem/src/libext/lib/* /opt/nwchem/src/libext/libxc/install/lib/* ||true \
	     && echo done \
	     && du -sh /opt/nwchem/src/* |sort -n \
            &&       apt-get -y purge  wget git make curl  unzip cmake cmake-data libhwloc-plugins manpages manpages-dev iproute2 libelf1 libmnl0 libxtables12 libxau6 libxcb1 libxdmcp6 libx11-6 libx11-data libxext6 libxmuu1 xauth xz-utils localepurge  perl libltdl-dev   autoconf automake  libsigsegv2 libtool ibverbs-providers bc &&  apt-get -y autoremove  && apt-get clean \
	   && apt-get purge -y libgfortran-11-dev libssl-dev fonts-dejavu-core   javascript-common libexpat1 libctf-nobfd0 libjs-underscore libjs-sphinxdoc libjs-jquery  \
	     && dpkg-query -Wf '${Installed-Size}\t${Package}\n' | sort -n | tail -n 100

	     
	     

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
            PATH=${PATH}:/opt/nwchem/bin/LINUX64


USER        nwchem

WORKDIR     /data
ENTRYPOINT  ["nwchem"]

##CMD ["/bin/bash"]

#XX_MARCH
##make DEPEND_CC=gcc CC=$(xx-info)-gcc _CC=gcc FC=$(xx-info)-gfortran _FC=gfortran FFLAG_INT="-fdefault-integer-8"  _CPU=${XX_MARCH}
##make DEPEND_CC=${CC_FOR_BUILD} CC=${CC} _CC=${_CC} FC=${FC} _FC=${_FC} CFLAGS_FORGA="-fPIC -Wl,-rpath,${PREFIX}/lib -L${PREFIX}/lib" FFLAGS_FORGA="-Wl,-rpath,${PREFIX}/lib -L${PREFIX}/lib" FFLAG_INT="-fdefault-integer-8"  _CPU=${XX_MARCH}
