`timescale 1ns/1ns
`define     IR_rs1          19:15
`define     IR_rs2          24:20
`define     IR_rd           11:7
`define     IR_opcode       6:2
`define     IR_funct3       14:12
`define     IR_funct7       31:25
`define     IR_shamt        24:20

`define     OPCODE_Branch   5'b11_000
`define     OPCODE_Load     5'b00_000
`define     OPCODE_Store    5'b01_000
`define     OPCODE_JALR     5'b11_001
`define     OPCODE_JAL      5'b11_011
`define     OPCODE_Arith_I  5'b00_100
`define     OPCODE_Arith_R  5'b01_100
`define     OPCODE_AUIPC    5'b00_101
`define     OPCODE_LUI      5'b01_101
`define     OPCODE_SYSTEM   5'b11_100 
`define     OPCODE_Custom   5'b10_001

`define     F3_ADD          3'b000
`define     F3_SLL          3'b001
`define     F3_SLT          3'b010
`define     F3_SLTU         3'b011
`define     F3_XOR          3'b100
`define     F3_SRL          3'b101
`define     F3_OR           3'b110
`define     F3_AND          3'b111

`define     BR_BEQ          3'b000
`define     BR_BNE          3'b001
`define     BR_BLT          3'b100
`define     BR_BGE          3'b101
`define     BR_BLTU         3'b110
`define     BR_BGEU         3'b111

`define     OPCODE          IR[`IR_opcode]

`define     ALU_ADD         4'b00_00
`define     ALU_SUB         4'b00_01
`define     ALU_PASS        4'b00_11
`define     ALU_OR          4'b01_00
`define     ALU_AND         4'b01_01
`define     ALU_XOR         4'b01_11
`define     ALU_SRL         4'b10_00
`define     ALU_SRA         4'b10_10
`define     ALU_SLL         4'b10_01
`define     ALU_SLT         4'b11_01
`define     ALU_SLTU        4'b11_11

`define     SYS_EC_EB       3'b000


module riscv(input clk, ///
   reset, //
    ssdclk,//
    input [1:0] ledsel,//
    input [3:0] ssdsel, //
    output reg [15:0] LED ,//
    output  [3:0] Anode, //
    output  [6:0] LED_out //
    );

reg  [12:0] ssd;
wire [31:0] pc_output, instruction,write_data,write_data_mem;
wire [31:0] pc_input  ;
wire [8:0] address;
wire Branch,MemRead,MemtoReg,MemWrite,ALUSrc,RegWrite;
wire [2:0] ALUOp;
wire [1:0] Reg_write_mux,PC_mux;
wire [31:0] read_data_one, read_data_two, immediate;

wire [3:0] ALU_Selection;
wire [31:0] alu_input_two;
wire [31:0] mem_data_out;
wire cf, zf, vf, sf,signal_branch,cout;
wire [31:0]alu_output;
wire [31:0] EX_MEM_imm_pc, EX_MEM_ALU_out, EX_MEM_RegR2;
wire [31:0] imm_pc, four_pc;
wire[31:0] pc_branch;
wire and_out;

//added but nedd modification to accomidate the missing signal
wire [31:0] ID_EX_PC, ID_EX_RegR1, ID_EX_RegR2, ID_EX_Imm,ID_EX_PC_4;
wire [12:0] cont={Reg_write_mux,PC_mux,Branch,MemRead,MemtoReg,MemWrite,ALUSrc,RegWrite,ALUOp};
//Reg_write_mux,PC_mux,Branch,MemRead,MemtoReg,MemWrite,ALUSrc,RegWrite,ALUOp
wire [12:0] ID_EX_Ctrl;
wire [31:0] ID_EX_inst;
wire[4:0] ID_EX_Rs1, ID_EX_Rs2, ID_EX_Rd;


//added but nedd modification to accomidate the missing signal
wire EX_MEM_cf, EX_MEM_zf, EX_MEM_vf, EX_MEM_sf;
wire [8:0] EX_MEM_Ctrl;
wire [4:0] EX_MEM_Rd;
wire [31:0] EX_MEM_inst,EX_MEM_PC_4;


wire anded_branch_signal;


wire [31:0] MEM_WB_Mem_out, MEM_WB_ALU_out;
wire [1:0] MEM_WB_Ctrl;


Four_Digit_Seven_Segment_Driver_OptimizedFour_Digit_Seven_Segment_Driver_Optimized   ur(
    ssdclk, ///
    ssd, 
    Anode,  /// 
    LED_out //
    ); 

always @(ledsel)begin 
case (ledsel)
    2'b00 :begin
        LED= instruction[15:0];
    end
  
    2'b01 :begin
       LED= instruction[31:16];
    end// sub
       
    2'b10 :begin 
       LED= {2'b00,Branch,MemRead,MemtoReg,MemWrite,ALUSrc,RegWrite,ALUOp, ALU_Selection, zf,and_out};
    end
    
    2'b11 :begin
        LED= {2'b00,Branch,MemRead,MemtoReg,MemWrite,ALUSrc,RegWrite,ALUOp, ALU_Selection, zf,and_out};
     end
     
    default: begin
        LED= {2'b00,Branch,MemRead,MemtoReg,MemWrite,ALUSrc,RegWrite,ALUOp, ALU_Selection, zf,and_out};
    end
endcase 
end

always @(ssdsel)begin 
case (ssdsel)
    4'b0000 :begin
        ssd=pc_output;
    end
    
    4'b0001 :begin
        ssd=four_pc;
    end// sub
    
    4'b0010 :begin 
        ssd=imm_pc;
    end
    
    4'b0011 : begin
        ssd=pc_input;
    end
    
    4'b0100 :begin
        ssd=read_data_one;
    end   
     
    4'b0101 :begin
        ssd=read_data_two;
    end// sub
    
    4'b0110 :begin 
        ssd=write_data;
    end
    
    4'b0111 : begin
        ssd=immediate;
    end
    
    4'b1000 :begin
        ssd=immediate;
    end 
       
    4'b1001 :begin
        ssd=alu_input_two;
    end// sub
    
    4'b1010 :begin 
        ssd=alu_output;
    end
    
    4'b1011 : begin
        ssd=mem_data_out;
    end
    
    default: begin
        ssd=pc_output;
    end
    
endcase 
end
wire [4:0] MEM_WB_Rd;
wire [31:0] MEM_WB_PC_4,MEM_WB_imm_pc;
wire slwclk;
assign slwclk= ~clk;

assign address= pc_output[8:0];//here we need to mke the memory byte addressable [7:0]

assign four_pc= pc_output+32'd4;

assign pc_input= (EX_MEM_Ctrl[6:5]==2'b00)?four_pc:(EX_MEM_Ctrl[6:5]==2'b01)?pc_branch:(EX_MEM_Ctrl[6:5]==2'b10)?EX_MEM_imm_pc:EX_MEM_ALU_out; //don't forget
wire  loadpc;
assign loadpc = ((ID_EX_inst[6:2]==5'b00011)|(ID_EX_inst[6:2]==5'b11100))?1'b0:1'b1;

/////////////////////////////////////////////////
/////////////////////////////////////////////////                                                  
/////////////////////////////////////////////////
/////////////////////////////////////////////////
                N_bit_reg #(32) pc ( clk,pc_input,loadpc,reset,pc_output);//clock needs modification 
/////////////////////////////////////////////////
/////////////////////////////////////////////////                                                  
/////////////////////////////////////////////////
/////////////////////////////////////////////////


//replace
//InstMem instructionmemory(address,instruction); 

/////////////////////////////////////////////////
//added but nedd modification to accomidate the missing signal
wire [31:0] IF_ID_PC, IF_ID_Inst,IF_ID_PC_4;

/////////////////////////////////////////////////
/////////////////////////////////////////////////                                                  
/////////////////////////////////////////////////
/////////////////////////////////////////////////

                N_bit_reg #(96) IF_ID (slwclk,  {pc_output,instruction,four_pc}  ,1'b1 ,reset,{IF_ID_PC,IF_ID_Inst,IF_ID_PC_4} );

/////////////////////////////////////////////////
/////////////////////////////////////////////////                                                  
/////////////////////////////////////////////////
/////////////////////////////////////////////////



control_unit cont_unit(IF_ID_Inst,Branch,MemRead,MemtoReg,MemWrite,ALUSrc,RegWrite,ALUOp,Reg_write_mux,PC_mux); 

/////this mux needs to be reconsidered ater getting all it's signals from wb
assign write_data= (Reg_write_mux==2'b00)?write_data_mem:(Reg_write_mux==2'b10)?imm_pc:(Reg_write_mux==2'b01)?four_pc:write_data_mem;

/// reg write needs wb , MEM_WB_Rd is done but revisit it
reg_file  #(32) regfile(slwclk,reset,MEM_WB_Ctrl[0],write_data,IF_ID_Inst[19:15],IF_ID_Inst[24:20],MEM_WB_Rd,read_data_one,read_data_two);

rv32_ImmGen  ig(  IF_ID_Inst,immediate);

wire [12:0] incont;
assign incont = (anded_branch_signal|(EX_MEM_inst[6:2]==5'b11011)|(EX_MEM_inst[6:2]==5'b11001)) ? 12'd0:cont;

/////////////////////////////////////////////////
/////////////////////////////////////////////////                                                  
/////////////////////////////////////////////////
/////////////////////////////////////////////////


                N_bit_reg #(218) ID_EX (clk, 
                {incont,IF_ID_PC,read_data_one,read_data_two,immediate,IF_ID_Inst,IF_ID_Inst[19:15],IF_ID_Inst[24:20],IF_ID_Inst [11:7],IF_ID_PC_4},
                1'b1,reset,
                {ID_EX_Ctrl,ID_EX_PC,ID_EX_RegR1,ID_EX_RegR2,
                 ID_EX_Imm, ID_EX_inst,ID_EX_Rs1,ID_EX_Rs2,ID_EX_Rd,ID_EX_PC_4} );
/////////////////////////////////////////////////
/////////////////////////////////////////////////                                                  
/////////////////////////////////////////////////
/////////////////////////////////////////////////

Alu_control_unit alucont( ALU_Selection, ID_EX_Ctrl[2:0], ID_EX_inst);

assign imm_pc= ID_EX_PC+ID_EX_Imm;

f_unit aaa( EX_MEM_Ctrl[0], MEM_WB_Ctrl[0], ID_EX_Rs1, ID_EX_Rs2,EX_MEM_Rd ,MEM_WB_Rd,forwardA,forwardB );



wire [31:0]  forward_dataA,forward_dataB;

assign forward_dataA =(forwardA)?  write_data_mem :  ID_EX_RegR1 ;
assign forward_dataB =(forwardB)?  write_data_mem  :  ID_EX_RegR2  ;

assign alu_input_two= (ID_EX_Ctrl[4]) ? ID_EX_Imm:  forward_dataB;

wire [4:0]shamt ;

assign shamt=alu_input_two[4:0] ;

prv32_ALU alu(forward_dataA,alu_input_two,shamt,alu_output,cf, zf, vf, sf,ALU_Selection);

/////////////////////////////////////////////////


/////////////////////////////////////////////////
/////////////////////////////////////////////////                                                  
/////////////////////////////////////////////////
/////////////////////////////////////////////////

            N_bit_reg #(178) EX_MEM (slwclk, {cf, zf, vf, sf,{ID_EX_Ctrl[12:5],ID_EX_Ctrl[3]},imm_pc,ID_EX_inst , alu_output,forward_dataB,ID_EX_Rd,ID_EX_PC_4},1'b1,reset,
            {EX_MEM_cf, EX_MEM_zf, EX_MEM_vf, EX_MEM_sf, EX_MEM_Ctrl, EX_MEM_imm_pc, EX_MEM_inst ,EX_MEM_ALU_out, EX_MEM_RegR2, EX_MEM_Rd,EX_MEM_PC_4} );

/////////////////////////////////////////////////
/////////////////////////////////////////////////                                                  
/////////////////////////////////////////////////
/////////////////////////////////////////////////

branching_unit branch_unit(EX_MEM_cf, EX_MEM_zf, EX_MEM_vf, EX_MEM_sf, EX_MEM_inst , signal_branch);


assign anded_branch_signal=(signal_branch & EX_MEM_Ctrl[4] );


assign pc_branch= (anded_branch_signal )?EX_MEM_imm_pc:four_pc;


    
//DataMem dm ( clk,EX_MEM_Ctrl[3],EX_MEM_Ctrl[1],EX_MEM_ALU_out[8:0],EX_MEM_RegR2,EX_MEM_inst,mem_data_out);

wire [8:0] single_memory_address;
assign single_memory_address= (slwclk)?EX_MEM_ALU_out[8:0]:address;

single__memory physical_memory( clk,EX_MEM_Ctrl[3],EX_MEM_Ctrl[1],  single_memory_address, mem_data_out,EX_MEM_RegR2,EX_MEM_inst );
//wire [4:0] MEM_WB_Rd;
assign instruction =mem_data_out;


    
/////////////////////////////////////////////////
/////////////////////////////////////////////////
/////////////////////////////////////////////////
/////////////////////////////////////////////////

                N_bit_reg #(135) MEM_WB (clk,
                {{EX_MEM_Ctrl[2],EX_MEM_Ctrl[0]},mem_data_out,EX_MEM_ALU_out,EX_MEM_Rd,EX_MEM_PC_4,EX_MEM_imm_pc},
                1'b1,reset,
                {MEM_WB_Ctrl,MEM_WB_Mem_out, MEM_WB_ALU_out,MEM_WB_Rd,MEM_WB_PC_4,MEM_WB_imm_pc} );
                
                               
/////////////////////////////////////////////////
/////////////////////////////////////////////////
/////////////////////////////////////////////////
/////////////////////////////////////////////////   

assign write_data_mem= (MEM_WB_Ctrl[1]) ? MEM_WB_Mem_out:  MEM_WB_ALU_out;

endmodule




//////////////////////////////////////
////////////////////////////////////////////
/////////////////////////////
/////////////////////////////////////



module prv32_ALU(
	input   wire [31:0] a, b,
	input   wire [4:0]  shamt,
	output  reg  [31:0] r,
	output  wire cf, zf, vf, sf,
	input   wire [3:0]  alufn
);

    wire [31:0] add, sub, op_b;
    wire cfa, cfs;
    
    assign op_b = (~b); //for -b two's complement
    
    assign {cf, add} = alufn[0] ? (a + op_b + 1'b1) : (a + b);  //two's complement else addition, cf for branching
    
    assign zf = (add == 0); //for branching
    assign sf = add[31]; //for branching
    assign vf = (a[31] ^ (op_b[31]) ^ add[31] ^ cf); //for branching
    
    wire[31:0] sh;
    shifter shifter0(.a(a), .shamt(shamt), .type(alufn[1:0]),  .r(sh));
    
    always @ * begin
        r = 0;
        (* parallel_case *)
        case (alufn)
            // arithmetic
            4'b00_00 : r = add;
            4'b00_01 : r = add;
            4'b00_11 : r = b;
            // logic
            4'b01_00:  r = a | b;
            4'b01_01:  r = a & b;
            4'b01_11:  r = a ^ b;
            // shift
            4'b10_00:  r=sh;//srl
            4'b10_01:  r=sh;//sll
            4'b10_10:  r=sh;//sra
            // slt & sltu
            4'b11_01:  r = {31'b0,(sf != vf)};//slt 
            4'b11_11:  r = {31'b0,(~cf)};          //sltu  	
        endcase
    end
endmodule



//////////////////////////////////////
////////////////////////////////////////////
/////////////////////////////
/////////////////////////////////////


module control_unit( input [31:0] inst,output reg Branch,MemRead,MemtoReg,MemWrite,ALUSrc,RegWrite,output reg [2:0]ALUOp,output reg [1:0]Reg_write_mux,output reg [1:0]PC_mux);

always @ (*) begin 
case (inst[6:2] )

    5'b01100 : begin //r-format
        Branch=1'b0;
        MemRead=1'b0;
        MemtoReg=1'b0;
        ALUOp=3'b001;
        MemWrite=1'b0;
        ALUSrc=1'b0;
        RegWrite=1'b1;
        Reg_write_mux=2'b00;
        PC_mux=2'b00;
    end
    
    5'b00000 : begin //load
        Branch=1'b0;
        MemRead=1'b1;
        MemtoReg=1'b1;
        ALUOp=3'b000;
        MemWrite=1'b0;
        ALUSrc=1'b1;
        RegWrite=1'b1;
        Reg_write_mux=2'b00;
        PC_mux=2'b00;
    end
          
    5'b01000 : begin //store
        Branch=1'b0;
        MemRead=1'b0;
        MemtoReg=1'b0;
        ALUOp=3'b000;
        MemWrite=1'b1;
        ALUSrc=1'b1;
        RegWrite=1'b0;
        Reg_write_mux=2'b00;//x
        PC_mux=2'b00;
    end

    5'b00100 : begin //ALU I instruction
        Branch=1'b0;
        MemRead=1'b0;
        MemtoReg=1'b0;
        ALUOp=3'b010;
        MemWrite=1'b0;
        ALUSrc=1'b1;
        RegWrite=1'b1;
        Reg_write_mux=2'b00;
        PC_mux=2'b00;
    end
    
    5'b11000 : begin //branch
        Branch=1'b1;
        MemRead=1'b0;
        MemtoReg=1'b0;//x
        ALUOp=3'b111; //x
        MemWrite=1'b0;
        ALUSrc=1'b0;
        RegWrite=1'b0;
        Reg_write_mux=2'b00;//x
        PC_mux=2'b01;
    end
    
    5'b01101 : begin //LUI u-type
        Branch=1'b0;
        MemRead=1'b0;
        MemtoReg=1'b0;
        ALUOp=3'b100;
        MemWrite=1'b0;
        ALUSrc=1'b1;
        RegWrite=1'b1;
        Reg_write_mux=2'b00;
        PC_mux=2'b00;
    end
    
    5'b00101 : begin //AUIPC u-type
        Branch=1'b0;
        MemRead=1'b0;
        MemtoReg=1'b0;
        ALUOp=3'b101;
        MemWrite=1'b0;
        ALUSrc=1'b1;
        RegWrite=1'b1;
        Reg_write_mux=2'b10;
        PC_mux=2'b00;
    end
    
    5'b11011 : begin //JAL J-type
        Branch=1'b0;
        MemRead=1'b0;
        MemtoReg=1'b0;
        ALUOp=3'b000;//x    
        MemWrite=1'b0;
        ALUSrc=1'b0;//x
        RegWrite=1'b1;
        Reg_write_mux=2'b01;
        PC_mux=2'b10;
    end
    
    5'b11001 : begin //JALR i-type
        Branch=1'b0;
        MemRead=1'b0;
        MemtoReg=1'b0;
        ALUOp=3'b000;//x
        MemWrite=1'b0;
        ALUSrc=1'b1;
        RegWrite=1'b1;
        Reg_write_mux=2'b01;
        PC_mux=2'b11;
    end
    
    5'b00011: begin //fence
        Branch=1'b0;
        MemRead=1'b0;
        MemtoReg=1'b0;
        ALUOp=3'b110;
        MemWrite=1'b0;
        ALUSrc=1'b0;
        RegWrite=1'b0;
        Reg_write_mux=2'b00;
        PC_mux=2'b00;
    end
    
   5'b11100: begin //ecall / ebreak
        Branch=1'b0;
        MemRead=1'b0;
        MemtoReg=1'b0;
        ALUOp=3'b110;
        MemWrite=1'b0;
        ALUSrc=1'b0;
        RegWrite=1'b0;
        Reg_write_mux=2'b00;
        PC_mux=2'b00;
    end
          
    default: begin 
        Branch=1'b0;
        MemRead=1'b0;
        MemtoReg=1'b0;
        ALUOp=3'b110;
        MemWrite=1'b0;
        ALUSrc=1'b0;
        RegWrite=1'b0;
        Reg_write_mux=2'b00;
        PC_mux=2'b00;
    end
    
endcase 
end

endmodule


///////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////


module Alu_control_unit(output reg [3:0] ALU_FN, input [2:0] ALUOp, input [31:0] inst);

always @ (*) begin 

case (ALUOp)
    3'b001 : begin // r-type instructions
    
        case (inst[14:12])
            3'b000 : begin // 
                if (inst[30]==0)    ALU_FN= `ALU_ADD;
                else     ALU_FN= `ALU_SUB;
            end
            
            3'b001 : begin //
                ALU_FN= `ALU_SLL;
            end
            
            3'b010 : begin //
                ALU_FN= `ALU_SLT;
            end    
        
            3'b011 : begin //
                ALU_FN= `ALU_SLTU;
            end
        
            3'b100 : begin //
                ALU_FN= `ALU_XOR;
            end
        
            3'b101 : begin // 
                if (inst[30]==0)    ALU_FN= `ALU_SRL;
                else     ALU_FN= `ALU_SRA;
            end
            
            3'b110 : begin //  
                ALU_FN= `ALU_OR;
            end    

            3'b111 : begin // 
                ALU_FN= `ALU_AND; 
            end 

            default: begin 
                ALU_FN= 4'b000;       
            end
        endcase
    end
    
    3'b000 : begin  //load, store instructions
        ALU_FN= `ALU_ADD;
    end


    3'b010 : begin // ALU i-type instructions
        case (inst[14:12])
            3'b000 : begin //
                ALU_FN= `ALU_ADD; 
            end
            
            3'b001 : begin //
                ALU_FN= `ALU_SLL;
            end
            
            3'b010 : begin //
                ALU_FN= `ALU_SLT;
            end    
        
            3'b011 : begin //
                ALU_FN= `ALU_SLTU;
            end
        
            3'b100 : begin //
                ALU_FN= `ALU_XOR;
            end
        
            3'b101 : begin // 
                if (inst[30]==0)    ALU_FN= `ALU_SRL;
                else     ALU_FN= `ALU_SRA;
            end
            
            3'b110 : begin //  
                ALU_FN= `ALU_OR;
            end    

            3'b111 : begin // 
                ALU_FN= `ALU_AND; 
            end 

            default: begin 
                ALU_FN= 4'b000;       
            end
        endcase
    end

    3'b100 : begin // lui 
        ALU_FN= `ALU_PASS;
    end

    3'b101 : begin // AUIPC
        ALU_FN= `ALU_ADD;
    end
    
    3'b110 : begin // JALR 
        ALU_FN= `ALU_ADD;
    end    

    3'b111 : begin // branch 
        ALU_FN= `ALU_PASS;
    end
    default: begin 
        ALU_FN= `ALU_PASS;
    end
endcase 
end

endmodule



///////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////



module branching_unit(input cf, zf, vf, sf,input [31:0] instruction ,  output reg signal_branch );

always@(*)begin 
case (instruction[14:12] )

    3'b000 : begin //beq
        if (zf)
            signal_branch= 1'b1;
        else 
            signal_branch= 1'b0;
    end
    
    3'b001 : begin //bne
        if (~zf)
            signal_branch= 1'b1;
        else 
            signal_branch= 1'b0;
    end
          
    3'b100 : begin //blt
        if (sf != vf)
            signal_branch= 1'b1;
        else 
            signal_branch= 1'b0;
    end
          
    3'b101 : begin //bge
        if (sf==vf)
            signal_branch= 1'b1;
        else 
            signal_branch= 1'b0;
    end
          
    3'b110 : begin //bltu
        if (~cf)
            signal_branch= 1'b1;
        else 
            signal_branch= 1'b0;
    end
          
    3'b111 : begin //bgeu
        if (cf)
            signal_branch= 1'b1;
        else 
            signal_branch= 1'b0;
    end
      
    default: begin 
        signal_branch= 1'b0;
    end

endcase 
end

endmodule





module   f_unit(input  EX_MEM_regwrite, MEM_WB_regwrite, input [4:0] ID_EX_rs1, ID_EX_rs2,EX_MEM_Rd ,MEM_WB_Rd, output reg  forwardA,forwardB );

always @(*) begin 

//if (EX_MEM_regwrite & (EX_MEM_Rd != 0)& (EX_MEM_Rd == ID_EX_rs1) )begin 
//forwardA = 2'b10;
//end 
//else 
if( (MEM_WB_regwrite & (MEM_WB_Rd != 0)& (MEM_WB_Rd== ID_EX_rs1)))begin 
forwardA = 1'b1;
end 
else begin 
forwardA = 1'b0;
end


//if (EX_MEM_regwrite & (EX_MEM_Rd != 0)& (EX_MEM_Rd == ID_EX_rs2) )begin 
//forwardB = 2'b10;
//end
//else 
if( (MEM_WB_regwrite & (MEM_WB_Rd != 0)& (MEM_WB_Rd== ID_EX_rs2)) ) begin 
forwardB = 1'b1;
end 
else begin 
forwardB = 1'b0;
end
end

endmodule


module rv32_ImmGen (
    input  wire [31:0]  IR,
    output reg  [31:0]  Imm
);

always @(*) begin
	case (`OPCODE)
		`OPCODE_Arith_I   : 	Imm = { {21{IR[31]}}, IR[30:25], IR[24:21], IR[20] };
		`OPCODE_Store     :     Imm = { {21{IR[31]}}, IR[30:25], IR[11:8], IR[7] };
		`OPCODE_LUI       :     Imm = { IR[31], IR[30:20], IR[19:12], 12'b0 };
		`OPCODE_AUIPC     :     Imm = { IR[31], IR[30:20], IR[19:12], 12'b0 };
		`OPCODE_JAL       : 	Imm = { {12{IR[31]}}, IR[19:12], IR[20], IR[30:25], IR[24:21], 1'b0 };
		`OPCODE_JALR      : 	Imm = { {21{IR[31]}}, IR[30:25], IR[24:21], IR[20] };
		`OPCODE_Branch    : 	Imm = { {20{IR[31]}}, IR[7], IR[30:25], IR[11:8], 1'b0};
		default           : 	Imm = { {21{IR[31]}}, IR[30:25], IR[24:21], IR[20] }; // IMM_I
	endcase 
end

endmodule



module single__memory( clk,MemRead, MemWrite,  address, data_out,data_in,inst );
input [8:0] address;
output  [31:0] data_out;
input [31:0] data_in,inst ;
input clk, MemRead, MemWrite;
reg [7:0] mem [0:512];
reg [31:0] inst_out;
reg [31:0] dm_out;

wire [8:0] byte0=address+256;
wire [8:0] byte1=address+257;
wire [8:0] byte2=address+258;
wire [8:0] byte3=address+259;

always @ (posedge clk) begin
  
        if (MemWrite) begin
            case (inst[14:12] ) 
            3'b000 : begin //sb
            mem[byte0]= data_in[7:0];
            end
            
            3'b001 : begin //sh
            {mem[byte1],mem[byte0]}= data_in[15:0];
            end
                    
            3'b010 : begin //sw
           {mem[byte3],mem[byte2],mem[byte1],mem[byte0]}= data_in[31:0];
            end        
            default: begin 
          
           ///////////////////////////////////////////////////
            end
            endcase
      end
    end




always@(*) begin 

         if (MemRead) begin 
                 case (inst[14:12] ) 
                 3'b000 : begin //sb
                 dm_out  =  {{24 {mem[byte0][7]}},mem[byte0]};
                 end
                 
                 3'b001 : begin //lh
                 dm_out  = {{16 {mem[byte1][7]}},mem[byte1],mem[byte0]};
                 end
                         
                 3'b010 : begin //lw
                 dm_out = {mem[byte3],mem[byte2],mem[byte1],mem[byte0]};
                 end
         
                 3'b100 : begin //lw
                 dm_out = {24'd0,mem[byte0]};
                 end    
         
                 3'b101 : begin //lw
                 dm_out = {16'd0,mem[byte1],mem[byte0]};
                 end
                 
                 default: begin 
                 dm_out = 0;
                ///////////////////////////////////////////////////
                 end
                 endcase
    
 end else begin 
      dm_out = 0;
 end 
end


assign data_out=(~clk)?dm_out:inst_out;

always@(*) begin 
inst_out= {mem[address+3],mem[address+2],mem[address+1],mem[address]};
end


endmodule






module mux (input a, input b, input load , output out);

assign out= (load)?a: b;

endmodule


module fullAdder(input A,B ,cin, output sum, cout);
   
assign {cout, sum}= A+B+cin;

endmodule


module eightbit( first, second, cin,  cout,  sum );

parameter n= 1;
input [n-1:0] first;
input [n-1:0]  second;
input cin;
output cout;
output [n-1:0]  sum;
genvar i;
wire [n-1:0] cout1;
fullAdder add1(.A(first[0]),.B(second[0]),.cin(cin), .sum(sum[0]), .cout(cout1[0]));

generate

for(i=1; i<n; i=i+1)
begin
 
fullAdder hh(.A(first[i]),.B(second[i]),.cin(cout1[i-1]), .sum(sum[i]), .cout(cout1[i]));
end

endgenerate

assign cout= cout1[n-1];

endmodule



module n_bit_shift (in, out);

parameter n=2;
input [n-1:0] in;
output [n-1:0] out;

assign out= {in[n-2:0],1'b0};

endmodule





module DFlipFlop (input clk, input rst, input D, output reg Q);

always @ (posedge clk or posedge rst)
    if (rst) begin
        Q <= 1'b0;
    end 
    
    else begin
        Q <= D;
    end
    
endmodule

///////////////////////////////////////////////////////////////////////

module N_bit_reg ( clk, in, load , reset, out  );

parameter n = 8;
input clk;
input [n-1:0] in;
output [n-1:0] out;
input load;
input reset;
genvar i;
generate 

for (i=0; i<n; i= i+1) begin

wire x;

mux muxi(in[i],  out[i],  load , x);

DFlipFlop dd(clk,  reset,  x,  out[i]);

end 
endgenerate

endmodule

///////////////////////////////////////////////////////////////////////

module reg_file(clk,rst, reg_write, write_data,readreg_one, readreg_two, write_reg,  read_data_one, read_data_two );

parameter n=32;
input [4:0] readreg_one, readreg_two, write_reg;
input clk, reg_write, rst;
input [31:0] write_data;
output [31:0] read_data_one, read_data_two;
reg [31:0] load ;
wire [n-1: 0] Q [31:0];

assign Q[0] =0;
genvar i;

generate

 N_bit_reg #(n) mmmmm( clk,write_data , 0 , rst, Q[0]  );
for (i=1; i<32; i= i+1)begin 

 N_bit_reg #(n) rr( clk,write_data , load[i] , rst, Q[i]  );
end 

endgenerate

always @ (*) begin
    if (reg_write) begin 
        load = 32'd0;
        load[write_reg]=1;
    end 
    else begin
        load = 32'd0;
    end
end

assign read_data_one= Q[readreg_one];
assign read_data_two= Q[readreg_two];

endmodule







module Four_Digit_Seven_Segment_Driver_OptimizedFour_Digit_Seven_Segment_Driver_Optimized(
input clk, 
input [7:0] num, 
output reg [3:0] Anode, 
output reg [6:0] LED_out 
); 
wire [3:0] Thousands;
wire [3:0] Hundreds;
wire [3:0] Tens;
wire [3:0] Ones ;

wire [3:0] indicate;
// if 2s complement
assign indicate= (num[7]==1)?10:11;

wire [7:0] num2;


assign num2= (num[7]==1)? ~num+1: num;



 BCD firs(  num2,  Thousands ,Hundreds,  Tens,  Ones ); 



reg [3:0] LED_BCD; 
reg [19:0] refresh_counter = 0; // 20-bit counter 
wire [1:0] LED_activating_counter; 
always @(posedge clk) 
begin 
refresh_counter <= refresh_counter + 1; 
end 

assign LED_activating_counter = refresh_counter[19:18]; 

always @(*) 
begin 
case(LED_activating_counter) 
2'b00: begin
Anode = 4'b0111; 


LED_BCD = indicate; 
end 
2'b01: begin
Anode = 4'b1011; 
LED_BCD = Hundreds; 
end 
2'b10: begin
Anode = 4'b1101; 
LED_BCD =Tens; 
end 
2'b11: begin
Anode = 4'b1110; 
LED_BCD = Ones; 
end 
endcase 
end 
always @(*) 
begin 
case(LED_BCD) 
4'b0000: LED_out = 7'b0000001; // "0" 
4'b0001: LED_out = 7'b1001111; // "1" 
4'b0010: LED_out = 7'b0010010; // "2" 
4'b0011: LED_out = 7'b0000110; // "3" 
4'b0100: LED_out = 7'b1001100; // "4" 
4'b0101: LED_out = 7'b0100100; // "5" 
4'b0110: LED_out = 7'b0100000; // "6" 
4'b0111: LED_out = 7'b0001111; // "7" 
4'b1000: LED_out = 7'b0000000; // "8" 
4'b1001: LED_out = 7'b0000100; // "9" 
4'b1010: LED_out = 7'b1111110; // "off 10" 
4'b1011: LED_out = 7'b1111111; // "-  11" 
default: LED_out = 7'b0000001; // "0" 
endcase 
end 
endmodule



module BCD ( 
input [7:0] num, 
output reg [3:0] Thousands,
output reg [3:0] Hundreds, 
output reg [3:0] Tens, 
output reg [3:0] Ones 
); 
integer i; 
always @(num) 
begin 
//initialization
 Thousands = 4'd0; 
 Hundreds = 4'd0; 
 Tens = 4'd0; 
 Ones = 4'd0; 
for (i = 7; i >= 0 ; i = i-1 ) 
begin 
if(Thousands >= 5 ) 
 Thousands = Thousands + 3; 
if(Hundreds >= 5 ) 
 Hundreds = Hundreds + 3; 
if (Tens >= 5 ) 
 Tens = Tens + 3; 
 if (Ones >= 5) 
 Ones = Ones +3; 
//shift left one 
 Thousands = Thousands << 1; 
 Thousands [0] = Hundreds [3]; 
 Hundreds = Hundreds << 1; 
 Hundreds [0] = Tens [3]; 
 Tens = Tens << 1; 
 Tens [0] = Ones[3]; 
 Ones = Ones << 1; 
 Ones[0] = num[i]; 
end 
end 
endmodule 

module shifter(input [31:0] a, input [4:0]  shamt, input [1:0] type, output reg [31:0] r);


wire signed [31:0] w1 =a; 
always @(*) begin



	case (type)
		2'b00  :begin  r = a >> shamt ; end 	//srl
		2'b01  :  begin  r = a<< shamt; end   //sll
		2'b10  :  begin r = w1 >>> shamt; end   //sra
		default :begin r= a;  end   // IMM_I
	endcase 
	
	end
	


endmodule
