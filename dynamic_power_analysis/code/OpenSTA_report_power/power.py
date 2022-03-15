import os
import csv
import sys
from tokenize import Double

import numpy as np






states=[["module", "Internal before","Switching before","Leakage before","Total before",
                    "Internal after","Switching after","Leakage after","Total after",
                     "total power difference", "percentage reduction"],]

states_two=[["module", "all cells power before at 0.1","flipflops power before at 0.1","flipflops power before at 1.0","total power before",
                    "all cells power after at 0.1","flipflops power after at 0.1","flipflops power after at 0.05","total power after",
                     "total power difference", "percentage reduction"],]



states_internal=[["module","all cells Internal before at 0.1", "all cells power before at 0.1","ff Internal before at 0.1","ff power before at 0.1","ff Internal before at 1.0","ff power before at 1.0","total power before",
                    "all cells Internal after at 0.1", "all cells power after at 0.1","ff Internal after at 0.1", "ff power after at 0.1", "ff Internal after at 0.05","ff power after at 0.05","total power after",
                     "total power difference", "percentage reduction"],]

states_switching=[["module","all cells switching before at 0.1", "all cells power before at 0.1","ff switching before at 0.1","ff power before at 0.1","ff switching before at 1.0","ff power before at 1.0","total power before",
                    "all cells switching after at 0.1", "all cells power after at 0.1","ff switching after at 0.1", "ff power after at 0.1", "ff switching after at 0.05","ff power after at 0.05","total power after",
                     "total power difference", "percentage reduction"],]


states_leakage=[["module","all cells leakage before at 0.1", "all cells power before at 0.1","ff leakage before at 0.1","ff power before at 0.1","ff leakage before at 1.0","ff power before at 1.0","total power before",
                    "all cells leakage after at 0.1", "all cells power after at 0.1","ff leakage after at 0.1", "ff power after at 0.1", "ff leakage after at 0.05","ff power after at 0.05","total power after",
                     "total power difference", "percentage reduction"],]


dir_list = [
            ["blabla",               "clk",         "65.0"],
            ["chacha",               "clk",         "25.0"],
            ["ldpc_decoder_802_3an", "clk",         "77.0"],
            ["ldpcenc",              "clk",         "12.9"], 
            #["sp_mul" ,              "clk",         "4.4"], 
            ["PPU" ,                 "clk",         "3.5"],
            #["ula",                  "clk14",       "0.8"], 
            #["vm80a",                "pin_clk",     "3.2"], 
            #["xtea" ,                "clock",       "26.03"],
            ["y_huff",               "clk",         "14.0"], 
            ["y_quantizer",          "clk",         "1.0"], 
            #["zigzag",               "clk",         "0.8"], 
            #["zipdiv" ,              "i_clk",       "20.0"], 
            ["y_dct" ,               "clk",         "20.0"], 
            ["jpeg_encoder",         "clk",         "16.0"],
            #["aes_cipher",           "clk",         "10.0"],
            ["sha512",               "clk",         "40.0"], 
            ["picorv32a",            "clk",         "24.0"], 
            ["riscv_top_151",        "clk",         "50.0"], 
            ["genericfir",        "i_clk",           "15.0"],
            ["NfiVe32_RF",        "HCLK",           "10.0"],
            ["rf_64x64",        "HCLK",           "10.0"]
            ] 
# add generic fir
            #"genericfir",
#dir_list = [
##        #   ["FF",        "clk",         "10.0"]
#            ["y_dct" ,               "clk",         "20.0"], 
#          ]
def parse_ff_power(filename):
    count=0
    f = open(filename, "r+")
    acc_internal=np.longdouble(0)
    acc_switch  =np.longdouble(0)
    acc_leakage =np.longdouble(0)
    acc_total   =np.longdouble(0)
    for line in f:
        count+=1
        if count>3:

            line=line[3:]
            line=line.split("   ")
            #print(line)
            acc_internal+=  np.longdouble(line[0])
            acc_switch  +=  np.longdouble(line[1])
            acc_leakage +=  np.longdouble(line[2])
            x= line[3].split(" ")
            acc_total   +=  np.longdouble(x[0])
    power_array=[acc_internal,acc_switch,acc_leakage,acc_total]
    f.truncate(0)
    f.close()
    return power_array


