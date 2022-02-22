

module \$mul (A, B, Y);

 parameter A_SIGNED = 0; 
 parameter B_SIGNED = 0; 
 parameter A_WIDTH = 1; 
 parameter B_WIDTH = 1; 
 parameter Y_WIDTH = 1;

input [A_WIDTH-1:0] A; 
input [B_WIDTH-1:0] B; 
output [Y_WIDTH-1:0] Y;

wire _TECHMAP_FAIL_ = A_WIDTH != B_WIDTH || B_WIDTH != Y_WIDTH; 

MYMUL #( .WIDTH(Y_WIDTH) ) g ( .A(A), .B(B), .Y(Y) );

endmodule


module \$adffe (ARST, CLK, D, EN, Q);


parameter ARST_POLARITY =1'b1;
parameter ARST_VALUE  =1'b0;
parameter CLK_POLARITY =1'b1;
parameter EN_POLARITY =1'b1;
parameter WIDTH =1;


input ARST, CLK, EN;
input [WIDTH -1 :0] D; 
output [WIDTH -1 :0] Q;




wire GCLK;





generate


if (WIDTH < 4) begin

sky130_fd_sc_hd__dlclkp_1  clk_gate ( .GCLK(GCLK), .CLK(CLK), .GATE(EN) );

end
else if (WIDTH < 17) begin
sky130_fd_sc_hd__dlclkp_2  clk_gate ( .GCLK(GCLK), .CLK(CLK), .GATE(EN) );
end
else begin
sky130_fd_sc_hd__dlclkp_4  clk_gate ( .GCLK(GCLK), .CLK(CLK), .GATE(EN) );
end


endgenerate

$adff  #( 
        .WIDTH(WIDTH), 
        .CLK_POLARITY(CLK_POLARITY),
        .ARST_VALUE(ARST_VALUE) ,
        .ARST_POLARITY (ARST_POLARITY)
        ) 
        flipflop(  
 
        .CLK(GCLK), 
        .ARST(ARST),
        .D(D), 
        .Q(Q)
        );




endmodule



module \$dffe ( CLK, D, EN, Q);



parameter CLK_POLARITY =1'b1;
parameter EN_POLARITY =1'b1;
parameter WIDTH =1;


input  CLK, EN;
input [WIDTH -1:0] D; 
output [WIDTH -1:0] Q;




wire GCLK;
sky130_fd_sc_hd__dlclkp_1  clk_gate ( .GCLK(GCLK), .CLK(CLK), .GATE(EN) );

$dff  #( 
        .WIDTH(WIDTH), 
        .CLK_POLARITY(CLK_POLARITY),
        ) 
        flipflop(  
        .CLK(GCLK), 
        .D(D), 
        .Q(Q)
        );

endmodule

