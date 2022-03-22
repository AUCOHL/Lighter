# Project Name

# Table of contents
* Overview
* File structure
* Benchmarks
* Dependancies
* Authors

# Overview
This project provides an automatic clock gating utility that is generic for all SKY_130 RTL designs. The automatic clock gating tool provided takes a RTL HDL design (typically Verilog) and applies synthesis and clock gating using over-the-shelf commands provided by Yosys, and outputs a clock-gated gatelevel netlist. Clock gating is a technique used to reduce the dynamic power by reducing the activation factor of the flipflops in the design significantly, correspondingly reducing their swithing frequency, by adding a clock gate cell at the input of each register.

![image](https://user-images.githubusercontent.com/63082375/159457330-bbe795a6-c30b-4bd7-9a41-eacfc6692682.jpeg)

.The clock-gating problem is transformed into a graph problem with the help of Yosys RTLIL (register transfer level intermediate language), where the tool replaces all flipflops with enable inputs into clock-gated flipflops. The tool produces a  

This repo provides a script to by run by the Yosys software, and attached to it is a mapfile that is used to map all flipflops with enable inputs into clock-gated flipflops. An auto testing python code is also implemented to auto test and analyze the dynamic power reduction of the provided design.


# File structure
* docs/ contains documentation
* code/ contains clock gating Yosys scripts and their dependancies
* power_report/ contains automatic testing and power reporting python code (auto_test.py) 
* power_report/designs/ contains designs for testing
* power_report/stats/ contains full benchmarking results
* tests/ contains simple test cases and graphical representation of the clock gating process
* validation/ contains automatic validation python code for clock gated designs

# Documentation slides
https://www.canva.com/design/DAE4K_5a9jc/peu76OEkvt6rcjPXY_-9Kg/view?utm_content=DAE4K_5a9jc&utm_campaign=designshare&utm_medium=link&utm_source=publishpresent
    
# Dependancies

    - TCL       latest version
    - Yosys     latest version
    - OpenSta   latest version

You can find their installation steps in requirements.txt

Dependancies references
    - https://github.com/YosysHQ/yosys
    - https://github.com/The-OpenROAD-Project/OpenSTA



# Benchmarks

To evaluate the performance of this tool, the OpenSta API was used to calculate the dynamic power of the input design before and after clock gating, and produce a power reduction summary. 

| module               | Internal before | Switching before | Leakage before | Total before | Internal after | Switching after | Leakage after | Total after | total power difference | percentage reduction |
|----------------------|-----------------|------------------|----------------|--------------|----------------|-----------------|---------------|-------------|------------------------|----------------------|
| blabla               | 1.87E-03        | 4.74E-04         | 4.49E-08       | 2.34E-03     | 1.38E-03       | 3.20E-04        | 4.59E-08      | 1.71E-03    | 6.35E-04               | 27.11%               |
| chacha               | 5.40E-03        | 1.49E-03         | 4.35E-08       | 6.90E-03     | 3.82E-03       | 8.29E-04        | 4.21E-08      | 4.66E-03    | 2.24E-03               | 32.43%               |
| ldpc_decoder_802_3an | 2.14E-03        | 1.98E-03         | 1.23E-07       | 4.12E-03     | 3.57E-03       | 7.20E-04        | 1.33E-07      | 4.30E-03    | -1.71E-04              | -4.13%               |
| ldpcenc              | 9.14E-03        | 9.96E-03         | 7.46E-08       | 1.88E-02     | 7.45E-03       | 2.14E-03        | 6.91E-08      | 9.60E-03    | 9.25E-03               | 49.05%               |
| PPU                  | 5.39E-02        | 9.27E-03         | 4.38E-08       | 6.33E-02     | 4.22E-02       | 5.96E-03        | 3.58E-08      | 4.84E-02    | 1.49E-02               | 23.57%               |
| y_huff               | 1.14E-02        | 2.21E-03         | 3.76E-08       | 1.36E-02     | 9.33E-03       | 1.24E-03        | 3.64E-08      | 1.06E-02    | 3.05E-03               | 22.38%               |
| y_quantizer          | 1.92E-01        | 3.54E-02         | 4.53E-08       | 2.27E-01     | 1.35E-01       | 1.79E-02        | 3.12E-08      | 1.53E-01    | 7.46E-02               | 32.82%               |
| y_dct                | 2.22E-02        | 1.15E-02         | 2.70E-07       | 3.38E-02     | 1.63E-02       | 6.15E-03        | 2.68E-07      | 2.25E-02    | 1.13E-02               | 33.33%               |
| jpeg_encoder         | 2.32E-02        | 1.21E-02         | 2.10E-07       | 3.45E-02     | 1.85E-02       | 5.26E-03        | 2.02E-07      | 2.37E-02    | 1.08E-02               | 31.26%               |
| sha512               | 5.95E-03        | 1.76E-03         | 7.47E-08       | 7.68E-03     | 4.44E-03       | 8.83E-04        | 6.48E-08      | 5.32E-03    | 2.36E-03               | 30.74%               |
| picorv32a            | 4.63E-03        | 1.80E-03         | 4.24E-08       | 6.43E-03     | 3.44E-03       | 7.56E-04        | 3.94E-08      | 4.21E-03    | 2.22E-03               | 34.49%               |
| riscv_top_151        | 1.17E-03        | 5.96E-04         | 3.00E-08       | 1.77E-03     | 9.00E-04       | 2.02E-04        | 2.86E-08      | 1.10E-03    | 6.75E-04               | 38.03%               |
| genericfir           | 5.70E-02        | 2.73E-02         | 4.51E-07       | 8.43E-02     | 4.32E-02       | 1.29E-02        | 4.44E-07      | 5.61E-02    | 2.81E-02               | 33.39%               |
| NfiVe32_RF           | 6.85E-03        | 9.89E-04         | 1.76E-08       | 7.84E-03     | 4.71E-03       | 6.78E-04        | 1.40E-08      | 5.39E-03    | 2.45E-03               | 31.26%               |
| rf_64x64             | 2.74E-02        | 4.01E-03         | 7.00E-08       | 3.14E-02     | 1.85E-02       | 2.76E-03        | 5.31E-08      | 2.12E-02    | 1.02E-02               | 32.39%               |
|                      |                 |                  |                |              |                |                 |               |             |                        | avg percentage       |
|                      |                 |                  |                |              |                |                 |               |             |                        | 29.88%               |


# Authors:
    - Dr. Mohamed Shalan
    - Youssef Kandil



