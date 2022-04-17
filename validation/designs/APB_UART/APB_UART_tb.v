`include "includes/tb_util.vh"


`include "includes/primitives.v"
`include "includes/sky130_hd.v"

module APB_UART_tb;

  parameter [7:0]       DATA_REG_OFF      = 8'h0,
                        STATUS_REG_OFF    = 8'h8,
                        CTRL_REG_OFF      = 8'h8,
                        PRESCALE_REG_OFF  = 8'h10,
                        IMASK_REG_OFF     = 8'h18,
                        TXFIFOTR_REG_OFF  = 8'h20,
                        RXFIFOTR_REG_OFF  = 8'h28;

  reg         PCLK;
  reg         PRESETn;
  reg         PWRITE;
  reg  [31:0] PWDATA;
  reg  [31:0] PADDR;
  reg         PENABLE;

  reg         PSEL;

  //APB Outputs
  wire        PREADY;
  wire [31:0] PRDATA;

  //Serial Port Signals
  wire        RsRx;  //Input from RS-232
  wire        RsTx;  //Output to RS-232

  //UART Interrupt
  wire        uart_irq;  //Interrupt

	`TB_CLK_GEN(PCLK, 10)
  `TB_INIT(APB_UART_tb, "APB_UART_tb.vcd", 0, 5_0000)
  `TB_RESET_SYNC(PCLK, PRESETn, 'b0, 500)

  initial begin
    // Wait for rest to be done
    #100;
    @(posedge PRESETn);

    // Configure the prescales
    APB_WR(1, PRESCALE_REG_OFF);
    APB_WR(1, CTRL_REG_OFF);
    APB_WR(0, IMASK_REG_OFF);
    APB_WR(6, TXFIFOTR_REG_OFF );
    APB_WR(9, IMASK_REG_OFF);
    
		// Write 8 bytes to the TX FIFO
		APB_WR(8'h70, DATA_REG_OFF);
		APB_WR(8'h71, DATA_REG_OFF);
    APB_WR(8'h72, DATA_REG_OFF);
		APB_WR(8'h73, DATA_REG_OFF);
    APB_WR(8'h74, DATA_REG_OFF);
		APB_WR(8'h75, DATA_REG_OFF);
    APB_WR(8'h76, DATA_REG_OFF);
		APB_WR(8'h77, DATA_REG_OFF);

    // wait for the first byte to be received
    APB_RD(STATUS_REG_OFF);
    while ((PRDATA&2)!=2) begin
      APB_RD(STATUS_REG_OFF);
    end  

    // Read the received data
    APB_RD(DATA_REG_OFF);
    $display("UART RX: 0x%X (Expected 0x70)", PRDATA);
    if(PRDATA != 8'h70) begin
      $display("Test FAILED");
      $finish;
    end

    // change the baud rate
    APB_WR(0, CTRL_REG_OFF);
    APB_WR(4, PRESCALE_REG_OFF);
    APB_WR(1, CTRL_REG_OFF);

    // Write 2 bytes to the TX FIFO
		APB_WR(8'h80, DATA_REG_OFF);
		APB_WR(8'h81, DATA_REG_OFF);
    
	end

		task APB_WR (input [31:0] data, input [31:0] address);
			begin
				@(posedge PCLK);
				PSEL = 1;
				PWRITE = 1;
				PWDATA = data;
				PENABLE = 0;
        PADDR = address;
				@(posedge PCLK);
        PENABLE = 1;
				@(posedge PCLK);
				PSEL = 0;
				PWRITE = 0;
				PENABLE = 0;
        //$display("APB Write to 0x%X: 0x%X", address, PWDATA);
			end
		endtask
		
    task APB_RD(input [31:0] address);
			begin
				@(posedge PCLK);
				PSEL = 1;
				PWRITE = 0;
				PENABLE = 0;
        PADDR = address;
				@(posedge PCLK);
        PENABLE = 1;
				@(posedge PCLK);
				PSEL = 0;
				PWRITE = 0;
				PENABLE = 0;
        //$display("APB READ from 0x%X: 0x%X", address, PRDATA);
			end
		endtask
	

	APB_UART MUV (
    //APB Inputs
    PCLK,
    PRESETn,
    PWRITE,
    PWDATA,
    PADDR,
    PENABLE,
    PSEL,
    PREADY,
    PRDATA,
    //UART Interrupt
    uart_irq,  //Interrupt

    //Serial Port Signals
    RsRx,  //Input from RS-232
    RsTx  //Output to RS-232

    
  );

  // loopback!
  assign RsRx = RsTx;

endmodule
