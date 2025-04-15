# ❄️ Lighter ❄️

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![example workflow](https://github.com/kanndil/Lighter/actions/workflows/main.yml/badge.svg)
[![code style: black](https://img.shields.io/badge/code%20style-black-000000.svg)](https://github.com/psf/black)

An automatic clock gating utility. 


## Table of contents

* [Overview](#-overview)
* [File structure](#file-structure)
* [Dependencies](#-dependencies)
* [How to use](#-how-to-use)
* [How it works](#-how-it-works)
* [Power reduction analysis](#-power-reduction-analysis)
* [Authors](#authors)
* [Copyright and Licensing](#%EF%B8%8F-copyright-and-licensing)

<br>
<br>

# 📖 Overview

Electrical Power reduction in digital systems is significant for several reasons, including portability, reliability, and cost reduction. Because of this, power dissipation has become a critical parameter in low-power VLSI circuit designs. There are two sources for power dissipation in CMOS circuits: static power and dynamic power. Dynamic power is associated with the circuit switching activities due to the charging and discharging of internal node capacitances. On the other hand, static power is due to leakage current, or current that flows through the transistor when there is no activity. Dynamic power is the dominating component in mature fabrication processes such as sky130. It is still dominating in cutting-edge fabrication technologies. However, static power contribution to the total power is higher than mature technologies.

Several techniques can be utilized to reduce dynamic power through reducing the circuit switching activity. Clock gating is the most widely used technique here. It can be done manually or automatically. Automatic clock gating can be peformed for load-enabled registers. 

Typically, RTL synthesizer maps load-enabled registers to flip-flops and multiplexors (or to load-enabled flip-flops if the standard cell library has them). In both cases, the dynamic power is very high as the flip-flops are connected to the clock, which is the fastest signal in the design. Instead of circulating the register output back to its input when the load condition is false (typically using multiplexors), the register clock can be enabled only when the load condition is true. This reduces the switching activities, which leads to lower dynamic power and less area (due to the elimination of the multiplexors). The following figure illustrates the automatic clock gating for a single flip flop.

<img src="https://github.com/AUCOHL/Lighter/blob/main/docs/diagrams/clock_gating.png" width="500"/>

Lighter is a Yosys plugin and technology mapping files that can perform automatic clock gating for registers to reduce the dynamic power. Currently, Lighter supports the following open-source standard cell libraries:

1. sky130_fd_sc_hd
2. sky130_fd_sc_hs
3. sky130_fd_sc_hvl
4. sky130_fd_sc_ms
5. gf180mcu_fd_sc_mcu7t5v0
6. gf180mcu_fd_sc_mcu9t5v0

Through extensive experimentation, Lighter has demonstrated significant power and area savings. To explore the detailed results, kindly refer to the following link: [here](https://github.com/kanndil/Lighter#-power-reduction-analysis)
<br>
<br>

## File structure
* [designs](https://github.com/kanndil/Lighter/tree/main/designs) / conatains verilog designs for benchmarking
* [docs/](https://github.com/kanndil/Lighter/tree/main/docs) contains documentation
* [platform/](https://github.com/kanndil/Lighter/tree/main/platform/sky130) contains standard cell libraries 
* [report_power/](https://github.com/kanndil/Lighter/tree/main/report_power) contains power reporting python code (report_power.py) 
    * [stats/](https://github.com/kanndil/Lighter/tree/main/report_power/stats) contains full benchmarking results
* [src/](https://github.com/kanndil/Lighter/tree/main/src) contains clock gating Yosys plugin code
* [validation/](https://github.com/kanndil/Lighter/tree/main/validation) contains automatic validation python code for clock-gated designs
<br>
<br>
    
# 🧱 Dependencies

You can find the installation steps in [dependencies.md](https://github.com/kanndil/Lighter/blob/main/dependencies.md) for:
- [macos](https://github.com/kanndil/Lighter/blob/main/dependencies.md#For-macos)
- [Linux](https://github.com/kanndil/Lighter/blob/main/dependencies.md#For-Linux)
- [Windows-10](https://github.com/kanndil/Lighter/blob/main/dependencies.md#For-Windows-10)

<br>
<br>

# 🔍 How to use

## Option one

First make sure to follow the dependancies section to install all requirements. 

Generate the Yosys plugin using the following command:

    yosys-config --build cg_plugin.so clock_gating_plugin.cc

Add the clock gating technology maping file to your project directory. 
For example, if you are using the sky130_fd_sc_hd standard cell library add the following file. You can find other supported libraries [here](https://github.com/AUCOHL/Lighter/tree/main/platform). 

- [sky130_fd_sc_hd_ff_map.v](https://github.com/kanndil/Lighter/blob/main/platform/sky130_fd_sc_hd/sky130_fd_sc_hd_ff_map.v)

Add the flipflop clock gating command to your synthesis script:

    reg_clock_gating sky130_fd_sc_hd_ff_map.v


For example:

    read_verilog design
    read_liberty -lib -ignore_miss_dir -setattr blackbox sky130_fd_sc_hd.lib
    hierarchy -check
    reg_clock_gating -map sky130_fd_sc_hd_ff_map.v
    synth -top design
    dfflibmap -liberty sky130_fd_sc_hd.lib
    abc -D 1250 -liberty sky130_fd_sc_hd.lib
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

You can use the selection option to specify the flipflops you want to map in the clock gating step by doing the following:

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
    read_liberty -lib -ignore_miss_dir -setattr blackbox sky130_fd_sc_hd.lib
    hierarchy -check
    reg_clock_gating -map sky130_hd_ff_map.v a:clock_gate
    synth -top design
    dfflibmap -liberty sky130_fd_sc_hd.lib 
    abc -D 1250 -liberty sky130_fd_sc_hd.lib 
    splitnets
    opt_clean -purge
    opt;; 
    write_verilog -noattr -noexpr -nohex -nodec -defparam  design.gl.v

<br>
<br>

# 🧐 How it works 

A detailed guide can be found [here](https://github.com/kanndil/Lighter/blob/main/docs/how_it_works.md)
<br>
<br>

# 🔬 Power reduction analysis

|Design          |# Cells|# Added Clock Gates|Power reduction %|# Cells reduction %|
|----------------|-------|-------------------|-----------------|-------------------|
|AHB_SRAM        |245    |47                 |17.29%           |25.71%             |
|blabla          |10589  |1098               |28.80%           |3.72%              |
|blake2s         |14207  |1872               |33.70%           |11.05%             |
|blake2s_core    |12971  |1353               |36.05%           |12.53%             |
|blake2s_m_select|4518   |512                |43.00%           |22.29%             |
|chacha          |12857  |1936               |31.49%           |4.28%              |
|genericfir      |143575 |11624              |32.62%           |5.51%              |
|i2c_master      |758    |106                |13.29%           |13.19%             |
|jpeg_encoder    |62472  |4637               |30.23%           |11.78%             |
|ldpcenc         |20134  |1273               |18.04%           |6.14%              |
|NfiVe32_RF      |3362   |1024               |30.46%           |30.58%             |
|picorv32a       |14271  |1244               |25.42%           |12.48%             |
|PPU             |10248  |2845               |19.74%           |34.44%             |
|prv32_cpu       |2241   |207                |28.57%           |23.47%             |
|rf_64x64        |13475  |4096               |32.01%           |32.07%             |
|sha512          |20187  |3669               |30.53%           |12.85%             |
|spi_master      |175    |43                 |9.16%            |17.14%             |
|y_huff          |11004  |2345               |19.55%           |21.33%             |
|y_quantizer     |8281   |2816               |30.96%           |30.85%             |
|zigzag          |3807   |769                |31.95%           |58.21%             |


## Further Stats:

| Average Power Reduction % | Average cell Reduction % |
| ------------------------- | ------------------------ |
| 27.14%                    | 19.48%                   |

| Max Power Reduction % | Min Power Reduction % |
| --------------------- | --------------------- |
| 43.00%                | 9.16%                |

| Max cell Reduction % | Min cell Reduction % |
| -------------------- | -------------------- |
| 58.21%               | 3.72%                |


<img src="https://github.com/AUCOHL/Lighter/blob/main/docs/diagrams/power_reduction_summary.png" alt="power_summary" width="750"/>

<img src="https://github.com/AUCOHL/Lighter/blob/main/docs/diagrams/area_reduction_summary.png" alt="cells_summary" width="750"/>


## To access the complete benchmarking data, methodology, and all the necessary details, we have prepared a dedicated file called [benchmarks.md](https://github.com/kanndil/Lighter/blob/main/docs/benchmarks.md).
<br>
<br>

# Authors

* [Mohamed Shalan](https://github.com/shalan)
* [Youssef Kandil](https://github.com/kanndil)
<br>
<br>

### 📄 Paper

Youssef Kandil and Mohamed Shalan,  
*Lighter: An Open-Source Automatic Clock Gating Tool for Dynamic Power Reduction in ASIC*.  
Presented at the **Workshop on Open Source EDA Technologies (WOSET)**, 2024.  
🔗 [Read the paper on OpenReview](https://openreview.net/forum?id=tNriFilLTO)

---

### 📚 Citation

If you use **Lighter** in your work, please cite:

```bibtex
@misc{WOSET2024lighter,
  author       = {Youssef Kandil and Mohamed Shalan},
  title        = {Lighter: An Open-Source Automatic Clock Gating Tool for Dynamic Power Reduction in ASIC},
  howpublished = {Presented at the Workshop on Open Source EDA Technologies (WOSET)},
  year         = {2024},
  url          = {https://woset-workshop.github.io/PDFs/2024/15_Lighter_An_Open_Source_Auto.pdf},
  note         = {Available on OpenReview}
}
```

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
