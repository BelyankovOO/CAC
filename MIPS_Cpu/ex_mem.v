module ex_mem(input write, input [4:0] i_rd, input [2:0] i_m, input [1:0] i_wb, input clk, input rst, input [31:0] i_target, input i_eq, input [31:0] i_alu_result, input [31:0] i_valB, input [4:0] i_res, input [5:0] i_operation, output [4:0] o_rd, output [2:0] o_m, output [1:0] o_wb, output [31:0] o_target, output o_eq, output [31:0] o_alu_result, output [31:0] o_valB, output [4:0] o_res, output [5:0] o_operation);

reg [31:0] o_target, o_valB, o_alu_result;
reg [5:0] o_operation;
reg [4:0] o_res, o_rd;
reg [2:0] o_m;
reg [1:0] o_wb;
reg o_eq;

always @(posedge clk or posedge rst)
if(rst)
begin
	o_rd <= 0;
	o_m <= 0;
	o_wb <= 0;
	o_target <= 0;
	o_eq <= 0;
	o_valB <= 0;
	o_alu_result <= 0;
	o_res <= 0;
	o_operation <= 6'b111111; //change noop
end	
else
if(write)
begin
	o_rd <= i_rd;
	o_m <= i_m;
	o_wb <= i_wb;
	o_target <= i_target;
	o_eq <= i_eq;
	o_valB <= i_valB;
	o_alu_result <= i_alu_result;
	o_res <= i_res;
	o_operation <= i_operation;
end	

endmodule