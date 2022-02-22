module \$mem_v2 (RD_CLK, RD_EN, RD_ARST, RD_SRST, RD_ADDR, RD_DATA, WR_CLK, WR_EN, WR_ADDR, WR_DATA);

parameter MEMID = "";
parameter signed SIZE = 4;
parameter signed OFFSET = 0;
parameter signed ABITS = 2;
parameter signed WIDTH = 8;
parameter signed INIT = 1'bx;

parameter signed RD_PORTS = 1;
parameter RD_CLK_ENABLE = 1'b1;
parameter RD_CLK_POLARITY = 1'b1;
parameter RD_TRANSPARENCY_MASK = 1'b0;
parameter RD_COLLISION_X_MASK = 1'b0;
parameter RD_WIDE_CONTINUATION = 1'b0;
parameter RD_CE_OVER_SRST = 1'b0;
parameter RD_ARST_VALUE = 1'b0;
parameter RD_SRST_VALUE = 1'b0;
parameter RD_INIT_VALUE = 1'b0;

parameter signed WR_PORTS = 1;
parameter WR_CLK_ENABLE = 1'b1;
parameter WR_CLK_POLARITY = 1'b1;
parameter WR_PRIORITY_MASK = 1'b0;
parameter WR_WIDE_CONTINUATION = 1'b0;


input [RD_PORTS-1:0] RD_CLK;
input [RD_PORTS-1:0] RD_EN;
input [RD_PORTS-1:0] RD_ARST;
input [RD_PORTS-1:0] RD_SRST;
input [RD_PORTS*ABITS-1:0] RD_ADDR;
output reg [RD_PORTS*WIDTH-1:0] RD_DATA;

input [WR_PORTS-1:0] WR_CLK;
input [WR_PORTS*WIDTH-1:0] WR_EN;
input [WR_PORTS*ABITS-1:0] WR_ADDR;
input [WR_PORTS*WIDTH-1:0] WR_DATA;


wire GCLK;

generate
    if (WIDTH < 4) begin
            sky130_fd_sc_hd__dlclkp_1  clk_gate ( .GCLK(GCLK), .CLK(WR_CLK), .GATE(WR_EN) );
            end
        else if (WIDTH < 17) begin
            sky130_fd_sc_hd__dlclkp_2  clk_gate ( .GCLK(GCLK), .CLK(WR_CLK), .GATE(WR_EN) );
            end
        else begin
            sky130_fd_sc_hd__dlclkp_4  clk_gate ( .GCLK(GCLK), .CLK(WR_CLK), .GATE(WR_EN) );
    end
endgenerate


$mem_v2   #( 
    .MEMID(MEMID), 
    .SIZE(SIZE), 
    .OFFSET(OFFSET), 
    .ABITS(ABITS), 
    .WIDTH(WIDTH), 
    .INIT(INIT), 
    .RD_PORTS(RD_PORTS), 
    .RD_CLK_ENABLE(RD_CLK_ENABLE), 
    .RD_CLK_POLARITY(RD_CLK_POLARITY), 
    .RD_TRANSPARENCY_MASK(RD_TRANSPARENCY_MASK), 
    .RD_COLLISION_X_MASK(RD_COLLISION_X_MASK), 
    .RD_WIDE_CONTINUATION(RD_WIDE_CONTINUATION), 
    .RD_CE_OVER_SRST(RD_CE_OVER_SRST), 
    .RD_ARST_VALUE(RD_ARST_VALUE), 
    .RD_SRST_VALUE(RD_SRST_VALUE), 
    .RD_INIT_VALUE(RD_INIT_VALUE), 
    .WR_PORTS(WR_PORTS), 
    .WR_CLK_ENABLE(WR_CLK_ENABLE), 
    .WR_CLK_POLARITY(WR_CLK_POLARITY), 
    .WR_PRIORITY_MASK(WR_PRIORITY_MASK), 
    .WR_WIDE_CONTINUATION(WR_WIDE_CONTINUATION), 
    ) 
    replaced_mem_v2 (
    .RD_CLK(RD_CLK), 
    .RD_EN(RD_EN), 
    .RD_ARST(RD_ARST), 
    .RD_SRST(RD_SRST), 
    .RD_ADDR(RD_ADDR), 
    .RD_DATA(RD_DATA), 
    .WR_CLK(GCLK), 
    .WR_EN(1), 
    .WR_ADDR(WR_ADDR), 
    .WR_DATA(WR_DATA)
    );


endmodule 

/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////

module \$mem (RD_CLK, RD_EN, RD_ADDR, RD_DATA, WR_CLK, WR_EN, WR_ADDR, WR_DATA);

parameter MEMID = "";
parameter signed SIZE = 4;
parameter signed OFFSET = 0;
parameter signed ABITS = 2;
parameter signed WIDTH = 8;
parameter signed INIT = 1'bx;

parameter signed RD_PORTS = 1;
parameter RD_CLK_ENABLE = 1'b1;
parameter RD_CLK_POLARITY = 1'b1;
parameter RD_TRANSPARENT = 1'b1;



parameter signed WR_PORTS = 1;
parameter WR_CLK_ENABLE = 1'b1;
parameter WR_CLK_POLARITY = 1'b1;

input [RD_PORTS-1:0] RD_CLK;
input [RD_PORTS-1:0] RD_EN;
input [RD_PORTS*ABITS-1:0] RD_ADDR;
output reg [RD_PORTS*WIDTH-1:0] RD_DATA;

input [WR_PORTS-1:0] WR_CLK;
input [WR_PORTS*WIDTH-1:0] WR_EN;
input [WR_PORTS*ABITS-1:0] WR_ADDR;
input [WR_PORTS*WIDTH-1:0] WR_DATA;

wire GCLK;
generate
    if (WIDTH < 4) begin
            sky130_fd_sc_hd__dlclkp_1  clk_gate ( .GCLK(GCLK), .CLK(WR_CLK), .GATE(WR_EN) );
            end
        else if (WIDTH < 17) begin
            sky130_fd_sc_hd__dlclkp_2  clk_gate ( .GCLK(GCLK), .CLK(WR_CLK), .GATE(WR_EN) );
            end
        else begin
            sky130_fd_sc_hd__dlclkp_4  clk_gate ( .GCLK(GCLK), .CLK(WR_CLK), .GATE(WR_EN) );
    end
endgenerate
$mem   #( 
    .MEMID(MEMID), 
    .SIZE(SIZE), 
    .OFFSET(OFFSET), 
    .ABITS(ABITS), 
    .WIDTH(WIDTH), 
    .INIT(INIT), 
    .RD_PORTS(RD_PORTS), 
    .RD_CLK_ENABLE(RD_CLK_ENABLE), 
    .RD_CLK_POLARITY(RD_CLK_POLARITY), 
    .RD_TRANSPARENT(RD_TRANSPARENT), 
    .WR_PORTS(WR_PORTS), 
    .WR_CLK_ENABLE(WR_CLK_ENABLE), 
    .WR_CLK_POLARITY(WR_CLK_POLARITY), 

    ) 
    replaced_mem (
    .RD_CLK(RD_CLK), 
    .RD_EN(RD_EN), 
    .RD_ADDR(RD_ADDR), 
    .RD_DATA(RD_DATA), 
    .WR_CLK(GCLK), 
    .WR_EN(1), 
    .WR_ADDR(WR_ADDR), 
    .WR_DATA(WR_DATA)
    );


endmodule 