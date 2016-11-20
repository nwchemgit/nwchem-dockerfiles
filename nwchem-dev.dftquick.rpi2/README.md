Builds on non-ARM hardware a NWChem binary for Rapsberry Pi2 (should be compatible for Pi3, too) on a Debian and/or Ubuntu box.

Steps required
* Copy /usr/bin/qemu-arm-static to the current work directory

cp /usr/bin/qemu-arm-static .

* build the Docker image

docker build -t <image name> .

After successful build one you can run NWChem on a input file input.nw file placed in [host_system_dir]

by typing the command

docker run -dv [host_system_dir]:/data nwchem-dev "input.nw"

This command will return [container ID] value to read logs by

docker logs [container ID]

or using the interactive command

docker run -v [host_system_dir]:/data nwchem-dev.dftquick "input.nw"

EXAMPLE

docker build -t nwchem-dev .

docker run -v /home/edo/nwchem/tests:/data nwchem-dev.dftquick xvdw.nw

