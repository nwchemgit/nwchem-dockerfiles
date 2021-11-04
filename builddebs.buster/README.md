# Docker build to test NWChem debian packages

The file Dockerfile can be used by tying the command
```
docker build -t  builddebs.buster .
```

### Examples




The following command will get a  shell on the Docker container and copy the `*.deb` files to the host filesystem.
```
docker run  --entrypoint='/bin/bash' -v /home/edo/debs:/data -it builddebs.buster
cp -ax /debichem-team/nwchem/nwchem*deb /data/.
```
