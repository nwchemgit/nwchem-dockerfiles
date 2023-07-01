FROM --platform=$BUILDPLATFORM tonistiigi/xx AS xx

FROM --platform=$BUILDPLATFORM ubuntu:jammy
LABEL maintainer="Edoardo Apra <edoardo.apra@pnnl.gov>"

LABEL org.opencontainers.image.description="NWChem image built from the master branch"
LABEL org.opencontainers.image.source "https://github.com/nwchemgit/nwchem"
LABEL org.opencontainers.image.documentation="https://nwchemgit.github.io/Containers.html"

#create user nwchem
RUN           groupadd -r nwchem -g 1994 \
              && useradd  -u 1994 -r -g nwchem -c 'NWChem user' -m -d /opt/nwchem -s /bin/bash nwchem 

#caching from host cache dir
COPY Dockerfile cache* /tmp/

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
#get NWCHEM_TARGET
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# copy xx scripts to your build stage
RUN uname -a
COPY --from=xx / /
# export TARGETPLATFORM (or other TARGET*)
ARG TARGETPLATFORM
COPY depend.c .
COPY build_scalapa.sh /tmp/.
COPY build_openblas.sh /tmp/.
COPY build_mpich.sh /tmp/.
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# you can now call xx-* commands
RUN xx-info env && \
    env|grep PLATF && \
    xx-apt install -y libc6-dev  gcc binutils gcc gfortran  &&\
    apt-get install -y make file gcc && \
    $(xx-info)-gcc -v && \
    dpkg-query -l|sort && \
    ls -lrta /tmp && \
XX_MARCH=$(xx-info march) &&\
arch=${XX_MARCH} ; echo " xx arch is " $arch ;if [[ "$arch" == "x86_64" ]] || [[ "$arch" == "aarch64" ]] || [[ "$arch" == "riscv64" ]] || [[ "$arch" == "ppc64le" ]]; then echo "export NWCHEM_TARGET=LINUX64" > /tmpfile ; fi && \
arch_123=$(uname -m|cut -c 1-3); if [[ "$arch" == "i686" ]] || [[ "$arch" == "i386" ]] || [[ "$arch_123" == "arm" ]] ; then echo "export NWCHEM_TARGET=LINUX" > /tmpfile ; fi  &&\
. /tmpfile; echo "NWCHEM_TARGET is " ${NWCHEM_TARGET}  && \
     echo ' defining modules according to CACHE_HIT=' "$CACHE_HIT" && \
     if [[ "$arch" != "x86_64" ]] && [[ "$CACHE_HIT" == "N" ]]; then export NWCHEM_MODULES="nwdft"; echo 'smaller build without cache. CACHE_HIT='$CACHE_HIT ; else echo 'large build with cache. CACHE_HIT='$CACHE_HIT ; export NWCHEM_MODULES="nwdft driver vib solvation gwmol tce"  ; fi &&\
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
            && arch3=$(uname -m|cut -c 1-3) \
            && arch5=$(uname -m|cut -c 1-5) \
	    &&  cd /tmp ; wget https://raw.githubusercontent.com/${GITHUB_REPOSITORY_OWNER}/nwchem-dockerfiles/master/patches/cmake_multip.patch; cd /opt/nwchem ; patch -p1 < /tmp/cmake_multip.patch; cd /opt/nwchem/src \
	    && cp /tmp/build_openblas.sh /opt/nwchem/src/libext/openblas/. \
	    && cp /tmp/build_mpich.sh /opt/nwchem/src/libext/mpich/. \
	    && cp /tmp/build_scalapa.sh /opt/nwchem/src/libext/scalapack/. \
	    && if [[ "$arch" == "aarch64" ]]; then export FORCETARGET=" TARGET=ARMV8 "; fi \
	    && if [[ "$arch" == "ppc64le" ]]; then export FORCETARGET=" TARGET=POWER8 "; fi \
	    && if [[ "$arch" == "riscv64" ]]; then export FORCETARGET=" TARGET=RISCV64_GENERIC "; export ARMCI_NETWORK=MPI-TS; unset USE_OPENMP; fi \
	    && if [[ "$arch5" == "armv6" ]]; then export FORCETARGET=" TARGET=ARMV6 "; fi \
	    && if [[ "$arch5" == "armv7" ]]; then export FORCETARGET=" TARGET=ARMV7 "; export ARMCI_NETWORK=MPI-TS; fi \
