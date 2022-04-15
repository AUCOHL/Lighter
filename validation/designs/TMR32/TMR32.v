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
/*
	A 32-bit Timer/Counter with Input Capture support and PWM generation
    Modes of operation:
        + 32-bit timer with 16-bit prescaler (periodic and one-shot)
        + 32-bit event counter (external pin)
        + 32-bit Input Capture with 16-bit prescaler (Edge: Positive, Negative or Both)
        + 32-bit PWM Generator

	TMR : 32-bit up counter
	CMP: Timer CMP register
	CAPTURE: Capture Register 
    PRE: 16-bit Clock prescalar (timer_clk = clk / (PRE+1))
    OVF: Timer overflow (TMR>=CMP)
	OVF_CLR: Control signal to clear the TMROV flag
    EN: ENable
    MODE: 1: Periodic, 0: One-shot
    UD: Up/Down
    TC: Timer/Counter
    CP: Enable Capture Mode
    PNE: Posedge or Negede - Counter/Capture
    BE: Both Edges - Counter/Capture
    PWMEN: PWM Enable
*/

`timescale          1ns/1ps
`default_nettype    none

module TMR32 (
        input   wire            clk,
        input   wire            rst_n,
        output  wire    [31:0]  TMR,
        output  wire    [31:0]  CAPTURE,
        input   wire    [15:0]  PRE,
        input   wire    [31:0]  CMP,
        input   wire    [31:0]  LOAD,
        output  wire            OVF,
        output  wire            CMPF,
        output  wire            EEVF,        // Trigger event flag for Capture mode.
        input   wire            OVF_CLR,
        input   wire            CMPF_CLR,
        input   wire            EEVF_CLR,
		input   wire            EN,
        input   wire            MODE,       // Periodic or One-shot
        input   wire            UD,         // Up or Down
        input   wire            TC,         // Timer/Counter
        input   wire            CP,         // Enable Capture Mode
        input   wire            PNE,        // Posedge or Negede - Counter/Capture
        input   wire            BE,         // Both Edges
        input   wire            PWMEN,      // PWM Enable
        input   wire            EXTPIN, 
        output  wire            PWMPIN
	);

	reg [15:0] 	clkdiv;
	wire 		timer_clk = (clkdiv==PRE) ;
	wire 		tmrov = UD ? (CNTR == LOAD) : (CNTR == 32'h0);
    reg         TMROVF;
    reg         TMRCMPF;
    reg         TMREEVF;
    reg [31:0]  TMRCPR;

    // Input Capture Synchronizer
    reg [1:0]   sync;
    wire        EXTPIN_sync = sync[1];
    always @(posedge clk)
        sync <= {sync[0], EXTPIN};
    
    // Edge Detector
    wire pedge = (state == ST_B);
    wire nedge = (state == ST_D);
    wire bedge = pedge | nedge;
    reg [1:0] state, nstate;
    parameter ST_A=2'h0, ST_B=2'h1, ST_C=2'h2, ST_D=2'h3;
    always @(posedge clk or negedge rst_n)
        if(!rst_n)  
            state = ST_A;
        else
            state = nstate;
    
    always @*
        case(state)
            ST_A: if(EXTPIN_sync == 1)  nstate = ST_B; else nstate = ST_A;
            ST_B: nstate = ST_C; 
            ST_C: if(EXTPIN_sync == 0)  nstate = ST_D; else nstate = ST_C;
            ST_D: nstate = ST_A;
        endcase
    
    // External pin events
    wire    ext_clk =   BE  ?   bedge   :
                        PNE ?   pedge   :   nedge;

    wire    ext_event = (BE & bedge) | (PNE & pedge) | (~PNE & nedge);

	// 16-bit Prescalar
	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			clkdiv <= 16'd0;
		else if(timer_clk)
			clkdiv <= 16'd0;
		else if(EN)
			clkdiv <= clkdiv + 16'd1;
	end

	// The Counter
    wire clk_src =  CP ? timer_clk : 
                    TC ? timer_clk : ext_clk;
    reg  [31:0] CNTR;
    wire [31:0] CNTR_LOAD = UD ? 32'h0 : LOAD;
	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			CNTR <= 'h0;
        else if(!EN)
            CNTR <= CNTR_LOAD;
        else if(ext_event & CP)
            CNTR <= 'h0;
		else if(tmrov)
			CNTR <= CNTR_LOAD;
		else if(clk_src)
            if(MODE)
			    CNTR <= CNTR + (UD ? 32'd1 : -32'd1);
            else 
                if(!TMROVF) CNTR <= CNTR + (UD ? 32'd1 : -32'd1);
	end
    
    // OVF
	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			TMROVF <= 1'd0;
        else if(!EN)
        	TMROVF <= 1'd0;
		else if(OVF_CLR)
			TMROVF <= 1'd0;
		else if(tmrov)
			TMROVF <= 1'd1;
	end

    //CMPF
    wire cmpf = (CNTR == CMP);
    always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			TMRCMPF <= 1'd0;
        else if(!EN)
        	TMRCMPF <= 1'd0;
		else if(CMPF_CLR)
			TMRCMPF <= 1'd0;
		else if(cmpf)
			TMRCMPF <= 1'd1;
	end

    // External Event Flag
	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			TMREEVF <= 1'd0;
        else if(!EN)
        	TMREEVF <= 1'd0;
		else if(EEVF_CLR)
			TMREEVF <= 1'd0;
		else if(CP & ext_event)
			TMREEVF <= 1'd1;
	end


    // Capture Register
    always @(posedge clk or negedge rst_n)
		if(!rst_n)
            TMRCPR <= 32'b0;
        else 
            if(CP & ext_event) 
                TMRCPR <= CNTR;
                
    assign CAPTURE = TMRCPR;

    // PWM
    assign PWMPIN = PWMEN & (CNTR>=CMP);

    assign TMR = CNTR;
    assign OVF = TMROVF;
    assign CMPF = TMRCMPF;
    assign EEVF = TMREEVF;

endmodule



