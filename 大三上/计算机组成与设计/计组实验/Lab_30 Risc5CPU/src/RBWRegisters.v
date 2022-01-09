module RBWRegisters(clk, ReadRegister1, ReadRegister2, WriteData, WriteRegister, RegWrite, ReadData1, ReadData2);
	input clk, RegWrite;
	input [4:0] ReadRegister1, ReadRegister2, WriteRegister; // 寄存器号
    input [31:0] WriteData; // 数据
	output [31:0] ReadData1, ReadData2;
	
	reg [31:0] regs [31:0]; // 定义32*32存储器变量
	assign ReadData1 = (ReadRegister1==5'b0)?32'b0:regs[ReadRegister1]; // 端口1数据读出
	assign ReadData2 = (ReadRegister2==5'b0)?32'b0:regs[ReadRegister2]; // 端口2数据读出
	always @ (posedge clk)
	begin 
		if (RegWrite) regs[WriteRegister] <= WriteData;
	end
endmodule