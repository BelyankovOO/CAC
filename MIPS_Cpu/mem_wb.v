module mem_wb(input [4:0] i_rd, input [1:0] i_wb, input clk, input rst, input [31:0] i_alu_result, input [31:0] i_mem_out, input [4:0] i_res, input [5:0] i_operation, output [4:0] o_rd, output [1:0] o_wb,  output [31:0] o_alu_result, output [31:0] o_mem_out, output [4:0] o_res, output [5:0] o_operation);

reg [31:0] o_alu_result, o_mem_out;
reg [4:0] o_res, o_rd;
reg [5:0] o_operation;
reg [1:0] o_wb;

always @(posedge clk or posedge rst)
if(rst)
begin
	o_rd <= 0;
	o_wb <= 0;
	o_alu_result <= 0;
	o_mem_out <= 0;
	o_res <= 0;
	o_operation <= 6'b111111; //change noop
end	
else
begin
	o_rd <= i_rd;
	o_wb <= i_wb;
	o_alu_result <= i_alu_result;
	o_mem_out <= i_mem_out;
	o_res <= i_res;
	o_operation <= i_operation;
end	

endmodule