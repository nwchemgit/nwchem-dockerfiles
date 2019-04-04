FROM        ubuntu:xenial

MAINTAINER  Edoardo Apra <edoardo.apra@gmail.com>

ENV         MYHOME=/home/nwchem
ENV         NWCHEM_TOP=$MYHOME/nwchem-6.8

RUN         sed -i 's|archive.ubuntu.com|mirrors.us.kernel.org|' /etc/apt/sources.list \
            && apt -qq update \
            && apt -qq -y upgrade \
            && apt-get install -y python-dev gfortran  libopenmpi-dev openmpi-bin make git subversion  unzip cmake perl tcsh ssh bzip2 tar patch libopenblas-dev \
            &&  apt-get clean \
            && useradd -c 'NWChem user' -m -d $MYHOME -s /bin/bash nwchem
USER        nwchem
WORKDIR     $MYHOME
#RUN         mkdir -p nwchem-6.8
#WORKDIR     nwchem-6.8
ENV         NWCHEM_TARGET=LINUX64
ENV          NWCHEM_MODULES="nwdft driver stepper  python" 
#ENV         NWCHEM_MODULES="all python"
ENV         PYTHONVERSION=2.7
ENV         PYTHONHOME="/usr"
ENV         USE_PYTHONCONFIG=Y
ENV         BLASOPT="-lopenblas -lpthread -lrt"
ENV         BLAS_SIZE=4
ENV         PATH=$PATH:${NWCHEM_TOP}/bin/LINUX64
#ENV         USE_OPENMP=y
ENV         USE_64TO32=y
ENV         USE_MPI=y
env          USE_PYTHONCONFIG=y
env          PYTHONVERSION=2.7
#ENV         USE_MPIF=y
#ENV         USE_MPIF4=y
#ENV         MRCC_METHODS=y

RUN        cd $MYHOME; git clone -b release-6-8 https://github.com/nwchemgit/nwchem.git nwchem-6.8  \
            && cd nwchem-6.8/src \
            && ls -lrt  \
            && make clean && make nwchem_config && make 64_to_32;make -j3 
#            && rm -rf /opt/nwchem/.svn \
#            && make clean && make nwchem_config && make 64_to_32;make -j3 \
#            && rm -rf tce tools nwdft NWints geom symmetry util nwxc ddscf lapack b#las rism argos peigs rmdft gradients symmetry property smd lucia dplot propery hess#ian ccsd mp2_grad moints cafe analyz dimqm  $MYHOME/nwchem-6.8/lib


WORKDIR     /data
ENTRYPOINT  ["mpirun","-np","3","nwchem"]