# _SIZE=4 and openblas pkg for 32bit archs
            && echo 'FORCETARGET is ' $FORCETARGET \
	    && if [[ ${NWCHEM_TARGET} == "LINUX" ]]; then export BLAS_SIZE=4; unset SCALAPACK_SIZE; unset BUILD_SCALAPACK;  fi  \
# smaller build on qemu emulated archs
	    && if [[ "$arch" != "x86_64" ]]; then export NWCHEM_MODULES="nwdft driver solvation "; fi \
# compile libxc for amd64 
	    && if [[ "$arch" == "x86_64" ]]; then export USE_LIBXC=1;  \
	    export USE_SIMINT=1; export SIMINT_MAXAM=5; export SIMINT_VECTOR=avx2 ; fi \
            && if [[ -f /tmp/libext.tar.bz2 ]]; then cd libext ; tar xjvf /tmp/libext.tar.bz2; rm -rf /tmp/libext.tar.bz2 ; cd ..  ; fi \
            && if [[ -f /tmp/simint.tar.bz2 ]]; then cd NWints/simint/libsimint_source ; tar xjf /tmp/simint.tar.bz2; rm -rf /tmp/simint.tar.bz2 ; cd ../../..  ; fi\
	    && df -h /dev/shm \
            && mkdir -p ../bin/${NWCHEM_TARGET} \
            && gcc -o ../bin/"$NWCHEM_TARGET/depend.x" config/depend.c \
            && make nwchem_config \
            && make DEPEND_CC=gcc CC=$(xx-info)-gcc  FC=$(xx-info)-gfortran  FFLAG_INT="-fdefault-integer-8"  _CPU=${XX_MARCH} MAYBE_HOST="--host=$(xx-info triple)"  \
	    &&  if [[ -f ../bin/${NWCHEM_TARGET}/nwchem ]]; then echo 'NWChem binary created' ; else  cat tools/build/config.log ;  echo 'compilation error1'; exit 1; fi \
	    && tools/build/config.log \
            &&    CC=$(xx-info)-gcc _CC=gcc FC=$(xx-info)-gfortran _FC=gfortran _CPU=${XX_MARCH} ../contrib/getmem.nwchem 1000  || true \
	    &&  if [[ -f ../bin/${NWCHEM_TARGET}/nwchem ]]; then echo 'NWChem binary created' ; else  echo 'compilation error2'; exit 1; fi \
