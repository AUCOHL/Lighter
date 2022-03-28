/*

	Copyright 2020 Mohamed Shalan
	
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

`timescale              1ns/1ps
`default_nettype        none

/*
	Copyright 2020 Mohamed Shalan

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









































































































































































/*
    Refactored version of the FLASH Controller
    Don't change the LINE_SIZE
*/
module AHB_FLASH_CTRL #(parameter LINE_SIZE=128, NUM_LINES=32) (
    input               HCLK,
    input               HRESETn,

    // AHB-Lite Slave Interface
    
    input wire          HSEL,
    input wire [31:0]   HADDR,
    input wire [1:0]    HTRANS,
    input wire          HWRITE,
    input wire          HREADY,
    input wire [31:0]   HWDATA,
    input wire [2:0]    HSIZE,
    output wire         HREADYOUT,
    output wire [31:0]  HRDATA,
    
    // External Interface to Quad I/O
    output              sck,
    output              ce_n,
    input   wire [3:0]  din,
    output  wire [3:0]  dout,
    output  wire [3:0]  douten     
);

    wire [23:0]             fr_addr, addr_0;
    wire                    fr_rd, rd_0;
    wire                    fr_done, done_0;
    wire [LINE_SIZE-1: 0]   fr_line, line_0;

    wire                    oe;


    AHB_FLASH_CACHE_CTRL #( .LINE_SIZE(LINE_SIZE), 
                            .NUM_LINES(NUM_LINES) ) 
        CCTRL (
            // AHB-Lite Slave Interface
            .HCLK(HCLK),
            .HRESETn(HRESETn),
            .HSEL(HSEL),
            .HADDR(HADDR),
            .HTRANS(HTRANS),
            .HWRITE(HWRITE),
            .HREADY(HREADY),
            .HREADYOUT(HREADYOUT),
            .HRDATA(HRDATA),

            // The Flash Reader Interface
            .fr_addr(fr_addr),
            .fr_rd(fr_rd),
            .fr_done(fr_done),
            .fr_line(fr_line)
    );

    FLASH_READER #( .LINE_SIZE(LINE_SIZE)) 
        FR (
            .clk(HCLK),
            .rst_n(HRESETn),
            .addr(fr_addr),
            .rd(fr_rd),
            .done(fr_done),
            .line(fr_line),    

            .sck(sck),
            .ce_n(ce_n),
            .din(din),
            .dout(dout),
            .douten(oe)
    );

    assign douten = {4{oe}};

endmodule


