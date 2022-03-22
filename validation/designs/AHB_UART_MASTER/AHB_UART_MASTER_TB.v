/*
	Copyright 2021 Mohamed Shalan
	
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
    A testbench for the AHB_UART_MASTER and AHB_FLASH_WRITER IPs
    The testbench perform read and write operations from/to a 
    QSPI flash memory.

    The testbench reads the device JEDEC ID and prints it out.
    The provided tasks can be converted into PYTHON code to talk
    to the flash memory when the IP is implemented ASIC/FPGA.
*/

`timescale              1ns/1ps
`default_nettype        none

module AHB_UART_MASTER_TB;

    localparam  WE_OFF = 0,
                SS_OFF = 4,
                SCK_OFF= 8,
                OE_OFF = 12,
                SO_OFF = 16,
                SI_OFF = 20;

    reg  HCLK;
    reg  HRESETn;
    
    //APB Outputs
    wire        PREADY;
    wire [31:0] PRDATA;

    //Serial Port Signals
    wire        RX;  // From UART to TB 
    reg         TX;  // From TB to UART

    always #5 HCLK = !HCLK;

    initial begin
        $dumpfile("uart_ahb_master_tb.vcd");
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
    
    // Test Case
    reg[32:0] data;
    initial begin
        TX = 1;
        #2000;
        
        // READ the Flash Writer Magic Number
        FW_RD(24, data);
        #200;

        // READ The JEDEC ID
        FW_ENABLE;
        SPI_OE(4'b0001);
        SPI_STATRT;
        SPI_BYTE_WR(8'h9F);
        SPI_BYTE_RD(data);
        $display("JEDEC Byte 0:%x", data);
        SPI_BYTE_RD(data);
        $display("JEDEC Byte 1:%x", data);
        SPI_BYTE_RD(data);
        $display("JEDEC Byte 2:%x", data);
        SPI_STOP;
        #400;

        // Write few bytes
        FLASH_WEN;
        FLASH_PROT_UNLK;
        FLASH_WEN;
        #25_000;
        FLASH_CHIP_ERASE;
        #25_000;
        FLASH_WEN;
        FLASH_BYTE_PROG(24'h0, 8'hA);
        FLASH_BYTE_PROG(24'h0, 8'hB);
        FLASH_BYTE_PROG(24'h0, 8'hC);
        FLASH_BYTE_PROG(24'h0, 8'hD);
        FLASH_WDI;
        
        $finish;
    end

    wire        HREADY, HWRITE;
    wire [2:0]  HSIZE;
    wire [1:0]  HTRANS;
    wire [31:0] HADDR, HRDATA, HWDATA;

    wire        fm_ce_n,fm_sck;
    wire [3:0]  SIO; 
    wire [3:0]  fm_din, fm_dout,fm_douten;

    // baud rate = 1228800
    AHB_UART_MASTER #(.PRESCALE(4)) UM(
        .HCLK(HCLK),
        .HRESETn(HRESETn),

        .HREADY(HREADY),
        .HWDATA(HWDATA),
        .HRDATA(HRDATA),
        .HSIZE(HSIZE),
        .HWRITE(HWRITE),
        .HTRANS(HTRANS),
        .HADDR(HADDR),

        .RX(TX),
        .TX(RX)
    );

    AHB_FLASH_WRITER FW (
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
        
        // FLASH Interface
        .fm_sck(fm_sck),
        .fm_ce_n(fm_ce_n),
        .fm_din(fm_din),
        .fm_dout(fm_dout),
        .fm_douten(fm_douten)
);

    assign fm_din = SIO;

    assign SIO[0] = fm_douten[0] ? fm_dout[0] : 1'bz;
    assign SIO[1] = fm_douten[1] ? fm_dout[1] : 1'bz;
    assign SIO[2] = fm_douten[2] ? fm_dout[2] : 1'bz;
    assign SIO[3] = fm_douten[3] ? fm_dout[3] : 1'bz;
     
    sst26wf080b FLASH (.SCK(fm_sck),.SIO(SIO),.CEb(fm_ce_n));
    defparam FLASH.I0.Tsce = 25_000;

    // Enable this if you want to monitor the data being sent to the UART
    //UART_MON MON (.RX(TX));

    // Baud rate 1228800
    // Bit time ~ 813.8ns
    // 8N1
    localparam BITTIME = 813.8;
    task UART_SEND (input [7:0] data);
        begin : task_body
            integer i;
            #BITTIME;
            @(posedge HCLK);
            TX = 0;
            #BITTIME;
            for(i=0; i<8; i=i+1) begin
                TX = data[i];
                #BITTIME;
            end
            TX = 1;
            //#BITTIME;
        end
    endtask

    task UART_REC (output [7:0] data);
        begin : task_body
            integer i;
            @(negedge RX);
            #(BITTIME+(BITTIME/2));
            for(i=0; i<8; i=i+1) begin
                data[i] = RX;
                #BITTIME;
            end
        end
    endtask

    task FW_WR(input [31:0] A, input [31:0] D);
        begin
            UART_SEND(8'hA3);
            UART_SEND(A[7:0]);
            UART_SEND(A[15:8]);
            UART_SEND(A[23:16]);
            UART_SEND(A[31:24]);
            UART_SEND(D[7:0]);
            UART_SEND(D[15:8]);
            UART_SEND(D[23:16]);
            UART_SEND(D[31:24]);
        end
    endtask

    task FW_RD(input [31:0] A, output [31:0] D);
        begin
            UART_SEND(8'hA5);
            UART_SEND(A[7:0]);
            UART_SEND(A[15:8]);
            UART_SEND(A[23:16]);
            UART_SEND(A[31:24]);
            UART_REC(D[7:0]);
            UART_REC(D[15:8]);
            UART_REC(D[23:16]);
            UART_REC(D[31:24]);
        end
    endtask

    task SPI_STATRT;
        FW_WR(SS_OFF, 0);
    endtask

    task SPI_STOP;
        FW_WR(SS_OFF, 1);
    endtask

    task SPI_OE(input [3:0] data);
        FW_WR(OE_OFF, data);
    endtask

    task FW_ENABLE;
        FW_WR(WE_OFF,32'hA5A85501);
    endtask

    task SPI_BYTE_WR(input [7:0] data);
        begin : task_body
            integer i;
            for(i=7; i>=0; i=i-1) begin
                FW_WR(SO_OFF, data[i]);
                FW_WR(SCK_OFF, 1);
                FW_WR(SCK_OFF, 0);
            end
        end
    endtask

    task SPI_WORD_WR(input [32:0] data);
        begin 
            SPI_BYTE_WR(data[7:0]);
            SPI_BYTE_WR(data[15:8]);
            SPI_BYTE_WR(data[23:16]);
            SPI_BYTE_WR(data[31:24]);
        end
    endtask

    task SPI_BYTE_RD(output [7:0] data);
        begin : task_body
            integer i;
            reg [31:0] word;
            for(i=7; i>=0; i=i-1) begin
                FW_WR(SCK_OFF, 1);
                FW_RD(SI_OFF, word);
                data[i] = word[0];
                FW_WR(SCK_OFF, 0);
            end
        end
    endtask

    task FLASH_WEN;
        begin : task_body
            SPI_OE(4'b0001);
            SPI_STATRT;
            SPI_BYTE_WR(8'h06); // write enable
            SPI_STOP;
        end
    endtask

    task FLASH_PROT_UNLK;
        begin : task_body
            SPI_OE(4'b0001);
            SPI_STATRT;
            SPI_BYTE_WR(8'h98); // global protection unlock
            SPI_STOP;
        end
    endtask

    task FLASH_WDI;
        begin : task_body
            SPI_OE(4'b0001);
            SPI_STATRT;
            SPI_BYTE_WR(8'h04);
            SPI_STOP;
        end
    endtask
    
    task FLASH_CHIP_ERASE;
        begin : task_body
            SPI_OE(4'b0001);
            SPI_STATRT;
            SPI_BYTE_WR(8'hC7);
            SPI_STOP;
        end
    endtask

    // Page program
    // Re-implement
    task FLASH_BYTE_PROG(input[23:0] A, input[7:0] D);
        begin : task_body
            SPI_OE(4'b0001);
            SPI_STATRT;
            SPI_BYTE_WR(8'h02);
            SPI_BYTE_WR(A[23:16]);
            SPI_BYTE_WR(A[15:8]);
            SPI_BYTE_WR(A[7:0]);
            SPI_BYTE_WR(D);
            SPI_STOP;
        end
    endtask

endmodule



module UART_MON #(parameter BITTIME=813.8)(input RX);
    reg [7:0] data;
    integer i;
    initial begin
        forever begin
            @(negedge RX);
            #BITTIME;
            for(i=0; i<8; i=i+1) begin
                data = {RX, data[7:1]};
                #BITTIME;
            end
            #BITTIME;
            // Enable one of the following lines to display the monitored data
            //$write("%c", data);
            $display("0x%X", data);
        end
    end

endmodule

