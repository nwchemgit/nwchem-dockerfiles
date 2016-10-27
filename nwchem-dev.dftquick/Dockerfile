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
            && apt-get install -y  gfortran  libopenmpi-dev openmpi-bin tcsh make ssh patch curl subversion wget unzip perl
#get OpenBLAS and compile with 64-bit integers
WORKDIR     /opt
RUN         wget  https://github.com/xianyi/OpenBLAS/archive/develop.zip && unzip develop.zip
WORKDIR     OpenBLAS-develop
RUN         make -j3 INTERFACE64=1 NO_CBLAS=1 NO_LAPACK=1 NO_LAPACKE=1
WORKDIR     /opt
RUN         mkdir -p nwchem
# checkout some QAs
WORKDIR     ${NWCHEM_TOP}
RUN         svn co --depth empty https://svn.pnl.gov/svn/nwchem/trunk/QA
WORKDIR     QA
RUN         svn update doafewqmtests.mpi doqmtests.mpi runtests.mpi.unix nwparse.pl
RUN         svn co --depth empty https://svn.pnl.gov/svn/nwchem/trunk/QA/tests
WORKDIR     tests
RUN         svn update h2o_opt dft_he2+ h2o_dk
WORKDIR     ${NWCHEM_TOP}
RUN         svn co --depth empty https://svn.pnl.gov/svn/nwchem/trunk/src
WORKDIR     src
RUN         pwd
RUN         svn update GNUmakefile nwchem.F config \
            tools include basis geom inp input  \
	    pstat rtdb task symmetry util peigs perfm bq cons blas lapack \
            NWints atomscf cphf ddscf driver gradients hessian nwdft optim property stepper symmetry vib
WORKDIR     ${NWCHEM_TOP}/src/tools
RUN         ./get-tools 
#ADD         Nwchem-6.6.revision27746-src.2015-10-20.tar.bz2 /opt
WORKDIR     ${NWCHEM_TOP}/src
ENV         NWCHEM_TARGET=LINUX64
#ENV         NWCHEM_MODULES="all python"
ENV         NWCHEM_MODULES="nwdft driver stepper"
ENV         PYTHONVERSION=2.7
ENV         PYTHONHOME="/usr"
ENV         USE_PYTHONCONFIG=Y
ENV         BLASOPT="-L/opt/OpenBLAS-develop -lopenblas"
ENV         BLAS_SIZE=8
ENV         LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/opt/OpenBLAS-develop"
ENV         USE_MPI=y
ENV         USE_MPIF=y
ENV         USE_MPIF4=y
#ENV         MRCC_METHODS=y
#ENV         CCSDTQ=y
#ENV         CCSDTLR=y
ENV         FC=gfortran

WORKDIR     ${NWCHEM_TOP}/src
RUN         make clean && make nwchem_config && make -j3

#WORKDIR     ${NWCHEM_TOP}/contrib
#RUN         ./getmem.nwchem

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

WORKDIR     ${NWCHEM_TOP}/QA
ENTRYPOINT  ["runtests.mpi.unix"]
