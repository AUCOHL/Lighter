

if { $::argc > 0 } {
    puts "no command line argument passed"
    set i 1
    foreach arg $::argv {
        puts "argument $i is $arg"

        set design $arg
        puts "$design"
        read_verilog $design/$design.v

        hierarchy -check -top $design
        proc;
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
        #hilomap -hicell "sky130_fd_sc_hd__conb_1 HI" -locell "sky130_fd_sc_hd__conb_1 LO" 
        splitnets
        opt_clean -purge
        insbuf -buf sky130_fd_sc_hd__buf_2 A X
        dffinit
        opt;; 
        write_verilog -noattr -noexpr -nohex -nodec -defparam   $design/before_gl.v

        incr i
    }
} else {
    puts "no command line argument passed"
}
