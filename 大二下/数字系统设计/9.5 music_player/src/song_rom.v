module song_rom (clk, dout, addr);	
	input clk;				
	output [11:0] dout;	
	input [5:0] addr; // 地址即为计时，第几个音符				
					
	reg [11:0] dout;						

	always @(posedge clk)
	begin
		case (addr)
			0: dout <= 'h005;       // 低音5
			1: dout <= 'h005;
			2: dout <= 'h030;       // 中音3
			3: dout <= 'h020;       // 中音2
			4: dout <= 'h010;       // 中音1
			5: dout <= 'h005;       // 低音5
			6: dout <= 'h005;       
			7: dout <= 'h005;
			8: dout <= 'h005;       
			9: dout <= 'h030;
			10: dout <= 'h020;      
			11: dout <= 'h010; 
			12: dout <= 'h006; 
			13: dout <= 'h006; 
			14: dout <= 'h006; 
			15: dout <= 'h006; 
			16: dout <= 'h006; 
			17: dout <= 'h040;
			18: dout <= 'h030;
			19: dout <= 'h020;
			20: dout <= 'h006; 
			21: dout <= 'h006; 
			22: dout <= 'h006; 
			23: dout <= 'h006; 
			24: dout <= 'h050; 
			25: dout <= 'h050; 
			26: dout <= 'h040; 
			27: dout <= 'h020; 
			28: dout <= 'h030;
			29: dout <= 'h030; 
			30: dout <= 'h010; 
			31: dout <= 'h005; 
			32: dout <= 'h005; 
			33: dout <= 'h003; 
			34: dout <= 'h002; 
			35: dout <= 'h001; 
			36: dout <= 'h005; 
			37: dout <= 'h005; 
			38: dout <= 'h005; 
			39: dout <= 'h005; 
			40: dout <= 'h005; 
			41: dout <= 'h030; 
			42: dout <= 'h020; 
			43: dout <= 'h010; 
			44: dout <= 'h006; 
			45: dout <= 'h006; 
			46: dout <= 'h006; 
			47: dout <= 'h006; 
			48: dout <= 'h006; 
			49: dout <= 'h040; 
			50: dout <= 'h030; 
			51: dout <= 'h020; 
			52: dout <= 'h050;
			53: dout <= 'h050;
			54: dout <= 'h050;
			55: dout <= 'h050;
			56: dout <= 'h060;
			57: dout <= 'h050;
			58: dout <= 'h040;
			59: dout <= 'h020;
			60: dout <= 'h010;
			61: dout <= 'h010;
			62: dout <= 'h010;
		endcase					
	end
endmodule							
