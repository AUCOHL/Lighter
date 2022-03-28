`define CHECK_W(X, T)  if(rdata == X) $display("Test %0d: passed", T); else $display("Test %0d: failed", T);
`define CHECK_H(X, T) if(rdata == X) $display("Test %0d: passed", T); else $display("Test %0d: failed", T);
`define CHECK_B(X, T)  if(rdata == X) $display("Test %0d: passed", T); else $display("Test %0d: failed", T);
`include "/Users/youssef/Desktop/EDA/Dynamic_Power_Clock_Gating/validation/designs/AHB_FLASH_CTRL/sky130_hd.v"
`include "/Users/youssef/Desktop/EDA/Dynamic_Power_Clock_Gating/validation/designs/AHB_FLASH_CTRL/primitives.v"



module sram32 #(parameter AW=10, VERBOSE=1) (
    input  wire         clk,
    input  wire         cs,
    input  wire [3:0]   we,
    input  wire [AW-1:0] A,
    input  wire [31:0]  Di,
    output reg  [31:0]  Do
);
    reg[31:0] ram[(2**AW)-1:0];
    always @(posedge clk)
        if(cs) begin
            Do <= ram[A];
            if(we[0]) ram[A][ 7: 0] <= Di[7:0];
            if(we[1]) ram[A][15:8] <= Di[15:8];
            if(we[2]) ram[A][23:16] <= Di[23:16];
            if(we[3]) ram[A][31:24] <= Di[31:24];
            if(VERBOSE==1) begin
                if(we==0) $display("SRAM READ from %0h data %0h", A, Do);
                else $display("SRAM Write (%0h):  %0h to %0h", we, Di, A);
            end
        end 
endmodule

module AHB_SRAM_TB;
    localparam SRAM_AW = 10;

    reg  HCLK;
    reg  HRESETn;

    wire                    HREADY; 
    reg                     HWRITE;
    reg  [2:0]              HSIZE;
    reg  [1:0]              HTRANS;
    reg  [31:0]             HADDR, HWDATA;
    wire [31:0]             HRDATA; 

    wire [31:0]             SRAMRDATA;  // SRAM Read Data
    wire [3:0]              SRAMWEN;    // SRAM write enable (active high)
    wire [31:0]             SRAMWDATA;  // SRAM write data
    wire                    SRAMCS;     // SRAM Chip Select (active high)
    wire [SRAM_AW-1:0]      SRAMADDR;    // SRAM address
        
    always #10 HCLK = !HCLK;

    initial begin
        $dumpfile("ahb_srm_tb.vcd");
        $dumpvars;
        # 45_000_000 $finish;
    end

    // RESET
    initial begin
        HCLK = 0;
        HRESETn = 1;
		#10;
		@(posedge HCLK);
		HRESETn = 0;
		#100;
		@(posedge HCLK);
		HRESETn = 1;
    end
    

    AHB_SRAM #( .AW(SRAM_AW+2) ) MUV ( 
        .HCLK(HCLK),
        .HRESETn(HRESETn),
    
        // AHB-Lite Slave Interface
        .HSEL(1'b1),
        .HREADYOUT(HREADY),
        .HREADY(HREADY),
        .HWDATA(HWDATA),
        .HRDATA(HRDATA),
        .HSIZE(HSIZE),
        .HWRITE(HWRITE),
        .HTRANS(HTRANS),
        .HADDR(HADDR),

        .SRAMRDATA(SRAMRDATA),
        .SRAMWEN(SRAMWEN),  
        .SRAMWDATA(SRAMWDATA),
        .SRAMCS(SRAMCS),   
        .SRAMADDR(SRAMADDR) 
);   


sram32 #( .AW(SRAM_AW), .VERBOSE(0) ) SRAM (
    .clk(HCLK),
    .cs(SRAMCS),
    .we(SRAMWEN),
    .A(SRAMADDR),
    .Di(SRAMWDATA),
    .Do(SRAMRDATA)
);

/*
	Copyright 2022 Mohamed Shalan
	
	Licensed under the Apache License, Version 2.0 (the "License"); 
	you may not use this file except in compliance with the License. 
	You may obtain a copy of the License at:
	http://www.apache.org/licenses/LICENSE-2.0
	Unless required by applicable law or agreed to in writing, software 
	distributed under the License is distributed on an "AS IS" BASIS, 
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
	See the License for the specific language governing permissions and 
	limitations under the License.
*/

task AHB_READ_WORD(input [31:0] ADDR, output [31:0] data);
    begin : task_body
        wait (HREADY == 1'b1);
        @(posedge HCLK);
        #1;
        HTRANS <= 2'b10;
        HWRITE <= 1'b0;
        HADDR <= ADDR;
        HSIZE <= 3'd2;
        @(posedge HCLK);
        #1;
        HTRANS <= 2'b00;
        wait (HREADY == 1'b1);
        @(posedge HCLK) data = HRDATA;
    end
endtask

task AHB_WRITE_WORD(input [31:0] ADDR, input [31:0] data);
    begin : task_body
        //wait (HREADY == 1'b1);
        @(posedge HCLK);
        #1;
        HTRANS <= 2'b10;
        HWRITE <= 1'b1;
        HADDR <= ADDR;
        HSIZE <= 3'd2;
        @(posedge HCLK);
        HTRANS <= 0;
        HWDATA <= data;
    end
endtask


task AHB_READ_HALF(input [31:0] ADDR, output [15:0] data);
    begin : task_body
        wait (HREADY == 1'b1);
        @(posedge HCLK);
        #1;
        HTRANS <= 2'b10;
        HWRITE <= 1'b0;
        HADDR <= ADDR;
        HSIZE <= 3'd1;
        @(posedge HCLK);
        #1;
        HTRANS <= 2'b00;
        wait (HREADY == 1'b1);
        @(posedge HCLK) data = HRDATA;
    end
endtask

task AHB_WRITE_HALF(input [31:0] ADDR, input [15:0] data);
    begin : task_body
        //wait (HREADY == 1'b1);
        @(posedge HCLK);
        #1;
        HTRANS <= 2'b10;
        HWRITE <= 1'b1;
        HADDR <= ADDR;
        HSIZE <= 3'd1;
        @(posedge HCLK);
        HTRANS <= 0;
        HWDATA <= data;
    end
endtask


task AHB_READ_BYTE(input [31:0] ADDR, output [7:0] data);
    begin : task_body
        wait (HREADY == 1'b1);
        @(posedge HCLK);
        #1;
        HTRANS <= 2'b10;
        HWRITE <= 1'b0;
        HADDR <= ADDR;
        HSIZE <= 3'd0;
        @(posedge HCLK);
        #1;
        HTRANS <= 2'b00;
        wait (HREADY == 1'b1);
        @(posedge HCLK) data = HRDATA;
    end
endtask

task AHB_WRITE_BYTE(input [31:0] ADDR, input [7:0] data);
    begin : task_body
        //wait (HREADY == 1'b1);
        @(posedge HCLK);
        #1;
        HTRANS <= 2'b10;
        HWRITE <= 1'b1;
        HADDR <= ADDR;
        HSIZE <= 3'd0;
        @(posedge HCLK);
        HTRANS <= 0;
        HWDATA <= data;
    end
endtask

task AHB_WRITE_READ_WORD(input [31:0] WADDR, input [31:0] RADDR, input [31:0] WDATA, output [31:0] RDATA);
    begin : task_body
        @(posedge HCLK);
        #1;
        HTRANS <= 2'b10;
        HWRITE <= 1'b1;
        HADDR <= WADDR;
        HSIZE <= 3'd2;
        @(posedge HCLK);
        #1;
        HTRANS <= 2'b10;
        HWRITE <= 1'b0;
        HADDR <= RADDR;
        HSIZE <= 3'd2;
        HWDATA <= WDATA;
        @(posedge HCLK);
        HTRANS <= 2'b00;
        @(posedge HCLK);
        RDATA = HRDATA;
    end
endtask

// test case
reg [31:0] rdata;
initial begin
    @(posedge HRESETn);
    #200;
    AHB_WRITE_WORD(32'h0000_0000, 32'h44_33_22_11);
    #25;
    AHB_READ_WORD(32'h0000_0000, rdata);
    #25;
    `CHECK_W(32'h44_33_22_11, 1);
    #25;
    AHB_READ_HALF(32'h0000_0000, rdata);
    #25;
    `CHECK_H(16'h22_11, 2);
    #25;
    AHB_READ_BYTE(32'h0000_0000, rdata);
    #25;
    `CHECK_B(8'h11, 3);
    #25;
    AHB_WRITE_WORD(32'h000F_FFF0, 32'hABCD_1234);
    #25;
    AHB_READ_WORD(32'h000F_FFF0, rdata);
    #25;
    `CHECK_W(32'hABCD_1234, 4);
    #100;
    // Read after write
    AHB_WRITE_READ_WORD(32'h0000_0A00, 32'h0000_0000, 32'hDEADBEEF, rdata);
    #100;
    AHB_READ_WORD(32'h0000_0A00, rdata);
    #25;
    `CHECK_W(32'hDEADBEEF, 5);
    $finish;
end

endmodule