/* AHB Cache Controller w/ an integrated parmetrized RO Cache */
module AHB_FLASH_CACHE_CTRL #(parameter LINE_SIZE=128, NUM_LINES=32)(
    // AHB-Lite Slave Interface
    input                           HCLK,
    input                           HRESETn,
    input                           HSEL,
    input   wire [31:0]             HADDR,
    input   wire [1:0]              HTRANS,
    input   wire                    HWRITE,
    input   wire                    HREADY,
    output  reg                     HREADYOUT,
    output  wire [31:0]             HRDATA,

    // The Flash Reader Interface
    output  wire [23:0]             fr_addr,
    output  wire                    fr_rd,
    input   wire                    fr_done,
    input   wire [LINE_SIZE-1: 0]   fr_line
);

    // The State Machine
    localparam [1:0] st_idle    = 2'b00;
    localparam [1:0] st_wait    = 2'b01;
    localparam [1:0] st_rw      = 2'b10;
    reg [1:0]   state, nstate;

    // Cache wires/buses
    wire [31:0]     c_datao;
    wire [23:0]     c_A;
    wire            c_hit;
    reg  [1:0]      c_wr;
    
    //AHB-Lite Address Phase Regs
    reg             last_HSEL;
    reg [31:0]      last_HADDR;
    reg             last_HWRITE;
    reg [1:0]       last_HTRANS;

    // AHB Interface lgic
    always@ (posedge HCLK) begin
        if(HREADY) begin
            last_HSEL       <= HSEL;
            last_HADDR      <= HADDR;
            last_HWRITE     <= HWRITE;
            last_HTRANS     <= HTRANS;
        end
    end

    assign HRDATA   = c_datao;

    always @(posedge HCLK or negedge HRESETn)
        if(!HRESETn) HREADYOUT <= 1'b1;
        else
            case (state)
                st_idle :   if(HTRANS[1] & HSEL & HREADY & c_hit) HREADYOUT <= 1'b1;
                            else if(HTRANS[1] & HSEL & HREADY & ~c_hit) HREADYOUT <= 1'b0;
                            else HREADYOUT <= 1'b1;
                st_wait :   if(c_wr[1]) HREADYOUT <= 1'b1;
                            else HREADYOUT <= 1'b0;
                st_rw   :   if(HTRANS[1] & HSEL & HREADY & c_hit) HREADYOUT <= 1'b1;
                            else if(HTRANS[1] & HSEL & HREADY & ~c_hit) HREADYOUT <= 1'b0;
                            //else HREADYOUT <= 1'b1;
            endcase

    // The controller SM
    always @ (posedge HCLK or negedge HRESETn)
        if(HRESETn == 0) state <= st_idle;
        else 
            state <= nstate;

    always @* begin
        nstate = st_idle;
        case(state)
            st_idle :   if(HTRANS[1] & HSEL & HREADY & c_hit) nstate = st_rw;
                        else if(HTRANS[1] & HSEL & HREADY & ~c_hit) nstate = st_wait;
            st_wait :   if(c_wr[1]) nstate = st_rw; 
                        else  nstate = st_wait;
            st_rw   :   //nstate = st_idle; 
                        if(HTRANS[1] & HSEL & HREADY & c_hit) nstate = st_rw;
                        else if(HTRANS[1] & HSEL & HREADY & ~c_hit) nstate = st_wait;
        endcase
    end

    // The cache interface
    assign c_A  = last_HADDR[23:0];

    always @ (posedge HCLK) begin
        c_wr[0] <= fr_done;
        c_wr[1] <= c_wr[0];
    end

    DMC #(  .LINE_SIZE(LINE_SIZE), 
            .NUM_LINES(NUM_LINES) 
        ) 
        CACHE ( 
            .clk(HCLK), 
            .rst_n(HRESETn), 
            .A(last_HADDR[23:0]), 
            .A_h(HADDR[23:0]), 
            .Do(c_datao), 
            .hit(c_hit), 
            .line(fr_line), 
            .wr(c_wr[0])    // was 1
    );
        
    // The Flash Reader Interface
    assign fr_rd        =   ( HTRANS[1] & HSEL & HREADY & ~c_hit & (state==st_idle) ) |
                            ( HTRANS[1] & HSEL & HREADY & ~c_hit & (state==st_rw) );

    assign fr_addr      = {HADDR[23:4], 4'd0};
    
endmodule

/*
    RTL Model for reading from Quad I/O flash using the QUAD I/O FAST READ (0xEB) command
    The Quad I/O bit has to be set in the flash memory (through flash programming); the 
    provided flash memory model has the bit set.

    Every transaction reads 128 bits (16 bytes) from the flash.
    To start a transaction, provide the memory address and assert rd for 1 clock cycle.
    done is a sserted for 1 clock cycle when the data is ready

*/
module FLASH_READER #(parameter LINE_SIZE=128)(
    input   wire                    clk,
    input   wire                    rst_n,
    input   wire [23:0]             addr,
    input   wire                    rd,
    output  wire                    done,
    output  wire [LINE_SIZE-1: 0]   line,      

    output  reg                     sck,
    output  reg                     ce_n,
    input   wire[3:0]               din,
    output      [3:0]               dout,
    output  wire                    douten
);

    localparam LINE_BYTES = LINE_SIZE/8;
    localparam LINE_CYCLES = LINE_BYTES * 8;

    parameter IDLE=1'b0, READ=1'b1;

    reg         state, nstate;
    reg [7:0]   counter;
    reg [23:0]  saddr;
    reg [7:0]   data [LINE_BYTES-1 : 0]; 

    reg         first;

    wire[7:0]   EBH     = 8'heb;
    
    // for debugging
    wire [7:0] data_0 = data[0];
    wire [7:0] data_1 = data[1];
    wire [7:0] data_15 = data[15];


    always @*
        case (state)
            IDLE: if(rd) nstate = READ; else nstate = IDLE;
            READ: if(done) nstate = IDLE; else nstate = READ;
        endcase 

    always @ (posedge clk or negedge rst_n)
        if(!rst_n) first = 1'b1;
        else if(first & done) first <= 0;

    
    always @ (posedge clk or negedge rst_n)
        if(!rst_n) state = IDLE;
        else state <= nstate;

    always @ (posedge clk or negedge rst_n)
        if(!rst_n) sck <= 1'b0;
        else if(~ce_n) sck <= ~ sck;
        else if(state == IDLE) sck <= 1'b0;

    always @ (posedge clk or negedge rst_n)
        if(!rst_n) ce_n <= 1'b1;
        else if(state == READ) ce_n <= 1'b0;
        else ce_n <= 1'b1;

    always @ (posedge clk or negedge rst_n)
        if(!rst_n) counter <= 8'b0;
        else if(sck & ~done) counter <= counter + 1'b1;
        else if(state == IDLE) 
            if(first) counter <= 8'b0;
            else counter <= 8'd8;

    always @ (posedge clk or negedge rst_n)
        if(!rst_n) saddr <= 24'b0;
        else if((state == IDLE) && rd) saddr <= addr;

    always @ (posedge clk)
        if(counter >= 20 && counter <= 19+LINE_BYTES*2)
            if(sck) data[counter/2 - 10] <= {data[counter/2 - 10][3:0], din}; // Optimize!

    //assign busy = (state == READ);

    assign dout     =   (counter < 8)   ? EBH[7 - counter] :
                        (counter == 8)  ? saddr[23:20] : 
                        (counter == 9)  ? saddr[19:16] :
                        (counter == 10)  ? saddr[15:12] :
                        (counter == 11)  ? saddr[11:8] :
                        (counter == 12)  ? saddr[7:4] :
                        (counter == 13)  ? saddr[3:0] :
                        (counter == 14)  ? 4'hA :
                        (counter == 15)  ? 4'h5 : 4'h0;    
        
    assign douten   = (counter < 20);

    assign done     = (counter == 20+LINE_BYTES*2);  // was 19?!

    generate
        genvar i; 
        for(i=0; i<LINE_BYTES; i=i+1)
            assign line[i*8+7: i*8] = data[i];
    endgenerate

