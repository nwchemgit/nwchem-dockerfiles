FROM        debian:buster

MAINTAINER  Edoardo Apra <edoardo.apra@gmail.com>

ENV         DEBIAN_FRONTEND=noninteractive

RUN         apt-get update \
            && apt-get -y upgrade \
            && apt-get install -y curl  python3-dev gfortran  mpi-default-bin mpi-default-dev ssh git  dpkg-dev  devscripts debhelper dh-python pkg-config python3-dev python-minimal python-dev cmake  libarmci-mpi-dev libscalapack-mpi-dev libglobalarrays-dev libopenblas-base libopenblas-dev \
            &&  apt-get clean \
            &&  git  clone https://salsa.debian.org/edoapra-guest/nwchem.git \
            &&  cd nwchem \
            && curl -LJO https://github.com/nwchemgit/nwchem/archive/refs/tags/v7.0.2-release.tar.gz \
	    && ln -sf nwchem-7.0.2-release.tar.gz nwchem_7.0.2.orig.tar.gz \
	    && tar xzf nwchem*release.tar.gz \
	    && cp -rp debian nwchem-*/. \
	    && cd nwchem-* \
	    && dpkg-buildpackage  -d -rfakeroot -us -uc \
            && cd .. \
            && find . -name "nwc*deb" \
	    && echo **** DONE **************

WORKDIR     /data
ENTRYPOINT  ["/bin/bash"]
