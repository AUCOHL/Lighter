module div_tb;

    reg clk, rst;
    reg [31:0] dividend_i, divisor_i;

    reg start_i;                 
    reg [2:0] op_i;                
    reg [4:0] reg_waddr_i; 

    // to ex
    wire[31:0] result_o;
    wire ready_o;                 
    wire busy_o;                  
    wire[4:0] reg_waddr_o;

div MUV (
    .clk(clk),
    .rst(rst),

    // from ex
    .dividend_i(dividend_i),      
    .divisor_i(divisor_i),       
    .start_i(start_i),                 
    .op_i(op_i),                
    .reg_waddr_i(reg_waddr_i), 

    // to ex
    .result_o(result_o),        
    .ready_o(ready_o),                 
    .busy_o(busy_o),                  
    .reg_waddr_o(reg_waddr_o)  
);

    always #5 clk = ~ clk;

    initial begin
        $dumpfile("div.vcd");
        $dumpvars(0, tb);
    end

    initial begin
        clk = 0;
        rst = 1'bx;
        dividend_i = 500;
        divisor_i = 33;
        start_i = 0;
        op_i = `INST_REM;
        #99; @(posedge clk);
        rst = 0;
        #999; @(posedge clk);
        rst = 1;
        #77; @(posedge clk);
        start_i = 1;
        #66; @(posedge clk);
        @(posedge ready_o);
        #25;
        @(posedge clk);
        start_i = 0;
        #10000;
        $finish;
    end
endmodule
