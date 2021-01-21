# builds a nwchem raspian image for rpi2 on x86_64 host
# Create the image with the command
# docker build -t edoapra/nwchem-dev.dftquick.rip2 .
# 

#docker run  -it -v /usr/bin/qemu-arm-static:/usr/bin/qemu-arm-static  sdhibit/rpi-raspbian bash
#docker run nwchem-dev dft_he2+ h2o_dk h2o_opt
#

#FROM        sdhibit/rpi-raspbian
#ADD        qemu-arm-static /usr/bin
#VOLUME    /usr/bin/qemu-arm-static:/usr/bin/qemu-arm-static
FROM        arm32v7/debian:bullseye

MAINTAINER  Edoardo Apra <edoardo.apra@pnnl.gov>
ENV 	    DEBIAN_FRONTEND=noninteractive \
            NWCHEM_TOP="/home/nwchem/nwchem-master" \
            NWCHEM_TARGET=LINUX \
            NWCHEM_MODULES="nwdft solvation driver stepper" \
            PYTHONVERSION=2.7 \
            PYTHONHOME="/usr" \
            USE_PYTHONCONFIG=Y \
            BLASOPT=-lopenblas \
            LAPACK_LIB=-lopenblas \
            BLAS_SIZE=4 \
            FORCETARGET=" TARGET=ARMV7 " \
            USE_MPI=y \
            USE_MPIF=y \
            USE_MPIF4=y
RUN         uname -m \
	    && apt-get update \
            && apt-get install -y bzip2 curl unzip tar wget \
	    && bzip2 -V \
            && apt-get install -y gfortran libopenmpi-dev openmpi-bin libopenblas-dev make openssh-client\
            && apt-get clean \
            && useradd -c 'NWChem user' -m -d /home/nwchem -s /bin/bash nwchem \
            && cd     /home/nwchem \
            && wget -q https://github.com/nwchemgit/nwchem/archive/master.zip \
            && unzip -qq  master.zip  nwchem-master/src/* \
	    && rm -f *.zip || true \
            && cd nwchem-master/src \
            && sed -i 's|-march=native||' config/makefile.h \
            && sed -i 's|-mtune=native|-mtune=generic|' config/makefile.h \
            && sed -i 's|-mfpmath=sse||' config/makefile.h \
            && sed -i 's|-msse3||' config/makefile.h  \
            && ls -lrt  \
            &&  make nwchem_config  \
            &&  make V=1 -j3 \
#clean unnecessary source to reduce docker size
            && rm -rf tce tools nwdft NWints geom symmetry util nwxc ddscf lapack blas rism argos peigs rmdft gradients symmetry property smd lucia dplot propery hessian ccsd mp2_grad moints cafe analyz dimqm /home/nwchem/nwchem-master/lib \
           && apt-get -y purge cmake make curl patch unzip  &&  apt-get -y autoremove && apt-get clean \
	   && chown -R nwchem /home/nwchem && chgrp -R nwchem /home/nwchem
USER        nwchem
RUN         ls -lrt /home/nwchem/nwchem-master && ls -lrt /home/nwchem/nwchem-master/bin/LINUX \
            && env \
	    && whoami


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
#ENTRYPOINT  ["nwchem"]
ENTRYPOINT  ["/bin/bash"]
#ENTRYPOINT  ["mpirun","-np","3","nwchem"]
