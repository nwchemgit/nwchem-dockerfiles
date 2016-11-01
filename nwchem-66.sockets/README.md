Base on earlier work by Vladimir Konjkov

Builds a NWChem 6.6  binary using just the DFT modules and ARMCI_NETWORK=SOCKETS

The file Dockerfile can be used by tying the command

docker build -t nwchem .

The following command will run on 3 processors (will remove the hardwired value later ...)

docker run -v [host_dir]:/data nwchem [input.nw]
