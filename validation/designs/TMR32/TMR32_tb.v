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


`include "includes/primitives.v"
`include "includes/sky130_hd.v"



module tmr32_tb;
    reg         clk;
    reg         rst_n;
    wire [31:0] TMR;
    wire [31:0] CAPTURE;
    reg  [15:0] PRE;
    reg  [31:0] CMP;
    reg  [31:0] LOAD;
    wire        OVF;
    wire        CMPF;
    wire        EEVF;        // Trigger event flag for Capture mode.
    reg         OVF_CLR;
    reg         CMPF_CLR;
    reg         EEVF_CLR;
    reg         EN;
    reg         MODE;       // Perioid or One-shot
    reg         UD;         // Up or Down
    reg         TC;         // Timer or Counter
    reg         CP;         // Enable Capture Mode
    reg         PNE;        // Posedge or Negede - Counter/Capture
    reg         BE;         // Both Edges
    reg         PWMEN;
    reg         EXTPIN; 
    wire        PWMPIN;


    TMR32 MUV (
		.clk(clk),
		.rst_n(rst_n),
		.TMR(TMR),
        .CAPTURE(CAPTURE),
		.PRE(PRE),
		.CMP(CMP),
        .LOAD(LOAD),
		.OVF(OVF),
		.CMPF(CMPF),
        .EEVF(EEVF),        // Trigger event flag for Capture mode.
        .OVF_CLR(),
        .CMPF_CLR(),
        .EEVF_CLR(),
		.EN(EN),
        .MODE(MODE),       // Perioid or One-shot
        .UD(UD),         // Up or Down
        .TC(TC),         // Timer/Counter
        .CP(CP),         // Enable Capture Mode
        .PNE(PNE),        // Posedge or Negede - Counter/Capture
        .BE(BE),         // Both Edges
        .PWMEN(PWMEN),
        .EXTPIN(EXTPIN), 
        .PWMPIN(PWMPIN)
	);

    initial begin
        $dumpfile("tmr.vcd");
        $dumpvars(0, MUV);
        $monitor("capture: 0x%X , TMR: 0x%X ", CAPTURE, TMR);
        
    end

    initial begin
        clk = 0;
        rst_n = 0;
        PRE = 3;
        CMP = 5;
        LOAD = 10;
        OVF_CLR = 0;
        CMPF_CLR = 0;
        EEVF_CLR = 0;
        EN = 0;
        MODE = 1;       // Perioid or One-shot
        UD = 0;         // Up or Down
        TC = 1;         // Timer / Counter
        CP = 0;         // Enable Capture Mode
        PNE = 0;        // Posedge or Negede - Counter/Capture
        BE = 0;         // Both Edges
        EXTPIN = 0; 
        PWMEN = 0;

        #10_000 $finish;
    end

    always #5 clk = !clk;

    always #157 EXTPIN = ~ EXTPIN;

    initial begin
        #342;
        @(posedge clk);
        rst_n = 1;
        #333;
        @(posedge clk);
        EN = 1;
        #1111;
        @(posedge clk);
        UD = 1;
        #321;
        @(posedge clk);
        EN = 0;
        #611;
        @(posedge clk);
        EN = 1;
        #199;
        @(posedge clk);
        EN = 0;
        #333;
        @(posedge clk);
        TC = 0;
        EN = 1;
        #977;
        @(posedge clk);
        EN = 0;
        CP = 1;
        #100;
        @(posedge clk);
        EN = 1;
        #555;
        @(posedge clk);
        CP = 0;
        EN = 0;
        TC = 1;
        PWMEN = 1;
        #777;
        @(posedge clk);
        EN = 1;
        #1500;
        @(posedge clk);
        EN = 0;
        CMP = 3;
        #111;
        @(posedge clk);
        EN = 1;
    end
endmodule

