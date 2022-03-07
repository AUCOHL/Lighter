
read_liberty sky130_hd.lib
set design riscv_top_151

read_verilog $design/before_gl.v
puts "passed reading $design"
link_design $design

puts "passed linking $design"
#find_timing_paths -path_delay min
report_power $design
puts "passed power analysis "


read_verilog $design/after_gl.v
link_design $design
report_power $design





