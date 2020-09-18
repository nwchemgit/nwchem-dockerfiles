#based on earlier work by Vladimir Konjkov <Konjkov.VV@gmail.com>
#
# Create the image with the command
# docker build -t nwchem-701.mpipr.nersc .
# 
#after successful build one you can execute the QA tests using the command
#docker run nwchem-701.mpipr.nersc dft_he2+ h2o_dk h2o_opt
#

FROM        ubuntu:20.04

MAINTAINER  Edoardo Apra <edoardo.apra@pnnl.gov>
SHELL ["/bin/bash", "-c"]

ARG DEBIAN_FRONTEND=noninteractive
ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1
ARG nwchem_hash=75f3db2a2074e9158d605516009964d1a363e71f
ENV         ARMCI_NETWORK=MPI-PR NWCHEM_TOP="/opt/nwchem-$nwchem_hash" \
            NWCHEM_TARGET=LINUX64 \
            NWCHEM_MODULES="nwdft driver stepper solvation" \
            BLASOPT=" -lmkl_intel_ilp64 -lmkl_sequential -lmkl_core  -lpthread -lm -ldl"\
            LAPACK_LIB="-lmkl_intel_ilp64 -lmkl_sequential -lmkl_core  -lpthread -lm -ldl"\
            SCALAPACK_LIB=" -lmkl_scalapack_ilp64 -lmkl_blacs_intelmpi_ilp64 -lpthread -lm -ldl" \
            BLAS_SIZE=8 \
            SCALAPACK_SIZE=8 \
            USE_64TO32=y \
	    USE_FPICF=y \
            USE_MPI=y \
            USE_MPIF=y \
            USE_MPIF4=y 
RUN         apt-get update \
            && apt-get -y upgrade \
            && apt-get install -y  g++ gfortran   make ssh patch curl subversion wget unzip perl git file python3 python3-dev gnupg2 software-properties-common \
            && cd /tmp  \
            && wget https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS-2023.PUB \
            && apt-key add GPG-PUB-KEY-INTEL-SW-PRODUCTS-2023.PUB  \
            && rm GPG-PUB-KEY-INTEL-SW-PRODUCTS-2023.PUB  \
            && echo "deb https://apt.repos.intel.com/oneapi all main" | tee /etc/apt/sources.list.d/oneAPI.list \
            && add-apt-repository "deb https://apt.repos.intel.com/oneapi all main" \
            && apt-get update \
            && apt install -y intel-oneapi-ifort intel-oneapi-mpi intel-oneapi-mpi-devel intel-oneapi-mkl intel-oneapi-dpcpp-cpp-compiler-pro \
            && apt-get clean \
            && cd /opt;curl -SL     https://github.com/nwchemgit/nwchem/archive/$nwchem_hash.tar.gz | tar xzf - \
	    &&  source /opt/intel/oneapi/mpi/latest/env/vars.sh \
	    &&  source /opt/intel/oneapi/compiler/latest/env/vars.sh \
	    &&  source /opt/intel/oneapi/mkl/latest/env/vars.sh \
	    && env|grep _lin \
            && cd nwchem-$nwchem_hash/src \
#strip native compiler options as Fedora does
            && sed -i 's|-march=native||' config/makefile.h \
            && sed -i 's|-mtune=native|-mtune=generic|' config/makefile.h \
            && sed -i 's|-mfpmath=sse||' config/makefile.h \
            && sed -i 's|-msse3||' config/makefile.h  \
            && make nwchem_config && make FC=ifort -j3 \
	  #clean unnecessary source to reduce docker size
            && rm -rf tce tools nwdft NWints geom symmetry util nwxc ddscf lapack blas rism argos peigs rmdft gradients symmetry property smd lucia dplot propery hessian ccsd mp2_grad moints cafe analyz dimqm /opt/nwchem/lib ../../QA \
#clean unnecessary packages
         && apt-get -y purge  make curl subversion  unzip cmake perl tcsh intel-oneapi-ifort intel-oneapi-dpcpp-cpp-compiler-pro intel-oneapi-tbb-devel intel-oneapi-tbb &&  apt-get -y autoremove && apt -y install intel-oneapi-mkl && apt-get clean

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
            PATH=$PATH:${NWCHEM_TOP}/bin/LINUX64:/opt/intel/oneapi/mpi/latest//libfabric/bin:/opt/intel/oneapi/mpi/latest//bin \
            I_MPI_ROOT=/opt/intel/oneapi/mpi/latest \
            FI_PROVIDER_PATH=/opt/intel/oneapi/mpi/latest/libfabric/lib/prov \
            LIBRARY_PATH=/opt/intel/oneapi/mpi/latest//libfabric/lib:/opt/intel/oneapi/mpi/latest//lib/release:/opt/intel/oneapi/mpi/latest/lib \
            CLASSPATH=/opt/intel/oneapi/mpi/latest//lib/mpi.jar \
            LD_LIBRARY_PATH=opt/intel/oneapi/mpi/latest/lib:/opt/intel/oneapi/mpi/latest/lib/release:/opt/intel/oneapi/mkl/latest/lib/intel64/:/opt/intel/oneapi/mpi/latest/libfabric/lib:/opt/intel/oneapi/mpi/latest/lib/ \
            CPATH=/opt/intel/oneapi/mpi/latest//include


WORKDIR     /data
ENTRYPOINT  ["mpirun","-np","3","nwchem"]
