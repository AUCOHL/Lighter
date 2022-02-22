yosys -import

#read design
read_verilog test1.v

#generic synthesis
synth -top test
#muxcover
#opt_clean -purge
#flatten; opt
#opt_clean -purge
#techmap -map mux2_map.v
#simplemap

# flatten the gate level netlist 


#mapping to sky130 SCL
dfflibmap -liberty sky130_hd.lib 
abc -D 1250 -liberty sky130_hd.lib 

splitnets
opt_clean -purge

# write synthesized design
write_verilog -noattr -noexpr -nohex -nodec -defparam test_outout_gatelevel.gl.v