def parse_all_power(filename):
    f = open(filename, "r+")
    acc_internal=np.longdouble(0)
    acc_switch  =np.longdouble(0)
    acc_leakage =np.longdouble(0)
    acc_total   =np.longdouble(0)
    for line in f:
        if "Total                  " in line:
            x=line.split("Total                  ")
            #print(x)
            line=x[1].split("   ")
            #print(line)
            acc_internal+=  np.longdouble(line[0])
            acc_switch  +=  np.longdouble(line[1])
            acc_leakage +=  np.longdouble(line[2])
            x= line[3].split(" ")
            acc_total   +=  np.longdouble(x[0])
    power_array=[acc_internal,acc_switch,acc_leakage,acc_total]
    f.truncate(0)
    f.close()
    return power_array


for test in dir_list:
    with open("./power.tcl", "w") as f:
        
        f.write(
            '''
read_liberty sky130_hd.lib
##############################
##############################
puts "'''+test[0]+'''"
set design '''+test[0]+'''
set clk '''+test[1]+'''
set period '''+test[2]+'''
##############################
##############################

read_verilog $design/before_gl.v
link_design $design
create_clock -period $period $clk
set_power_activity -global -activity 0.1
report_power $design >>./stats/all_dump_stats_0_1_before.txt
report_power $design -instances [all_registers -cells] >>./stats/ff_dump_stats_0_1_before.txt

set_power_activity -global -activity 1.0
report_power $design -instances [all_registers -cells] >>./stats/ff_dump_stats_1_0_before.txt
##############################
##############################

read_verilog $design/after_gl.v
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
            '''
        )
    f.close()
    os.system("/Users/youssef/OpenSTA/app/sta -no_splash ./power.tcl" )

#    ff_0_1_before = parse_ff_power("./stats/ff_dump_stats_0_1_before.txt")

#    ff_1_0_before =parse_ff_power("./stats/ff_dump_stats_1_0_before.txt")
#    ff_0_1_after =parse_ff_power("./stats/ff_dump_stats_0_1_after.txt")
#    ff_0_05_after =parse_ff_power("./stats/ff_dump_stats_0_05_after.txt")

#    all_0_1_before =parse_all_power("./stats/all_dump_stats_0_1_before.txt")
#    all_0_1_after =parse_all_power('./stats/all_dump_stats_0_1_after.txt')



#    #before_power =  list()
#    #for item1, item2, intem3 in zip(all_0_1_before, ff_0_1_before,ff_1_0_before):
#    #    item = item1 - item2 +intem3
#    #    before_power.append(item)

#    before_power=list()
#    before_power.append(all_0_1_before[0] - ff_0_1_before[0] + ff_1_0_before[0])
#    before_power.append(all_0_1_before[1] - ff_0_1_before[1] + ff_1_0_before[1])
#    before_power.append(all_0_1_before[2] - ff_0_1_before[2] + ff_1_0_before[2])
#    before_power.append(all_0_1_before[3] - ff_0_1_before[3] + ff_1_0_before[3])

#    after_power=list()
#    after_power.append(all_0_1_after[0] - ff_0_1_after[0] + ff_0_05_after[0])
#    after_power.append(all_0_1_after[1] - ff_0_1_after[1] + ff_0_05_after[1])
#    after_power.append(all_0_1_after[2] - ff_0_1_after[2] + ff_0_05_after[2])
#    after_power.append(all_0_1_after[3] - ff_0_1_after[3] + ff_0_05_after[3])

#    states.append(
#                  [
#                    test[0],
#                    str(before_power[0]), str(before_power[1]),str(before_power[2]),str(before_power[3]),
#                    str(after_power[0]), str(after_power[1]),str(after_power[2]),str(after_power[3]),
#                    str(before_power[3]-after_power[3]), str(((before_power[3]-after_power[3])/before_power[3])*100)+" %"
#                    ]
#                    )


