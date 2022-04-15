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
  APB UART that supports 8N1 with the following features
  - 16-byte TX and RX FIFOs with programmable thresholds
  - 16-bit prescaler (PR) for programable baud rate generation
    Baudrate = CLK/((PR+1)*16)
  - Four Interrupt Sources:
    + TX Fifo not full
    + RX Fifo not empty
    + RX Fifo level exceeded the threshold
    + TX Fifo level is below the threshold

  offset    I/O Register
  ------    ------------
  00        data in/out (RW)
  08        status: 0:TX_Full, 1: TX_Empty, 2:RX_Full, 3:RX_Empty, 4:tx_less_threshold, 5:rx_more_threshold  (R)
  08        control: 0: Enable UART 
  10        PRESCALER (RW)
  18        IM: 0: All, 1:~TX_full, 2:~RX_Empty, 3:tx_less_threshold, 4: rx_more_threshold (RW)
  20        TX FIFO Threshold
  28        TR FIFO Threshold
*/

`timescale          1ns/1ps
`default_nettype    none

`include  "designs/APB_UART/apb_util.vh"

module APB_UART #(parameter FDEPTH=16)
(
    // APB Bus Interface
    input wire          PCLK,
    input wire          PRESETn,

    `APB_SLAVE_IFC,
    
    // Serial Port Pins
    input wire          Rx,  
    output wire         Tx

);

    localparam FAWIDTH = $clog2(FDEPTH);

    parameter [7:0]       DATA_REG_OFF      = 8'h0,
                          STATUS_REG_OFF    = 8'h8,
                          CTRL_REG_OFF      = 8'h8,
                          PRESCALE_REG_OFF  = 8'h10,
                          IMASK_REG_OFF     = 8'h18,
                          TXFIFOTR_REG_OFF  = 8'h20,
                          RXFIFOTR_REG_OFF  = 8'h28;
    
    //Internal Signals
    //Data I/O between Bus and FIFO
    wire [7:0] uart_wdata;  
    wire [7:0] uart_rdata;

    //Signals from TX/RX to FIFOs
    wire uart_wr;
    wire uart_rd;

    //wires between FIFO and TX/RX
    wire [7:0] tx_data;
    wire [7:0] rx_data;

    //FIFO Status
    wire tx_full;
    wire tx_empty;
    wire rx_full;
    wire rx_empty;

    //UART status ticks
    wire tx_done;
    wire rx_done;

    //baud rate signal
    wire b_tick;
  
    // FIFO level
    wire [FAWIDTH-1:0] tx_level;
    wire [FAWIDTH-1:0] rx_level;


    `APB_REG(DATA_REG, 8, 0, )
    `APB_REG(CTRL_REG, 1, 0, )
    `APB_REG(PRESCALE_REG, 16, 0, )
    `APB_REG(IMASK_REG, 5, 0, )
    `APB_REG(TXFIFOTR_REG, 8, 0, )
    `APB_REG(RXFIFOTR_REG, 8, 0, )
    
    assign PREADY = 1; 
    
    //UART  write select
    assign uart_wr = PSEL & PWRITE & PENABLE & (PADDR[7:0]==DATA_REG_OFF);
    
    //Only write last 8 bits of Data
    assign uart_wdata = PWDATA;

    //UART read select
    assign uart_rd = PSEL & ~PWRITE & PENABLE & (PADDR[7:0]==DATA_REG_OFF);
    
    //Assign UART output to AHB RDATA
    //wire [7:0] DATA_REG = uart_rdata;
    wire [31:0] STATUS_REG = {26'd0, rx_more_threshold, tx_less_threshold ,rx_empty, rx_full ,tx_empty, tx_full};
    assign PRDATA = `APB_REG_READ(uart_rdata, DATA_REG_OFF)
                    `APB_REG_READ(STATUS_REG, STATUS_REG_OFF)
                    `APB_REG_READ(PRESCALE_REG, PRESCALE_REG_OFF)
                    `APB_REG_READ(IMASK_REG, IMASK_REG_OFF)
                    `APB_REG_READ(TXFIFOTR_REG, TXFIFOTR_REG_OFF)
                    `APB_REG_READ(RXFIFOTR_REG, RXFIFOTR_REG_OFF)
                    32'hDEADDEAD;
   
    wire tx_less_threshold = (tx_level < TXFIFOTR_REG);
    wire rx_more_threshold = (rx_level > TXFIFOTR_REG);
    
    assign PIRQ     = IMASK_REG[0] &  ( (~rx_empty & IMASK_REG[2])          | 
                                        (~tx_full & IMASK_REG[1])           | 
                                        (tx_less_threshold & IMASK_REG[3])  | 
                                        (rx_more_threshold & IMASK_REG[4])
                                      ); 

    BAUDGEN uBAUDGEN(
        .clk(PCLK),
        .rst_n(PRESETn),
        .prescale(PRESCALE_REG),
        .en(CTRL_REG[0]),
        .baudtick(b_tick)
    );
    
    FIFO #(.AWIDTH(FAWIDTH)) uFIFO_TX 
    (
        .clk(PCLK),
        .rst_n(PRESETn),
        .rd(tx_done),
        .wr(uart_wr),
        .w_data(uart_wdata[7:0]),
        .empty(tx_empty),
        .full(tx_full),
        .r_data(tx_data[7:0]),
        .level(tx_level)
    );
    
    FIFO #(.AWIDTH(FAWIDTH)) uFIFO_RX(
        .clk(PCLK),
        .rst_n(PRESETn),
        .rd(uart_rd),
        .wr(rx_done),
        .w_data(rx_data[7:0]),
        .empty(rx_empty),
        .full(rx_full),
        .r_data(uart_rdata[7:0]),
        .level(rx_level)
    );
    
    UART_RX uUART_RX(
        .clk(PCLK),
        .resetn(PRESETn),
        .b_tick(b_tick),
        .rx(Rx),
        .rx_done(rx_done),
        .dout(rx_data[7:0])
    );
    
    UART_TX uUART_TX(
        .clk(PCLK),
        .resetn(PRESETn),
        .tx_start(!tx_empty),
        .b_tick(b_tick),
        .d_in(tx_data[7:0]),
        .tx_done(tx_done),
        .tx(Tx)
    );
    
  
