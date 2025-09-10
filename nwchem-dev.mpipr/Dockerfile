#based on earlier work by Vladimir Konjkov <Konjkov.VV@gmail.com>
#
# Create the image with the command
# docker build -t nwchem-700.mpipr .
# 
#after successful build one you can execute the QA tests using the command
#docker run nwchem-700.mpipr dft_he2+ h2o_dk h2o_opt
#

FROM        debian

COPY Dockerfile cache* /tmp/
MAINTAINER  Edoardo Apra <edoardo.apra@pnnl.gov>
ARG         FC
ARG         NWCHEM_BRANCH
ARG         GITHUB_REPOSITORY_OWNER
ARG         ARMCI_NETWORK
ARG         CACHE_HIT
ARG         MPI_IMPL


#get OpenBLAS and compile with 64-bit integers
WORKDIR     /opt
ENV         FC=${FC}
ENV         NWCHEM_BRANCH=${NWCHEM_BRANCH}
ENV         GITHUB_REPOSITORY_OWNER=${GITHUB_REPOSITORY_OWNER}
ENV         CACHE_HIT=${CACHE_HIT}
ENV         ARMCI_NETWORK=${ARMCI_NETWORK}
ENV         MPI_IMPL=${MPI_IMPL}
ENV         NWCHEM_TOP="/opt/nwchem" \
            NWCHEM_TARGET=LINUX64 \
            NWCHEM_MODULES="all python" \
            BUILD_OPENBLAS=1 \
            BUILD_SCALAPACK=1 \
            BLAS_SIZE=8 \
            SCALAPACK_SIZE=8 \
	    USE_HWOPT=n \
	    USE_OPENMP=1 \
	    USE_LIBXC=1 \
	    USE_SIMINT=1 \
	    SIMINT_VECTOR=AVX2 \
	    SIMINT_MAXAM=4 \
	    CXX=g++ \
            USE_MPI=y \
            USE_MPIF=y \
            USE_MPIF4=y 
#ENV         MRCC_METHODS=y
#ENV         CCSDTQ=y
#ENV         CCSDTLR=y
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN         apt-get update \
            && apt-get -y upgrade \
	    && if [[ $MPI_IMPL == mpich ]]; then export libmpi=mpich; export libmpidev=libmpich-dev; fi \
	    && if [[ $MPI_IMPL == openmpi ]]; then export libmpi=openmpi-bin; export libmpidev=libopenmpi-dev; fi \
	    && echo libmpi $libmpi \
	    && echo libmpidev $libmpidev \
            && apt-get install -y  gfortran g++ $libmpi $libmpidev  make ssh patch curl subversion wget unzip perl git file python3 python3-dev bzip2 \
            && apt-get clean \
            && env|grep GITHUB_RE ; echo NWCHEM_BRANCH $NWCHEM_BRANCH ; echo RRR;cd /opt; rm -rf nwchem||true \
	    && wget -q https://github.com/${GITHUB_REPOSITORY_OWNER}/nwchem/tarball/${NWCHEM_BRANCH} -O - | tar -xz  --exclude=web --exclude=examples --exclude=doc --exclude="nwxc*"  --exclude="chem-library-tests" \
	    &&    mv ${GITHUB_REPOSITORY_OWNER}-nwchem-* nwchem \
            && cd nwchem/src \
	    && echo 'checking cache #1 ' \
            && if [[ -f /tmp/libext.tar.bz2 ]]; then cd libext ; tar xjf /tmp/libext.tar.bz2; rm -rf /tmp/libext.tar.bz2 ; cd ..  ; fi\
	    && echo 'checking cache #3 ' \
            && if [[ -f /tmp/simint.tar.bz2 ]]; then cd NWints/simint/libsimint_source ; tar xjf /tmp/simint.tar.bz2; rm -rf /tmp/simint.tar.bz2 ; cd ../../.. ; fi\
            && make nwchem_config && make -j3 || { echo "Compilation failure"; exit 1; }  \
#clean unnecessary source to reduce docker size
	    && mkdir -p /opt/cache \
	    && cd libext ; tar cjvf /opt/cache/libext.tar.bz2 include/* lib/* libxc/install/lib/* libxc/install/include/* ||true \
	    && cd $NWCHEM_TOP/src/NWints/simint/libsimint_source/ ; tar cjvf /opt/cache/simint.tar.bz2 simint_install/* || true \
            && cd $NWCHEM_TOP/src && rm -rf libext  tce tools nwdft NWints geom symmetry util nwxc ddscf lapack blas rism argos peigs rmdft gradients symmetry property smd lucia dplot propery hessian ccsd mp2_grad moints cafe analyz dimqm /opt/nwchem/lib  \
	    && strip ../bin/*/nwchem  || true\
	    && cd $NWCHEM_TOP/QA/tests && rm -rf talc metagga* neb* had* dft* hess*  || true\
#clean unnecessary packages
            &&         apt-get -y purge git  make curl subversion  unzip cmake perl tcsh $libmpidev  libgcc-1*-dev &&  apt-get -y autoremove && apt-get install -y libgomp1 libgfortran5 $libmpi && apt-get clean \
&& echo "dddddddddddd"  \
&& dpkg-query -Wf '${Installed-Size}\t${Package}\n' | sort -n | tail -n 100 \
&& echo "dddddddddddd" \
	    && rm -rf  /var/lib/dpkg/ /var/lib/apt


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


WORKDIR     /data
ENTRYPOINT  ["mpirun","-np","3","nwchem"]
