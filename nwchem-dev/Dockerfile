#based on earlier work by Vladim Konjkov <Konjkov.VV@gmail.com>
#
# Create the image with the command
# docker build -t nwchem-dev .
# 
#after successful build one should run container to calculate input.nw file placed in <host_system_dir>
#docker run -dv <host_system_dir>:/data nwchem-dev "input.nw"
#this command return container ID to read logs by
#docker logs <container ID>
#
#It is possible to pause execution, and then continue.
#docker pause <container ID>
#docker unpause <container ID>

FROM        debian

MAINTAINER  Edoardo Apra <edoardo.apra@pnnl.gov>

ENV         NWCHEM_TOP="/opt/nwchem" \
            NWCHEM_TARGET=LINUX64  \
            NWCHEM_MODULES="all python"  \
            PYTHONVERSION=2.7  \
            PYTHONHOME="/usr"  \
            USE_PYTHONCONFIG=Y  \
            ARMCI_NETWORK=MPI-PT  \
            USE_OPENMP=y  \
            USE_NOIO=y  \
            USE_MPI=y  \
            USE_MPIF=y  \
            USE_MPIF4=y  \
            NWCHEM_EXECUTABLE=${NWCHEM_TOP}/bin/LINUX64/nwchem \
            NWCHEM_BASIS_LIBRARY=${NWCHEM_TOP}/src/basis/libraries/ \
            NWCHEM_NWPW_LIBRARY=${NWCHEM_TOP}/src/nwpw/libraryps/  \
            FFIELD=amber  \
            AMBER_1=${NWCHEM_TOP}/src/data/amber_s/  \
            AMBER_2=${NWCHEM_TOP}/src/data/amber_q/  \
            AMBER_3=${NWCHEM_TOP}/src/data/amber_x/  \
            AMBER_4=${NWCHEM_TOP}/src/data/amber_u/  \
            SPCE=${NWCHEM_TOP}/src/data/solvents/spce.rst  \
            CHARMM_S=${NWCHEM_TOP}/src/data/charmm_s/  \
            CHARMM_X=${NWCHEM_TOP}/src/data/charmm_x/  \
	    BUILD_OPENBLAS=1 \
	    BUILD_SCALAPACK=1 \
	    BLAS_SIZE=8 \
	    SCALAPACK_SIZE=8 \
            PATH=$PATH:/opt/nwchem/bin/LINUX64 
#one single ugly command to reduce docker size
RUN         apt-get update \
            && apt-get -y upgrade \
            && apt-get install -y python-dev gfortran  mpich libmpich-dev  make curl   unzip cmake ssh git file wget \
            && cd /opt; git clone --depth 1  https://github.com/nwchemgit/nwchem.git  \
            && cd nwchem/src \
#strip native compiler options as Fedora does
            && sed -i 's|-march=native||' config/makefile.h \
            && sed -i 's|-mtune=native|-mtune=generic|' config/makefile.h \
            && sed -i 's|-mfpmath=sse||' config/makefile.h \
            && sed -i 's|-msse3||' config/makefile.h  \
            && make nwchem_config    && make -j3 \
#clean unnecessary source to reduce docker size
            && rm -rf tce tools nwdft NWints geom symmetry util nwxc ddscf lapack blas rism argos peigs rmdft gradients symmetry property smd lucia dplot propery hessian ccsd mp2_grad moints cafe analyz dimqm /opt/nwchem/lib libext/scalapack libext/openblas ../QA ../contrib ../examples ../.git ../travis \
#clean unnecessary packages
            &&       apt-get -y remove wget git make curl  unzip cmake  &&  apt-get -y autoremove && apt-get clean \
	    && dpkg-query -Wf '${Installed-Size}\t${Package}\n' | sort -n | tail -n 40

WORKDIR     /data
ENTRYPOINT  ["nwchem"]

#CMD ["/bin/bash"]

