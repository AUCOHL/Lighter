
read_liberty sky130_hd.lib
##############################
##############################
puts "blabla"
set design blabla
set clk clk
set period 65.0
##############################
##############################

read_verilog $design/before_gl.v
link_design $design
create_clock -period $period $clk
set_power_activity -input -activity 0.1
report_power $design >>./stats/all_dump_stats_0_1_before.txt
report_power $design -instances [all_registers -cells] >>./stats/ff_dump_stats_0_1_before.txt

set_power_activity -input -activity 1.0
report_power $design -instances [all_registers -cells] >>./stats/ff_dump_stats_1_0_before.txt
##############################
##############################

read_verilog $design/after_gl.v
link_design $design
create_clock -period $period $clk

set_clock_gating_check $clk
set_power_activity -input -activity 0.1
report_power $design >>./stats/all_dump_stats_0_1_after.txt
report_power $design -instances [all_registers -cells] >>./stats/ff_dump_stats_0_1_after.txt

set_power_activity -input -activity 0.05
report_power $design -instances [all_registers -cells] >>./stats/ff_dump_stats_0_03125_after.txt
exit
##############################
            