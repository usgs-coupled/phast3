README.TXT

        PhreeqcRM--A reaction module for transport simulators 
               based on the geochemical model PHREEQC

This file describes how to compile the PhreeqcRM library and use
it in C++, C, and Fortran programs. The library may be compiled
after generating Makefiles either with configure or CMake. For 
Windows, Visual Studio solution files are provided for Visual
Studio 2005 through 2013. All source and compilation-related
files are available at the following web site:
http://wwwbrr.cr.usgs.gov/projects/GWC_coupled/phreeqc/index.html.


	  TABLE OF CONTENTS

	  A. Distribution file
	  B. Documentation
	  C. Download and unzip the distribution file
	  D. Linux Compiling, testing, and installing the PhreeqcRM library
	  E. Windows Compilation of PhreeqcRM library
	  F. Using the library
	        F.1. C++
		F.2. C
                F.3. Fortran
	  G. Tests
	  H. Contacts


A. Distribution file

	The following distribution package (containing the software, 
	compilation-related files, and an advection example in
        C++, C, and Fortran) is available for Linux and Windows:

        phreeqcrm-@VERSION@-@REVISION@.tar.gz      


B. Documentation

Parkhurst, D.L. and Wissmeier, Laurin, 2015, PhreeqcRM--A reaction module 
   for transport simulators based on the geochemical model PHREEQC: Advances in
   Water Resources, in press.
   
   *The following two user's guides are available in electronic format. Portable
   Document Format (PDF) files are included in the doc subdirectory of the
   PHREEQC program distribution.
   
Parkhurst, D.L., and Appelo, C.A.J., 2013, Description of input and examples
   for PHREEQC version 3--A computer program for speciation, batch-reaction,
   one- dimensional transport, and inverse geochemical calculations: U.S.
   Geological Survey Techniques and Methods, book 6, chap. A43, 497 p.
   http://pubs.usgs.gov/tm/06/a43/.

Parkhurst, D.L., and Appelo, C.A.J., 1999, User's guide to PHREEQC (Version
   2)-- A computer program for speciation, batch-reaction, one-dimensional
   transport, and inverse geochemical calculations: U.S. Geological Survey
   Water-Resources Investigations Report 99-4259, 312 p.
   http://pubs.er.usgs.gov/publication/wri994259.

   *The following two reports document the theory and implementation of
   isotopes in PHREEQC. Portable Document Format (PDF) of Thorstenson and
   Parkhurst (2002) is included in the doc subdirectory of the PHREEQC program
   distribution.

Thorstenson, D.C., and Parkhurst, D.L., 2002, Calculation of individual isotope
   equilibrium constants for implementation in geochemical models: U.S.
   Geological Survey Water-Resources Investigations Report 02-4172, 129 p.
   http://pubs.er.usgs.gov/publication/wri024172.

Thorstenson, D.C., and Parkhurst, D.L., 2004, Calculation of individual isotope
   equilibrium constants for geochemical reactions: Geochimica et Cosmochimica
   Acta, v. 68, no. 11, p. 2449-2465.
   
   *Brief description of the program PhreeqcI.

Charlton, S.R., and Parkhurst, D.L., 2002, PhreeqcI--A graphical user interface
   to the geochemical model PHREEQC: U.S. Geological Survey Fact Sheet
   FS-031-02, 2 p.


C. Download and unzip the distribution file

Follow the steps using gunzip, 7zip, or other compression program that can unzip a tar.gz file:

  Steps in extracting files                  Explanation
  ----------------------------------------   -----------------------------------
  gunzip phreeqcrm-@VERSION@-@REVISION@.tar.gz           Uncompress the tar.gz file.

  tar -xvpof phreeqcrm-@VERSION@-@REVISION@.tar          Extract files from the tar file.

The directory phreeqcrm-@VERSION@-@REVISION@ is created when the files are
extracted; if this directory already exists, you may want to delete or rename
it before extracting the files. The following directory structure is created 
(the contents of each directory are shown to the right):

   phreeqcrm-@VERSION@-@REVISION@ Files related to configure and some source code
     `--config      More configure files
     `--database    Database files for PHREEQC
     `--doc         Documentation files 
     `--IPhreeqcPhast More source code for PhreeqcRM
     `--VS2005      Visual Studio project for PhreeqcRM
     `--VS2008      Visual Studio project for PhreeqcRM
     `--VS2010      Visual Studio project for PhreeqcRM
     `--VS2012      Visual Studio project for PhreeqcRM
     `--VS2013      Visual Studio project for PhreeqcRM
     `--Tests       Advection example in C++, C, and Fortran
     `     --config      Linux configure
     `     --VS2005      Visual Studio project for test program
     `     --VS2008      Visual Studio project for test program
     `     --VS2010      Visual Studio project for test program
     `     --VS2012      Visual Studio project for test program
     `     --VS2013      Visual Studio project for test program

