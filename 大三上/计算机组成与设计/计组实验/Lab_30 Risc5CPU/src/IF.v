`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:  zju
// Engineer: qmj
//////////////////////////////////////////////////////////////////////////////////
module IF(clk, reset, Branch, Jump, IFWrite, JumpAddr, Instruction_if, PC, IF_flush);
    input clk;
    input reset;
    input Branch;
    input Jump;
    input IFWrite; // 低电平有效
    input [31:0] JumpAddr;
    output [31:0] Instruction_if;
    output [31:0] PC;
    output IF_flush;
	
	reg [31:0] PC;
	wire [31:0] NextPC_if, PC_temp;
	
	assign IF_flush = Branch||Jump;
	
	// 确定下条指令地址
	always @ (posedge clk)
	begin
		if (reset) PC = 0;
		else if (!IFWrite) PC = PC; // 流水线阻塞
		else PC = PC_temp;
	end
	
	adder_32bits adder(.a(PC), .b(32'd4), .ci(0), .s(NextPC_if), .co());
	mux2 mux(.in0(NextPC_if), .in1(JumpAddr), .addr(IF_flush), .out(PC_temp));
	
	// 取指令机器码，注意addr的值
	InstructionROM InstructionROM(.addr(PC[7:2]), .dout(Instruction_if));
endmodule
