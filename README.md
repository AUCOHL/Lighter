# ❄️ Lighter ❄️

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![example workflow](https://github.com/kanndil/Lighter/actions/workflows/main.yml/badge.svg)
[![code style: black](https://img.shields.io/badge/code%20style-black-000000.svg)](https://github.com/psf/black)

An automatic clock gating utility. 


## Table of contents

* [Overview](https://github.com/kanndil/Lighter#-overview)
* [File structure](https://github.com/kanndil/Lighter#file-structure)
* [Dependencies](https://github.com/kanndil/Lighter#-dependencies)
* [How to use](https://github.com/kanndil/Lighter#-how-to-use)
* [How it works](https://github.com/kanndil/Lighter#-how-it-works)
* [Power reduction analysis](https://github.com/kanndil/Lighter#-power-reduction-analysis)
* [Authors](https://github.com/kanndil/Lighter#authors)
* [Copyright and Licensing](https://github.com/kanndil/Lighter#%EF%B8%8F-copyright-and-licensing)

# 📖 Overview

Electrical Power reduction in digital systems is significant for several reasons, including portability, reliability, and cost reduction. Because of this, power dissipation has become a critical parameter in low-power VLSI circuit designs. There are two sources for power dissipation in CMOS circuits: static power and dynamic power. Dynamic power is associated with the circuit switching activities due to the charging and discharging of internal node capacitances. On the other hand, static power is due to leakage current, or current that flows through the transistor when there is no activity. Dynamic power is the dominating component in mature fabrication processes such as sky130. It is still dominating in cutting-edge fabrication technologies. However, static power contribution to the total power is higher than mature technologies.

Several techniques can be utilized to reduce dynamic power through reducing the circuit switching activity. Clock gating is the most widely used technique here. It can be done manually or automatically. Automatic clock gating can be peformed for load-enabled registers. 

Typically, RTL synthesizer maps load-enabled registers to flip-flops and multiplexors (or to load-enabled flip-flops if the standard cell library has them). In both cases, the dynamic power is very high as the flip-flops are connected to the clock, which is the fastest signal in the design. Instead of circulating the register output back to its input when the load condition is false (typically using multiplexors), the register clock can be enabled only when the load condition is true. This reduces the switching activities, which leads to lower dynamic power and less area (due to the elimination of the multiplexors). The following figure illustrates the automatic clock gating for a single flip flop.

<img src="https://github.com/AUCOHL/Lighter/blob/main/docs/diagrams/clock_gating.png" width="500"/>

Lighter is a Yosys plugin and technology mapping files that can perform automatic clock gating for registers to reduce the dynamic power. Currently, Lighter supports Sky130 HD library. The support for other Sky130 libraries as well as other open-source PDKs will be added shortly. Experiments results showed significat power and area savings. Check the results [here](https://github.com/kanndil/Lighter#-power-reduction-analysis)

## File structure

* [designs](https://github.com/kanndil/Lighter/tree/main/designs) / conatains verilog designs for benchmarking
* [docs/](https://github.com/kanndil/Lighter/tree/main/docs) contains documentation
* [platform/](https://github.com/kanndil/Lighter/tree/main/platform/sky130) contains standard cell libraries 
* [report_power/](https://github.com/kanndil/Lighter/tree/main/report_power) contains power reporting python code (report_power.py) 
    * [stats/](https://github.com/kanndil/Lighter/tree/main/report_power/stats) contains full benchmarking results
* [src/](https://github.com/kanndil/Lighter/tree/main/src) contains clock gating Yosys plugin code
* [validation/](https://github.com/kanndil/Lighter/tree/main/validation) contains automatic validation python code for clock-gated designs

    
# 🧱 Dependencies

You can find the installation steps in [dependencies.md](https://github.com/kanndil/Lighter/blob/main/dependencies.md) for:
- [macos](https://github.com/kanndil/Lighter/blob/main/dependencies.md#For-macos)
- [Linux](https://github.com/kanndil/Lighter/blob/main/dependencies.md#For-Linux)
- [Windows-10](https://github.com/kanndil/Lighter/blob/main/dependencies.md#For-Windows-10)


# 🔍 How to use

## Option one

First make sure to follow the dependancies section to install all requirements. 

Generate the Yosys plugin using the following command:

    yosys-config --build cg_plugin.so clock_gating_plugin.cc

Add the following files to your project directory:

- [sky130_clkg_blackbox.v](https://github.com/kanndil/Lighter/blob/main/src/sky130_clkg_blackbox.v)

- [sky130_ff_map.v](https://github.com/kanndil/Lighter/blob/main/src/sky130_ff_map.v)

Add the flipflop clock gating command to your synthesis script:

    read_verilog sky130_clkg_blackbox.v
    reg_clock_gating sky130_ff_map.v

 
* Check the [platform](https://github.com/AUCOHL/Lighter/tree/main/platform) directory to find the files for your standard cell library
    * Sky130 libraries are supported

For example:

    read_verilog design
    read_verilog sky130_clkg_blackbox.v
    hierarchy -check
    reg_clock_gating -map sky130_ff_map.v
    synth -top design
    dfflibmap -liberty lib/sky130_hd.lib 
    abc -D 1250 -liberty lib/sky130_hd.lib 
    splitnets
    opt_clean -purge
    opt;; 
    write_verilog -noattr -noexpr -nohex -nodec -defparam   design.gl.v


Run your Yosys synthesis script as follows:

    yosys -m cg_plugin.so your_script.ys

Or TCL synthesis script as follows:

    yosys -m cg_plugin.so your_script.tcl


## Option two 


Follow the same steps above for generating the Yosys plugin and adding the library files. 

you can use the selection option to specify the flipflops you want to map in the clock gating step by doing the following:

* You need to add an attribute (pragma) to the module intended (inside the module declaration), for example:

        module test (...);
        (* clock_gate *)
        ...
        ...
        endmodule


* Then add the attribute to the clock gating command as a selection like:

        reg_clock_gating -map sky130_hd_ff_map.v a:clock_gate



For example:

    read_verilog design
    read_verilog sky130_clkg_blackbox.v
    hierarchy -check
    reg_clock_gating -map sky130_hd_ff_map.v a:clock_gate
    synth -top design
    dfflibmap -liberty lib/sky130_hd.lib 
    abc -D 1250 -liberty lib/sky130_hd.lib 
    splitnets
    opt_clean -purge
    opt;; 
    write_verilog -noattr -noexpr -nohex -nodec -defparam  design.gl.v

    
# 🧐 How it works 

A detailed guide can be found [here](https://github.com/kanndil/Lighter/blob/main/docs/how_does_it_work.md)


# 🔬 Power reduction analysis
|Design          |# Cells|# Added Clock Gates|Power reduction %|# Cells reduction %|
|----------------|-------|-------------------|-----------------|-------------------|
|AHB_SRAM        |245    |47                 |17.29%           |25.71%             |
|blake2s         |14225  |512                |5.65%            |-0.20%             |
|chacha          |12857  |832                |13.49%           |-0.19%             |
|genericfir      |143703 |1536               |7.57%            |-0.98%             |
|i2c_master      |759    |106                |12.97%           |10.41%             |
|jpeg_encoder    |63757  |4637               |30.26%           |11.83%             |
|ldpcenc         |19947  |1273               |17.65%           |6.19%              |
|NfiVe32_RF      |3362   |1024               |30.46%           |30.58%             |
|picorv32a       |14348  |1011               |22.31%           |12.02%             |
|PPU             |10156  |2824               |19.62%           |32.55%             |
|prv32_cpu       |2186   |207                |28.63%           |23.97%             |
|rf_64x64        |13461  |4096               |32.02%           |31.97%             |
|sha512          |20240  |3669               |30.22%           |12.82%             |
|spi_master      |179    |43                 |8.45%            |18.99%             |
|y_quantizer     |8281   |176                |1.06%            |1.92%              |
|zigzag          |3807   |769                |31.95%           |58.21%             |


<img src="https://github.com/AUCOHL/Lighter/blob/main/docs/diagrams/power_reduction_summary.png" alt="power_summary" width="750"/>

<img src="https://github.com/AUCOHL/Lighter/blob/main/docs/diagrams/area_reduction_summary.png" alt="cells_summary" width="750"/>


Full benchmarking data can be found [here](https://github.com/kanndil/Lighter/blob/main/docs/benchmarks.md)

# Authors

* [Mohamed Shalan](https://github.com/shalan)
* [Youssef Kandil](https://github.com/kanndil)


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
