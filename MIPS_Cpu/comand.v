module comand(input clk, input rst , input [31:0] in, input store, output reg [31:0] out);

always @(posedge clk or posedge rst)
	if(rst) out <= 0; 
	else if(store) out <= in;  

endmodule