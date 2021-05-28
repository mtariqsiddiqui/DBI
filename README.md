# DbI Application Artefact
The DbI application artefact is a web application developed in D language with vibe.d web application framework. The application requires MongoDB as a backend data-base. 
4.3.2.1	Setup Application
Install one of the D language compilers from the D language website. 
- https://dlang.org/download.html
The project is developed using DMD 2.096.0 as DMD is faster in compilation, but also tested with LDC 1.23.0, LDC can be used to create a release as LDC produces LLVM based more optimised binary.
Install MongoDB locally or use MongoDB Atlas cluster. The project is developed using local MongoDB due to some network environment restriction in the workplace.  
- https://docs.mongodb.com/manual/administration/install-community/ 
- https://cloud.mongodb.com/
Clone the Git repository https://github.com/mtariqsiddiqui/DBI.git
Type dub run from the repository main directory to run the project. The dub is the default build tool for the D language, and it is installed with the DMD compiler. Browse the website http://127.0.0.1:3000/ using any modern browser. The project is devel-oped using Google Chrome but also tested on Safari latest versions.
