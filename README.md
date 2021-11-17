# NWChem Dockerfiles
Dockerfiles to create NWChem Docker containers

https://nwchemgit.github.io/


## USAGE SYNTAX

```
 docker run --rm -v [host_system_dir]:/data ghcr.io/nwchemgit/nwchem-dev/[arch] input.nw
```
where the `[arch]` option can have the values `amd64`, `arm64`, `ppc64le` or `armv7`
## EXAMPLE

```
cd /tmp

wget https://raw.githubusercontent.com/nwchemgit/nwchem/master/QA/tests/libxc_waterdimer_bmk/libxc_waterdimer_bmk.nw

docker run --rm -v /tmp:/data ghcr.io/nwchemgit/nwchem-dev/amd64 libxc_waterdimer_bmk.nw
```

