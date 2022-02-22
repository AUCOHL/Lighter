 (* blackbox *)
module sky130_fd_sc_hd__dlclkp_1 (
  input GATE,
  input CLK,
  output GCLK);
endmodule

 (* blackbox *)
module sky130_fd_sc_hd__dlclkp_2 (
  input GATE,
  input CLK,
  output GCLK);
endmodule

 (* blackbox *)
module sky130_fd_sc_hd__dlclkp_4 (
  input GATE,
  input CLK,
  output GCLK);
endmodule


module look_ahead_4bit(input[3:0] first, input[3:0] sec, input cin, output [3:0] sum, output cout );
 
  wire  c1, c2, c3;
  
  assign c1 =   (first[0] & sec[0]) | (cin & (first[0] | sec[0]));
  assign c2 =   (first[1] & sec[1]) | (c1 & (first[1] | sec[1]));
  assign c3 =   (first[2] & sec[2]) | (c2 & (first[2] | sec[2]));
  assign cout = (first[3] & sec[3]) | (c3 & (first[3] | sec[3]));
 
 
 assign sum[0] = cin ^ first[0] ^ sec[0];
 assign sum[1] = c1  ^ first[1] ^ sec[1];
 assign sum[2] = c2  ^ first[2] ^ sec[2];
 assign sum[3] = c3  ^ first[3] ^ sec[3];
endmodule

module carry_select_eightbit(input[7:0] first, input[7:0] sec, input cin, output [7:0] sum, output cout );
 
 wire cout1, cout0, cout3;
 wire [3:0] sum1, sum0;
 look_ahead_4bit a1( .first(first[3:0]), .sec(sec[3:0]), .cin(cin), .sum(sum[3:0]), .cout(cout3) );
 
 
 look_ahead_4bit a2( .first(first[7:4]), .sec(sec[7:4]), .cin(1'b1), .sum(sum1), .cout(cout1));
 
 look_ahead_4bit a3( .first(first[7:4]), .sec(sec[7:4]), .cin(1'b0), .sum(sum0), .cout(cout0) );
 
 assign sum [7:4]= (cout3) ? sum1: sum0;
 
 assign cout = (cout3) ? cout1: cout0;
 
 
endmodule




module test(input [7:0] x, y, input clk, s1,rst,  output reg [7:0] r);


    
    always @(posedge clk, posedge rst)
    begin
        begin
            if(rst)begin
                r<=0;
           end
            else if(s1) begin 
            r<=x+y;
            end 
        end


    end
endmodule
//module test(input [7:0] x, y, input clk, s1,rst,  output reg [8:0] r, output z);


//    wire q; 
//    wire [7:0]  b;

//    carry_select_eightbit adding (.first(x), .sec(y), .cin(0), .sum(b), .cout(q));

    
//    always @(posedge clk, posedge rst)
//    begin
//        begin
//            if(rst)begin
                
         
//                r<=0;
//                z<=0;
//           end
//            else if(s1) begin 

//            r<={q,b[7:0]};
//            z<=x|y;
//            end 
//        end


//    end
//endmodule
