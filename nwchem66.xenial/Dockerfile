FROM        ubuntu:xenial

MAINTAINER  Edoardo Apra <edoardo.apra@gmail.com>

ENV         MYHOME=/home/nwchem
ENV         NWCHEM_TOP=$MYHOME/nwchem-6.6

RUN         apt-get update \
            && apt-get -y upgrade \
            && apt-get install -y python-dev gfortran  libopenmpi-dev openmpi-bin make curl subversion  unzip cmake perl tcsh ssh bzip2 tar patch \
            &&  apt-get clean \
            && useradd -c 'NWChem user' -m -d $MYHOME -s /bin/bash nwchem
USER        nwchem
WORKDIR     $MYHOME
#get OpenBLAS using the default 32bit ints to work with Scalapack
RUN         mkdir -p lib  \
            &&  curl -L https://github.com/xianyi/OpenBLAS/archive/develop.zip -o develop.zip && unzip develop.zip ; rm develop.zip
WORKDIR     OpenBLAS-develop
#TARGET=CORE2 for compatibility
RUN         make -j3  TARGET=CORE2 NO_CBLAS=1 NO_LAPACKE=1 && cp libopenblas.* $MYHOME/lib \
            && rm -rf $MYHOME/OpenBLAS-develop
# build scalapack 
WORKDIR     $MYHOME
#RUN         svn --trust-server-cert co https://icl.cs.utk.edu/svn/scalapack-dev/scalapack/trunk scalapack
#WORKDIR     scalapack
RUN         curl http://www.netlib.org/scalapack/scalapack-2.0.2.tgz -o scalapack-2.0.2.tgz \ 
            &&  tar xzf scalapack-2.0.2.tgz && rm scalapack-2.0.2.tgz \
            && mkdir -p $MYHOME/scalapack-2.0.2/build
WORKDIR     $MYHOME/scalapack-2.0.2/build
RUN         cmake ../ -DCMAKE_BUILD_TYPE=MinSizeRel -DBUILD_TESTING=OFF -DBUILD_SHARED_LIBS=ON -DUSE_OPTIMIZED_LAPACK_BLAS=ON -DBLAS_blas_LIBRARY="$MYHOME/lib/libopenblas.so" -DLAPACK_lapack_LIBRARY="$MYHOME/lib/libopenblas.so" \
            && make -j3 \
            && cp $MYHOME/scalapack-2.0.2/build/lib/libscalapack.* $MYHOME/lib/. \
            && rm -rf $MYHOME/scalapack-2.0.2
WORKDIR     $MYHOME
#RUN         mkdir -p nwchem-6.6
#WORKDIR     nwchem-6.6
ENV         NWCHEM_TARGET=LINUX64
ENV          NWCHEM_MODULES="nwdft driver stepper solvation" 
#ENV         NWCHEM_MODULES="all python"
ENV         PYTHONVERSION=2.7
ENV         PYTHONHOME="/usr"
ENV         USE_PYTHONCONFIG=Y
ENV         BLASOPT="-L$MYHOME/lib -lopenblas"
ENV         BLAS_SIZE=4
ENV         SCALAPACK="-L$MYHOME/lib -lscalapack"
ENV         SCALAPACK_SIZE=4
ENV          USE_SCALAPACK=y
ENV         LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$MYHOME/lib
ENV         PATH=$PATH:${NWCHEM_TOP}/bin/LINUX64
#ENV         USE_OPENMP=y
ENV         USE_64TO32=y
ENV         USE_MPI=y
#ENV         USE_MPIF=y
#ENV         USE_MPIF4=y
#ENV         MRCC_METHODS=y

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
            && rm -rf tce tools nwdft NWints geom symmetry util nwxc ddscf lapack blas rism argos peigs rmdft gradients symmetry property smd lucia dplot propery hessian ccsd mp2_grad moints cafe analyz dimqm  $MYHOME/nwchem-6.6/lib


WORKDIR     /data
ENTRYPOINT  ["mpirun","-np","3","nwchem"]
