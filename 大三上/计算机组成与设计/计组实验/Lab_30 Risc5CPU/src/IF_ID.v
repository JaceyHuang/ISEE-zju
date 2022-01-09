module IF_ID(clk, EN, R, PC_if, Instruction_if, PC_id, Instruction_id);
	input clk, EN, R; // EN低电平表示数据冒险
	input [31:0] PC_if, Instruction_if;
	output reg [31:0] PC_id, Instruction_id;
	
	always @ (posedge clk)
	begin
		// 跳转或分支成立，清空流水线寄存器
		if (R) begin PC_id = 0; Instruction_id = 0; end
		// 发生数据冒险，阻塞流水线寄存器
		else if (!EN) begin PC_id = PC_id; Instruction_id = Instruction_id; end
		// 正常工作
		else begin PC_id = PC_if; Instruction_id = Instruction_if; end
	end
endmodule