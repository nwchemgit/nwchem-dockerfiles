#based on earlier work by Vladimir Konjkov <Konjkov.VV@gmail.com>
#
# Create the image with the command
# docker build -t nwchem-dev .
# 
#

FROM        nersc/centos-mpi:7

MAINTAINER  Edoardo Apra <edoardo.apra@pnnl.gov>

ENV         PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:. \
            ARMCI_NETWORK=MPI-PR NWCHEM_TOP="/usr/local/src/nwchem-6.8.1" \
            NWCHEM_TARGET=LINUX64 \
            NWCHEM_MODULES="nwdft driver stepper" \
            BLASOPT="-L/usr/lib64 -lopenblas" \
            BLAS_SIZE=4 \
            SCALAPACK="-L/opt/lib -lscalapack" \
            SCALAPACK_SIZE=4 \
            LD_LIBRARY_PATH=/opt/lib/:"$LD_LIBRARY_PATH" \
            USE_64TO32=y \
            USE_MPI=y \
            USE_MPIF=y \
            USE_MPIF4=y 
#ENV         MRCC_METHODS=y
#ENV         CCSDTQ=y
#ENV         CCSDTLR=y
RUN         rpm -Uvh http://download.fedoraproject.org/pub/epel/7/x86_64/Packages/e/epel-release-7-11.noarch.rpm \
            && rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY* \
            && yum -y makecache fast; yum -y install deltarpm \
            && yum -y update; yum -y upgrade \
            && yum install -y  libgfortran4 python-devel gcc-gfortran openblas-devel tcsh openssh-clients which bzip2 patch make perl   findutils hostname git unzip cmake  \
            && yum clean all  && rm -rf /var/cache/yum  \
            && cd /usr/local/src \
            && wget  http://www.netlib.org/scalapack/scalapack-2.0.2.tgz \
	    && tar xzf scalapack-2.0.2.tgz && ln -sf scalapack-2.0.2 scalapack \
	    && cd scalapack \
	    && mkdir -p build && cd build \
            &&  cmake ../ -DCMAKE_BUILD_TYPE=MinSizeRel -DBUILD_TESTING=OFF -DBUILD_SHARED_LIBS=ON -DUSE_OPTIMIZED_LAPACK_BLAS=ON -DBLAS_Accelerate_LIBRARY="/usr/lib64/libopenblas.so" -DLAPACK_Accelerate_LIBRARY="/usr/lib64/libopenblas.so" \
            && make -j3 scalapack \
            && mkdir -p  /opt/lib/ \
            && cp lib/libscalapack.* /opt/lib/. \
            && cd ../.. && rm -rf scalapack*
RUN         cd /usr/local/src \
            && git clone  --depth 1 -b hotfix/release-6-8 https://github.com/nwchemgit/nwchem.git nwchem-6.8.1 \
            && cd nwchem-6.8.1/src \
#strip native compiler options as Fedora does
            && sed -i 's|-march=native||' config/makefile.h \
            && sed -i 's|-mtune=native|-mtune=generic|' config/makefile.h \
            && sed -i 's|-mfpmath=sse||' config/makefile.h \
            && sed -i 's|-msse3||' config/makefile.h  \
            && sed -i 's|child = fork();|/*child = fork();*/|' util/util_debug.c \
            && make nwchem_config && (make 64_to_32 >& 6log &) && make  -j3  \
#clean unnecessary source to reduce docker size
            && rm -rf tce tools nwdft NWints geom symmetry util nwxc ddscf lapack blas rism argos peigs rmdft gradients symmetry property smd lucia dplot property hessian ccsd mp2_grad moints cafe analyz dimqm /usr/local/src/nwchem/lib \
            && rpm -e make    unzip  tcsh  &&  yum clean all  && rm -rf /var/cache/yum 

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
            LD_LIBRARY_PATH=/opt/lib/  \
            PATH=${NWCHEM_TOP}/bin/LINUX64:/usr/bin:/bin:/usr/sbin:/sbin
#clean unnecessary packages

WORKDIR     /data
ENTRYPOINT  ["/bin/bash"]
