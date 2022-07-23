"""
 	Copyright 2022 AUC Open Source Hardware Lab
	
	Licensed under the Apache License, Version 2.0 (the "License"); 
	you may not use this file except in compliance with the License. 
	You may obtain a copy of the License at:

	http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software 
	distributed under the License is distributed on an "AS IS" BASIS, 
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
	See the License for the specific language governing permissions and 
	limitations under the License.
"""


import os
import csv
import numpy as np



dir_list = [
    # ["FF"      ,             "clk",         "10.0"],
    ["AHB_SRAM", "HCLK", "10.0"],
    ["blabla", "clk", "65.0"],
    ["blake2s", "clk", "20.0"],
    ["blake2s_core", "clk", "20.0"],
    ["blake2s_m_select", "clk", "20.0"],
    ["chacha", "clk", "25.0"],
    ["genericfir", "i_clk", "15.0"],
    ["i2c_master", "sys_clk", "20.0"],
    ["jpeg_encoder", "clk", "16.0"],
    ["ldpcenc", "clk", "12.9"],
    ["NfiVe32_RF", "HCLK", "10.0"],
    ["picorv32a", "clk", "24.0"],
    ["PPU", "clk", "3.5"],
    ["prv32_cpu", "clk", "20.0"],
    ["rf_64x64", "HCLK", "10.0"],
    # ["riscv_top_151",       "clk",         "50.0"],
    ["sha512", "clk", "40.0"],
    ["spi_master", "clk", "20.0"],
    ["y_dct", "clk", "20.0"],
    ["y_huff", "clk", "14.0"],
    ["y_quantizer", "clk", "1.0"],
    ["zigzag", "clk", "0.8"],
]



states = [
    [
        "module",
        "Internal before",
        "Switching before",
        "Leakage before",
        "Total before",
        "Internal after",
        "Switching after",
        "Leakage after",
        "Total after",
        "total power difference",
        "percentage reduction",
    ],
]


states_internal = [
    [
        "module",
        "all cells Internal before at 0.1",
        "all cells power before at 0.1",
        "ff Internal before at 0.1",
        "ff power before at 0.1",
        "ff Internal before at 1.0",
        "ff power before at 1.0",
        "total power before",
        "all cells Internal after at 0.1",
        "all cells power after at 0.1",
        "ff Internal after at 0.1",
        "ff power after at 0.1",
        "ff Internal after at 0.05",
        "ff power after at 0.05",
        "total power after",
        "total power difference",
        "percentage reduction",
    ],
]


states_switching = [
    [
        "module",
        "all cells switching before at 0.1",
        "all cells power before at 0.1",
        "ff switching before at 0.1",
        "ff power before at 0.1",
        "ff switching before at 1.0",
        "ff power before at 1.0",
        "total power before",
        "all cells switching after at 0.1",
        "all cells power after at 0.1",
        "ff switching after at 0.1",
        "ff power after at 0.1",
        "ff switching after at 0.05",
        "ff power after at 0.05",
        "total power after",
        "total power difference",
        "percentage reduction",
    ],
]


states_leakage = [
    [
        "module",
        "all cells leakage before at 0.1",
        "all cells power before at 0.1",
        "ff leakage before at 0.1",
        "ff power before at 0.1",
        "ff leakage before at 1.0",
        "ff power before at 1.0",
        "total power before",
        "all cells leakage after at 0.1",
        "all cells power after at 0.1",
        "ff leakage after at 0.1",
        "ff power after at 0.1",
        "ff leakage after at 0.05",
        "ff power after at 0.05",
        "total power after",
        "total power difference",
        "percentage reduction",
    ],
]

benchmarks = [
    [
        "Design",
        "# Cells before", 
        "# Cells after",
        "# Clock Gates",
        "# Flipflops",
        "# Clock-gated Flipflops",
        "Total power before (W)",
        "Total power after (W)",
        "Total power difference (W)",
        "Power reduction %",
        "Cells reduction %",
    ],
]

