
# For macos

## Install python3.6+
- get homebrew

        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

- install python using homebrew

        export PATH="/usr/local/opt/python/libexec/bin:$PATH"
        brew install python3
## Install gcc 

        brew install gcc

## Install Yosys 

You can find the installation steps in [Yosys installation](https://github.com/YosysHQ/yosys).

## Optional to run validation
- Install Iverilog  

        brew install icarus-verilog

## Optional to run report power
- Install Pandas

        pip3 install pandas

- Install OpenSTA  

You can find the installation steps in [OpenSTA installation](https://github.com/The-OpenROAD-Project/OpenSTA).


<br/><br/>

# For Linux

## Install Conda for package installation

    bash Miniconda3-latest-Linux-x86_64.sh

## Use  Conda to install all dependencies

    conda install -y -c litex-hub -c conda-forge python yosys gxx 

## Optional to run validation
- Install Iverilog  

        conda install -y -c litex-hub -c conda-forge iverilog

## Optional to run report power
- Install Pandas

        pip3 install pandas

- Install OpenSTA  

        conda install -y -c litex-hub -c conda-forge openroad

    or

    You can find the installation steps in [OpenSTA installation](https://github.com/The-OpenROAD-Project/OpenSTA).

<br/><br/>


# For Windows-10

## Install python3.6+
Install using the executable installer [here](https://www.python.org/downloads/windows/)

## Install gcc 

Install using the executable installer [here](https://sourceforge.net/projects/mingw/files/Installer/mingw-get-setup.exe/download)

## Install Yosys 

You can find the installation steps in [Yosys installation](https://github.com/YosysHQ/yosys).

## Optional to run validation
- Install Iverilog  
    Install using the executable installer [here](https://bleyer.org/icarus/)

## Optional to run report power
- Install Pandas

        pip3 install pandas

- Install OpenSTA  

You can find the installation steps in [OpenSTA installation](https://github.com/The-OpenROAD-Project/OpenSTA).
