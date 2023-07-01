#!/usr/bin/env bash
source ../libext_utils/get_tgz.sh
rm -rf mpich  mpich-?.?.?
#VERSION=3.4.2
VERSION=4.0.2
#curl -L http://www.mpich.org/static/downloads/${VERSION}/mpich-${VERSION}.tar.gz -o mpich.tgz
#curl -L https://github.com/pmodels/mpich/releases/download/v${VERSION}/mpich-${VERSION}.tar.gz -o mpich.tgz
get_tgz https://github.com/pmodels/mpich/releases/download/v${VERSION}/mpich-${VERSION}.tar.gz  mpich.tgz
tar xzf mpich.tgz
ln -sf mpich-${VERSION} mpich
cd mpich
if [[  -z "${FC}" ]]; then
    export FC=gfortran
fi
if [[  -z "${NWCHEM_TOP}" ]]; then
    dir3=$(dirname `pwd`)
    dir2=$(dirname "$dir3")
    NWCHEM_TOP=$(dirname "$dir2")
fi
echo FC is $FC
FC_EXTRA=$(${NWCHEM_TOP}/src/config/strip_compiler.sh ${FC})
echo FC_EXTRA is $FC_EXTRA
if  [[ ${FC_EXTRA} == gfortran ]] ; then
    GNUMAJOR=`$FC -dM -E - < /dev/null 2> /dev/null | grep __GNUC__ |cut -c18-`
    echo GNUMAJOR is $GNUMAJOR
    if [[ $GNUMAJOR -ge 10  ]]; then
	export FFLAGS=" -fallow-argument-mismatch "
        export FCFLAGS=" -fallow-argument-mismatch "
    fi
fi
if  [[ ${FC_EXTRA} == nvfortran ]] ; then
    export FFLAGS+=" -fPIC "
    export FCFLAGS+=" -fPIC "
fi
#mpich crashes when F90 and F90FLAGS are set
unset F90
unset F90FLAGS
echo 'using FFLAGS=' $FFLAGS
if [[  -z "${BUILD_ELPA}" ]]; then
    SHARED_FLAGS="--disable-shared"
else
    SHARED_FLAGS="--enable-shared"
    if  [[ ${FC_EXTRA} == amdflang ]] ; then
	echo ${FC_EXTRA} not compatible with shared libraries
	exit 1
    fi
fi
#cross compilation
if [ -x "$(command -v xx-info)" ]; then
    export CROSS_F77_SIZEOF_REAL=4 
    export CROSS_F77_SIZEOF_DOUBLE_PRECISION=8 
    export CROSS_F77_TRUE_VALUE=1 
    export CROSS_F77_FALSE_VALUE=0 
    export CROSS_F77_SIZEOF_INTEGER=4 
    export CROSS_F90_ADDRESS_KIND=8 
    export CROSS_F90_OFFSET_KIND=8 
    export CROSS_F90_INTEGER_KIND=8
    export CROSS_F90_REAL_MODEL=6,37 
    export CROSS_F90_DOUBLE_MODEL=15,307
    export CROSS_F90_INTEGER_MODEL_MAP={9,4,4}
    SHARED_FLAGS+=" --host=$(xx-info triple) "
fi
./configure --prefix=`pwd`/../.. --enable-fortran=all $SHARED_FLAGS  --disable-cxx --enable-romio --with-pm=gforker --with-device=ch3:nemesis --disable-cuda --disable-opencl --enable-silent-rules  --enable-fortran=all 
cat config.log
mkdir -p ../../../lib
echo
echo mpich compilation in progress
echo output redirected to libext/mpich/mpich/mpich.log
echo
make -j3 >& mpich.log
if [[ "$?" != "0" ]]; then
    tail -500 mpich.log
    echo " "
    echo "MPICH compilation failed"
    echo " "
    exit 1
fi

make install >& mpich_install.log
