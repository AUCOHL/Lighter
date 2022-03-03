



read_liberty sky130_hd.lib
set design blabla

read_verilog $design/before_gl.v

link_design $design

report_power $design



read_verilog $design/test_outout_gatelevel.gl.v
link_design $design
report_power $design