Notes:  (a) A compiled executable is not included in the distribution.
        (b) It is recommended that no user files be kept in the directory structure.  


D. Linux Compiling, testing, and installing the PhreeqcRM library

In general, to compile the software, you will need:

       (a) a C++ compiler, and
       (b) a minimal level of knowledge of configure or CMake, Make, the compiler, and
           the Linux operating system.

A Makefile can be generated by configure, and the Makefile can be used to
compile, test, and install the software.

To compile, test, and install PHREEQC with configure:

1.  Change directory to the directory that was extracted from the tar file.

        cd phreeqcrm-@VERSION@-@REVISION@
        
2.  Make a directory, for example, Release.
	
	mkdir Release
	
3.  Change directory to Release.
	
	cd Release

4.  Run configure
	
	../configure
	
    Many of the options for configure can be seen by typing:
    
    	../configure --help

5.  Compile the PhreeqcRM library
	
	make
	
6.  Check that compiled version runs the test cases. Check may take several
	minutes.
	
	make check
	
???    Results of running the test cases are stored in the directory
    	
???    	Release/test

7.  Install the PhreeqcRM library. By default the program is installed in /usr/local/bin
    and /usr/local/share/doc/phreeqcrm. You can specify an installation prefix
    other than "/usr/local" by using the prefix option, prefix=$HOME for
    example.
    
    	make install
    	
    The locations of various files are given (a) for default installation (make
    install), and (b) if prefix is defined to be $HOME (make install prefix=
    $HOME). $HOME is used to represent your home directory in the following
    pathnames.
    
    Executable:
      	(a) /usr/local/bin/phreeqcrm.lib
    	(b) $HOME/bin/phreeqcrm.lib
    	
    Documentation (PDFs, README, NOTICE, phreeqcrm.txt):
    	
    	(a) /usr/local/share/doc/phreeqcrm
    	(b) $HOME/share/doc/phreeqcrm
    
    Databases: 
    
    	(a) /usr/local/share/doc/phreeqcrm/database
    	(b) $HOME/share/doc/phreeqcrm/database
    

 E. Windows Compilation of PhreeqcRM library

In general, to compile the PhreeqcRM library, you will need:

       (a) a C++ compiler,
       (b) familiarity with the compiler and the Windows operating system.

Multiple Visual Studio projects (phreeqc.sln) are provided. Use the one that
is compatible with your version of Visual Studio. Visual Studio is freely
avaialble beginning with the 2013 version.

You can include the PhreeqcRM project in the Visual Studio solution for
your transport model.


F. Using the library

F.1. C++
     
     In C++, you will include the PhreeqcRM.h header file and 
     create a PhreeqcRM instance (multithreaded in these examples):

     #include "PhreeqcRM.h"
     PhreeqcRM  my_phreeqcrm(nxyz, nthreads);

     or

     PhreeqcRM * myphreeqc_ = new PhreeqcRM(nxyz, nthreads);

     You will need to link to the PhreeqcRM.lib that you compiled.

F.2. C

     In C, you will include the C interface header, RM_interface_C.h, and
     create a PhreeqcRM instance.

     #include "RM_interface.C.h"
     int rm_id;
     rm_id = RM_create(nxyz, nthreads);

     You will need to link to the PhreeqcRM.lib that you compiled.

F.3. Fortran

     In Fortran, you will need to include the source file RM_interface_F.F90
     as one of the project files. This file defines the PhreeqcRM Fortran module.
     In the source code, you will USE the PhreeqcRM module and
     create a PhreeqcRM instance.

     USE PhreeqcRM
     integer rm_id
     rm_id = RM_create(nxyz, nthreads)

     You will need to link to the PhreeqcRM.lib that you compiled.


G. Tests

An example advection calculation with geochemical reactions is provided in 
the directory Tests. Nearly all PhreeqcRM methods are used in the
C++, C, and Fortran Fortran files. 

Configure, CMake, or Visual Studio may be used to compile the test program.
Compilation-related files are provided in the Tests directory. Use thes files
in the same way as described for the PhreeqcRM library.

You will need to have a Fortran compiler and to set the preprocessor directive 
TEST_FORTRAN to compile and test the Fortran version of the test program.

The test programs may be compiled to be (1) multithreaded, preprocessor directive
USE_OPENMP, (2) multiprocessor, preprocessor directive USE_MPI, or (3) serial,
neither preprocessor directive.

H. CONTACTS

Inquiries about this software distribution should be directed to:

e-mail:  h2osoft@usgs.gov or dlpark@usgs.gov

