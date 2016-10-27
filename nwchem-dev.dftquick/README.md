
 Based on earlier work by Vladimir Konjkov <Konjkov.VV@gmail.com>

 Copy the Dockerfile to a local directory and create the image with the command
 docker build -t nwchem-dev .
 
After successful build one you can execute the QA tests using the command

docker run nwchem-dev dft_he2+ h2o_dk h2o_opt
