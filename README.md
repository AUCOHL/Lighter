# Project Name

# Table of contents
* Overview
* File structure
* Benchmarks
* Dependencies
* Authors
# Overview
This project provides an automatic clock gating utility that is generic for all SKY_130 RTL designs. The automatic clock gating tool provided takes an RTL HDL design (typically Verilog) and applies synthesis and clock gating using over-the-shelf commands provided by Yosys, and outputs a clock-gated gate-level netlist. Clock gating is a technique used to reduce the dynamic power by reducing the activation factor of the flip-flops in the design significantly, correspondingly reducing their switching frequency, by adding a clock gate cell at the input of each register.

![image](https://user-images.githubusercontent.com/63082375/159457330-bbe795a6-c30b-4bd7-9a41-eacfc6692682.jpeg)

.The clock-gating problem is transformed into a graph problem with the help of Yosys RTLIL (register transfer level intermediate language), where the tool replaces all flipflops with enable inputs into clock-gated flipflops. The tool produces a 

This repo provides a script to be run by the Yosys software, and attached to it is a map file that is used to map all flipflops with enable inputs into clock-gated flipflops. An auto-testing python code is also implemented to autotest and analyze the dynamic power reduction of the provided design.

# File structure
* docs/ contains documentation
* code/ contains clock gating Yosys scripts and their dependencies
* power_report/ contains automatic testing and power reporting python code (auto_test.py) 
    * designs/ contains designs for testing
    * stats/ contains full benchmarking results
* tests/ contains simple test cases and graphical representation of the clock gating process
* validation/ contains automatic validation python code for clock gated designs

# Documentation slides
https://www.canva.com/design/DAE4K_5a9jc/peu76OEkvt6rcjPXY_-9Kg/view?utm_content=DAE4K_5a9jc&utm_campaign=designshare&utm_medium=link&utm_source=publishpresent
    
# Dependencies

    - TCL       latest version
    - Yosys     latest version
    - OpenSta   latest version

You can find their installation steps in requirements.txt

Dependancies references
    - https://github.com/YosysHQ/yosys
    - https://github.com/The-OpenROAD-Project/OpenSTA



# Benchmarks

To evaluate the performance of this tool, the OpenSta API was used to calculate the dynamic power of the input design before and after clock gating, and produce a power reduction summary. 

| module                  | clock gates | Total before | Total after | total power difference | percentage reduction |
| ----------------------- | ----------- | ------------ | ----------- | ---------------------- | -------------------- |
| blabla                  | 24          | 2.34E-03     | 1.71E-03    | 6.35E-04               | 27.11%               |
| chacha                  | 52          | 6.90E-03     | 4.66E-03    | 2.24E-03               | 32.43%               |
| ldpc\_decoder\_802\_3an | 2048        | 4.12E-03     | 4.30E-03    | \-1.71E-04             | \-4.13%              |
| ldpcenc                 | 28          | 1.88E-02     | 9.60E-03    | 9.25E-03               | 49.05%               |
| PPU                     | 375         | 6.33E-02     | 4.84E-02    | 1.49E-02               | 23.57%               |
| y\_huff                 | 450         | 1.36E-02     | 1.06E-02    | 3.05E-03               | 22.38%               |
| y\_quantizer            | 256         | 2.27E-01     | 1.53E-01    | 7.46E-02               | 32.82%               |
| y\_dct                  | 247         | 3.38E-02     | 2.25E-02    | 1.13E-02               | 33.33%               |
| jpeg\_encoder           | 258         | 3.45E-02     | 2.37E-02    | 1.08E-02               | 31.26%               |
| sha512                  | 74          | 7.68E-03     | 5.32E-03    | 2.36E-03               | 30.74%               |
| picorv32a               | 122         | 6.43E-03     | 4.21E-03    | 2.22E-03               | 34.49%               |
| riscv\_top\_151         | 53          | 1.77E-03     | 1.10E-03    | 6.75E-04               | 38.03%               |
| genericfir              | 5           | 8.43E-02     | 5.61E-02    | 2.81E-02               | 33.39%               |
| NfiVe32\_RF             | 32          | 7.84E-03     | 5.39E-03    | 2.45E-03               | 31.26%               |
| rf\_64x64               | 64          | 3.14E-02     | 2.12E-02    | 1.02E-02               | 32.39%               |
|                         |             |              |             |                        | avg percentage       |
|                         |             |              |             |                        | 29.88%               |

# Authors:
* Dr. Mohamed Shalan
* Youssef Kandil



