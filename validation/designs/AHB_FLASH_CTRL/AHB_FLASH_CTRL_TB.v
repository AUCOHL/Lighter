`define CHECK_W(X, T)  if(rdata == X) $display("Test %0d: passed", T); else $display("Test %0d: failed", T);
`define CHECK_H(X, T) if(rdata == X) $display("Test %0d: passed", T); else $display("Test %0d: failed", T);
`define CHECK_B(X, T)  if(rdata == X) $display("Test %0d: passed", T); else $display("Test %0d: failed", T);


module AHB_FLASH_CTRL_TB;
    reg  HCLK;
    reg  HRESETn;

    wire                    HREADY; 
    reg                     HWRITE;
    reg  [2:0]              HSIZE;
    reg  [1:0]              HTRANS;
    reg  [31:0]             HADDR, HWDATA;
    wire [31:0]             HRDATA; 
        
    wire [3:0]		fdi;
    wire [3:0]    	fdo;
    wire [3:0]      fdio;
    wire [3:0]	    fdoe;
    wire          	fsclk;
    wire          	fcen;


    
    always #5 HCLK = !HCLK;

    initial begin
        $dumpfile("ahb_flash_ctrl_tb.vcd");
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
    

    AHB_FLASH_CTRL #( .AW(SRAM_AW+2) ) MUV ( 
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

        .sck(fsclk),
        .ce_n(fcen),
        .din(fdi),
        .dout(fdo),
        .douten(fdoe)     
);   


    /* Program Flash */
    assign fdio[0] = fdoe[0] ? fdo[0] : 1'bz;
    assign fdio[1] = fdoe[1] ? fdo[1] : 1'bz;
    assign fdio[2] = fdoe[2] ? fdo[2] : 1'bz;
    assign fdio[3] = fdoe[3] ? fdo[3] : 1'bz;

    assign fdi = fdio;

    sst26wf080b FLASH(
        .SCK(fsclk),
        .SIO(fdio),
        .CEb(fcen)
    );

    initial begin
        #1  $readmemh("flash.hex", FLASH.I0.memory);
    end


`include "AHB_tasks.vh"

// test case
reg [31:0] rdata;
initial begin
    @(posedge HRESETn);
    #200;
    AHB_READ_WORD(32'h0000_0000, rdata);
    #25;
    `CHECK_W(32'haa_aa_aa_00, 1);
    #25;
    AHB_READ_WORD(32'h0000_0004, rdata);
    #25;
    `CHECK_W(32'hbb_bb_bb_01, 2);
    #25;
    AHB_READ_WORD(32'h0000_000C, rdata);
    #25;
    `CHECK_W(32'hdd_dd_dd_03, 3);
    #25;
    AHB_READ_WORD(32'h0000_0014, rdata);
    #25;
    `CHECK_W(32'hff_ff_ff_05, 4);
    #25;
    $finish;
end

endmodule

