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

dir_list = [
    "AHB_SRAM",
    "blabla",
    "blake2s",
    "blake2s_core",
    "blake2s_m_select",
    "chacha",
    "genericfir",
    "i2c_master",
    "jpeg_encoder",
    # "ldpc_decoder_802_3an",
    "ldpcenc",
    "NfiVe32_RF",
    "picorv32a",
    "PPU",
    "prv32_cpu",
    "rf_64x64",
    # "riscv_top_151",
    # "rv32cpu",
    "sha512",
    "spi_master",
    "y_dct",
    "y_huff",
    "y_quantizer",
    "zigzag",   # check license
]


states = [
    [
        "module",
        "clock gates",
        "flipflops",
        "clock gated flipflops",
        "cells before",
        "cells after",
        "cells difference",
    ],
]


for test in dir_list:
    print(test)
    with open("./synth.ys", "w") as f:

        f.write(
            """
read_verilog ../designs/"""
            + test
            + """/"""
            + test
            + """.v
read_liberty -lib -ignore_miss_dir -setattr blackbox ../platform/sky130/sky130_hd.lib 
hierarchy -check -top """
            + test
            + """

proc;
opt;; 
memory_collect
memory_map
opt;; 
opt_clean -purge
synth -top """
            + test
            + """
dfflibmap -liberty ../platform/sky130/sky130_hd.lib 
abc -D 1250 -liberty ../platform/sky130/sky130_hd.lib 
splitnets
opt_clean -purge
hilomap -hicell sky130_fd_sc_hd__conb_1 HI -locell sky130_fd_sc_hd__conb_1 LO
splitnets
opt_clean -purge
insbuf -buf sky130_fd_sc_hd__buf_2 A X
dffinit
flatten
opt;; 
check
write_verilog -noattr -noexpr -nohex -nodec -defparam   ../designs/"""
            + test
            + """/before_gl.v
            """
        )

    os.system("yosys ./synth.ys")

    with open("./synth2.ys", "w") as f:

        f.write(
            """
read_verilog ../designs/"""
            + test
            + """/"""
            + test
            + """.v
read_liberty -lib -ignore_miss_dir -setattr blackbox ../platform/sky130/sky130_hd.lib 
#read_verilog sky130_clkg_blackbox.v
hierarchy -check -top """
            + test
            + """

reg_clock_gating sky130_ff_map.v
opt_clean -purge
synth -top """
            + test
            + """
dfflibmap -liberty ../platform/sky130/sky130_hd.lib 
abc -D 1250 -liberty ../platform/sky130/sky130_hd.lib 
splitnets
opt_clean -purge
hilomap -hicell sky130_fd_sc_hd__conb_1 HI -locell sky130_fd_sc_hd__conb_1 LO
splitnets
opt_clean -purge
insbuf -buf sky130_fd_sc_hd__buf_2 A X
dffinit
flatten
opt;; 
check
write_verilog -noattr -noexpr -nohex -nodec -defparam   ../designs/"""
            + test
            + """/after_gl.v
            """
        )

    os.system("yosys -m cg_plugin.so ./synth2.ys")
    cells_before = os.popen(
        "grep sky130_fd_sc_hd ../designs/" + test + "/before_gl.v | wc -l"
    )
    cells_before_no = cells_before.read()
    cells_before_no = cells_before_no[:-1]
    cells_after = os.popen(
        "grep sky130_fd_sc_hd ../designs/" + test + "/after_gl.v | wc -l"
    )
    cells_after_no = cells_after.read()
    cells_after_no = cells_after_no[:-1]
    clk_gates = os.popen("grep dlclk ../designs/" + test + "/after_gl.v | wc -l")
    clk_gates_no = clk_gates.read()
    clk_gates_no = clk_gates_no[:-1]
    cell_diff = int(cells_after_no) - int(cells_before_no)

    flipflops = os.popen(
        "grep sky130_fd_sc_hd__df ../designs/" + test + "/after_gl.v | wc -l"
    )
    flipflops_no = flipflops.read()
    flipflops_no = flipflops_no[:-1]

    icg_flipflops = os.popen(
        "grep '    .CLK(_' ../designs/" + test + "/after_gl.v | wc -l"
    )
    icg_flipflops_no = icg_flipflops.read()
    icg_flipflops_no = icg_flipflops_no[:-1]

    row = [
        test,
        clk_gates_no,
        flipflops_no,
        icg_flipflops_no,
        cells_before_no,
        cells_after_no,
        cell_diff,
    ]
    states.append(row)

f = open("../report_power/stats/stats_cells_file.csv", "w")
writer = csv.writer(f)
for row in states:
    writer.writerow(row)
f.close()
