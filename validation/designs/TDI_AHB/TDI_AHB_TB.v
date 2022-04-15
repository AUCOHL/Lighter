`include "includes/tb_util.vh"
`include "includes/primitives.v"
`include "includes/sky130_hd.v"



module TDI_tb;

    reg HCLK, HRESETn, SCK, SDI;
    wire SDO;
    wire SDOE;
    reg [31:0] tmp;
    wire [31:0] DATA;
    reg SCK_en;

    TDI_AHB UUT (
        .HCLK(HCLK),
        .HRESETn(HRESETn),
        .SCK(SCK),
        .SDI(SDI),
        .SDO(SDO),
        .SDOE(SDOE)
    );

    `TB_CLK_GEN(HCLK, 10)

    initial #53 SCK = 1'b1;
    always #(333/2) if(SCK_en) SCK = ~ SCK;

    `TB_RESET_SYNC(HCLK, HRESETn, 1'b0, 113)

    `TB_INIT(TDI_tb, "TDI_tb.vcd", 0, 100_000)

    task send_cmd;
    input [7:0] cmd;
    send_data(cmd, 8);
    endtask

    task send_data;
    input [31:0] data;
    input [7:0] size;
    integer i;
        begin
            SCK_en = 1;
            SDI = data[0];
            @(posedge SCK)
            for(i=0; i<size-1; i=i+1) begin
                @(negedge SCK);
                data = data >> 1;
                SDI = data[0];
            end
            @(posedge SCK);
            SCK_en = 0;
        end
    endtask

    task read_data;
    output [31:0] data;
    input [7:0] size;
    integer i;
        begin
            data = 0;
            SCK_en = 1;
            for(i=0; i<size; i=i+1) begin
                @(posedge SCK);
                data = {SDO, data[31:1]};
            end
            SCK_en = 0;
        end
    endtask

    // Test Case
    reg[31:0] res;
    integer i;
    initial begin
        SCK_en = 0;
        #552;
        //send_data(8'hA5, 8);
        send_cmd(8'hA1);
        #553;
        read_data(res, 8);
        #551;
        send_cmd(8'hA2);
        #553;
        read_data(res, 16);
        
        // Write
        #553;
        send_cmd(8'hA9);
        #553;
        send_data(32'hABCD_1234, 32);
        #553;
        send_data(32'hDEAD_5555, 32);
        #551;

        // READ
        send_cmd(8'hA8);
        #500;
        send_data(32'hABCD_4141, 32);
        #500;
        read_data(res, 32);

        // HALT
        #555;
        send_cmd(8'hA4);
        #551;
        read_data(res, 8);

        // Resume
        #1555;
        send_cmd(8'hA5);
        #551;
        read_data(res, 8);


    end

endmodule



















