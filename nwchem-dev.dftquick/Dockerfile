#based on earlier work by Vladimir Konjkov <Konjkov.VV@gmail.com>
#
# Create the image with the command
# docker build -t nwchem-dev .
# 
#after successful build one you can execute the QA tests using the command
#docker run nwchem-dev dft_he2+ h2o_dk h2o_opt
#

FROM        debian

MAINTAINER  Edoardo Apra <edoardo.apra@pnnl.gov>

ENV         NWCHEM_TOP="/opt/nwchem"

RUN         apt-get update \
            && apt-get -y upgrade \
            && apt-get install -y  gfortran  libopenmpi-dev openmpi-bin tcsh make ssh patch curl subversion wget unzip perl \
            && apt-get clean
#get OpenBLAS and compile with 64-bit integers
WORKDIR     /opt
RUN         mkdir -p /opt/lib/ \
            && wget  https://github.com/xianyi/OpenBLAS/archive/develop.zip \
            && unzip develop.zip \
            && rm develop.zip \
            && cd  OpenBLAS-develop \
            && make -j3 TARGET=CORE2 INTERFACE64=1 NO_CBLAS=1 NO_LAPACK=1 NO_LAPACKE=1 \
            &&  cp libopenblas.* /opt/lib \
            && rm -rf /opt/OpenBLAS-develop
WORKDIR     /opt
ENV         NWCHEM_TARGET=LINUX64
ENV         NWCHEM_MODULES="nwdft driver stepper"
ENV         PYTHONVERSION=2.7
ENV         PYTHONHOME="/usr"
ENV         USE_PYTHONCONFIG=Y
ENV         BLASOPT="-L/opt/lib -lopenblas"
ENV         BLAS_SIZE=8
ENV         LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/opt/lib"
ENV         USE_MPI=y
ENV         USE_MPIF=y
ENV         USE_MPIF4=y
#ENV         MRCC_METHODS=y
#ENV         CCSDTQ=y
#ENV         CCSDTLR=y
RUN         mkdir -p nwchem \
            && cd nwchem \
            && svn co --depth empty https://svn.pnl.gov/svn/nwchem/trunk/src \
            && cd src \
            && svn update GNUmakefile nwchem.F config \
            tools include basis geom inp input  \
	    pstat rtdb task symmetry util peigs perfm bq cons blas lapack \
            NWints atomscf cphf ddscf driver gradients hessian nwdft optim property stepper symmetry vib \
            && rm -rf /opt/nwchem/.svn \
            && cd tools \
            && svn export --non-interactive --username nwchem --password nwchem https://svn.pnl.gov/svn/hpctools/branches/ga-5-5  \
            && cd .. \
#strip native compiler options as Fedora does
            && sed -i 's|-march=native||' config/makefile.h \
            && sed -i 's|-mtune=native|-mtune=generic|' config/makefile.h \
            && sed -i 's|-mfpmath=sse||' config/makefile.h \
            && sed -i 's|-msse3||' config/makefile.h  \
            && make nwchem_config && make -j3  \
#clean unnecessary source to reduce docker size
            && rm -rf tce tools nwdft NWints geom symmetry util nwxc ddscf lapack blas rism argos peigs rmdft gradients symmetry property smd lucia dplot propery hessian ccsd mp2_grad moints cafe analyz dimqm /opt/nwchem/lib

ENV         NWCHEM_EXECUTABLE=${NWCHEM_TOP}/bin/LINUX64/nwchem
ENV         NWCHEM_BASIS_LIBRARY=${NWCHEM_TOP}/src/basis/libraries/
ENV         NWCHEM_NWPW_LIBRARY=${NWCHEM_TOP}/src/nwpw/libraryps/
ENV         FFIELD=amber
ENV         AMBER_1=${NWCHEM_TOP}/src/data/amber_s/
ENV         AMBER_2=${NWCHEM_TOP}/src/data/amber_q/
ENV         AMBER_3=${NWCHEM_TOP}/src/data/amber_x/
ENV         AMBER_4=${NWCHEM_TOP}/src/data/amber_u/
ENV         SPCE=${NWCHEM_TOP}/src/data/solvents/spce.rst
ENV         CHARMM_S=${NWCHEM_TOP}/src/data/charmm_s/
ENV         CHARMM_X=${NWCHEM_TOP}/src/data/charmm_x/
ENV         PATH=$PATH:${NWCHEM_TOP}/bin/LINUX64:${NWCHEM_TOP}/QA/

#clean unnecessary packages
RUN         apt-get -y remove  make curl subversion  unzip cmake perl tcsh  &&  apt-get -y autoremove && apt-get clean

WORKDIR     /data
ENTRYPOINT  ["nwchem"]
