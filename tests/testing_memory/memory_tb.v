// file: NfiVe32_RF_tb.v
// author: @youssefkandil
// Testbench for NfiVe32_RF

`define FUNCTIONAL
`define UNIT_DELAY #1
`include "primitives.v"
`include "sky130_hd.v"
`timescale 1ns/1ns


module NfiVe32_RF_tb;
	// Declarations
	reg  HCLK;
	reg  WR;
	reg [4:0]  RA;
	reg [4:0]  RB;
	reg [4:0]  RW;
	reg [31:0]  DW;
	wire [31:0]  DA;
	wire [31:0]  DB;

	// Instantiation of Unit Under Test
	NfiVe32_RF uut (
		.HCLK(HCLK),
		.WR(WR),
		.RA(RA),
		.RB(RB),
		.RW(RW),
		.DW(DW),
		.DA(DA),
		.DB(DB)
	);
	
	        initial begin
            $dumpfile("out2.vcd"); 
            // vcd dump file
            $dumpvars; 
            // dump everything

	end
	
	initial begin
	    HCLK =0;
	    //Inputs init:ialization
	   forever begin:   block1
        if (HCLK> 400)begin 
       disable block1;
       end
        else #(5) HCLK<=~HCLK;

       end


	end
	
	
	
	initial begin
		// Input Initialization
		WR = 1'b0;
		RA = 5'b00101;
		RB = 5'b01010;
		RW = 5'b00000;
		DW = 32'b0000000000000000000000000000000000000;
		#10;
		
		
		
		WR = 1'b1;
		RA = 5'b00101;
		RB = 5'b01010;
		RW =5'b00101;
		DW = 32'b00000000000000000000000001100100;
		#10;
		
		
		WR = 1'b1;
		RA = 5'b00101;
		RB = 5'b01010;
		RW = 5'b01010;
		DW = 32'b00000000000000000000000011001000;
		#10;
		
		
	    WR = 1'b1;
		RA =  5'b00101;
		RB =  5'b01010;
		RW = 5'b10100;
		DW = 32'b00000000000000000000001111100111;
		#10;
		
		
		
				
	  WR = 1'b0;
		RA = 5'b10100;
		RB = 5'b01010;
		RW = 5'b11110;
		DW = 32'b00000000000000000000001110000011;
		#10;
		// Reset
		#100;


end


endmodule