# QA tests
#	    && cd src \
#clean unnecessary source to reduce docker size
            && rm -rf tce tools nwdft geom symmetry util nwxc ddscf lapack blas rism argos peigs rmdft gradients symmetry property smd lucia dplot propery hessian ccsd mp2_grad moints cafe analyz dimqm /opt/nwchem/lib libext/scalapack libext/openblas  develop ../QA ../contrib ../examples ../.git ../travis ../web nwpw/nwpwlib/nwpwxc rdmft ../doc libext/libxc/libxc* libext/mpich  /tmp/libext || true \
	    && ls -lrt libext/libxc || true \
	    && ls -lrt libext/lib || true \
	    && strip ../bin/${NWCHEM_TARGET}/nwchem \
	    && rm libext/libxc/install/bin/xc* || true \
	    && cd libext ; tar cjvf libext.tar.bz2 lib/* libxc/install/lib/* libxc/install/include/* ||true \
	    && rm -rf lib/* libxc/install/lib/* ||true \
	    && cd $NWCHEM_TOP/src/NWints/simint/libsimint_source/ ; tar cjvf $NWCHEM_TOP/src/libext/simint.tar.bz2 simint_install/* || true \
	    && cd  $NWCHEM_TOP/src &&  rm -rf NWints || true \
	    && cd $NWCHEM_TOP/src || { echo "Failure"; exit 1; } \
	    && cd $NWCHEM_TOP \
#clean unnecessary packages
            && DEBIAN_FRONTEND=noninteractive apt-get -q=2 -y install --no-install-recommends localepurge \
	    && echo MANDELETE >  /etc/locale.nopurge \
	    && echo DONTBOTHERNEWLOCALE >> /etc/locale.nopurge \
	    && echo en_US.UTF-8 >> /etc/locale.nopurge \
	    && localepurge \
	    && rm -rf /usr/share/doc \
            &&       apt-get -q=2 -y purge  wget git make curl  unzip cmake cmake-data libhwloc-plugins libicu66 manpages manpages-dev iproute2 libelf1 libmnl0 libxtables12 libxau6 libxcb1 libxdmcp6 libx11-6 libx11-data libxext6 libxmuu1 xauth xz-utils localepurge  g++-8 g++ libstdc++-9-dev libopenmpi-dev perl libhwloc-dev libibverbs-dev libopenmpi-dev libcoarrays-dev libcoarrays-openmpi-dev libevent-dev libltdl-dev libnl-3-dev libnl-route-3-dev libnuma-dev autoconf automake autotools-dev libcaf-openmpi-3 libevent-extra-2.1-7 libsigsegv2 libtool ibverbs-providers bc &&  apt-get -y autoremove && apt-get -q=2 -y install libopenmpi3 && apt-get clean \
#            &&       apt-get -y purge  wget git make curl  unzip cmake cmake-data libhwloc-plugins libicu66 manpages manpages-dev iproute2 libelf1 libmnl0 libxtables12 libxau6 libxcb1 libxdmcp6 libx11-6 libx11-data libxext6 libxmuu1 xauth xz-utils localepurge  g++-8 g++ libstdc++-9-dev libmpich-dev  &&  apt-get -y autoremove \
           && apt-get -y purge cpp-9 gfortran-9 gcc-9  libnl-3-dev libnl-route-3-dev libnuma-dev libibverbs-dev libgcc-9-dev autotools-dev libevent-dev libc6-dev linux-libc-dev libexpat1-dev zlib1g-dev libcrypt-dev perl-modules-5.30 libperl5.30  || true \
	   && apt-get clean \
	   && rm -rf /opt/nwchem/src/libext/libext_utils || true \
	   && chown -R nwchem /opt/nwchem && chgrp -R nwchem /opt/nwchem \
	   && du -sh /opt/nwchem \
	   && du -sh /opt/nwchem/src/libext/lib || true \
	   && du -sk /opt/nwchem/*|sort -n \
	   && ls -lrt /opt/lib || true \
	   && du -sh /opt/nvidia || true \
	   && dpkg-query -Wf '${Installed-Size}\t${Package}\n' | sort -n | tail -n 100
	   
ENV LD_LIBRARY_PATH /opt/lib


USER        nwchem

WORKDIR     /data
ENTRYPOINT  ["nwchem"]

##CMD ["/bin/bash"]

#XX_MARCH
##make DEPEND_CC=gcc CC=$(xx-info)-gcc _CC=gcc FC=$(xx-info)-gfortran _FC=gfortran FFLAG_INT="-fdefault-integer-8"  _CPU=${XX_MARCH}
##make DEPEND_CC=${CC_FOR_BUILD} CC=${CC} _CC=${_CC} FC=${FC} _FC=${_FC} CFLAGS_FORGA="-fPIC -Wl,-rpath,${PREFIX}/lib -L${PREFIX}/lib" FFLAGS_FORGA="-Wl,-rpath,${PREFIX}/lib -L${PREFIX}/lib" FFLAG_INT="-fdefault-integer-8"  _CPU=${XX_MARCH}
