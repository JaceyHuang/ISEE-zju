module mux4_1(in, addr, out);
    input [3:0] in; // 4个输入
    input [1:0] addr; // 2位地址
    output reg out; //输出

    always @ (in, addr)
    begin
        out = in[addr];
    end
endmodule