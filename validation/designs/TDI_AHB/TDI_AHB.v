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
//`define                     VERIFY

`timescale                  1ns/1ps
`default_nettype            none

`include "designs/TDI_AHB/ahb_util.vh"

`define     SYNC_BEGIN(r, v)  always @ (posedge HCLK or negedge HRESETn) if(!HRESETn) r <= v; else begin
`define     SYNC_END          end

/*
    Two-wire Debugging Interface (TDI) w/ AHB-Lite Master Interface
    Supported commands:
        CMD     OpCode      Payload         Response
        ---     ------      -------         --------
        PING    0xA1        N/A             1 byte = 0x81
        CYCLES  0xA2        N/A             Cycles/SCK (16 bit)
        HALT    0xA4        N/A             1 byte = 0x01
        RESUME  0xA5        N/A             1 byte = 0x01
        RESET   0xA6        N/A             1 byte = 0x01
        READ    0xA8        A (32 bit)      D (32 bit)
        WRITE   0xA9        A+D (64 bit)    N/A
*/

module TDI_AHB(
    input  wire SCK,
    input  wire SDI,
    output wire SDO,
    output wire SDOE,

    input wire  HCLK,
    input wire  HRESETn,

    `AHB_MASTER_IFC(),

    output wire HALT,
    output wire RSTn
);
    localparam  CMD_PING    = 8'hA1,
                CMD_CYCLES  = 8'hA2,
                CMD_HALT    = 8'hA4,
                CMD_RESUME  = 8'hA5,
                CMD_RESET   = 8'hA6,
                CMD_READ    = 8'hA8,
                CMD_WRITE   = 8'hA9;

    localparam  ST_CMD      = 16'b0000_0000_0001,
                ST_PING     = 16'b0000_0000_0010,
                ST_CYCLES   = 16'b0000_0000_0100,
                ST_HALT     = 16'b0000_0000_1000,
                ST_RESUME   = 16'b0000_0001_0000,
                ST_WA       = 16'b0000_0010_0000,
                ST_WD       = 16'b0000_0100_0000,
                ST_RA       = 16'b0000_1000_0000,
                ST_RD       = 16'b0001_0000_0000,
                ST_RST      = 16'b0010_0000_0000;
                
    reg [15:0]  state, 
                nstate;

    wire [31:0] DATA;
    wire        BRCK, BWCK;
    reg [7:0]   bit_cntr;

    wire [7:0]  PONG = 8'h81;
    reg [15:0]  CYCLES;
    reg [31:0]  shifter;

    reg [31:0] RDATA;

    wire [7:0]  CMD = DATA[31:24];

    RX Rec (
        .HCLK(HCLK),
        .HRESETn(HRESETn),
        .SCK(SCK),
        .SDI(SDI),
        .DATA(DATA),
        .BRCK(BRCK),
        .BWCK(BWCK)
    );

    // cyclees counter
    always @(posedge HCLK or negedge HRESETn)
        if(!HRESETn)
            CYCLES <= 16'h0;
        else if(BRCK & (bit_cntr == 8'd6))
            CYCLES <= 16'h0;
        else if( (state == ST_CMD) && (bit_cntr == 8'd7) )
            CYCLES <= CYCLES + 8'd1;

    // Bit Counter
    reg [7:0] bit_cntr_next;
    always @* begin
        if(BRCK) bit_cntr_next = bit_cntr_next + 1'd1; else bit_cntr_next = bit_cntr;
        case(bit_cntr)
            8'd8:   if(state == ST_CMD) bit_cntr_next = 8'd0;
                    else if(state == ST_PING) bit_cntr_next = 8'd0;
                    else if(state == ST_HALT) bit_cntr_next = 8'd0;
                    else if(state == ST_RESUME) bit_cntr_next = 8'd0;
                    else if(state == ST_RST) bit_cntr_next = 8'd0;
            8'd16:  if(state == ST_CYCLES) bit_cntr_next = 8'd0;
            8'd32:  if(state == ST_RA) bit_cntr_next = 8'd0;
                    else if(state == ST_RD) bit_cntr_next = 8'd0;
                    else if(state == ST_WA) bit_cntr_next = 8'd0;
                    else if(state == ST_WD) bit_cntr_next = 8'd0;
            default:
                bit_cntr_next = bit_cntr;
        endcase
    end 

    always @(posedge HCLK or negedge HRESETn)
        if(!HRESETn)
            bit_cntr <= 8'h0;
        else
            bit_cntr <= bit_cntr_next;

    // FSM
    always @(posedge HCLK or negedge HRESETn)
        if(!HRESETn)
            state <= ST_CMD;
        else
            state <= nstate;

    always @*
        case(state)
            // CMD
            ST_CMD:    if(bit_cntr == 8'd8) begin
                            if(DATA[31:24] == CMD_PING) nstate = ST_PING; 
                            else if(DATA[31:24] == CMD_HALT) nstate = ST_HALT;
                            else if(DATA[31:24] == CMD_RESUME) nstate = ST_RESUME;
                            else if(DATA[31:24] == CMD_CYCLES) nstate = ST_CYCLES; 
                            else if(DATA[31:24] == CMD_WRITE) nstate = ST_WA; 
                            else if(DATA[31:24] == CMD_READ) nstate = ST_RA;
                            else if(DATA[31:24] == CMD_RESET) nstate = ST_RST; 
                        end else 
                            nstate = ST_CMD; 
            // PING
            ST_PING:    if(bit_cntr == 8'd8) nstate = ST_CMD; else nstate = ST_PING;
            // CYCLES
            ST_CYCLES:  if(bit_cntr == 8'd16) nstate = ST_CMD; else nstate = ST_CYCLES;
            // HALT
            ST_HALT:    if(bit_cntr == 8'd8) nstate = ST_CMD; else nstate = ST_HALT;
            // RESUME
            ST_RESUME:    if(bit_cntr == 8'd8) nstate = ST_CMD; else nstate = ST_RESUME;
            // Write (A)
            ST_WA:      if(bit_cntr == 8'd32) nstate = ST_WD; else nstate = ST_WA;
            // Write (D)
            ST_WD:      if(bit_cntr == 8'd32) nstate = ST_CMD; else nstate = ST_WD;
            // READ (A)
            ST_RA:      if(bit_cntr == 8'd32) nstate = ST_RD; else nstate = ST_RA;
            // READ (D)
            ST_RD:      if(bit_cntr == 8'd32) nstate = ST_CMD; else nstate = ST_RD;
            // RESET
            ST_RST:     if(bit_cntr == 8'd8) nstate = ST_CMD; else nstate = ST_RST;

            default: 
                nstate= state;

        endcase    

    // Transmitter (SDO) Logic
    // The shift register
    always @(posedge HCLK or negedge HRESETn)
        if(!HRESETn)
            shifter <= 32'h0;
        else
            if( (state == ST_CMD) && (bit_cntr == 8'h8) ) begin
                case (CMD)
                    CMD_PING    :   shifter <= PONG;
                    CMD_CYCLES  :   shifter <= CYCLES;
                    CMD_HALT    :   shifter <= 'h1;
                    CMD_RESUME  :   shifter <= 'h1;
                    CMD_RESET   :   shifter <= 'h1;
                    
                endcase
            end 
            else if( (state == ST_RD) && (bit_cntr == 8'h0) && BWCK ) 
                    shifter <= HRDATA;
            else if(BWCK && (bit_cntr != 'h0)) 
                    if( (state == ST_PING) || (state == ST_CYCLES) || (state == ST_HALT) || (state == ST_RESUME) || (state == ST_RD)) 
                        shifter <= shifter >> 1;
                    
    assign SDO = shifter[0];
    assign SDOE=    (state == ST_PING) ||
                    (state == ST_CYCLES) ||
                    (state == ST_HALT) ||
                    (state == ST_RESUME) ||
                    (state == ST_RST) ||
                    (state == ST_RD);

    // HALT
    reg halt;
    `SYNC_BEGIN(halt, 1'b0)
        if((state == ST_HALT) && (bit_cntr == 'h8))
            halt <= 1'b1;
        else if((state == ST_RESUME) && (bit_cntr == 'h8))
            halt <= 1'b0;
    `SYNC_END

    assign HALT = halt;

    // RSTn
    reg rstn;
    `SYNC_BEGIN(rstn, 1'b1)
        if((state == ST_RST) && (bit_cntr == 'h0))
            rstn <= 1'b0;
        else if((state == ST_RST) && (bit_cntr == 'h8))
            rstn <= 1'b1;    
    `SYNC_END

    assign RSTn = rstn;

    // AHB Master Interface Logic
    reg [31:0] WADDR;
    `SYNC_BEGIN(WADDR, 32'b0)
        if((state == ST_WA) && ( bit_cntr == 8'd32))
            WADDR <= DATA;
    `SYNC_END

    assign HADDR = (state == ST_WD) ? WADDR : DATA;
    assign HWRITE = (state == ST_WD);
    assign HWDATA = DATA;
    assign HTRANS[0] = 1'b0;
    assign HTRANS[1] = (((state == ST_WD) || (state == ST_RA)) && ( bit_cntr == 8'd32));
    assign HSIZE = 3'b010;


endmodule


module RX (
    input wire          HCLK,
    input wire          HRESETn,
    input wire          SCK,
    input wire          SDI,

    output wire [31:0]  DATA,
    output wire         BRCK,
    output wire         BWCK
);

    localparam  ST_S0 = 4'b0001,
                ST_S1 = 4'b0010,
                ST_S2 = 4'b0100,
                ST_S3 = 4'b1000;

    reg [3:0] state, nstate;

    // Synchronizers
    reg [1:0] sdi_sync;        
    `SYNC_BEGIN(sdi_sync, 2'h0)
        sdi_sync <= {sdi_sync[0], SDI};
    `SYNC_END

    reg [1:0] sck_sync;        
    `SYNC_BEGIN(sck_sync, 2'h3)
        sck_sync <= {sck_sync[0], SCK};
    `SYNC_END

    wire SDI_SYNC = sdi_sync[1];
    wire SCK_SYNC = sck_sync[1];

    // Edge detector
    `SYNC_BEGIN(state, ST_S0)
        state <= nstate;
    `SYNC_END

    always @*
        case(state)
            ST_S0: if(SCK_SYNC) nstate = ST_S0; else nstate = ST_S1;
            ST_S1: nstate = ST_S2; 
            ST_S2: if(SCK_SYNC) nstate = ST_S3; else nstate = ST_S2;
            ST_S3: nstate = ST_S0; 
            default:
                nstate= state;
        endcase

    // Shift Register
    reg [31:0] shifter;
    `SYNC_BEGIN(shifter, 'h0)
        if((state == ST_S1) /*&& (SCK_SYNC == 1'b1)*/) shifter <= {SDI_SYNC, shifter[31:1]};
    `SYNC_END

    assign DATA = shifter;
    assign BRCK = (state == ST_S3);
    assign BWCK = (state == ST_S1);
    

endmodule