power_report_summary = [
    [
        "Design",
        "# Cells",
        "# Clock Gates",
        "Power reduction %",
        "Cells reduction %",
    ],
]


def parse_cell_collection_power_report(file_Path):
    count = 0
    f = open(file_Path, "r+")
    acc_internal = np.longdouble(0)
    acc_switch = np.longdouble(0)
    acc_leakage = np.longdouble(0)
    acc_total = np.longdouble(0)
    for line in f:
        count += 1
        if count > 3:
            
            line = line[3:]
            line = line.split("   ")
            # print(line)
            acc_internal += np.longdouble(line[0])
            acc_switch += np.longdouble(line[1])
            acc_leakage += np.longdouble(line[2])
            x = line[3].split(" ")
            acc_total += np.longdouble(x[0])
    power_array = [acc_internal, acc_switch, acc_leakage, acc_total]
    f.truncate(0)
    f.close()
    return power_array


def parse_all_cells_power_report(file_Path):
    f = open(file_Path, "r+")
    acc_internal = np.longdouble(0)
    acc_switch = np.longdouble(0)
    acc_leakage = np.longdouble(0)
    acc_total = np.longdouble(0)
    for line in f:
        if "Total                  " in line:
            x = line.split("Total                  ")
            line = x[1].split("   ")

            acc_internal += np.longdouble(line[0])
            acc_switch += np.longdouble(line[1])
            acc_leakage += np.longdouble(line[2])
            x = line[3].split(" ")
            acc_total += np.longdouble(x[0])

    power_array = [acc_internal, acc_switch, acc_leakage, acc_total]
    f.truncate(0)
    f.close()
    return power_array



