
read_liberty lib/sky130_hd.lib
##############################
##############################
puts "AHB_UART_MASTER"
set design AHB_UART_MASTER
set clk HCLK
set period 10.0
##############################
##############################

read_verilog designs/$design/before_gl.v
link_design $design
create_clock -period $period $clk
set_power_activity -global -activity 0.1
report_power $design >>./stats/all_dump_stats_0_1_before.txt
report_power $design -instances [all_registers -cells] >>./stats/ff_dump_stats_0_1_before.txt

set_power_activity -global -activity 1.0
report_power $design -instances [all_registers -cells] >>./stats/ff_dump_stats_1_0_before.txt
##############################
##############################

read_verilog designs/$design/after_gl.v
link_design $design
create_clock -period $period $clk

#set_clock_gating_check $clk
set_power_activity -global -activity 0.1
report_power $design >>./stats/all_dump_stats_0_1_after.txt
report_power $design -instances [all_registers -cells] >>./stats/ff_dump_stats_0_1_after.txt

set_power_activity -global -activity 0.05
report_power $design -instances [all_registers -cells] >>./stats/ff_dump_stats_0_05_after.txt
exit
##############################
            