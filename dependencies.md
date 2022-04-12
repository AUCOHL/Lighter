# Installing yosys

You need a C++ compiler with C++11 support (up-to-date CLANG or GCC is recommended) and some standard tools such as GNU Flex, GNU Bison, and GNU Make. TCL, readline and libffi are optional (see ENABLE_* settings in Makefile). Xdot (graphviz) is used by the show command in yosys to display schematics.

For example on Ubuntu Linux 16.04 LTS the following commands will install all prerequisites for building yosys:

    $ sudo apt-get install build-essential clang bison flex \
        libreadline-dev gawk tcl-dev libffi-dev git \
        graphviz xdot pkg-config python3 libboost-system-dev \
        libboost-python-dev libboost-filesystem-dev zlib1g-dev


Similarily, on Mac OS X Homebrew can be used to install dependencies (from within cloned yosys repository):

    $ brew tap Homebrew/bundle && brew bundle



or MacPorts:

    $ sudo port install bison flex readline gawk libffi \
    git graphviz pkgconfig python36 boost zlib tcl


On FreeBSD use the following command to install all prerequisites:

# pkg install bison flex readline gawk libffi\
	git graphviz pkgconf python3 python36 tcl-wrapper boost-libs


On FreeBSD system use gmake instead of make. To run tests use: % MAKE=gmake CC=cc gmake test
For Cygwin use the following command to install all prerequisites, or select these additional packages:

    setup-x86_64.exe -q --packages=bison,flex,gcc-core,gcc-g++,git,libffi-devel,libreadline-devel,make,pkg-config,python3,tcl-devel,boost-build,zlib-devel



To configure the build system to use a specific compiler, use one of

    $ make config-clang
    $ make config-gcc



For other compilers and build configurations it might be necessary to make some changes to the config section of the Makefile.

    $ vi Makefile            # ..or..
    $ vi Makefile.conf


To build Yosys simply type 'make' in this directory.

    $ make
    $ sudo make install


Note that this also downloads, builds and installs ABC (using yosys-abc as executable name).

Tests are located in the tests subdirectory and can be executed using the test target. Note that you need gawk as well as a recent version of iverilog (i.e. build from git). Then, execute tests via:

    $ make test

To use a separate (out-of-tree) build directory, provide a path to the Makefile.

    $ mkdir build; cd build
    $ make -f ../Makefile
Out-of-tree builds require a clean source tree.


# Installing OpenSTA

OpenSTA is built with CMake.

Prerequisites

The build dependency versions are show below. Other versions may work, but these are the versions used for development.

         from   Ubuntu   Xcode
                18.04.1  11.3
cmake    3.10.2 3.10.2   3.16.2
clang    9.1.0           11.0.0
gcc      3.3.2   7.3.0   
tcl      8.4     8.6     8.6.6
swig     1.3.28  3.0.12  4.0.1
bison    1.35    3.0.4   3.5
flex     2.5.4   2.6.4   2.5.35

Note that flex versions before 2.6.4 contain 'register' declarations that are illegal in c++17.


These packages are optional:

libz     1.1.4   1.2.5     1.2.8
cudd             2.4.1     3.0.0

CUDD is a binary decision diageram (BDD) package that is used to improve conditional timing arc handling. OpenSTA does not require it to be installed. It is available here or here.

Note that the file hierarchy of the CUDD installation changed with version 3.0. Some changes to CMakeLists.txt are required to support older versions.

Use the USE_CUDD option to look for the cudd library. Use the CUDD_DIR option to set the install directory if it is not in one of the normal install directories.

When building CUDD you may use the --prefix option to configure to install in a location other than the default (/usr/local/lib).

    cd $HOME/cudd-3.0.0
    mkdir $HOME/cudd
    ./configure --prefix $HOME/cudd
    make
    make install

    cd <opensta>/build
    cmake .. -DUSE_CUDD -DCUDD_DIR=$HOME/cudd
The Zlib library is an optional. If CMake finds libz, OpenSTA can read Verilog, SDF, SPF, and SPEF files compressed with gzip.

Installing with CMake

Use the following commands to checkout the git repository and build the OpenSTA library and excutable.

    git clone https://github.com/The-OpenROAD-Project/OpenSTA.git
    cd OpenSTA
    mkdir build
    cd build
    cmake ..
    make
The default build type is release to compile optimized code. The resulting executable is in app/sta. The library without a main() procedure is app/libSTA.a.


Optional CMake variables passed as -D= arguments to CMake are show below.

    CMAKE_BUILD_TYPE DEBUG|RELEASE
    CMAKE_CXX_FLAGS - additional compiler flags
    TCL_LIBRARY - path to tcl library
    TCL_HEADER - path to tcl.h
    CUDD - path to cudd installation
    ZLIB_ROOT - path to zlib
    CMAKE_INSTALL_PREFIX

If TCL_LIBRARY is specified the CMake script will attempt to locate the header from the library path.


The default install directory is /usr/local. To install in a different directory with CMake use:

    cmake .. -DCMAKE_INSTALL_PREFIX=<prefix_path>       
If you make changes to CMakeLists.txt you may need to clean out existing CMake cached variable values by deleting all of the files in the build directory.


Dependancies references

    - https://github.com/YosysHQ/yosys
    - https://github.com/The-OpenROAD-Project/OpenSTA
