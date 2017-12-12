Base on earlier work by Vladimir Konjkov

Builds a NWChem 6.8  binary using qm and pw modules and ARMCI_NETWORK=MPI-PR

The file Dockerfile can be used by tying the command

docker build -t  nwchem-68.fedora.mpipr .

The following command will run on 3 processors (will remove the hardwired value later ...)

docker run -v [host_dir]:/data docker run -v nwchem-68.fedora.mpipr [input.nw]

EXAMPLES

docker run -v /home/edo/park/nwchem-6.8/QA/tests/band:/data nwchem-68.fedora.mpipr band.nw

changes procs number

docker run --entrypoint='runtests.mpi.unix' nwchem-6.8.fedora.mpipr procs 3 h2o_opt

