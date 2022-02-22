// Copyright 2016, mshalan@aucegypt.edu
// Modeled after the design outlined by: 
//  https://www.microchip.com/content/dam/mchp/documents/OTH/ApplicationNotes/ApplicationNotes/DOC0529.PDF

module spm(clk, rst, x, y, p);
    parameter size = 32;
    input clk, rst;
    input y;
    input[size-1:0] x;
    output p;

    wire[size-1:1] pp;
    wire[size-1:0] xy;

    genvar i;

    CSADD csa0 (.clk(clk), .rst(rst), .x(x[0]&y), .y(pp[1]), .sum(p));
    
    generate 
        for(i=1; i<size-1; i=i+1) begin
            CSADD csa (.clk(clk), .rst(rst), .x(x[i]&y), .y(pp[i+1]), .sum(pp[i]));
        end 
    endgenerate
    
    TCMP tcmp (.clk(clk), .rst(rst), .a(x[size-1]&y), .s(pp[size-1]));

endmodule

