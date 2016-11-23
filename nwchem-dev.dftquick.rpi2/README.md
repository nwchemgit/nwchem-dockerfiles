Builds on non-ARM hardware a NWChem binary for Rapsberry Pi2 (should be compatible for Pi3, too, or any paltform compatible with ARMv7l architecture) on a Debian and/or Ubuntu box.

Steps required
* Copy /usr/bin/qemu-arm-static to the current work directory

cp /usr/bin/qemu-arm-static .

* build the Docker image

docker build -t "image name" .

After successful build one you can run NWChem on a input file input.nw file placed in [host_system_dir]

by typing the command

docker run -dv [host_system_dir]:/data "image name" "input.nw"

This command will return [container ID] value to read logs by

docker logs [container ID]

or using the interactive command

docker run -v [host_system_dir]:/data "image name" "input.nw"

BUILD EXAMPLE 

This can be performed on non ARM Hardware

cp /usr/bin/qemu-arm-static .

docker build -t my_nwchem .

RUN EXAMPLE

This must be executed on Raspberry Pi2 (or ARMV7l and later) Hardware

wget https://svn.pnl.gov/svn/nwchem/trunk/src/nwchem.nw

docker run -v /home/edo/nwchem/tests:/data my_nwchem nwchem.nw

