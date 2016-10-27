
 Based on earlier work by Vladimir Konjkov <Konjkov.VV@gmail.com>

 Create the image with the command
 docker build -t nwchem-dev .
 
After successful build one you can execute the QA tests using the command

docker run nwchem-dev dft_he2+ h2o_dk h2o_opt
