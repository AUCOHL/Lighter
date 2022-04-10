import os
import csv

dir_list = [ 
            #"aes256",
            "blabla", 
            "chacha", 
            "ldpc_decoder_802_3an",
            "ldpcenc", 
            #"sp_mul", 
            "PPU",
            #"des", 
            #"sbox", 
            #"ula", 
            #"vm80a", 
            #"xtea",
            "y_huff", 
            "y_quantizer", 
            #"zigzag", 
            #"zipdiv", 
            "y_dct", 
            "jpeg_encoder",
            #"aes_cipher",
            "sha512", 
            "picorv32a", 
            "riscv_top_151", 
            "genericfir",
            "NfiVe32_RF", 
            "rf_64x64",
            "AHB_FLASH_CTRL",
            "AHB_SRAM",
            ] 


#dir_list = ["NfiVe32_RF"]




states=[["module", "clock gates", "cells before","cells difference", "cells after", "a211oi_1 before", "a21oi_1 before","a22o_1 before", "a22oi_1 before" ,"a211oi_1 after", "a21oi_1 after","a22o_1 after", "a22oi_1 after", "aoi/ao difference"]]



for test in dir_list:
    print(test)
    with open("./synth.ys", "w") as f:
        
        f.write(
            '''
read_verilog designs/''' + test + '''/''' + test + '''.v
hierarchy -check -top ''' + test + '''

proc;
opt;; 
memory_collect
memory_map
opt;; 
synth -top ''' + test + '''
dfflibmap -liberty lib/sky130_hd.lib 
abc -D 1250 -liberty lib/sky130_hd.lib 
splitnets
opt_clean -purge
hilomap -hicell sky130_fd_sc_hd__conb_1 HI -locell sky130_fd_sc_hd__conb_1 LO
splitnets
opt_clean -purge
insbuf -buf sky130_fd_sc_hd__buf_2 A X
dffinit
opt;; 
write_verilog -noattr -noexpr -nohex -nodec -defparam   designs/''' + test + '''/before_gl.v
            '''
        )


    os.system("yosys ./synth.ys" )

    with open("./synth2.ys", "w") as f:
        
        f.write(
            '''
read_verilog designs/''' + test + '''/''' + test + '''.v
read_verilog lib/blackbox_clk_gates.v
hierarchy -check -top ''' + test + '''

proc;
opt;; 
memory_collect
memory_map
opt;; 
techmap -map lib/map_file.v;;


synth -top ''' + test + '''
dfflibmap -liberty lib/sky130_hd.lib 
abc -D 1250 -liberty lib/sky130_hd.lib 
splitnets
opt_clean -purge
hilomap -hicell sky130_fd_sc_hd__conb_1 HI -locell sky130_fd_sc_hd__conb_1 LO
splitnets
opt_clean -purge
insbuf -buf sky130_fd_sc_hd__buf_2 A X
dffinit
opt;; 
write_verilog -noattr -noexpr -nohex -nodec -defparam   designs/''' + test + '''/after_gl.v
            '''
        )


  
    os.system("yosys ./synth2.ys" )
    cells_before= os.popen('grep sky130_fd_sc_hd designs/'+test+'/before_gl.v | wc -l' )
    cells_before_no = cells_before.read()
    cells_before_no=cells_before_no[:-1]
    cells_after= os.popen('grep sky130_fd_sc_hd designs/'+test+'/after_gl.v | wc -l' )
    cells_after_no = cells_after.read()
    cells_after_no=cells_after_no[:-1]
    clk_gates=os.popen('grep dlclk designs/'+test+'/after_gl.v | wc -l' )
    clk_gates_no = clk_gates.read()
    clk_gates_no=clk_gates_no[:-1]
    cell_diff= int (cells_after_no)-int (cells_before_no)


    cell1_before= os.popen('grep sky130_fd_sc_hd__a211oi_1 designs/'+test+'/before_gl.v | wc -l' )
    cell1_before_no = cell1_before.read()
    cell1_before_no=cell1_before_no[:-1]

    cell2_before= os.popen('grep sky130_fd_sc_hd__a21oi_1 designs/'+test+'/before_gl.v | wc -l' )
    cell2_before_no = cell2_before.read()
    cell2_before_no=cell2_before_no[:-1]

    cell3_before= os.popen('grep sky130_fd_sc_hd__a22o_1 designs/'+test+'/before_gl.v | wc -l' )
    cell3_before_no = cell3_before.read()
    cell3_before_no=cell3_before_no[:-1]

    cell4_before= os.popen('grep sky130_fd_sc_hd__a22oi_1 designs/'+test+'/before_gl.v | wc -l' )
    cell4_before_no = cell4_before.read()
    cell4_before_no=cell4_before_no[:-1]


    cell1_after= os.popen('grep sky130_fd_sc_hd__a211oi_1 designs/'+test+'/after_gl.v | wc -l' )
    cell1_after_no = cell1_after.read()
    cell1_after_no=cell1_after_no[:-1]

    cell2_after= os.popen('grep sky130_fd_sc_hd__a21oi_1 designs/'+test+'/after_gl.v | wc -l' )
    cell2_after_no = cell2_after.read()
    cell2_after_no=cell2_after_no[:-1]

    cell3_after= os.popen('grep sky130_fd_sc_hd__a22o_1 designs/'+test+'/after_gl.v | wc -l' )
    cell3_after_no = cell3_after.read()
    cell3_after_no=cell3_after_no[:-1]

    cell4_after= os.popen('grep sky130_fd_sc_hd__a22oi_1 designs/'+test+'/after_gl.v | wc -l' )
    cell4_after_no = cell4_after.read()
    cell4_after_no=cell4_after_no[:-1]
    aoi_diff= int(cell1_after_no)+ int(cell2_after_no)+ int(cell3_after_no)+int(cell4_after_no) -int(cell1_before_no)- int(cell2_before_no)- int(cell3_before_no)-int(cell4_before_no)
   
    row= [test,clk_gates_no, cells_before_no, cells_after_no,cell_diff,
    cell1_before_no, cell2_before_no, cell3_before_no,cell4_before_no,  
    cell1_after_no, cell2_after_no, cell3_after_no,cell4_after_no, aoi_diff ]
    states.append(row)




f = open('./stats/stats_cells_file.csv', 'w')
writer = csv.writer(f)
for row in states:
    writer.writerow(row)
f.close()