Docker build of the current NWChem master branch on xlf/ppc64le
========================================
### BUILD INSTRUCTIONS

Dockerfile based on https://github.com/IBM/xlf-community-edition-dockerfile. Modified for Ubuntu 18.04.
```
docker    buildx build  --platform linux/ppc64le -t  nwchem-dev.xlf .
```

### RUN INSTRUCTIONS
```
 docker run  --rm -ti --platform linux/ppc64le  nwchem-dev.xlf
```
