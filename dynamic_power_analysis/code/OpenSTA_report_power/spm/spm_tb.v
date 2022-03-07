// Copyright 2016, mshalan@aucegypt.edu
// Modeled after the design outlined by: 
//  https://www.microchip.com/content/dam/mchp/documents/OTH/ApplicationNotes/ApplicationNotes/DOC0529.PDF

module spm_tb;

	//Inputs
	reg clk;
	reg rst;
	reg [7: 0] x;

    reg[7:0] Y;
    reg[15:0] P;

	//Outputs
	wire p;

    reg[3:0] cnt;

	// Instantiation of DUV
	// Here verifying the 8-bit version
	spm #(8) duv (
		.clk(clk),
		.rst(rst),
		.y(Y[0]),
		.x(x),
		.p(p)
	);

    always #5 clk = ~clk;

    always @ (posedge clk)
        if(rst) Y = -50;
        else Y <= {1'b0,Y[7:1]};

    always @ (posedge clk)
        if(rst) P = 0;
        else P <= {p, P[15:1]};

	always @ (posedge clk)
        if(rst) cnt = 0;
        else cnt <= cnt + 1;

	initial begin
	//Inputs initialization
		clk = 0;
		rst = 0;
		x = 50;

	//Reset
		#20 rst = 1;
		#20 rst = 0;
        #1000;
        $finish;
	end

endmodule
