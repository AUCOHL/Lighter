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


def gate_percentage(filename):
    f = open(filename, "r+")
    ratio_list = []
    stats_list = []
    for line in f:
        x = line.split(",")
        cg_ff = np.longdouble(0)
        ff_no = np.longdouble(0)
        try:
            ff_no += np.longdouble(x[2])
        except:
            continue
        try:
            cg_ff += np.longdouble(x[3])
        except:
            continue
        try:
            per = cg_ff / ff_no
        except:
            per = 0
        ratio_list.append(per)
        stats_list.append(x)
    return stats_list, ratio_list


def parse_ff_power(filename):
    count = 0
    f = open(filename, "r+")
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


def parse_all_power(filename):
    f = open(filename, "r+")
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


benchmarks_input, ratio_list = gate_percentage("./stats/stats_cells_file.csv")
j = -1
for test in dir_list:
    print(test)
    j += 1

    with open("./power_report.tcl", "w") as f:

        f.write(
            '''
read_liberty ../platform/sky130/sky130_hd.lib
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
report_power $design >>./stats/all_dump_stats_0_1_before.txt
report_power $design -instances [all_registers -cells] >>./stats/ff_dump_stats_0_1_before.txt

set_power_activity -global -activity 1.0
report_power $design -instances [all_registers -cells] >>./stats/ff_dump_stats_1_0_before.txt
##############################
##############################

read_verilog ../designs/$design/after_gl.v
link_design $design
create_clock -period $period $clk

set_power_activity -global -activity 0.1
report_power $design >>./stats/all_dump_stats_0_1_after.txt
report_power $design -instances [all_registers -cells] >>./stats/ff_dump_stats_0_1_after.txt

set_power_activity -global -activity 0.05
report_power $design -instances [all_registers -cells] >>./stats/ff_dump_stats_0_05_after.txt

set_power_activity -global -activity 1.0
report_power $design -instances [all_registers -cells] >>./stats/ff_dump_stats_1_0_after.txt
exit
##############################
            """
        )
    f.close()
    os.system("/Users/youssef/OpenSTA/app/sta -no_splash ./power_report.tcl")

    ff_0_1_before = parse_ff_power("./stats/ff_dump_stats_0_1_before.txt")

    ff_1_0_before = parse_ff_power("./stats/ff_dump_stats_1_0_before.txt")
    ff_1_0_after = parse_ff_power("./stats/ff_dump_stats_1_0_after.txt")

    ff_0_1_after = parse_ff_power("./stats/ff_dump_stats_0_1_after.txt")
    ff_0_05_after = parse_ff_power("./stats/ff_dump_stats_0_05_after.txt")

    ff_0_05_after[0] = (ratio_list[j] * ff_0_05_after[0]) + (
        (1 - ratio_list[j]) * ff_1_0_after[0]
    )
    ff_0_05_after[1] = (ratio_list[j] * ff_0_05_after[1]) + (
        (1 - ratio_list[j]) * ff_1_0_after[1]
    )
    ff_0_05_after[2] = (ratio_list[j] * ff_0_05_after[2]) + (
        (1 - ratio_list[j]) * ff_1_0_after[2]
    )
    ff_0_05_after[3] = (ratio_list[j] * ff_0_05_after[3]) + (
        (1 - ratio_list[j]) * ff_1_0_after[3]
    )

    all_0_1_before = parse_all_power("./stats/all_dump_stats_0_1_before.txt")
    all_0_1_after = parse_all_power("./stats/all_dump_stats_0_1_after.txt")

    before_power = list()
    before_power.append(all_0_1_before[0] - ff_0_1_before[0] + ff_1_0_before[0])
    before_power.append(all_0_1_before[1] - ff_0_1_before[1] + ff_1_0_before[1])
    before_power.append(all_0_1_before[2] - ff_0_1_before[2] + ff_1_0_before[2])
    before_power.append(all_0_1_before[3] - ff_0_1_before[3] + ff_1_0_before[3])
    # print(before_power[3])
    after_power = list()
    after_power.append(all_0_1_after[0] - ff_0_1_after[0] + ff_0_05_after[0])
    after_power.append(all_0_1_after[1] - ff_0_1_after[1] + ff_0_05_after[1])
    after_power.append(all_0_1_after[2] - ff_0_1_after[2] + ff_0_05_after[2])
    after_power.append(all_0_1_after[3] - ff_0_1_after[3] + ff_0_05_after[3])
    # print(after_power[3])
    states.append(
        [
            test[0],
            str(before_power[0]),
            str(before_power[1]),
            str(before_power[2]),
            str(before_power[3]),
            str(after_power[0]),
            str(after_power[1]),
            str(after_power[2]),
            str(after_power[3]),
            str(before_power[3] - after_power[3]),
            str(((before_power[3] - after_power[3]) / before_power[3]) * 100) + " %",
        ]
    )

    states_internal.append(
        [
            test[0],
            str(all_0_1_before[0]),
            str(all_0_1_before[3]),
            str(ff_0_1_before[0]),
            str(ff_0_1_before[3]),
            str(ff_1_0_before[0]),
            str(ff_1_0_before[3]),
            str(before_power[3]),
            str(all_0_1_after[0]),
            str(all_0_1_after[3]),
            str(ff_0_1_after[0]),
            str(ff_0_1_after[3]),
            str(ff_0_05_after[0]),
            str(ff_0_05_after[3]),
            str(after_power[3]),
            str(before_power[3] - after_power[3]),
            str(((before_power[3] - after_power[3]) / before_power[3]) * 100) + " %",
        ]
    )

    states_switching.append(
        [
            test[0],
            str(all_0_1_before[1]),
            str(all_0_1_before[3]),
            str(ff_0_1_before[1]),
            str(ff_0_1_before[3]),
            str(ff_1_0_before[1]),
            str(ff_1_0_before[3]),
            str(before_power[3]),
            str(all_0_1_after[1]),
            str(all_0_1_after[3]),
            str(ff_0_1_after[1]),
            str(ff_0_1_after[3]),
            str(ff_0_05_after[1]),
            str(ff_0_05_after[3]),
            str(after_power[3]),
            str(before_power[3] - after_power[3]),
            str(((before_power[3] - after_power[3]) / before_power[3]) * 100) + " %",
        ]
    )

    states_leakage.append(
        [
            test[0],
            str(all_0_1_before[2]),
            str(all_0_1_before[3]),
            str(ff_0_1_before[2]),
            str(ff_0_1_before[3]),
            str(ff_1_0_before[2]),
            str(ff_1_0_before[3]),
            str(before_power[3]),
            str(all_0_1_after[2]),
            str(all_0_1_after[3]),
            str(ff_0_1_after[2]),
            str(ff_0_1_after[3]),
            str(ff_0_05_after[2]),
            str(ff_0_05_after[3]),
            str(after_power[3]),
            str(before_power[3] - after_power[3]),
            str(((before_power[3] - after_power[3]) / before_power[3]) * 100) + " %",
        ]
    )
    area_reduction = float(benchmarks_input[j][6]) / float(benchmarks_input[j][4]) * 100
    benchmarks.append(
        [
            benchmarks_input[j][0],
            benchmarks_input[j][4],
            benchmarks_input[j][5],
            benchmarks_input[j][1],
            benchmarks_input[j][2],
            benchmarks_input[j][3],

            str(before_power[3]),
            str(after_power[3]),
            str(before_power[3] - after_power[3]),
            str(((before_power[3] - after_power[3]) / before_power[3]) * 100) + " %",
            str(area_reduction) + " %",
        ]
    )

    power_report_summary.append(
        [
            benchmarks_input[j][0],
            benchmarks_input[j][4],
            benchmarks_input[j][1],
            str(((before_power[3] - after_power[3]) / before_power[3]) * 100) + " %",
            str(area_reduction) + " %",
        ]
    )


f = open("./stats/stats_file.csv", "w")
writer = csv.writer(f)
for row in states:
    writer.writerow(row)
f.close()

f = open("./stats/stats_internal_file.csv", "w")
writer = csv.writer(f)
for row in states_internal:
    writer.writerow(row)
f.close()

f = open("./stats/stats_switching_file.csv", "w")
writer = csv.writer(f)
for row in states_switching:
    writer.writerow(row)
f.close()

f = open("./stats/stats_leakage_file.csv", "w")
writer = csv.writer(f)
for row in states_leakage:
    writer.writerow(row)
f.close()

f = open("../benchmarks.csv", "w")
writer = csv.writer(f)
for row in benchmarks:
    writer.writerow(row)
f.close()


f = open("../power_report_summary.csv", "w")
writer = csv.writer(f)
for row in power_report_summary:
    writer.writerow(row)
f.close()
