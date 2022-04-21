# Lighter

## Table of contents

* [Overview](https://github.com/kanndil/Lighter#overview)
* [File structure](https://github.com/kanndil/Lighter#file-structure)
* [Procedure](https://github.com/kanndil/Lighter#dependencies)
* [Dynamic Power Analysis](https://github.com/kanndil/Lighter#dynamic-power-analysis)
* [Power reduction analysis](https://github.com/kanndil/Lighter#power-reduction-analysis)
* [Validation](https://github.com/kanndil/Lighter#validation)
* [How does it work](https://github.com/kanndil/Lighter#how-does-it-work)
* [Authors](https://github.com/kanndil/Lighter#authors)
* [Copyright and Licensing](https://github.com/kanndil/Lighter#copyright-and-licensing)


# Overview


Clock gating is a technique used to reduce the dynamic power by reducing the activation factor of the flip-flops in the design significantly, correspondingly reducing their switching frequency, by adding a clock gate cell at the input of each register.

The clock-gating problem is transformed into a graph problem with the help of Yosys RTLIL (register transfer level intermediate language), where the tool replaces all flipflops with enable inputs into clock-gated flipflops. 

<!--//include clkgate image-->

This is a technology generic automatic clock gating tool, that takes an RTL design and a technology specification Jason file, then auto creates and runs a Yosys synthesis script and a clock-gate map file. The tool produces, a clock-gated gate-level design along with power reduction reports. 



<!--// rephrase
This repo provides a script to be run by the Yosys software, and attached to it is a map file that is used to map all flipflops with enable inputs into clock-gated flipflops. An auto-testing python code is also implemented to autotest and analyze the dynamic power reduction of the provided design.-->


[Slides](https://www.canva.com/design/DAE4K_5a9jc/peu76OEkvt6rcjPXY_-9Kg/view?utm_content=DAE4K_5a9jc&utm_campaign=designshare&utm_medium=link&utm_source=publishpresent)

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


# Dynamic Power Analysis

To evaluate the performance of this tool, the OpenSta API was used to calculate the dynamic power of the input design before and after clock gating, and produce a power reduction summary. Since that OpenSta calculates the activity factors by propagation over the cells, and does not assign a 100% activity factor for flipflops nor recognizes clock gates activity factor contribution, we applied the following formula to get reasonable and accurate power reports:

- Total power before clk_gating = (power of all cells at alpha(0.1)) - (flipflops power at alpha(0.1)) + (flipflops power at alpha(1.0))

- Total power after clk_gating =  (power of all cells at alpha(0.1)) - (flipflops power at alpha(0.1)) + (flipflops power at alpha(0.05))

Where alpha is the activity factor.


## Power reduction analysis
|Design          |Clock Gates|Flipflops|Clock-gated Flipflops|Total power before (W)|Total power after (W)|Total power difference (W)|Percentage power reduction %|
|----------------|-----------|---------|---------------------|----------------------|---------------------|--------------------------|----------------------------|
|AHB_SRAM        |7.00E+00   |4.90E+01 |4.70E+01             |3.90E-04              |2.97E-04             |9.22E-05                  |23.67%                      |
|blabla          |0.00E+00   |1.10E+03 |0.00E+00             |1.57E-03              |1.57E-03             |0.00E+00                  |0.00%                       |
|blake2s         |1.60E+01   |1.88E+03 |5.12E+02             |8.94E-03              |8.04E-03             |9.01E-04                  |10.07%                      |
|blake2s_core    |0.00E+00   |1.35E+03 |0.00E+00             |7.06E-03              |7.06E-03             |0.00E+00                  |0.00%                       |
|blake2s_m_select|0.00E+00   |5.12E+02 |0.00E+00             |2.64E-03              |2.64E-03             |0.00E+00                  |0.00%                       |
|chacha          |2.60E+01   |1.94E+03 |8.32E+02             |6.92E-03              |5.90E-03             |1.01E-03                  |14.66%                      |
|genericfir      |1.28E+02   |1.16E+04 |1.54E+03             |8.43E-02              |8.08E-02             |3.51E-03                  |4.17%                       |
|i2c_master      |2.10E+01   |1.45E+02 |1.06E+02             |5.79E-04              |4.89E-04             |8.96E-05                  |15.48%                      |
|jpeg_encoder    |3.88E+02   |4.64E+03 |4.64E+03             |3.41E-02              |2.34E-02             |1.07E-02                  |31.38%                      |
|ldpcenc         |2.80E+01   |1.37E+03 |1.27E+03             |1.90E-02              |1.04E-02             |8.58E-03                  |45.23%                      |
|NfiVe32_RF      |3.20E+01   |1.02E+03 |1.02E+03             |7.84E-03              |5.39E-03             |2.45E-03                  |31.26%                      |
|picorv32a       |8.50E+01   |1.62E+03 |1.01E+03             |6.45E-03              |5.04E-03             |1.41E-03                  |21.82%                      |
|PPU             |4.05E+02   |2.85E+03 |2.82E+03             |6.26E-02              |4.83E-02             |1.43E-02                  |22.84%                      |
|prv32_cpu       |1.00E+01   |2.11E+02 |2.07E+02             |1.03E-03              |7.28E-04             |3.00E-04                  |29.21%                      |
|rf_64x64        |6.40E+01   |4.10E+03 |4.10E+03             |3.14E-02              |2.12E-02             |1.02E-02                  |32.39%                      |
|sha512          |7.40E+01   |3.67E+03 |3.67E+03             |7.70E-03              |5.35E-03             |2.36E-03                  |30.59%                      |
|spi_master      |8.00E+00   |5.30E+01 |4.30E+01             |1.92E-04              |1.65E-04             |2.66E-05                  |13.85%                      |
|y_dct           |0.00E+00   |5.34E+03 |0.00E+00             |3.38E-02              |3.38E-02             |0.00E+00                  |0.00%                       |
|y_huff          |0.00E+00   |2.35E+03 |0.00E+00             |1.36E-02              |1.36E-02             |0.00E+00                  |0.00%                       |
|y_quantizer     |1.60E+01   |2.82E+03 |1.76E+02             |2.27E-01              |2.23E-01             |4.12E-03                  |1.81%                       |
|zigzag          |6.50E+01   |7.69E+02 |7.69E+02             |8.14E-02              |5.42E-02             |2.73E-02                  |33.46%                      |





# Validation

<!--The clock gated gate-level netlists produced by the tool pass the functional validation, such that the functionalities of the designs are not affected by the gate-level modifications applied by the tool. 
-->



# How does it work

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






# Authors

* Dr. Mohamed Shalan
* Youssef Kandil


# Copyright and Licensing