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

ARG DEBIAN_FRONTEND=noninteractive
ARG mpich=3.3
ARG mpich_prefix=mpich-$mpich
#get OpenBLAS and compile with 64-bit integers
WORKDIR     /opt
ENV         ARMCI_NETWORK=MPI-PR NWCHEM_TOP="/opt/nwchem-7.0.2" \
            NWCHEM_TARGET=LINUX64 \
            NWCHEM_MODULES="all python" \
	    USE_NOIO=1 \
	    USE_SIMINT=1 \
	    SIMINT_MAXAM=4 \
	    SIMINT_VECTOR=AVX2 \
            BUILD_OPENBLAS=1 \
            BUILD_SCALAPACK=1 \
            BLAS_SIZE=8 \
            SCALAPACK_SIZE=8 \
	    GA_RELEASE_NO=5.8.1 \
            USE_MPI=y \
            USE_MPIF=y \
            USE_MPIF4=y 
#ENV         MRCC_METHODS=y
#ENV         CCSDTQ=y
#ENV         CCSDTLR=y
#RUN          cd /opt;curl -SL     https://github.com/nwchemgit/nwchem/releases/download/v7.0.2-release/nwchem-7.0.2-release.revision-b9985dfa-src.2020-10-12.tar.bz2 | tar xjf - \
RUN         apt-get update \
            && apt-get -y upgrade \
            && apt-get install -y  g++ gfortran   make ssh patch curl  wget unzip perl git file python3 python3-dev binutils  cmake \
            && apt-get clean \
    && wget https://www.mpich.org/static/downloads/$mpich/$mpich_prefix.tar.gz && \
    tar xvzf $mpich_prefix.tar.gz                                           && \
    cd $mpich_prefix                                                        && \
    ./configure                                                             && \
    make -j 4                                                               && \
    make install                                                            && \
    make clean                                                              && \
    cd ..                                                                   && \
    rm -rf $mpich_prefix  &&\
          cd /opt; git clone --depth 1  -b hotfix/release-7-0-0 https://github.com/nwchemgit/nwchem.git nwchem-7.0.2 \
            && cd nwchem-7.0.2/src \
#strip native compiler options as Fedora does
            && sed -i 's|-march=native||' config/makefile.h \
            && sed -i 's|-mtune=native|-mtune=generic|' config/makefile.h \
            && sed -i 's|-mfpmath=sse||' config/makefile.h \
            && sed -i 's|-msse3||' config/makefile.h  \
	    && wget https://raw.githubusercontent.com/nwchemgit/nwchem/master/src/NWints/simint/libsimint_source/build_simint.sh -O NWints/simint/libsimint_source/build_simint.sh \
	    && wget https://raw.githubusercontent.com/nwchemgit/nwchem/master/src/config/strip_compiler.sh -O src/config/strip_compiler.sh \
            && make nwchem_config && make  USE_SIMINT=1 SIMINT_MAXAM=4 SIMINT_VECTOR=AVX2 CXX=g++ V=0 -j3  \
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
