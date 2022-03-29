# name

## Table of contents
* Overview
* File structure
* Procedure
* Dependencies
* Dynamic Power Analysis
* Benchmarks
* Validation
* Authors
* Copyright and Licensing

# Overview
This project provides an automatic clock gating utility that is generic for all SKY_130 RTL designs. The automatic clock gating tool provided takes an RTL HDL design (typically Verilog) and applies synthesis and clock gating using over-the-shelf commands provided by Yosys, and outputs a clock-gated gate-level netlist. Clock gating is a technique used to reduce the dynamic power by reducing the activation factor of the flip-flops in the design significantly, correspondingly reducing their switching frequency, by adding a clock gate cell at the input of each register.

//include clkgate image

<!--![image](https://user-images.githubusercontent.com/63082375/159457330-bbe795a6-c30b-4bd7-9a41-eacfc6692682.jpeg)-->

.The clock-gating problem is transformed into a graph problem with the help of Yosys RTLIL (register transfer level intermediate language), where the tool replaces all flipflops with enable inputs into clock-gated flipflops. The tool produces a 

This repo provides a script to be run by the Yosys software, and attached to it is a map file that is used to map all flipflops with enable inputs into clock-gated flipflops. An auto-testing python code is also implemented to autotest and analyze the dynamic power reduction of the provided design.

## File structure
* docs/ contains documentation
* code/ contains clock gating Yosys scripts and their dependencies
* power_report/ contains automatic testing and power reporting python code (auto_test.py) 
    * designs/ contains designs for testing
    * stats/ contains full benchmarking results
* tests/ contains simple test cases and graphical representation of the clock gating process
* validation/ contains automatic validation python code for clock gated designs

## Documentation slides
//clickable link 

https://www.canva.com/design/DAE4K_5a9jc/peu76OEkvt6rcjPXY_-9Kg/view?utm_content=DAE4K_5a9jc&utm_campaign=designshare&utm_medium=link&utm_source=publishpresent
    
## Dependencies

    - TCL       latest version
    - Yosys     latest version
    - OpenSta   latest version

You can find their installation steps in requirements.txt
// clickable link

// another readme file for installation

<!--
Dependancies references

    - https://github.com/YosysHQ/yosys
    - https://github.com/The-OpenROAD-Project/OpenSTA-->


# Procedure

Here is an example guided illustration of the clock-gating process done by the tool.

Consider a normal n-bit enable register.

First, the design is read and converted to RTLIL (register transfer level intermediate language) graphical representation inside Yosys frontend synthesizer.

<img width="587" alt="Screen Shot 2022-03-22 at 1 09 19 PM" src="https://user-images.githubusercontent.com/63082375/159468706-791b13c4-5131-476a-bdcc-2dbe5c1cd360.png">

Then the design is optimized to combine multiplexors and flip-flops into one cell (enabled flip-flop)

<img width="442" alt="Screen Shot 2022-03-22 at 1 10 01 PM" src="https://user-images.githubusercontent.com/63082375/159468757-62eb12e1-c5aa-4adc-b81d-9ea0832f301e.png">


Note; For a register file or a memory component, the design needs to be further optimized to break down the memory components in RTLIL into basic cells for the mapping to take place later.

<img width="664" alt="Screen Shot 2022-03-22 at 1 10 53 PM" src="https://user-images.githubusercontent.com/63082375/159468905-aae4202c-df4e-4a22-929b-8ea5399b3eaf.png">

optimized memory cell

<img width="1216" alt="Screen Shot 2022-03-22 at 1 11 47 PM" src="https://user-images.githubusercontent.com/63082375/159469039-e2ac0bab-5317-4d1b-9189-ad26caf094f4.png">

Now, using the technology mapping command provided by Yosys, the enabled flip-flop cells are replaced with clock-gated flip-flop cells, which are provided in the map file. 

<img width="692" alt="Screen Shot 2022-03-22 at 1 12 16 PM" src="https://user-images.githubusercontent.com/63082375/159469114-804c4746-bcd1-433f-b174-17cdb1005c03.png">


# Dynamic Power Analysis

To evaluate the performance of this tool, the OpenSta API was used to calculate the dynamic power of the input design before and after clock gating, and produce a power reduction summary. Since that OpenSta calculates the activity factors by propagation over the cells, and does not assign a 100% activity factor for flipflops nor recognizes clock gates activity factor contribution, we applied the following formula to get reasonable and accurate power reports:

- Total power before clk_gating = (power of all cells at alpha(0.1)) - (flipflops power at alpha(0.1)) + (flipflops power at alpha(1.0))

- Total power after clk_gating =  (power of all cells at alpha(0.1)) - (flipflops power at alpha(0.1)) + (flipflops power at alpha(0.05))

Where alpha is the activity factor.

## Benchmarks

| Module                  | Clock Gates | Total before | Total after | Total power difference | Percentage reduction |
| ----------------------- | ----------- | ------------ | ----------- | ---------------------- | -------------------- |
| blabla                  | 24          | 2.34E-03     | 1.71E-03    | 6.35E-04               | 27.11%               |
| chacha                  | 52          | 6.90E-03     | 4.66E-03    | 2.24E-03               | 32.43%               |
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
|                         |             |              |             |                        | Avg percentage       |
|                         |             |              |             |                        | 29.88%               |




# Validation

The clock gated gate-level netlists produced by the tool pass the functional validation, such that the functionalities of the designs are not affected by the gate-level modifications applied by the tool. 




# Authors

* Dr. Mohamed Shalan
* Youssef Kandil


# Copyright and Licensing