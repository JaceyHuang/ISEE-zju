module BranchTest(Instruction, rs1Data, rs2Data, Branch);
	input [31:0] Instruction, rs1Data, rs2Data;
	output reg Branch;
    
	parameter SB_type_op = 7'b1100011; // 7'h63;
	parameter beq_funct3 = 3'o0;
	parameter bne_funct3 = 3'o1;
	parameter blt_funct3 = 3'o4;
	parameter bge_funct3 = 3'o5;
	parameter bltu_funct3 = 3'o6;
	parameter bgeu_funct3 = 3'o7;
	
	wire [6:0] op; // 操作码
	wire [2:0] funct3; // 功能码
	wire [31:0] sum; // 加法结果
	wire SB_type;
	wire isLT, isLTU; // 比较结果
	assign op = Instruction[6:0];
	assign funct3 = Instruction[14:12];
	assign SB_type = (op==SB_type_op);
	
	// sum = rs1Data + ~rs2Data + 1
	adder_32bits adder(.a(rs1Data), .b(~rs2Data), .ci(1), .s(sum), .co());
	
	// 确定比较运算的结果
	assign isLT = rs1Data[31]&&(~rs2Data)||(rs1Data[31]~^rs2Data[31])&&sum[31]; // 符号数
	assign isLTU = (~rs1Data[31])&&rs2Data[31]||(rs1Data[31]~^rs2Data[31])&&sum[31]; // 非符号数
	
	// 数据选择器完成分支检果
	always @ (*)
	begin
		if (SB_type)
		begin
			case (funct3)
				beq_funct3: Branch = ~(|sum[31:0]); // beq
				bne_funct3: Branch = |sum[31:0];    // bne
				blt_funct3: Branch = isLT;          // blt
				bge_funct3: Branch = ~isLT;         // bge
				bltu_funct3: Branch = isLTU;        // bltu
				bgeu_funct3: Branch = ~isLTU;       // bgeu
				default: Branch = 0;
			endcase
		end
		else Branch = 0;
	end
endmodule