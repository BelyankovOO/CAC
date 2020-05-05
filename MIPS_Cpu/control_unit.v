module control_unit(input [5:0] op, output [1:0] ex, output [2:0] m, output [1:0] wb);

wire choose_reg_for_dest, choose_alu_in2, branch, read_from_memory, write_to_memory, choose_in_for_reg, reg_to_write;

wire op_r = ~op[5]&~op[4]&~op[3]&~op[2]&~op[1]&~op[0];  //000000
wire op_lw = op[5]&~op[4]&~op[3]&~op[2]&op[1]&op[0];    //100011
wire op_sw = op[5]&~op[4]&op[3]&~op[2]&op[1]&op[0];     //101011
wire op_addi = ~op[5]&~op[4]&op[3]&~op[2]&~op[1]&~op[0];//001000
wire op_beq = ~op[5]&~op[4]&~op[3]&op[2]&~op[1]&~op[0];//000100
wire op_j = ~op[5]&~op[4]&~op[3]&~op[2]&op[1]&~op[0];   //000010

wire [1:0] ex;
wire [2:0] m;
wire [1:0] wb;

assign choose_reg_for_dest = op_r;
assign choose_alu_in2 = op_lw|op_sw|op_addi;

assign branch = op_beq;
assign read_from_memory = op_lw;
assign write_to_memory = op_sw;

assign choose_in_for_reg = op_lw;
assign reg_to_write = op_r|op_lw|op_addi; 

assign ex[1] = choose_reg_for_dest;
assign ex[0] = choose_alu_in2;

assign m[2] = branch;
assign m[1] = read_from_memory;
assign m[0] = write_to_memory;

assign wb[1] = choose_in_for_reg;
assign wb[0] = reg_to_write;

endmodule 


