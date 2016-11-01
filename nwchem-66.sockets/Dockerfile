FROM        ubuntu:14.04

MAINTAINER  Vladimir Konjkov <Konjkov.VV@gmail.com>

ENV         NWCHEM_TOP="/opt/nwchem-6.6"

RUN         apt-get update \
            && apt-get -y upgrade \
            && apt-get install -y python-dev gfortran libopenblas-dev libopenmpi-dev openmpi-bin tcsh make ssh patch curl

WORKDIR     /opt
RUN        curl -SL http://www.nwchem-sw.org/images/Nwchem-6.6.revision27746-src.2015-10-20.tar.bz2 | tar -jxf -
ADD         Nwchem-6.6.revision27746-src.2015-10-20.tar.bz2 /opt

WORKDIR     ${NWCHEM_TOP}
RUN         curl -SL http://www.nwchem-sw.org/images/Tddft_mxvec20.patch.gz | gzip -d | patch -p0
RUN         curl -SL http://www.nwchem-sw.org/images/Tools_lib64.patch.gz | gzip -d | patch -p0
RUN         curl -SL http://www.nwchem-sw.org/images/Config_libs66.patch.gz | gzip -d | patch -p0
RUN         curl -SL http://www.nwchem-sw.org/images/Cosmo_meminit.patch.gz | gzip -d | patch -p0
RUN         curl -SL http://www.nwchem-sw.org/images/Sym_abelian.patch.gz | gzip -d | patch -p0
RUN         curl -SL http://www.nwchem-sw.org/images/Xccvs98.patch.gz | gzip -d | patch -p0
RUN         curl -SL http://www.nwchem-sw.org/images/Dplot_tolrho.patch.gz | gzip -d | patch -p0
RUN         curl -SL http://www.nwchem-sw.org/images/Driver_smalleig.patch.gz | gzip -d | patch -p0
RUN         curl -SL http://www.nwchem-sw.org/images/Ga_argv.patch.gz | gzip -d | patch -p0
RUN         curl -SL http://www.nwchem-sw.org/images/Raman_displ.patch.gz | gzip -d | patch -p0
RUN         curl -SL http://www.nwchem-sw.org/images/Ga_defs.patch.gz | gzip -d | patch -p0
RUN         curl -SL http://www.nwchem-sw.org/images/Zgesvd.patch.gz | gzip -d | patch -p0
RUN         curl -SL http://www.nwchem-sw.org/images/Cosmo_dftprint.patch.gz | gzip -d | patch -p0
RUN         curl -SL http://www.nwchem-sw.org/images/Txs_gcc6.patch.gz | gzip -d | patch -p0
RUN         curl -SL http://www.nwchem-sw.org/images/Gcc6_optfix.patch.gz | gzip -d | patch -p0
RUN         curl -SL http://www.nwchem-sw.org/images/Util_gnumakefile.patch.gz | gzip -d | patch -p0
RUN         curl -SL http://www.nwchem-sw.org/images/Util_getppn.patch.gz | gzip -d | patch -p0
RUN         curl -SL http://www.nwchem-sw.org/images/Gcc6_macs_optfix.patch.gz | gzip -d | patch -p0
RUN         curl -SL http://www.nwchem-sw.org/images/Notdir_fc.patch.gz | gzip -d | patch -p0
RUN         curl -SL http://www.nwchem-sw.org/images/Xatom_vdw.patch.gz | gzip -d | patch -p0

ENV         NWCHEM_TARGET=LINUX64
#ENV         NWCHEM_MODULES="all python"
ENV         NWCHEM_MODULES="nwdft driver stepper solvation"
ENV         PYTHONVERSION=2.7
ENV         PYTHONHOME="/usr"
ENV         USE_PYTHONCONFIG=Y
ENV         BLASOPT="-L/usr/lib/openblas-base -lopenblas"
ENV         BLAS_SIZE=4
ENV         USE_64TO32=y
ENV         LIBRARY_PATH="$LIBRARY_PATH:/usr/lib/openblas-base"
ENV         USE_MPI=y
ENV         USE_MPIF=y
ENV         USE_MPIF4=y
ENV         MPI_LOC="/usr/lib/openmpi/lib"
ENV         MPI_INCLUDE="/usr/lib/openmpi/include"
ENV         LIBMPI="-lmpi -lopen-rte -lopen-pal -ldl -lmpi_f77 -lpthread"
ENV         LIBRARY_PATH="$LIBRARY_PATH:/usr/lib/openmpi/lib"
#ENV         MRCC_METHODS=y
#ENV         CCSDTQ=y
#ENV         CCSDTLR=y
ENV         ARMCI_NETWORK=SOCKETS
ENV         FC=gfortran

WORKDIR     ${NWCHEM_TOP}/src
RUN         make clean && make nwchem_config && make 64_to_32;make

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
ENV         PATH=$PATH:${NWCHEM_TOP}/bin/LINUX64

WORKDIR     /data
ENTRYPOINT  ["mpirun","-np","3","nwchem"]
