Builds on non-ARM hardware a NWChem binary for Rapsberry Pi2 (should be compatible for Pi3, too, or any paltform compatible with ARMv7l architecture) on a Debian and/or Ubuntu box.

Steps required
* Install multiarch/qemu-static
```
 docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
```

* build the Docker image
```
docker buildx build --platform linux/arm/v7 -t "image name" .
```
After successful build one you can run NWChem on a input file input.nw file placed in [host_system_dir]

by typing the command
```
docker run --rm -dv [host_system_dir]:/data "image name" "input.nw"
```
This command will return [container ID] value to read logs by
```
docker logs [container ID]
```
or using the interactive command
```
docker run --rm -v [host_system_dir]:/data "image name" "input.nw"
```
# BUILD EXAMPLE 

This can be performed on non ARM Hardware
```
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

docker build -t my_nwchem .
```
# RUN EXAMPLE

This must be executed on Raspberry Pi2 (or ARMV7l and later) Hardware
```
wget https://raw.githubusercontent.com/nwchemgit/nwchem/master/src/nwchem.nw

docker run --rm -v /home/edo/nwchem/tests:/data my_nwchem nwchem.nw
```
