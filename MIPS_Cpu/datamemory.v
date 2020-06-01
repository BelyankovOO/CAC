module datamemory(input clk, input rst, input [31:0] addr, input [31:0] id, input w, input r, output [31:0] od);

reg [31:0] od;

reg [31:0] DATA [0:1023];

integer i;

always @(posedge clk or posedge rst)
	if(rst)
	begin	
		for(i=0; i<1024; i=i+1)	DATA[i] <= 0;
		od <= 0;
	end	
	else
	if(w) DATA[addr] <= id;
	else 
	if(r) od <= DATA[addr];
endmodule

