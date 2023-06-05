# How does it work

Here is a guided illustration of the flipflop clock-gating process done by Lighter.

Consider a normal n-bit enabled-register.

We will run the following script to perform synthesis and flipflop clock-gating. 

    read_verilog design
    read_verilog sky130_clkg_blackbox.v
    hierarchy -check
    reg_clock_gating sky130_ff_map.v
    synth -top design
    dfflibmap -liberty lib/sky130_hd.lib 
    abc -D 1250 -liberty lib/sky130_hd.lib 
    splitnets
    opt_clean -purge
    opt;; 
    write_verilog -noattr -noexpr -nohex -nodec -defparam   design.gl.v


The reg_clock_gating command performs the following commands:

    proc
    opt;; 
    memory_collect
    memory_map;;
    opt;; 
    techmap -map lib/map_file.v
    opt;; 


First, the design is read and converted to RTLIL (register transfer level intermediate language) graphical representation inside Yosys frontend synthesizer.

    read_verilog design
    read_verilog sky130_clkg_blackbox.v
    hierarchy -check
    proc;

<img width="587" alt="Screen Shot 2022-03-22 at 1 09 19 PM" src="https://user-images.githubusercontent.com/63082375/159468706-791b13c4-5131-476a-bdcc-2dbe5c1cd360.png">

Then the design is optimized to combine multiplexers and flip-flops into one cell (enabled flip-flop)

    opt;; 

<img width="442" alt="Screen Shot 2022-03-22 at 1 10 01 PM" src="https://user-images.githubusercontent.com/63082375/159468757-62eb12e1-c5aa-4adc-b81d-9ea0832f301e.png">


Note; For a register file or a memory component, the design needs to be further optimized to break down the memory components in RTLIL into basic cells for the mapping to take place later.

    memory_collect
    memory_map
    opt;; 

<img width="664" alt="Screen Shot 2022-03-22 at 1 10 53 PM" src="https://user-images.githubusercontent.com/63082375/159468905-aae4202c-df4e-4a22-929b-8ea5399b3eaf.png">

optimized memory cell

<img width="1216" alt="Screen Shot 2022-03-22 at 1 11 47 PM" src="https://user-images.githubusercontent.com/63082375/159469039-e2ac0bab-5317-4d1b-9189-ad26caf094f4.png">

Now, using the technology mapping command provided by Yosys, the enabled flip-flop cells are replaced with clock-gated flip-flop cells, which are provided in the map file. 

    techmap -map lib/map_file.v;;
    opt;; 

<img width="692" alt="Screen Shot 2022-03-22 at 1 12 16 PM" src="https://user-images.githubusercontent.com/63082375/159469114-804c4746-bcd1-433f-b174-17cdb1005c03.png">