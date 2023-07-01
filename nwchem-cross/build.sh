#!/bin/bash
BUILDKIT_STEP_LOG_MAX_SIZE=10485760 docker build --no-cache --progress plain --platform linux/arm64 \
       --build-arg FC=gfortran --build-arg NWCHEM_BRANCH=master --build-arg CACHE_HIT=N --build-arg GITHUB_REPOSITORY_OWNER=edoapra    \
-t myxx .

#       --driver-opt env.BUILDKIT_STEP_LOG_MAX_SIZE=10485760 \

#2023-06-30T06:11:21.8977353Z   build-args: FC=gfortran
#NWCHEM_BRANCH=master
#CACHE_HIT=Y
#GITHUB_REPOSITORY_OWNER=edoapra
