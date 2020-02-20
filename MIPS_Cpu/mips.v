module mips(input clk, input rst);

wire store, w_reg, w_data, zero;
wire [5:0] op_alu, funct_control, op_control;

datapath datapath(
	.clk(clk),
	.rst(rst),
	.store(store),
	.w_reg(w_reg),
	.w_data(w_data),
	.op_alu(op_alu),
	.zero(zero),
	.funct_control(funct_control),
	.op_control(op_control)
	);

controlpath controlpath(
	.clk(clk),
	.rst(rst),
	.zero(zero),
	.funct(funct_control),
	.op(op_control),
	.w_data(w_data),
	.w_reg(w_reg),
	.store(store),
	.op_alu(op_alu)
	);

endmodule	