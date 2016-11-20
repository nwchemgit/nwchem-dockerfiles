# builds a nwchem raspian image for rpi2 on x86_64 host
# Create the image with the command
# docker build -t edoapra/nwchem-dev.dftquick.rip2 .
# 

#docker run  -it -v /usr/bin/qemu-arm-static:/usr/bin/qemu-arm-static  sdhibit/rpi-raspbian bash
#docker run nwchem-dev dft_he2+ h2o_dk h2o_opt
#

FROM        sdhibit/rpi-raspbian
ADD        qemu-arm-static /usr/bin
#VOLUME    /usr/bin/qemu-arm-static:/usr/bin/qemu-arm-static

MAINTAINER  Edoardo Apra <edoardo.apra@pnnl.gov>

RUN         apt-get update \
            && apt-get -y upgrade \
            && apt-get install -y  gfortran  libopenmpi-dev openmpi-bin tcsh make openssh-client patch  subversion wget unzip  \
            && apt-get clean
#get OpenBLAS 
WORKDIR     /opt
RUN         mkdir -p /opt/lib/ \
            && wget  https://github.com/xianyi/OpenBLAS/archive/develop.zip \
            && unzip develop.zip \
            && rm develop.zip \
            && cd  OpenBLAS-develop \
            && make -j3 TARGET=ARMV7 NO_CBLAS=1 NO_LAPACK=1 NO_LAPACKE=1 MAX_CPU_NUMBER=1 libs shared \
            &&  cp libopenblas.* /opt/lib \
            && rm -rf /opt/OpenBLAS-develop
WORKDIR     /opt
ENV         NWCHEM_TOP="/opt/nwchem" \
            NWCHEM_TARGET=LINUX \
            NWCHEM_MODULES="nwdft driver stepper" \
            PYTHONVERSION=2.7 \
            PYTHONHOME="/usr" \
            USE_PYTHONCONFIG=Y \
            BLASOPT="-L/opt/lib -lopenblas" \
            LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/opt/lib" \
            USE_MPI=y \
            USE_MPIF=y \
            USE_MPIF4=y 
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
            && rm -rf tce tools nwdft NWints geom symmetry util nwxc ddscf lapack blas rism argos peigs rmdft gradients symmetry property smd lucia dplot propery hessian ccsd mp2_grad moints cafe analyz dimqm /opt/nwchem/lib \\
#clean unnecessary packages
           && apt-get -y remove  make curl subversion  unzip   tcsh  &&  apt-get -y autoremove && apt-get clean; rm -f /usr/bin/qemu-arm-static


#ENV         NWCHEM_EXECUTABLE=${NWCHEM_TOP}/bin/LINUX/nwchem
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
            PATH=$PATH:${NWCHEM_TOP}/bin/LINUX \
            SCRATCH_DIR=/data \
            PERMANENT_DIR=/data 
WORKDIR     /data
ENTRYPOINT  ["nwchem"]
