module full_adder(a, b, s, co);
	input[21:0] a, b;
	output[21:0] s;
	output co;
	reg[21:0] s;
	reg co;
	always @(*)
	begin
        {co, s}=a+b;
	end
endmodule