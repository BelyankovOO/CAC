module id_ex(input [4:0] i_rs, input [4:0] i_rt, input [4:0] i_rd, input [1:0] i_ex, input [2:0] i_m, input [1:0] i_wb, input clk, input rst, input [31:0] i_valA, input [31:0] i_valB, input [31:0] i_imm, input [31:0] i_pc_plus4,  input [4:0] i_res, input [5:0] i_operation, output [4:0] o_rs, output [4:0] o_rt, output [4:0] o_rd, output [1:0] o_ex, output [2:0] o_m, output [1:0] o_wb, output [31:0] o_valA, output [31:0] o_valB, output [31:0] o_imm, output [31:0] o_pc_plus4, output [4:0] o_res, output [5:0] o_operation);

reg [1:0] o_ex, o_wb;
reg [2:0] o_m;
reg [31:0] o_valB, o_valA, o_imm, o_pc_plus4;
reg [4:0] o_res, o_rs, o_rt, o_rd;
reg [5:0] o_operation;

always @(posedge clk or posedge rst)
if(rst)
begin 
	o_rs <= 0;
	o_rt <= 0;
	o_rd <= 0;
	o_ex <= 0;
	o_m <= 0;
	o_wb <= 0;
	o_valA <= 0;
	o_valB <= 0;
	o_imm <= 0;
	o_pc_plus4 <= 0;
	o_res <= 0;
	o_operation <= 6'b111111; //change noop
end
else	
begin 
	o_rs <= i_rs;
	o_rt <= i_rt;
	o_rd <= (i_operation == 6'b001000 || i_operation == 6'b100011) ? i_rt : i_rd;// for forwarding addi operation || lw
	o_ex <= i_ex;
	o_m <= i_m;
	o_wb <= i_wb;
	o_valA <= i_valA;
	o_valB <= i_valB;
	o_imm <= i_imm;
	o_pc_plus4 <= i_pc_plus4;
	o_res <= i_res;
	o_operation <= i_operation;
end	

endmodule