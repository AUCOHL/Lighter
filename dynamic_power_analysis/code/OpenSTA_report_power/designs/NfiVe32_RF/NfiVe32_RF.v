


module NfiVe32_RF (
	input			HCLK,							// System clock
	input			WR,
	input [ 4:0]	RA,
	input [ 4:0]	RB,
	input [ 4:0]	RW,
	input [31:0]	DW, 
	output [31:0]	DA, 
	output [31:0]	DB
);
 	reg [31:0] RF [31:0];

	assign DA = RF[RA] & {32{~(RA==5'd0)}};
	assign DB = RF[RB] & {32{~(RB==5'd0)}};
	
	always @ (posedge HCLK) 
		if(WR)
			if(RW!=5'd0) begin 
				RF[RW] <= DW;
				//#1 $display("Write: RF[%d]=0x%X []", RW, RF[RW]);
			end
endmodule







//read_verilog ula/ula.v
//read_verilog blackbox_clk_gates.v

//hierarchy -check -top ula
//proc;
//opt;; 

//synth -top ula
//dfflibmap -liberty sky130_hd.lib 
//abc -D 1250 -liberty sky130_hd.lib 
//splitnets
//opt_clean -purge

//write_verilog -noattr -noexpr -nohex -nodec -defparam   ula/before_gl.v



//read_verilog vm80a/vm80a.v
//read_verilog blackbox_clk_gates.v

//hierarchy -check -top vm80a
//proc;
//opt;; 

//synth -top vm80a
//dfflibmap -liberty sky130_hd.lib 
//abc -D 1250 -liberty sky130_hd.lib 
//splitnets
//opt_clean -purge

//write_verilog -noattr -noexpr -nohex -nodec -defparam   vm80a/before_gl.v




//read_verilog xtea/xtea.v
//read_verilog blackbox_clk_gates.v

//hierarchy -check -top xtea
//proc;
//opt;; 

//synth -top xtea
//dfflibmap -liberty sky130_hd.lib 
//abc -D 1250 -liberty sky130_hd.lib 
//splitnets
//opt_clean -purge

//write_verilog -noattr -noexpr -nohex -nodec -defparam   xtea/before_gl.v



//read_verilog y_huff/y_huff.v
//read_verilog blackbox_clk_gates.v

//hierarchy -check -top y_huff
//proc;
//opt;; 

//synth -top y_huff
//dfflibmap -liberty sky130_hd.lib 
//abc -D 1250 -liberty sky130_hd.lib 
//splitnets
//opt_clean -purge

//write_verilog -noattr -noexpr -nohex -nodec -defparam   y_huff/before_gl.v




//read_verilog y_quantizer/y_quantizer.v
//read_verilog blackbox_clk_gates.v

//hierarchy -check -top y_quantizer
//proc;
//opt;; 

//synth -top y_quantizer
//dfflibmap -liberty sky130_hd.lib 
//abc -D 1250 -liberty sky130_hd.lib 
//splitnets
//opt_clean -purge

//write_verilog -noattr -noexpr -nohex -nodec -defparam   y_quantizer/before_gl.v



//read_verilog zigzag/zigzag.v
//read_verilog blackbox_clk_gates.v

//hierarchy -check -top zigzag
//proc;
//opt;; 

//synth -top zigzag
//dfflibmap -liberty sky130_hd.lib 
//abc -D 1250 -liberty sky130_hd.lib 
//splitnets
//opt_clean -purge

//write_verilog -noattr -noexpr -nohex -nodec -defparam   zigzag/before_gl.v



//read_verilog zipdiv/zipdiv.v
//read_verilog blackbox_clk_gates.v

//hierarchy -check -top zipdiv
//proc;
//opt;; 

//synth -top zipdiv
//dfflibmap -liberty sky130_hd.lib 
//abc -D 1250 -liberty sky130_hd.lib 
//splitnets
//opt_clean -purge

//write_verilog -noattr -noexpr -nohex -nodec -defparam   zipdiv/before_gl.v
