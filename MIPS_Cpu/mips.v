module mips(input clk, input rst);

wire w_reg, w_data, r_data, zero;
wire [5:0] op_alu, funct_control, op_control, op_control_mem, op_control_wb;

datapath datapath(
	.clk(clk),
	.rst(rst),
	.w_reg(w_reg),
	.w_data(w_data),
	.r_data(r_data),
	.op_alu(op_alu),
	.zero(zero),
	.funct_control(funct_control),
	.op_control(op_control),
	.op_control_mem(op_control_mem),
	.op_control_wb(op_control_wb)
	);

controlpath controlpath(
	.clk(clk),
	.rst(rst),
	.zero(zero),
	.funct(funct_control),
	.op(op_control),
	.op_mem(op_control_mem),
	.op_wb(op_control_wb),
	.w_data(w_data),
	.r_data(r_data),
	.w_reg(w_reg),
	.op_alu(op_alu)
	);

endmodule	