##states_two=[["module", "all cells power before at 0.1","flipflops power before at 0.1","flipflops power before at 1.0","total power before",
##                    "all cells power after at 0.1","flipflops power after at 0.1","flipflops power after at 0.05","total power after",
##                     "total power difference", "percentage reduction"],]

#    states_two.append([
#                        test[0],
#                        str(all_0_1_before[3]), str(ff_0_1_before[3]),str(ff_1_0_before[3]),str(before_power[3]),
#                        str(all_0_1_after[3]), str(ff_0_1_after[3]),str(ff_0_05_after[3]),str(after_power[3]),
#                        str(before_power[3]-after_power[3]), str(((before_power[3]-after_power[3])/before_power[3])*100)+" %"
#    ])



#    states_internal.append([
#                        test[0],
#                        str(all_0_1_before[0]),str(all_0_1_before[3]),str(ff_0_1_before[0]), str(ff_0_1_before[3]),str(ff_1_0_before[0]),str(ff_1_0_before[3]),str(before_power[3]),
#                        str(all_0_1_after[0]),str(all_0_1_after[3]),str(ff_0_1_after[0]), str(ff_0_1_after[3]),str(ff_0_05_after[0]),str(ff_0_05_after[3]),str(after_power[3]),
#                        str(before_power[3]-after_power[3]), str(((before_power[3]-after_power[3])/before_power[3])*100)+" %"
#    ])

#    states_switching.append([
#                        test[0],
#                        str(all_0_1_before[1]),str(all_0_1_before[3]),str(ff_0_1_before[1]), str(ff_0_1_before[3]),str(ff_1_0_before[1]),str(ff_1_0_before[3]),str(before_power[3]),
#                        str(all_0_1_after[1]),str(all_0_1_after[3]),str(ff_0_1_after[1]), str(ff_0_1_after[3]),str(ff_0_05_after[1]),str(ff_0_05_after[3]),str(after_power[3]),
#                        str(before_power[3]-after_power[3]), str(((before_power[3]-after_power[3])/before_power[3])*100)+" %"
#    ])

#    states_leakage.append([
#                        test[0],
#                        str(all_0_1_before[2]),str(all_0_1_before[3]),str(ff_0_1_before[2]), str(ff_0_1_before[3]),str(ff_1_0_before[2]),str(ff_1_0_before[3]),str(before_power[3]),
#                        str(all_0_1_after[2]),str(all_0_1_after[3]),str(ff_0_1_after[2]), str(ff_0_1_after[3]),str(ff_0_05_after[2]),str(ff_0_05_after[3]),str(after_power[3]),
#                        str(before_power[3]-after_power[3]), str(((before_power[3]-after_power[3])/before_power[3])*100)+" %"
#    ])

#f = open('./stats/stats_file.csv', 'w')

## create the csv writer
#writer = csv.writer(f)

## write a row to the csv file
#for row in states:
#    writer.writerow(row)

## close the file
#f.close()


#f = open('./stats/stats_two_file.csv', 'w')

## create the csv writer
#writer = csv.writer(f)

## write a row to the csv file
#for row in states_two:
#    writer.writerow(row)

## close the file
#f.close()

#f = open('./stats/stats_internal_file.csv', 'w')

## create the csv writer
#writer = csv.writer(f)

## write a row to the csv file
#for row in states_internal:
#    writer.writerow(row)

## close the file
#f.close()



#f = open('./stats/stats_switching_file.csv', 'w')

## create the csv writer
#writer = csv.writer(f)

## write a row to the csv file
#for row in states_switching:
#    writer.writerow(row)

## close the file
#f.close()


#f = open('./stats/stats_leakage_file.csv', 'w')

## create the csv writer
#writer = csv.writer(f)

## write a row to the csv file
#for row in states_leakage:
#    writer.writerow(row)

## close the file
#f.close()

