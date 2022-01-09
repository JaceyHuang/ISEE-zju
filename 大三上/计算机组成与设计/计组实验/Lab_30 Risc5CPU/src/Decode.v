//******************************************************************************
// //
// Decode.v
//******************************************************************************

module Decode(   
	// Outputs
	MemtoReg, RegWrite, MemWrite, MemRead,ALUCode,ALUSrcA,ALUSrcB,Jump,JALR,Imm,offset,
	// Inputs
    Instruction);
	input [31:0]       Instruction;	    // current Instruction
	output		       MemtoReg;		// use memory output as data to write into register
	output		       RegWrite;		// enable writing back to the register
	output		       MemWrite;		// write to memory
	output             MemRead;
	output reg[3:0]    ALUCode;         // ALU operation select
	output             ALUSrcA;
	output [1:0]       ALUSrcB;
	output         	   Jump;
	output             JALR;
	output reg[31:0]   Imm, offset;
	
//******************************************************************************
//  Instruction type decode
//******************************************************************************
	parameter  R_type_op=   7'b0110011; // 7'h33
	parameter  I_type_op=   7'b0010011; // 7'h13
	parameter  SB_type_op=  7'b1100011; // 7'h63
	parameter  LW_op=       7'b0000011; // 7'h03
	parameter  JALR_op=     7'b1100111; // 7'h67
	parameter  SW_op=       7'b0100011; // 7'h23
	parameter  LUI_op=      7'b0110111; // 7'h37
	parameter  AUIPC_op=    7'b0010111;	// 7'h17
	parameter  JAL_op=      7'b1101111;	// 7'h6f
//
  //
   parameter  ADD_funct3 =     3'b000 ;
   parameter  SUB_funct3 =     3'b000 ;
   parameter  SLL_funct3 =     3'b001 ;
   parameter  SLT_funct3 =     3'b010 ;
   parameter  SLTU_funct3 =    3'b011 ;
   parameter  XOR_funct3 =     3'b100 ;
   parameter  SRL_funct3 =     3'b101 ;
   parameter  SRA_funct3 =     3'b101 ;
   parameter  OR_funct3 =      3'b110 ;
   parameter  AND_funct3 =     3'b111;
   //
   parameter  ADDI_funct3 =     3'b000 ;
   parameter  SLLI_funct3 =     3'b001 ;
   parameter  SLTI_funct3 =     3'b010 ;
   parameter  SLTIU_funct3 =    3'b011 ;
   parameter  XORI_funct3 =     3'b100 ;
   parameter  SRLI_funct3 =     3'b101 ;
   parameter  SRAI_funct3 =     3'b101 ;
   parameter  ORI_funct3 =      3'b101 ;
   parameter  ANDI_funct3 =     3'b111;
   //
   parameter	 alu_add=  4'b0000;
   parameter	 alu_sub=  4'b0001;
   parameter	 alu_lui=  4'b0010;
   parameter	 alu_and=  4'b0011;
   parameter	 alu_xor=  4'b0100;
   parameter	 alu_or =  4'b0101;
   parameter 	 alu_sll=  4'b0110;
   parameter	 alu_srl=  4'b0111;
   parameter	 alu_sra=  4'b1000;
   parameter	 alu_slt=  4'b1001;
   parameter	 alu_sltu= 4'b1010; 