endmodule

/*
    Parametrized Direct Mapped Cache for Read Only memories (e.g., Flash)
    Supports any numer of lines (2^n; n: 8, 16, 32, ...): NUM_LINES
    Supports only 4-word (128) or 8-word (256) lines: LINE_SIZE
*/
module DMC #(parameter LINE_SIZE=128, NUM_LINES=32)(
    input wire                  clk,
    input wire                  rst_n,
    // 
    input wire  [23:0]          A,
    input wire  [23:0]          A_h,
    output wire [31:0]          Do,
    output wire                 hit,
    //
    input wire [LINE_SIZE-1:0]  line,
    input wire                  wr
);

    localparam  NUM_WORDS       = LINE_SIZE/32;  
    localparam  NUM_BYTES       = LINE_SIZE/8;  
    localparam  OFFSET_WIDTH    = $clog2(NUM_BYTES);
    localparam  INDEX_WIDTH     = $clog2(NUM_LINES);
    localparam  TAG_WIDTH       = 24 + 3 - INDEX_WIDTH - OFFSET_WIDTH;
    
    // Cache storage
    reg [LINE_SIZE-1:0] LINES   [NUM_LINES-1:0];
    reg [TAG_WIDTH-1:0] TAGS    [NUM_LINES-1:0];
    reg                 VALID   [NUM_LINES-1:0];

    wire [OFFSET_WIDTH-1:0] offset  =   A[OFFSET_WIDTH-1:0];
    wire [OFFSET_WIDTH-1:2] woffset =   A[OFFSET_WIDTH-1:2];
    wire [INDEX_WIDTH-1:0]  index   =   A[OFFSET_WIDTH+INDEX_WIDTH-1:OFFSET_WIDTH];
    wire [TAG_WIDTH-1:0]    tag     =   A[23:OFFSET_WIDTH+INDEX_WIDTH];

    wire [INDEX_WIDTH-1:0]  index_h =   A_h[OFFSET_WIDTH+INDEX_WIDTH-1:OFFSET_WIDTH];
    wire [TAG_WIDTH-1:0]    tag_h   =   A_h[23:OFFSET_WIDTH+INDEX_WIDTH];

    assign  hit =   VALID[index_h] & (TAGS[index_h] == tag_h);

    wire [LINE_SIZE:0]    sel_line  =   LINES[index];

    generate
        if(NUM_WORDS == 4) begin
            assign  Do  =   (offset[3:2] == 2'd0) ?  sel_line[31:0]     :
                            (offset[3:2] == 2'd1) ?  sel_line[63:32]    :
                            (offset[3:2] == 2'd2) ?  sel_line[95:64]    :   sel_line[127:96];
        end else if (NUM_WORDS == 8) begin
            assign  Do  =   (offset[4:2] == 'd0) ?  sel_line[31:0]     :
                            (offset[4:2] == 'd1) ?  sel_line[63:32]    :
                            (offset[4:2] == 'd2) ?  sel_line[95:64]    :   
                            (offset[4:2] == 'd3) ?  sel_line[127:96]     :
                            (offset[4:2] == 'd4) ?  sel_line[159:128]    :
                            (offset[4:2] == 'd5) ?  sel_line[191:160]    :   
                            (offset[4:2] == 'd6) ?  sel_line[223:192]    :   sel_line[255:224];
        end
    endgenerate

    // clear the VALID flags
    integer i;
    always @ (posedge clk or negedge rst_n)
        if(!rst_n) 
            for(i=0; i<NUM_LINES; i=i+1)
                VALID[i] <= 1'b0;
        else  if(wr)  VALID[index]    <= 1'b1;

    always @(posedge clk)
        if(wr) begin
            LINES[index]    <= line;
            TAGS[index]     <= tag;
        end

endmodule