endmodule


module FIFO #(parameter DWIDTH=8, AWIDTH=4)
(
  input wire clk,
  input wire rst_n,
  input wire rd,
  input wire wr,
  input wire [DWIDTH-1:0] w_data,
  output wire empty,
  output wire full,
  output wire [DWIDTH-1:0] r_data,
  output wire [AWIDTH-1:0] level
);

//Internal Signal declarations

  reg [DWIDTH-1:0] array_reg [2**AWIDTH-1:0];
  reg [AWIDTH-1:0] w_ptr_reg;
  reg [AWIDTH-1:0] w_ptr_next;
  reg [AWIDTH-1:0] w_ptr_succ;
  reg [AWIDTH-1:0] r_ptr_reg;
  reg [AWIDTH-1:0] r_ptr_next;
  reg [AWIDTH-1:0] r_ptr_succ;

  // Level
  reg [AWIDTH-1:0] level_reg;
  reg [AWIDTH-1:0] level_next; 
  
  reg full_reg;
  reg empty_reg;
  reg full_next;
  reg empty_next;
  
  wire w_en;
  

  always @ (posedge clk)
    if(w_en)
    begin
      array_reg[w_ptr_reg] <= w_data;
    end

  assign r_data = array_reg[r_ptr_reg];   

  assign w_en = wr & ~full_reg;           

//State Machine
  always @ (posedge clk, negedge rst_n)
  begin
    if(!rst_n)
      begin
        w_ptr_reg <= 0;
        r_ptr_reg <= 0;
        full_reg <= 1'b0;
        empty_reg <= 1'b1;
        level_reg <= 4'd0;
      end
    else
      begin
        w_ptr_reg <= w_ptr_next;
        r_ptr_reg <= r_ptr_next;
        full_reg <= full_next;
        empty_reg <= empty_next;
        level_reg <= level_next;
      end
  end


//Next State Logic
  always @*
  begin
    w_ptr_succ = w_ptr_reg + 1;
    r_ptr_succ = r_ptr_reg + 1;
    
    w_ptr_next = w_ptr_reg;
    r_ptr_next = r_ptr_reg;
    full_next = full_reg;
    empty_next = empty_reg;
    level_next = level_reg;
    
    case({w_en,rd})
      //2'b00: nop
      2'b01:
        if(~empty_reg)
          begin
            r_ptr_next = r_ptr_succ;
            full_next = 1'b0;
            level_next = level_reg - 1;
            if (r_ptr_succ == w_ptr_reg)
              empty_next = 1'b1;
          end
      2'b10:
        if(~full_reg)
          begin
            w_ptr_next = w_ptr_succ;
            empty_next = 1'b0;
            level_next = level_reg + 1;
            if (w_ptr_succ == r_ptr_reg)
              full_next = 1'b1;
          end
      2'b11:
        begin
          w_ptr_next = w_ptr_succ;
          r_ptr_next = r_ptr_succ;
        end
    endcase
  end

//Set Full and Empty

  assign full = full_reg;
  assign empty = empty_reg;

  assign level = level_reg;
  
endmodule


// Baudrate = Clk/((prescale+1)*16)
// 19200 = 50,000,000 / ((prescale+1)*16)
// prescale = 161.76 ==> 162
module BAUDGEN
(
  input wire clk,
  input wire rst_n,
  input wire [15:0] prescale, 
  input wire en,
  output wire baudtick
);

reg [15:0] count_reg;
wire [15:0] count_next;

//Counter
always @ (posedge clk, negedge rst_n)
  begin
    if(!rst_n)
      count_reg <= 0;
    else if(en)
      count_reg <= count_next;
end

