module datamemory(input clk, input [31:0] addr, input [31:0] id, input w, output [31:0] od);

reg [31:0] DATA [31:0];

always @(posedge clk)
	if(w) DATA[addr] <= id;

assign od = DATA[addr];

endmodule

