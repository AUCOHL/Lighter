



read_liberty sky130_hd.lib

read_verilog riscv/before_gl.v

link_design riscv

report_power riscv



read_verilog riscv/test_outout_gatelevel.gl.v
link_design riscv
report_power riscv