assign count_next = ((count_reg == prescale) ? 0 : count_reg + 1'b1);
assign baudtick = ((count_reg == prescale) ? 1'b1 : 1'b0);

endmodule


module UART_RX(
  input wire clk,
  input wire resetn,
  input wire b_tick,        //Baud generator tick
  input wire rx,            //RS-232 data port
  
  output reg rx_done,       //transfer completed
  output wire [7:0] dout    //output data
);

//STATE DEFINES  
  localparam [1:0] idle_st = 2'b00;
  localparam [1:0] start_st = 2'b01;
  localparam [1:0] data_st = 2'b11;
  localparam [1:0] stop_st = 2'b10;

//Internal Signals  
  reg [1:0] current_state;
  reg [1:0] next_state;
  reg [3:0] b_reg; //baud-rate/over sampling counter
  reg [3:0] b_next;
  reg [2:0] count_reg; //data-bit counter
  reg [2:0] count_next;
  reg [7:0] data_reg; //data register
  reg [7:0] data_next;
  
//State Machine  
  always @ (posedge clk, negedge resetn)
  begin
    if(!resetn)
      begin
        current_state <= idle_st;
        b_reg <= 0;
        count_reg <= 0;
        data_reg <=0;
      end
    else
      begin
        current_state <= next_state;
        b_reg <= b_next;
        count_reg <= count_next;
        data_reg <= data_next;
      end
  end

//Next State Logic 
  always @*
  begin
    next_state = current_state;
    b_next = b_reg;
    count_next = count_reg;
    data_next = data_reg;
    rx_done = 1'b0;
        
    case(current_state)
      idle_st:
        if(~rx)
          begin
            next_state = start_st;
            b_next = 0;
          end
          
      start_st:
        if(b_tick)
          if(b_reg == 7)
            begin
              next_state = data_st;
              b_next = 0;
              count_next = 0;
            end
          else
            b_next = b_reg + 1'b1;
            
      data_st:
        if(b_tick)
          if(b_reg == 15)
            begin
              b_next = 0;
              data_next = {rx, data_reg [7:1]};
              if(count_next ==7) // 8 Data bits
                next_state = stop_st;
              else
                count_next = count_reg + 1'b1;
            end
          else
            b_next = b_reg + 1;
            
      stop_st:
        if(b_tick)
          if(b_reg == 15) //One stop bit
            begin
              next_state = idle_st;
              rx_done = 1'b1;
            end
          else
           b_next = b_reg + 1;
    endcase
  end
  
  assign dout = data_reg;
  
endmodule

module UART_TX(
  input wire clk,
  input wire resetn,
  input wire tx_start,        
  input wire b_tick,          //baud rate tick
  input wire [7:0] d_in,      //input data
  output reg tx_done,         //transfer finished
  output wire tx              //output data to RS-232
  );
  
  
//STATE DEFINES  
  localparam [1:0] idle_st = 2'b00;
  localparam [1:0] start_st = 2'b01;
  localparam [1:0] data_st = 2'b11;
  localparam [1:0] stop_st = 2'b10;
  
//Internal Signals  
  reg [1:0] current_state;
  reg [1:0] next_state;
  reg [3:0] b_reg;          //baud tick counter
  reg [3:0] b_next;
  reg [2:0] count_reg;      //data bit counter
  reg [2:0] count_next;
  reg [7:0] data_reg;       //data register
  reg [7:0] data_next;
  reg tx_reg;               //output data reg
  reg tx_next;
  
//State Machine  
  always @(posedge clk, negedge resetn)
  begin
    if(!resetn)
      begin
        current_state <= idle_st;
        b_reg <= 0;
        count_reg <= 0;
        data_reg <= 0;
        tx_reg <= 1'b1;
      end
    else
      begin
        current_state <= next_state;
        b_reg <= b_next;
        count_reg <= count_next;
        data_reg <= data_next;
        tx_reg <= tx_next;
      end
  end


//Next State Logic  
  always @*
  begin
    next_state = current_state;
    tx_done = 1'b0;
    b_next = b_reg;
    count_next = count_reg;
    data_next = data_reg;
    tx_next = tx_reg;
    
    case(current_state)
      idle_st:
      begin
        tx_next = 1'b1;
        if(tx_start)
        begin
          next_state = start_st;
          b_next = 0;
          data_next = d_in;
        end
      end
      
      start_st: //send start bit
      begin
        tx_next = 1'b0;
        if(b_tick)
          if(b_reg==15)
            begin
              next_state = data_st;
              b_next = 0;
              count_next = 0;
            end
          else
            b_next = b_reg + 1;
      end
      
      data_st: //send data serially
      begin
        tx_next = data_reg[0];
        
        if(b_tick)
          if(b_reg == 15)
            begin
              b_next = 0;
              data_next = data_reg >> 1;
              if(count_reg == 7)    //8 data bits
                next_state = stop_st;
              else
                count_next = count_reg + 1;
            end
          else
            b_next = b_reg + 1;
      end
      
      stop_st: //send stop bit
      begin
        tx_next = 1'b1;
        if(b_tick)
          if(b_reg == 15)   //one stop bit
            begin
              next_state = idle_st;
              tx_done = 1'b1;
            end
          else
            b_next = b_reg + 1;
      end
    endcase
  end
  
  assign tx = tx_reg;
  
endmodule


