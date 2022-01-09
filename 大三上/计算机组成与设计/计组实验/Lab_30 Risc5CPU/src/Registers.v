module Registers(clk, rs1Addr, rs2Addr, WriteAddr, RegWrite, WriteData, rs1Data, rs2Data);
	input clk, RegWrite;
	input [4:0] rs1Addr, rs2Addr, WriteAddr; // 寄存器号
	input [31:0] WriteData; // 数据
	output [31:0] rs1Data, rs2Data;
	
	wire rs1Sel, rs2Sel; // 转发检测输出
	assign rs1Sel = RegWrite&&(WriteAddr!=0)&&(WriteAddr==rs1Addr);
	assign rs2Sel = RegWrite&&(WriteAddr!=0)&&(WriteAddr==rs2Addr);
	
	wire [31:0] ReadData1, ReadData2; 
	// Read Before Write寄存器堆
	RBWRegisters RBWReg(.clk(clk), .ReadRegister1(rs1Addr), .ReadRegister2(rs2Addr), .WriteData(WriteData), 
						.WriteRegister(WriteAddr), .RegWrite(RegWrite), .ReadData1(ReadData1), .ReadData2(ReadData2));
	
	// 选择输出
	mux2 mux_1(.in0(ReadData1), .in1(WriteData), .addr(rs1Sel), .out(rs1Data));
	mux2 mux_2(.in0(ReadData2), .in1(WriteData), .addr(rs2Sel), .out(rs2Data));
endmodule