FROM        centos:7

MAINTAINER  Edoardo Apra <edoardo.apra@gmail.com>

RUN         yum update && yum install -y epel-release deltarpm \
            && yum -y upgrade \
            && yum install -y python-devel gcc-gfortran  openblas openmpi-devel scalapack-openmpi-devel  tcsh openssh-clients which bzip2 patch make perl\
            && yum clean all \ 
            && useradd -c 'NWChem user' -m -d /home/nwchem -s /bin/bash nwchem

USER        nwchem
WORKDIR     /home/nwchem
ENV         NWCHEM_TOP="/home/nwchem/nwchem-6.6" \
             PATH=$PATH:/home/nwchem/nwchem-6.6/bin/LINUX64:/usr/lib64/openmpi/bin/:$PATH \
             NWCHEM_TARGET=LINUX64 \
#             NWCHEM_MODULES="nwdft driver stepper solvation" \
             NWCHEM_MODULES="all python" \
              PYTHONVERSION=2.7 \
              PYTHONHOME="/usr" \
              USE_PYTHONCONFIG=Y \
              BLASOPT="/usr/lib64/libopenblas.so.0 -lpthread -lrt" \
              BLAS_SIZE=4 \
              USE_64TO32=y \
              LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/lib64/openmpi/lib" \
              SCALAPACK="-L/usr/lib64/openmpi/lib -lscalapack " \
              USE_MPI=y \
              USE_MPIF=y \
              USE_MPIF4=y \
              ARMCI_NETWORK=SOCKETS  \
              NWCHEM_EXECUTABLE=${NWCHEM_TOP}/bin/LINUX64/nwchem \
              NWCHEM_BASIS_LIBRARY=${NWCHEM_TOP}/src/basis/libraries/ \
              NWCHEM_NWPW_LIBRARY=${NWCHEM_TOP}/src/nwpw/libraryps/ \
              FFIELD=amber \
              AMBER_1=${NWCHEM_TOP}/src/data/amber_s/ \
              AMBER_2=${NWCHEM_TOP}/src/data/amber_q/ \
              AMBER_3=${NWCHEM_TOP}/src/data/amber_x/ \
              AMBER_4=${NWCHEM_TOP}/src/data/amber_u/ \
              SPCE=${NWCHEM_TOP}/src/data/solvents/spce.rst \
              CHARMM_S=${NWCHEM_TOP}/src/data/charmm_s/ \
              CHARMM_X=${NWCHEM_TOP}/src/data/charmm_x/ 
#ENV          ELPA="-I/usr/lib64/gfortran/modules/openmpi -L/usr/lib64/openmpi/lib -lelpa"
RUN        curl -SL https://nwchemgit.github.io/images/Nwchem-6.6.revision27746-srconly.2015-10-20.tar.bz2 | tar -jxf -  \
            && cd nwchem-6.6 \
            && curl -SL https://nwchemgit.github.io/images/Tools_lib64.patch.gz | gzip -d | patch -p0 \
            &&   curl -SL https://nwchemgit.github.io/images/Config_libs66.patch.gz | gzip -d | patch -p0 \
            &&   curl -SL https://nwchemgit.github.io/images/Cosmo_meminit.patch.gz | gzip -d | patch -p0 \
            &&   curl -SL https://nwchemgit.github.io/images/Sym_abelian.patch.gz | gzip -d | patch -p0 \
            &&   curl -SL https://nwchemgit.github.io/images/Xccvs98.patch.gz | gzip -d | patch -p0 \
            &&   curl -SL https://nwchemgit.github.io/images/Dplot_tolrho.patch.gz | gzip -d | patch -p0 \
            &&   curl -SL https://nwchemgit.github.io/images/Driver_smalleig.patch.gz | gzip -d | patch -p0 \
            &&   curl -SL https://nwchemgit.github.io/images/Ga_argv.patch.gz | gzip -d | patch -p0 \
            &&   curl -SL https://nwchemgit.github.io/images/Raman_displ.patch.gz | gzip -d | patch -p0 \
            &&   curl -SL https://nwchemgit.github.io/images/Ga_defs.patch.gz | gzip -d | patch -p0 \
            &&   curl -SL https://nwchemgit.github.io/images/Zgesvd.patch.gz | gzip -d | patch -p0 \
            &&   curl -SL https://nwchemgit.github.io/images/Cosmo_dftprint.patch.gz | gzip -d | patch -p0 \
            &&   curl -SL https://nwchemgit.github.io/images/Txs_gcc6.patch.gz | gzip -d | patch -p0 \
            &&   curl -SL https://nwchemgit.github.io/images/Gcc6_optfix.patch.gz | gzip -d | patch -p0 \
            &&   curl -SL https://nwchemgit.github.io/images/Util_gnumakefile.patch.gz | gzip -d | patch -p0 \
            &&   curl -SL https://nwchemgit.github.io/images/Util_getppn.patch.gz | gzip -d | patch -p0 \
            &&   curl -SL https://nwchemgit.github.io/images/Gcc6_macs_optfix.patch.gz | gzip -d | patch -p0 \
            &&   curl -SL https://nwchemgit.github.io/images/Notdir_fc.patch.gz | gzip -d | patch -p0 \
            &&   curl -SL https://nwchemgit.github.io/images/Xatom_vdw.patch.gz | gzip -d | patch -p0 \
            && cd src  \
            && make clean && make nwchem_config && make 64_to_32;make -j3 \
            && rm -rf tce tools nwdft NWints geom symmetry util nwxc ddscf lapack blas rism argos peigs rmdft gradients symmetry property smd lucia dplot propery hessian ccsd mp2_grad moints cafe analyz dimqm  /home/nwchem/nwchem-6.6/lib


WORKDIR     /data
ENTRYPOINT  ["mpirun","-np","3","nwchem"]