//******************************************************************************
// Instruction field
//******************************************************************************
	wire [6:0]		op;
	wire  	 	    funct6_7;
	wire [2:0]		funct3;
	assign op			= Instruction[6:0];
	assign funct6_7		= Instruction[30];
 	assign funct3		= Instruction[14:12];
	
	// 指令类型赋值
	wire R_type, I_type, LW, JALR, SW, SB_type, LUI, AUIPC, JAL;
	assign R_type = (op==R_type_op);
	assign I_type = (op==I_type_op);
	assign LW = (op==LW_op);
	assign JALR = (op==JALR_op);
	assign SW = (op==SW_op);
	assign SB_type = (op==SB_type_op);
	assign LUI = (op==LUI_op);
	assign AUIPC =(op==AUIPC_op);
	assign JAL = (op==JAL_op);
	
	// 输出信号
	assign MemtoReg = LW;
	assign MemRead = LW;
	assign MemWrite = SW;
	assign RegWrite = R_type||I_type||LW||JALR||LUI||AUIPC||JAL;
    assign Jump = JALR||JAL;
	assign ALUSrcA = JALR||JAL||AUIPC;
	assign ALUSrcB[1] = JAL||JALR;
	assign ALUSrcB[0] = ~(R_type||JAL||JALR);
	
	// 确定ALUCode
	always @ (*)
	begin
		if (LUI) ALUCode = alu_lui; // 送数
		else if (R_type&&~I_type) // R_type == 1, I_type == 0
		begin 
			case (funct3)
				3'b000: begin
							if (~funct6_7) ALUCode = alu_add;  // 加
							else 		   ALUCode = alu_sub;  // 减
						end
				SLL_funct3:  if (~funct6_7) ALUCode = alu_sll;  // 左移
				SLT_funct3:  if (~funct6_7) ALUCode = alu_slt;  // 跳转
				SLTU_funct3: if (~funct6_7) ALUCode = alu_sltu; // 跳转(无符号数)
				XOR_funct3:  if (~funct6_7) ALUCode = alu_xor;  // 异或
				3'b101: begin
							if (~funct6_7) ALUCode = alu_srl;  // 逻辑右移
							else           ALUCode = alu_sra;  // 算术右移
						end
				OR_funct3:   if (~funct6_7) ALUCode = alu_or;   // 或
				AND_funct3:  if (~funct6_7) ALUCode = alu_and;  // 与
				default: ALUCode = alu_add; // 默认为加
 			endcase
		end
		else if (~R_type&&I_type) // R_type == 0, I_type == 1
		begin
			case (funct3)
				ADDI_funct3:  ALUCode = alu_add;  // 加
				SLLI_funct3:  ALUCode = alu_sll;  // 左移
				SLTI_funct3:  ALUCode = alu_slt;  // 跳转
				SLTIU_funct3: ALUCode = alu_sltu; // 跳转(无符号数)
				XORI_funct3:  ALUCode = alu_xor;  // 异或
				ORI_funct3:   ALUCode = alu_or;   // 或
				ANDI_funct3:  ALUCode = alu_and;  // 与
				3'b101: begin
							if (~funct6_7) ALUCode = alu_srl;  // 逻辑右移
							else           ALUCode = alu_sra;  // 算术右移
						end
				default: ALUCode = alu_add; // 默认为加
			endcase
		end
		else ALUCode = alu_add; // 加
	end
	
	// 立即数产生电路
	wire Shift; // 区分I-type的算术逻辑运算与移位运算
	assign Shift = (funct3==1)||(funct3==5); // 1：移位运算；0：算术逻辑运算
	
	always @ (*)
	begin
		if (I_type) 
		begin
			if (Shift)       begin Imm = {26'd0, Instruction[25:20]}; offset = 32'dx; end
			else 	         begin Imm = {{20{Instruction[31]}}, Instruction[31:20]}; offset = 32'dx; end
		end
		else if (LW)         begin Imm = {{20{Instruction[31]}}, Instruction[31:20]}; offset = 32'dx; end
		else if (SW)         begin Imm = {{20{Instruction[31]}}, Instruction[31:25], Instruction[11:7]}; offset = 32'dx; end
		else if (LUI||AUIPC) begin Imm = {Instruction[31:12], 12'd0}; offset = 32'dx; end
		else if (JALR)       begin Imm = 32'dx; offset = {{20{Instruction[31]}}, Instruction[31:20]}; end 
		else if (JAL)        begin Imm = 32'dx; offset = {{11{Instruction[31]}}, Instruction[31], Instruction[19:12], Instruction[20], Instruction[30:21], 1'b0}; end
		else if (SB_type)    begin Imm = 32'dx; offset = {{19{Instruction[31]}}, Instruction[31], Instruction[7], Instruction[30:25], Instruction[11:8], 1'b0}; end 
		else 		         begin Imm = 32'dx; offset = 32'dx; end
	end
endmodule