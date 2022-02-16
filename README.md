# NWChem Dockerfiles
Dockerfiles to create NWChem Docker containers

https://nwchemgit.github.io/


## USAGE SYNTAX

```
 docker run --shm-size 256m --rm -v [host_system_dir]:/data ghcr.io/nwchemgit/nwchem-dev/[arch] input.nw
```
where the `[arch]` option can have the values `amd64`, `arm64`, `ppc64le` or `armv7`  
## EXAMPLES

```
cd /tmp

wget https://raw.githubusercontent.com/nwchemgit/nwchem/master/QA/tests/dft_he2+/dft_he2+.nw
docker run --shm-size 256m --rm -v /tmp:/data ghcr.io/nwchemgit/nwchem-dev/amd64 dft_he2+.nw
```
Example of parallel run  

```
docker run --shm-size 256m --rm  --entrypoint='/usr/bin/mpirun' \
-v /tmp:/data ghcr.io/nwchemgit/nwchem-700.mpipr \
-np 3 nwchem dft_siosi3.nw
```

