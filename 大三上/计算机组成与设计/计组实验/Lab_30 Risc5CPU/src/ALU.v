//******************************************************************************
// MIPS verilog model
//
// ALU.v
//******************************************************************************

module ALU (
	// Outputs
	   ALUResult,
	// Inputs
	   ALUCode, A, B);
	input [3:0]	ALUCode;				// Operation select
	input [31:0]	A, B;
	output [31:0]	ALUResult;
	
// Decoded ALU operation select (ALUsel) signals
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

	wire Binvert; // 加减运算控制信号
	wire [31:0] sum;
	wire isLT, isLTU; // 比较电路
	reg [31:0] ALUResult;
	reg signed [31:0] A_reg; // 算术右移中间变量
	
	// 加减控制
	assign Binvert = ~(ALUCode==0);
	adder_32bits adder(.a(A), .b(B^{32{Binvert}}), .ci(Binvert), .s(sum), .co());
	
	// 比较控制
	assign isLT = A[31]&&(~B)||(A[31]~^B[31])&&sum[31]; // 符号数
	assign isLTU = (~A[31])&&B[31]||(A[31]~^B[31])&&sum[31]; // 非符号数
	
	// 基本运算
	always @ (*) 
	begin 
		A_reg = A;
		case (ALUCode)
			alu_add: ALUResult = sum;                    // add
			alu_sub: ALUResult = sum;                    // sub
			alu_lui: ALUResult = B;                      // lui
			alu_and: ALUResult = A&B;                    // and
			alu_xor: ALUResult = A^B;                    // xor
			alu_or:  ALUResult = A|B;                    // or
			alu_sll: ALUResult = A<<B;                   // sll
			alu_srl: ALUResult = A>>B;                   // srl
			alu_sra: ALUResult = A_reg>>>B;              // sra
			alu_slt: ALUResult = isLT?32'd1:32'd0;       // slt
			alu_sltu:ALUResult = isLTU?32'd1:32'd0;      // stlu
			default: ALUResult = sum;
		endcase
	end	
endmodule