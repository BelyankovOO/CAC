module registerblock(input clk, input rst, input [4:0] rn1, input [4:0] rn2, input [4:0] wn, input w, output [31:0] rd1, output [31:0] rd2, output [31:0] wd);


reg [31:0] rf [31:0];
integer i;

assign rd1 = rn1 ? rf[rn1] : 0;
assign rd2 = rn2 ? rf[rn2] : 0;

always @(posedge clk or posedge rst)
	if(rst) 
		begin
			for(i=0; i<32; i=i+1) rf[i] <= 0;
		end 
	else if(w) rf[wn] <= wd; 

endmodule	
