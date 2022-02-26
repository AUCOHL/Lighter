



read_liberty sky130_hd.lib

read_verilog testing_PPU/before_gl.v

link_design LoopyGen

report_power



read_verilog testing_PPU/test_outout_gatelevel.gl.v
link_design LoopyGen
report_power


