import os


#dir_list = ["aes156", "blabla", "chacha", "ldpc_decoder_802_3an",
#"ldpcenc", "sp_mul", "PPU","3des", "sbox", "ula", "vm80a", "xtea",
# "y_huff", "y_quantizer", "zigzag", "zipdiv", "y_dct", "jpeg_encoder", "aes_cipher","sha512", "picorv32a", "riscv_top_151"] 


dir_list = ["rv32cpu"]

#genericfir fires an error 6. Executing PROC_INIT pass (extract init attributes).
#Found init rule in `$paramod$75d9adb446428879bf1d097f1d2f41fbd2dcad71\firtap.$proc$genericfir/genericfir.v:0$21'.
#ERROR: Failed to get a constant init value for \genblk1.tap: $1\genblk1.tap[11:0]

for test in dir_list:
    print(test)
    command_list = []
    with open("./synth.tcl", "w") as f:
        
        f.write(
            '''
yosys -import
set design ''' + test + '''
puts "in tcl $design"
read_verilog $design/$design.v
hierarchy -check -top $design
proc_clean
proc_rmdead
proc_init
proc_arst
proc_mux
proc_dlatch
proc_dff
proc_clean

opt;; 
memory_collect
memory_map
opt;; 
synth -top $design
dfflibmap -liberty sky130_hd.lib 
abc -D 1250 -liberty sky130_hd.lib 
splitnets
opt_clean -purge
hilomap -hicell sky130_fd_sc_hd__conb_1 HI -locell sky130_fd_sc_hd__conb_1 LO
splitnets
opt_clean -purge
insbuf -buf sky130_fd_sc_hd__buf_2 A X
dffinit
opt;; 
write_verilog -noattr -noexpr -nohex -nodec -defparam   $design/before_gl.v
            '''
        )


    os.system("yosys ./synth.tcl" )

    with open("./synth2.tcl", "w") as f:
        
        f.write(
            '''
yosys -import
set design ''' + test + '''
puts "in tcl $design"
read_verilog $design/$design.v
read_verilog blackbox_clk_gates.v
hierarchy -check -top $design
proc_clean
proc_rmdead
proc_init
proc_arst
proc_mux
proc_dlatch
proc_dff
proc_clean

opt;; 
memory_collect
memory_map
techmap -map map_file.v;;
opt;; 

synth -top $design
dfflibmap -liberty sky130_hd.lib 
abc -D 1250 -liberty sky130_hd.lib 
splitnets
opt_clean -purge
hilomap -hicell sky130_fd_sc_hd__conb_1 HI -locell sky130_fd_sc_hd__conb_1 LO
splitnets
opt_clean -purge
insbuf -buf sky130_fd_sc_hd__buf_2 A X
dffinit
opt;; 
write_verilog -noattr -noexpr -nohex -nodec -defparam   $design/after_gl.v
            '''
        )


    os.system("yosys ./synth2.tcl" )


