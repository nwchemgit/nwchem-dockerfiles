# Create the image with the command
# docker build -t nwchem-qc .

# ------------------------------------------------------------
# Use Ubuntu base image
# ------------------------------------------------------------

FROM ubuntu:18.04

# --------------------------------
# Setup environment
# --------------------------------

ENV  NWCHEM_TOP="/opt/nwchem" \
     NWCHEM_TARGET=LINUX64 \
     ARMCI_NETWORK=MPI-PR \
     ARMCI_DEFAULT_SHMMAX_UBOUND=65536 \
     INTEL_64ALIGN=1 \
     NWCHEM_MODULES="all python" \
     USE_INTERNALBLAS=y \
     BLAS_SIZE=8 \
     LAPACK_SIZE=8 \
     USE_MPI=y \
     USE_MPIF=y \
     USE_MPIF4=y \
     IPCCSD=y \
     EACCSD=y \
     MRCC_METHODS=y \
     CCSDT=y \
     CCSDLR=y \
     PYTHONVERSION=2.7  \
     PYTHONHOME="/usr"  \
     USE_PYTHONCONFIG=Y  \
     PATH=$PATH:/opt/nwchem/bin/LINUX64 \
     OMP_NUM_THREADS=1 \
     PATH=$PATH:/opt/nwchem/contrib/quasar \
     NWCHEM_EXECUTABLE=/opt/nwchem/bin/LINUX64/nwchem

ARG nwchem_shaid=fb4151614232a00d292c2644c00745890e599522

# ------------------------------------------------------------
# Install dependencies
# ------------------------------------------------------------
RUN apt-get update -y && \
    apt-get install -y python-dev wget git curl gcc g++ gfortran make libopenmpi-dev && \
    apt-get clean && apt-get purge && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
# --------------------------------
# Build NWChem (master branch)
# ---------------------------------
    && cd /opt \
    && git clone https://github.com/nwchemgit/nwchem.git \
    && cd /opt/nwchem && git checkout ${nwchem_shaid} \
    && cd /opt/nwchem/src && make nwchem_config && make -j3 \
# -------------------------------------------
# Cleanup (remove unnecessary nwchem files)
# -------------------------------------------
    && cd /opt/nwchem && mv src/basis . && rm -rf src/* && mv basis src/ \
    && mv /opt/nwchem/QA/chem_library_tests/ /opt/nwchem/ \
    && rm -rf INSTALL* release.notes.* lib travis web doc examples QA \
# ---------------------------------------------
# Cleanup (remove unnecessary ubuntu packages)
# ---------------------------------------------
    && apt-get remove --purge -y $BUILD_PACKAGES $(apt-mark showauto) && rm -rf /var/lib/apt/lists/* \
    && apt-get update && apt-get --no-install-recommends install -y openmpi-bin openssh-client libgfortran-7-dev python-dev python3 python3-wheel python3-setuptools python3-pip \
    && pip3 install pyyaml && chmod +x /opt/nwchem/contrib/quasar/yaml_driver \
    && apt-get clean && apt-get purge && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && echo "#!""/bin/bash" > /usr/bin/nwchem_driver \
    && echo "mpirun --allow-run-as-root -np 2 \$NWCHEM_EXECUTABLE \$1" >> /usr/bin/nwchem_driver \
    && chmod +x /usr/bin/nwchem_driver


WORKDIR     /opt/data

ENTRYPOINT  ["yaml_driver"]



