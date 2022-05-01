# Lighter

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![example workflow](https://github.com/kanndil/Lighter/actions/workflows/main.yml/badge.svg)
[![code style: black](https://img.shields.io/badge/code%20style-black-000000.svg)](https://github.com/psf/black)

An automatic clock gating utility. 



## Table of contents

* [Overview](https://github.com/kanndil/Lighter#overview)
* [File structure](https://github.com/kanndil/Lighter#file-structure)
* [How to use](https://github.com/kanndil/Lighter#dependencies)
* [Power reduction analysis](https://github.com/kanndil/Lighter#power-reduction-analysis)
* [Authors](https://github.com/kanndil/Lighter#authors)
* [Copyright and Licensing](https://github.com/kanndil/Lighter#copyright-and-licensing)


# Overview


Clock gating is a technique used to reduce the dynamic power by reducing the activation factor of the flip-flops in the design significantly, correspondingly reducing their switching frequency, by adding a clock gate cell at the input of each register.

The clock-gating problem is transformed into a graph problem with the help of Yosys RTLIL (register transfer level intermediate language), where the tool replaces all flipflops with enable inputs into clock-gated flipflops. 

<!--//include clkgate image-->

This is a technology generic automatic clock gating tool, that takes an RTL design and a technology specification Jason file, then auto creates and runs a Yosys synthesis script and a clock-gate map file. The tool produces, a clock-gated gate-level design along with power reduction reports. 



<!--// rephrase
This repo provides a script to be run by the Yosys software, and attached to it is a map file that is used to map all flipflops with enable inputs into clock-gated flipflops. An auto-testing python code is also implemented to autotest and analyze the dynamic power reduction of the provided design.-->


## File structure
* docs/ contains documentation
* code/ contains clock gating Yosys scripts and their dependencies
* power_report/ contains automatic testing and power reporting python code (auto_test.py) 
    * designs/ contains designs for testing
    * stats/ contains full benchmarking results
* tests/ contains simple test cases and graphical representation of the clock gating process
* validation/ contains automatic validation python code for clock gated designs

    
## Dependencies

    - Yosys     latest version
    - OpenSta   latest version

You can find their installation steps in dependencies.txt

[dependencies](https://github.com/youssefkandil/Dynamic_Power_Clock_Gating/blob/main/dependencies.txt)


# How to use

Generate the Yosys plugin using the following command:

    yosys-config --build plugin.so clock_gating_plugin.cc


Add the flipflop clock gating command to your synthesis script:


    read_verilog lib/blackbox_clk_gates.v
    clock_gating lib/map_file.v


For example:

    read_verilog design
    read_verilog lib/blackbox_clk_gates.v
    hierarchy -check
    synth -top design
    dfflibmap -liberty lib/sky130_hd.lib 
    abc -D 1250 -liberty lib/sky130_hd.lib 
    splitnets
    opt_clean -purge
    opt;; 
    write_verilog -noattr -noexpr -nohex -nodec -defparam   design.gl.v


Run your Yosys as follows:

    yosys -m plugin.so -p your_script.ys

Or TCL synthesis script:

    yosys -m plugin.so -p your_script.tcl

# Power reduction analysis
|Design  |# Clock Gates| Power reduction %|  Cells reduction %|
|--------|-----------|----------------------------|------------------------------|
|AHB_SRAM|7          |23.67%                      |25.71%                        |
|blabla  |24         |28.54%                      |4.30%                         |
|blake2s |63         |34.43%                      |11.75%                        |
|blake2s_core|46         |36.28%                      |13.07%                        |
|blake2s_m_select|16         |43.36%                      |22.47%                        |
|chacha  |52         |32.44%                      |5.23%                         |
|genericfir|638        |33.55%                      |6.22%                         |
|i2c_master|21         |15.48%                      |10.41%                        |
|jpeg_encoder|388        |31.38%                      |11.83%                        |
|ldpcenc |28         |45.23%                      |6.19%                         |
|NfiVe32_RF|32         |31.26%                      |30.58%                        |
|picorv32a|127        |25.52%                      |12.91%                        |
|PPU     |410        |22.91%                      |32.62%                        |
|prv32_cpu|10         |29.21%                      |23.97%                        |
|rf_64x64|64         |32.40%                      |27.35%                        |
|sha512  |74         |30.59%                      |12.82%                        |
|spi_master|8          |13.85%                      |18.99%                        |
|y_dct   |247        |30.98%                      |5.95%                         |
|y_huff  |450        |22.07%                      |21.59%                        |
|y_quantizer|256        |32.78%                      |30.90%                        |
|zigzag  |65         |33.46%                      |58.21%                        |




# Authors

* Dr. Mohamed Shalan
* Youssef Kandil


# ⚖️ Copyright and Licensing

Copyright 2022 AUC Open Source Hardware Lab

Licensed under the Apache License, Version 2.0 (the "License"); 
you may not use this file except in compliance with the License. 
You may obtain a copy of the License at:

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software 
distributed under the License is distributed on an "AS IS" BASIS, 
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
See the License for the specific language governing permissions and 
limitations under the License.