for test in dir_list:
    print(test)

    with open("./power_report.tcl", "w") as f:

        f.write(
            '''
read_liberty ../platform/sky130_fd_sc_hd/sky130_fd_sc_hd.lib
##############################
##############################
puts "'''
            + test[0]
            + """"
set design """
            + test[0]
            + """
set clk """
            + test[1]
            + """
set period """
            + test[2]
            + """
##############################
##############################

read_verilog ../designs/$design/before_gl.v
link_design $design
create_clock -period $period $clk
set_power_activity -global -activity 0.1
report_power $design >>./stats/all_cells_normal_before.txt
report_power $design -instances [all_registers -cells] >>./stats/ff_cells_normal_before.txt

set_power_activity -global -activity 1.0
report_power $design -instances [all_registers -cells] >>./stats/ff_cells_high_before.txt
##############################
##############################

read_verilog ../designs/$design/after_gl.v
link_design $design
create_clock -period $period $clk

#  setting activity to low at alpha 0.1
set_power_activity -global -activity 0.1

#  reporting power for normal activity of all cells
report_power $design >>./stats/all_cells_normal_after.txt

#  reporting power for normal activity of all flipflops
report_power $design -instances [all_registers -cells] >>./stats/all_flipflops_normal_after.txt

#  get power of clock gated cells at 0.1 to be subtracted and replaced by lowest activity at 0.05

# gets the power report for all clock gates and clock gated flipflops 
report_power -instances [get_cells -of_objects [get_nets -of_objects [get_pins * -filter "name == GCLK"]]] >./stats/all_cg_and_ff_normal_after.txt
# gets the power report for all clock gates 
report_power -instances [get_cells -of_objects [get_pins * -filter "name == GCLK"]] >./stats/clock_gates_normal.txt
# the reports of the previous commands should be subtracted from each other to get clock_gated_flip_flops

set_power_activity -global -activity 0.05

# gets the power report for all clock gates and clock gated flipflops 
report_power -instances [get_cells -of_objects [get_nets -of_objects [get_pins * -filter "name == GCLK"]]] >./stats/all_cg_and_ff_low_after.txt
# gets the power report for all clock gates 
report_power -instances [get_cells -of_objects [get_pins * -filter "name == GCLK"]] >./stats/clock_gates_low.txt
# the reports of the previous commands should be subtracted from each other to get clock_gated_flip_flops


# the low activity power of clock gates should be replaced by high activity

set_power_activity -global -activity 1.0

#  reporting power for high activity of all flipflops
report_power $design -instances [all_registers -cells] >>./stats/all_flipflops_high_after.txt

# gets the power report for all clock gates and clock gated flipflops 
report_power -instances [get_cells -of_objects [get_nets -of_objects [get_pins * -filter "name == GCLK"]]] >./stats/all_cg_and_ff_high_after.txt
# gets the power report for all clock gates to replace low activity
report_power -instances [get_cells -of_objects [get_pins * -filter "name == GCLK"]] >./stats/clock_gates_high.txt


exit
##############################
            """
        )
    f.close()
    
    
    os.system("/usr/local/OpenSTA/app/sta -no_splash ./power_report.tcl")
    
    
    # first lets parse the complete power reports at 
    # normal activity before and after clock gating
    
    all_cells_normal_before = parse_all_cells_power_report("./stats/all_cells_normal_before.txt")
    all_cells_normal_after = parse_all_cells_power_report("./stats/all_cells_normal_after.txt")
    
    # Now lets calculate the correct power before clock gating 
    # considering the high  activity of the flipflop cells
    
    
    # parse the low and high activites of flipflop cells 
    ff_cells_normal_before = parse_cell_collection_power_report("./stats/ff_cells_normal_before.txt")
    ff_cells_high_before = parse_cell_collection_power_report("./stats/ff_cells_high_before.txt")
    
    
    # Calcultating the power before clock gating using this formula
    # power_before_clock_gating = all_cells_normal_before - ff_cells_normal_before + ff_cells_high_before
    
    power_before_clock_gating = list()
    power_before_clock_gating.append(all_cells_normal_before[0] - ff_cells_normal_before[0] + ff_cells_high_before[0])
    power_before_clock_gating.append(all_cells_normal_before[1] - ff_cells_normal_before[1] + ff_cells_high_before[1])
    power_before_clock_gating.append(all_cells_normal_before[2] - ff_cells_normal_before[2] + ff_cells_high_before[2])
    power_before_clock_gating.append(all_cells_normal_before[3] - ff_cells_normal_before[3] + ff_cells_high_before[3])
    
    ######################################################
    ######################################################
    
    # Now let's calculate the power after clock gating 
    
    
    # power_after_clock_gating = all_cells_normal_after - clockgated_ff_cells_normal + clockgated_ff_cells_low - clock_gates_normal + clock_gates_high - not_gated_flipflops_normal + not_gated_flipflops_high
    
    # where
    
    # clockgated_ff_cells_normal = all_cg_and_ff_normal_after - clock_gates_normal
    
    # clockgated_ff_cells_low = all_cg_and_ff_low_after - clock_gates_low
    
    # clockgated_ff_cells_high = all_cg_and_ff_high_after - clock_gates_high
    
    # not_gated_flipflops_normal = all_flipflops_normal_after - clockgated_ff_cells_normal
    
    # not_gated_flipflops_high = all_flipflops_high_after - clockgated_ff_cells_high
    
    
    
    
    # step one
    # clockgated_ff_cells_normal = all_cg_and_ff_normal_after - clock_gates_normal
    
    # get  all_cg_and_ff_normal_after
    all_cg_and_ff_normal_after = parse_cell_collection_power_report("./stats/all_cg_and_ff_normal_after.txt")
    
    # get  clock_gates_normal
    clock_gates_normal = parse_cell_collection_power_report("./stats/clock_gates_normal.txt")
    
    # claculate clockgated_ff_cells_normal = all_cg_and_ff_normal_after - clock_gates_normal
    clockgated_ff_cells_normal = list()
    clockgated_ff_cells_normal.append(all_cg_and_ff_normal_after[0] - clock_gates_normal[0])
    clockgated_ff_cells_normal.append(all_cg_and_ff_normal_after[1] - clock_gates_normal[1])
    clockgated_ff_cells_normal.append(all_cg_and_ff_normal_after[2] - clock_gates_normal[2])
    clockgated_ff_cells_normal.append(all_cg_and_ff_normal_after[3] - clock_gates_normal[3])
    
    ####################################################################################################
    
    
    # step Two
    # clockgated_ff_cells_low = all_cg_and_ff_low_after - clock_gates_low
    
    # get  all_cg_and_ff_low_after
    all_cg_and_ff_low_after = parse_cell_collection_power_report("./stats/all_cg_and_ff_low_after.txt")
    
    # get  clock_gates_low
    clock_gates_low = parse_cell_collection_power_report("./stats/clock_gates_low.txt")
    
    # claculate clockgated_ff_cells_low = all_cg_and_ff_low_after - clock_gates_low
    clockgated_ff_cells_low = list()
    clockgated_ff_cells_low.append(all_cg_and_ff_low_after[0] - clock_gates_low[0])
    clockgated_ff_cells_low.append(all_cg_and_ff_low_after[1] - clock_gates_low[1])
    clockgated_ff_cells_low.append(all_cg_and_ff_low_after[2] - clock_gates_low[2])
    clockgated_ff_cells_low.append(all_cg_and_ff_low_after[3] - clock_gates_low[3])
    ####################################################################################################
    
    
    # step three
    # clockgated_ff_cells_high = all_cg_and_ff_high_after - clock_gates_high
    
    # get  all_cg_and_ff_high_after
    all_cg_and_ff_high_after = parse_cell_collection_power_report("./stats/all_cg_and_ff_high_after.txt")
    
    # get  clock_gates_high
    clock_gates_high = parse_cell_collection_power_report("./stats/clock_gates_high.txt")
    
    # claculate clockgated_ff_cells_high = all_cg_and_ff_high_after - clock_gates_high
    clockgated_ff_cells_high = list()
    clockgated_ff_cells_high.append(all_cg_and_ff_high_after[0] - clock_gates_high[0])
    clockgated_ff_cells_high.append(all_cg_and_ff_high_after[1] - clock_gates_high[1])
    clockgated_ff_cells_high.append(all_cg_and_ff_high_after[2] - clock_gates_high[2])
    clockgated_ff_cells_high.append(all_cg_and_ff_high_after[3] - clock_gates_high[3])
    ####################################################################################################
    
    
    # step four 
    # not_gated_flipflops_normal = all_flipflops_normal_after - clockgated_ff_cells_normal
    
    # get  all_flipflops_normal_after
    all_flipflops_normal_after = parse_cell_collection_power_report("./stats/all_flipflops_normal_after.txt")
    
    # claculate not_gated_flipflops_normal = all_flipflops_normal_after - clockgated_ff_cells_normal
    not_gated_flipflops_normal = list()
    not_gated_flipflops_normal.append(all_flipflops_normal_after[0] - clockgated_ff_cells_normal[0])
    not_gated_flipflops_normal.append(all_flipflops_normal_after[1] - clockgated_ff_cells_normal[1])
    not_gated_flipflops_normal.append(all_flipflops_normal_after[2] - clockgated_ff_cells_normal[2])
    not_gated_flipflops_normal.append(all_flipflops_normal_after[3] - clockgated_ff_cells_normal[3])
    ####################################################################################################
    
    
    # step five 
    # not_gated_flipflops_high = all_flipflops_high_after - clockgated_ff_cells_high
    
    # get  all_flipflops_high_after
    all_flipflops_high_after = parse_cell_collection_power_report("./stats/all_flipflops_high_after.txt")
    
    # claculate not_gated_flipflops_high = all_flipflops_high_after - clockgated_ff_cells_high
    not_gated_flipflops_high = list()
    not_gated_flipflops_high.append(all_flipflops_high_after[0] - clockgated_ff_cells_high[0])
    not_gated_flipflops_high.append(all_flipflops_high_after[1] - clockgated_ff_cells_high[1])
    not_gated_flipflops_high.append(all_flipflops_high_after[2] - clockgated_ff_cells_high[2])
    not_gated_flipflops_high.append(all_flipflops_high_after[3] - clockgated_ff_cells_high[3])
    ####################################################################################################
    
    
    # Final step 
    # power_after_clock_gating = all_cells_normal_after - clockgated_ff_cells_normal + clockgated_ff_cells_low - clock_gates_normal + clock_gates_high - not_gated_flipflops_normal + not_gated_flipflops_high
    
    # claculate power_after_clock_gating = all_cells_normal_after - clockgated_ff_cells_normal + clockgated_ff_cells_low - clock_gates_normal + clock_gates_high - not_gated_flipflops_normal + not_gated_flipflops_high
    
    power_after_clock_gating = list()
    power_after_clock_gating.append(all_cells_normal_after[0] - clockgated_ff_cells_normal[0] + clockgated_ff_cells_low[0] - clock_gates_normal[0] + clock_gates_high[0] - not_gated_flipflops_normal[0] + not_gated_flipflops_high[0])
    power_after_clock_gating.append(all_cells_normal_after[1] - clockgated_ff_cells_normal[1] + clockgated_ff_cells_low[1] - clock_gates_normal[1] + clock_gates_high[1] - not_gated_flipflops_normal[1] + not_gated_flipflops_high[1])
    power_after_clock_gating.append(all_cells_normal_after[2] - clockgated_ff_cells_normal[2] + clockgated_ff_cells_low[2] - clock_gates_normal[2] + clock_gates_high[2] - not_gated_flipflops_normal[2] + not_gated_flipflops_high[2])
    power_after_clock_gating.append(all_cells_normal_after[3] - clockgated_ff_cells_normal[3] + clockgated_ff_cells_low[3] - clock_gates_normal[3] + clock_gates_high[3] - not_gated_flipflops_normal[3] + not_gated_flipflops_high[3])
    ####################################################################################################
    
    # generating reports
    
    
    states.append(
        [
            test[0],
            str(power_before_clock_gating[0]),
            str(power_before_clock_gating[1]),
            str(power_before_clock_gating[2]),
            str(power_before_clock_gating[3]),
            str(power_after_clock_gating[0]),
            str(power_after_clock_gating[1]),
            str(power_after_clock_gating[2]),
            str(power_after_clock_gating[3]),
            str(power_before_clock_gating[3] - power_after_clock_gating[3]),
            str(((power_before_clock_gating[3] - power_after_clock_gating[3]) / power_before_clock_gating[3]) * 100) + " %",
        ]
    )
    
    ###########################################
    
    #states_internal.append(
    #    [
    #        test[0],
    #        str(all_cells_normal_before[0]),
    #        str(all_cells_normal_before[3]),
    #        str(ff_cells_normal_before[0]),
    #        str(ff_cells_normal_before[3]),
    #        str(ff_cells_high_before[0]),
    #        str(ff_cells_high_before[3]),
    #        str(power_before_clock_gating[3]),
    #        str(all_cells_normal_after[0]),
    #        str(all_cells_normal_after[3]),
    #        str(ff_0_1_after[0]),
    #        str(ff_0_1_after[3]),
    #        str(ff_0_05_after[0]),
    #        str(ff_0_05_after[3]),
    #        str(power_after_clock_gating[3]),
    #        str(power_before_clock_gating[3] - power_after_clock_gating[3]),
    #        str(((power_before_clock_gating[3] - power_after_clock_gating[3]) / power_before_clock_gating[3]) * 100) + " %",
    #    ]
    #)
    
    
    ############################################


    
    #states_switching.append(
    #    [
    #        test[0],
    #        str(all_cells_normal_before[1]),
    #        str(all_cells_normal_before[3]),
    #        str(ff_cells_normal_before[1]),
    #        str(ff_cells_normal_before[3]),
    #        str(ff_cells_high_before[1]),
    #        str(ff_cells_high_before[3]),
    #        str(power_before_clock_gating[3]),
    #        str(all_cells_normal_after[1]),
    #        str(all_cells_normal_after[3]),
    #        str(ff_0_1_after[1]),
    #        str(ff_0_1_after[3]),
    #        str(ff_0_05_after[1]),
    #        str(ff_0_05_after[3]),
    #        str(power_after_clock_gating[3]),
    #        str(power_before_clock_gating[3] - power_after_clock_gating[3]),
    #        str(((power_before_clock_gating[3] - power_after_clock_gating[3]) / power_before_clock_gating[3]) * 100) + " %",
    #    ]
    #)
    
    ############################################


    #states_leakage.append(
    #    [
    #        test[0],
    #        str(all_cells_normal_before[2]),
    #        str(all_cells_normal_before[3]),
    #        str(ff_cells_normal_before[2]),
    #        str(ff_cells_normal_before[3]),
    #        str(ff_cells_high_before[2]),
    #        str(ff_cells_high_before[3]),
    #        str(power_before_clock_gating[3]),
    #        str(all_cells_normal_after[2]),
    #        str(all_cells_normal_after[3]),
    #        str(ff_0_1_after[2]),
    #        str(ff_0_1_after[3]),
    #        str(ff_0_05_after[2]),
    #        str(ff_0_05_after[3]),
    #        str(power_after_clock_gating[3]),
    #        str(power_before_clock_gating[3] - power_after_clock_gating[3]),
    #        str(((power_before_clock_gating[3] - power_after_clock_gating[3]) / power_before_clock_gating[3]) * 100) + " %",
    #    ]
    #)
    
    
    ###########################################
    
    
    #area_reduction = - float(benchmarks_input[j][6]) / float(benchmarks_input[j][4]) * 100
    #benchmarks.append(
    #    [
    #        benchmarks_input[j][0],
    #        benchmarks_input[j][4],
    #        benchmarks_input[j][5],
    #        benchmarks_input[j][1],
    #        benchmarks_input[j][2],
    #        benchmarks_input[j][3],

    #        str(power_before_clock_gating[3]),
    #        str(power_after_clock_gating[3]),
    #        str(power_before_clock_gating[3] - power_after_clock_gating[3]),
    #        str(((power_before_clock_gating[3] - power_after_clock_gating[3]) / power_before_clock_gating[3]) * 100) + " %",
    #        str(area_reduction) + " %",
    #    ]
    #)
    
    ############################################

    #power_report_summary.append(
    #    [
    #        benchmarks_input[j][0],
    #        benchmarks_input[j][4],
    #        benchmarks_input[j][1],
    #        str(((power_before_clock_gating[3] - power_after_clock_gating[3]) / power_before_clock_gating[3]) * 100) + " %",
    #        str(area_reduction) + " %",
    #    ]
    #)
    
    ############################################


f = open("./stats/stats_file.csv", "w")
writer = csv.writer(f)
for row in states:
    writer.writerow(row)
f.close()

#f = open("./stats/stats_internal_file.csv", "w")
#writer = csv.writer(f)
#for row in states_internal:
#    writer.writerow(row)
#f.close()

#f = open("./stats/stats_switching_file.csv", "w")
#writer = csv.writer(f)
#for row in states_switching:
#    writer.writerow(row)
#f.close()

#f = open("./stats/stats_leakage_file.csv", "w")
#writer = csv.writer(f)
#for row in states_leakage:
#    writer.writerow(row)
#f.close()

#f = open("../stats/benchmarks.csv", "w")
#writer = csv.writer(f)
#for row in benchmarks:
#    writer.writerow(row)
#f.close()


#f = open("../stats/power_report_summary.csv", "w")
#writer = csv.writer(f)
#for row in power_report_summary:
#    writer.writerow(row)
#f.close()
