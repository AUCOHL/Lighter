# How It Works

Lighter is an open-source automatic clock gating tool designed to optimize power consumption in digital circuits. By selectively replacing load-enabled registers by clock-gated registers, Lighter reduces dynamic power dissipation without compromising circuit functionality. This document provides a comprehensive overview of how Lighter works and its flip-flop clock-gating process.

## Flip-Flop Clock-Gating Process

To illustrate the flip-flop clock-gating process performed by Lighter, let's consider a normal n-bit load-enabled register. Lighter employs a Yosys script that performs synthesis and flip-flop clock-gating to achieve power optimization.

## Sample Synthesis Script
Here is a sample synthesis sctipt that utilizes Lighter plugin for Yosys:

    read_verilog design
    read_liberty -lib -ignore_miss_dir -setattr blackbox sky130_fd_sc_hd.lib
    hierarchy -check
    reg_clock_gating sky130_fd_sc_hd_ff_map.v
    synth -top design
    dfflibmap -liberty sky130_fd_sc_hd.lib 
    abc -D 1250 -liberty sky130_fd_sc_hd.lib 
    splitnets
    opt_clean -purge
    opt;; 
    write_verilog -noattr -noexpr -nohex -nodec -defparam design.gl.v


The "reg_clock_gating" plugin command is a collection of Yosys APIs which collectivly perform technology mapping of the load-enabled registers to clock-gated ones. The plugin includes the following steps:

1. 'proc': Converts the design to RTLIL (Register Transfer Level Intermediate Language) graphical representation inside the Yosys frontend synthesizer.
2. 'opt': Optimizes the design by combining multiplexers and flip-flops into one cell, known as a load-enabled flip-flop.
3. 'memory_collect': Further optimizes the design for register files or memory components by breaking down the memory components in RTLIL into basic cells for later mapping.
4. 'memory_map': Maps the optimized memory cells.
5. 'techmap': Uses the technology mapping command provided by Yosys to replace the enabled flip-flop cells with clock-gated flip-flop cells, which are provided in the map file.
<br>

# Explaination using Diagrams

## First, the design is read and converted to RTLIL 

(Register transfer level intermediate language) Graphical representation inside Yosys frontend synthesizer.

    read_verilog design
    read_liberty -lib -ignore_miss_dir -setattr blackbox sky130_fd_sc_hd.lib
    hierarchy -check
    proc;


Note that the attribute "-setattr blackbox" is used to ignore the missing definitions of the clock gates which will be added to the design. Another solution that can be helpfull in other cases would be adding the clock-gate cells as blackbox to the design. Thus, we provide blackbox definitions for the clock-gates for all the standard cell libraries supported, and you can find them [here](https://github.com/AUCOHL/Lighter/tree/main/platform). To add them to the design, add this line to your script:

    read_verilog sky130_fd_sc_hd_clkg_blackbox.v

<img width="587" alt="Screen Shot 2022-03-22 at 1 09 19 PM" src="https://user-images.githubusercontent.com/63082375/159468706-791b13c4-5131-476a-bdcc-2dbe5c1cd360.png">
<br>
<br>
<br>

## Then the design is optimized to combine multiplexers and flip-flops into one cell (load-enabled flip-flop)

    opt;; 

<img width="442" alt="Screen Shot 2022-03-22 at 1 10 01 PM" src="https://user-images.githubusercontent.com/63082375/159468757-62eb12e1-c5aa-4adc-b81d-9ea0832f301e.png">
<br>
<br>
<br>


## Note! For a register file or a memory component, the design needs to be further optimized to break down the memory components in RTLIL into basic cells for the mapping to take place later.

    memory_collect
    memory_map
    opt;; 

<img width="664" alt="Screen Shot 2022-03-22 at 1 10 53 PM" src="https://user-images.githubusercontent.com/63082375/159468905-aae4202c-df4e-4a22-929b-8ea5399b3eaf.png">
<br>
<br>
<br>

## Optimized memory cell

<img width="1216" alt="Screen Shot 2022-03-22 at 1 11 47 PM" src="https://user-images.githubusercontent.com/63082375/159469039-e2ac0bab-5317-4d1b-9189-ad26caf094f4.png">
<br>
<br>
<br>

## Now, using the technology mapping command provided by Yosys, the enabled flip-flop cells are replaced with clock-gated flip-flop cells, which are provided in the map file. 

    techmap -map sky130_fd_sc_hd_ff_map.v
    opt;; 

<img width="692" alt="Screen Shot 2022-03-22 at 1 12 16 PM" src="https://user-images.githubusercontent.com/63082375/159469114-804c4746-bcd1-433f-b174-17cdb1005c03.png">