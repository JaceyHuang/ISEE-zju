`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
//////////////////////////////////////////////////////////////////////////////////
module ID(clk,Instruction_id, PC_id, RegWrite_wb, rdAddr_wb, RegWriteData_wb, MemRead_ex, 
          rdAddr_ex, MemtoReg_id, RegWrite_id, MemWrite_id, MemRead_id, ALUCode_id, 
			 ALUSrcA_id, ALUSrcB_id,  Stall, Branch, Jump, IFWrite,  JumpAddr, Imm_id,
			 rs1Data_id, rs2Data_id,rs1Addr_id,rs2Addr_id,rdAddr_id);
    input clk; // 时钟
    input [31:0] Instruction_id; // 指令机器码
    input [31:0] PC_id; // 指令指针
    input RegWrite_wb; // 寄存器写允许信号，高电平有效
    input [4:0] rdAddr_wb; // 寄存器的写地址
    input [31:0] RegWriteData_wb; // 写入寄存器的数据
    input MemRead_ex; 
    input [4:0] rdAddr_ex; // 冒险检测的输入
    output MemtoReg_id; // 决定回写的数据来源
    output RegWrite_id; // 寄存器写允许信号，高电平有效
    output MemWrite_id; // 存储器写允许信号，高电平有效
    output MemRead_id; // 寄存器读允许信号，高电平有效
    output [3:0] ALUCode_id; // 决定ALU采取何种运算
    output ALUSrcA_id; // 决定ALU的A操作数来源
    output [1:0]ALUSrcB_id; // 决定ALU的B操作数来源
    output Stall; // ID/EX寄存器清空信号，高电平表示插入一个流水线气泡
    output Branch; // 条件分支指令的判断结果，高电平有效
    output Jump; // 无条件分支指令的判断结果，高电平有效
    output IFWrite; // 阻塞流水线的信号，低电平有效
    output [31:0] JumpAddr; // 分支地址
    output [31:0] Imm_id; // 立即数
    output [31:0] rs1Data_id;
    output [31:0] rs2Data_id; // 寄存器两个端口输出数据
	output [4:0] rs1Addr_id, rs2Addr_id; // 两个数据寄存器地址
	output [4:0] rdAddr_id; // 回写寄存器地址
	
	wire JALR; // 译码输出
	wire [31:0] JALRAddr; // 数据选择器输出
	wire [31:0] offset; // 立即数产生电路
	
	assign rs1Addr_id = Instruction_id[19:15];
	assign rs2Addr_id = Instruction_id[24:20];
	assign rdAddr_id = Instruction_id[11:7];
	
	// 指令译码
	Decode Decode(.MemtoReg(MemtoReg_id), .RegWrite(RegWrite_id), .MemWrite(MemWrite_id), 
				  .MemRead(MemRead_id), .ALUCode(ALUCode_id), .ALUSrcA(ALUSrcA_id), 
				  .ALUSrcB(ALUSrcB_id), .Jump(Jump), .JALR(JALR), .Imm(Imm_id), .offset(offset), 
				  .Instruction(Instruction_id));
	
	// 寄存器堆
	Registers Registers(.clk(clk), .rs1Addr(rs1Addr_id), .rs2Addr(rs2Addr_id), .WriteAddr(rdAddr_wb), 
					    .RegWrite(RegWrite_wb), .WriteData(RegWriteData_wb), 
						.rs1Data(rs1Data_id), .rs2Data(rs2Data_id));
	
	// 分支检测
	BranchTest BranchTest(.Instruction(Instruction_id), .rs1Data(rs1Data_id), .rs2Data(rs2Data_id), 
						  .Branch(Branch));
	
	// 分支地址
	mux2 mux_1(.in0(PC_id), .in1(rs1Data_id), .addr(JALR), .out(JALRAddr));
	adder_32bits adder_1(.a(JALRAddr), .b(offset), .ci(0), .s(JumpAddr), .co());
	
	// 冒险检测
	assign Stall = ((rdAddr_ex==rs1Addr_id)||(rdAddr_ex==rs2Addr_id))&&MemRead_ex;
	assign IFWrite = ~Stall;
endmodule
