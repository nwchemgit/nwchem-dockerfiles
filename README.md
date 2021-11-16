# NWChem Dockerfiles
Dockerfiles to create NWChem Docker containers

https://nwchemgit.github.io/


## USAGE SYNTAX

```
 docker run --rm -v [host_system_dir]:/data ghcr.io/nwchemgit/nwchem-dev/amd64 input.nw
```

## EXAMPLE

```
cd /tmp
wget https://raw.githubusercontent.com/nwchemgit/nwchem/master/QA/tests/libxc_waterdimer_bmk/libxc_waterdimer_bmk.nw
docker run -dv /tmp:/data ghcr.io/nwchemgit/nwchem-dev/amd64 libxc_waterdimer_bmk.nw
docker run --rm -v /tmp:/data ghcr.io/nwchemgit/nwchem-dev/amd64 libxc_waterdimer_bmk.nw
```

