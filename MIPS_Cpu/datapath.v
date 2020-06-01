module datapath(input clk, input rst, input w_reg, input w_data, input r_data, input [5:0] op_alu, output zero, output [5:0] funct_control, output [5:0] op_control, output [5:0] op_control_mem, output [5:0] op_control_wb);

wire store;	
wire [31:0] pc, pc_next, pc_plus4;
assign pc_plus4 = pc + 4;
assign pc_next = (ex_mem_operation == OP_J) || ((ex_mem_operation == OP_BEQ) && ex_mem_eq) ? ex_mem_target : pc + 4;

comand comand(.clk(clk), .rst(rst), .in(pc_next), .store(store), .out(pc));

wire [31:0] com;

instructionmemory instructionmemory(.addr(pc), .com(com));

wire [31:0] if_id_com, if_id_pc_plus4;
wire if_id_flush, if_id_write, id_ex_write, ex_mem_write, mem_wb_write, stall;
assign if_id_flush = (ex_mem_operation == OP_J) || ((ex_mem_operation == OP_BEQ) && ex_mem_eq) ;

if_id if_id(.clk(clk), .rst(rst), .flush(if_id_flush), .write(if_id_write), .i_pc_plus4(pc_plus4), .i_com(com), .o_com(if_id_com), .o_pc_plus4(if_id_pc_plus4));

wire [5:0] instruction_op;
assign instruction_op = if_id_com[31:26];
assign op_control = id_ex_operation;
assign op_control_mem = ex_mem_operation;
assign op_control_wb = mem_wb_operation;

wire [4:0] instruction_rs, instruction_rt, instruction_rd, instruction_shamt;
wire [5:0] instruction_funct;
assign instruction_rs = if_id_com[25:21];
assign instruction_rt = if_id_com[20:16];
assign instruction_rd = if_id_com[15:11];
assign instruction_funct = if_id_com[5:0];
assign funct_control = instruction_funct;

wire [15:0] instruction_imm;
wire [31:0] extend_instruction_imm;
assign instruction_imm = if_id_com[15:0];
assign extend_instruction_imm = {{16{instruction_imm[15]}}, instruction_imm};

wire [25:0] instruction_addr;
wire [31:0] extend_instruction_addr;
assign instruction_addr = if_id_com[25:0];
assign extend_instruction_addr = {{6{1'b0}}, instruction_addr};

wire [1:0] ex, wb, ex_control, wb_control;
wire [2:0] m, m_control;

control_unit control_unit(.op(instruction_op), .ex(ex_control), .m(m_control), .wb(wb_control));

wire hazard_check;

assign ex = hazard_check ? ex_control : 0;
assign wb = hazard_check ? wb_control : 0;
assign m = hazard_check ? m_control : 0;

reg [4:0] rn1, rn2;
wire [4:0] wn;
wire [31:0] rd1, rd2, wd;
 
registerblock registerblock(.clk(clk), .rst(rst), .rn1(rn1), .rn2(rn2), .wn(wn), .w(w_reg) , .rd1(rd1), .rd2(rd2), .wd(wd));

wire [31:0] offset;
wire [4:0] dest;
assign offset = (instruction_op == OP_J) ? extend_instruction_addr : extend_instruction_imm;
assign dest = ex[1] ? instruction_rd: instruction_rt;
wire [31:0] id_ex_valA, id_ex_valB, id_ex_imm, id_ex_pc_plus4;
wire [4:0] id_ex_res, id_ex_rs, id_ex_rt, id_ex_rd;
wire [5:0] id_ex_operation;
wire [1:0] id_ex_ex, id_ex_wb;
wire [2:0] id_ex_m;

id_ex id_ex(.write(id_ex_write), .i_rs(instruction_rs), .i_rt(instruction_rt), .i_rd(instruction_rd), .i_ex(ex), .i_m(m), .i_wb(wb), .clk(clk), .rst(rst), .i_valA(rd1), .i_valB(rd2), .i_imm(offset), .i_pc_plus4(if_id_pc_plus4), .i_res(dest), .i_operation(instruction_op), .o_rs(id_ex_rs), .o_rt(id_ex_rt), .o_rd(id_ex_rd), .o_ex(id_ex_ex), .o_m(id_ex_m), .o_wb(id_ex_wb), .o_valA(id_ex_valA), .o_valB(id_ex_valB), .o_imm(id_ex_imm), .o_pc_plus4(id_ex_pc_plus4), .o_res(id_ex_res), .o_operation(id_ex_operation));

hazard_detection_unit hazard_detection_unit(.stall(stall), .if_id_rs(instruction_rs), .if_id_rt(instruction_rt), .id_ex_rt(id_ex_rt), .id_ex_m(id_ex_m[1]), .pc_store(store), .if_id_write(if_id_write), .hazard_check(hazard_check), .id_ex_write(id_ex_write), .ex_mem_write(ex_mem_write), .mem_wb_write(mem_wb_write));

wire [1:0] forwardA, forwardB;

wire [31:0] alu_out;
wire [31:0] alu_in1, alu_in2;
wire [31:0] alu_in2_forwarding;
assign alu_in2_forwarding = (forwardB == 2) ? ex_mem_alu_result : (forwardB == 1) ? wd : (forwardB == 0) ? id_ex_valB : 0;
assign alu_in1 = (forwardA == 2) ? ex_mem_alu_result : (forwardA == 1) ? wd : (forwardA == 0) ? id_ex_valA : 0;
assign alu_in2 = id_ex_ex[0] ? id_ex_imm : alu_in2_forwarding;

alu alu(.in1(alu_in1), .in2(alu_in2), .opcode(op_alu), .zero(zero), .out(alu_out));

wire [31:0] target;
assign target = (id_ex_operation == OP_J) || (id_ex_operation == OP_BEQ) ? id_ex_imm : id_ex_pc_plus4;
wire [31:0] ex_mem_target, ex_mem_alu_result, ex_mem_valB;
wire ex_mem_eq;
wire [4:0] ex_mem_res, ex_mem_rd;
wire [5:0] ex_mem_operation;
wire [2:0] ex_mem_m;
wire [1:0] ex_mem_wb;

ex_mem ex_mem(.write(ex_mem_write), .i_rd(id_ex_rd), .i_m(id_ex_m), .i_wb(id_ex_wb), .clk(clk), .rst(rst), .i_target(target), .i_eq(zero), .i_alu_result(alu_out), .i_valB(alu_in2_forwarding), .i_res(id_ex_res), .i_operation(id_ex_operation), .o_rd(ex_mem_rd), .o_m(ex_mem_m), .o_wb(ex_mem_wb), .o_target(ex_mem_target), .o_eq(ex_mem_eq), .o_alu_result(ex_mem_alu_result), .o_valB(ex_mem_valB), .o_res(ex_mem_res), .o_operation(ex_mem_operation));

wire [31:0] dm_addr, dm_id, dm_od;
assign dm_id = (ex_mem_operation == OP_SW) ? ex_mem_valB : 0; //check
assign dm_addr = ex_mem_alu_result;

wire [31:0] read_data, data_from_mem, data_to_mem, addr_to_mem;
wire mem_write_index, mem_read_index; 

wire [31:0] data_from_mem_level_1, data_to_mem_level_1, addr_to_mem_level_1;
wire mem_write_index_level_1, mem_read_index_level_1; 

wire stall_level_2;
wire [127:0] block_of_data;

cache cache(.clk(clk), .rst(rst), .write_index(w_data), .read_index(r_data), .write_data(dm_id), .addr(dm_addr), .stall_level_2(stall_level_2), .block_of_data_from_cache_level_2(block_of_data), .stall(stall), .read_data(read_data), .data_to_mem(data_to_mem_level_1), .addr_to_mem(addr_to_mem_level_1), .mem_write_index(mem_write_index_level_1), .mem_read_index(mem_read_index_level_1));

cache_level_2 cache_level_2(.clk(clk), .rst(rst), .write_index(mem_write_index_level_1), .read_index(mem_read_index_level_1), .write_data(data_to_mem_level_1), .data_from_mem(data_from_mem), .addr(addr_to_mem_level_1), .stall(stall_level_2), .data_to_mem(data_to_mem), .addr_to_mem(addr_to_mem), .mem_write_index(mem_write_index), .mem_read_index(mem_read_index), .block_of_data_for_cache_level_1(block_of_data));

datamemory datamemory(.clk(clk), .rst(rst), .addr(addr_to_mem), .id(data_to_mem), .w(mem_write_index), .r(mem_read_index), .od(data_from_mem));

wire [31:0] mem_wb_alu_result, mem_wb_mem_out;
wire [4:0] mem_wb_res, mem_wb_rd;
wire [5:0] mem_wb_operation;
wire [1:0] mem_wb_wb;

mem_wb mem_wb(.write(mem_wb_write), .i_rd(ex_mem_rd), .i_wb(ex_mem_wb), .clk(clk), .rst(rst), .i_alu_result(ex_mem_alu_result), .i_mem_out(read_data), .i_res(ex_mem_res), .i_operation(ex_mem_operation), .o_rd(mem_wb_rd), .o_wb(mem_wb_wb), .o_alu_result(mem_wb_alu_result), .o_mem_out(mem_wb_mem_out), .o_res(mem_wb_res), .o_operation(mem_wb_operation));

assign wd = mem_wb_wb[1] ? mem_wb_mem_out : mem_wb_alu_result;
assign wn = mem_wb_res;

forwarding_unit forwarding_unit(.ex_mem_rd(ex_mem_rd), .mem_wb_rd(mem_wb_rd), .id_ex_rs(id_ex_rs), .id_ex_rt(id_ex_rt), .ex_mem_wb(ex_mem_wb[0]), .mem_wb_wb(mem_wb_wb[0]), .forwardA(forwardA), .forwardB(forwardB));

localparam  FUNCT_ADD = 6'b100000,
			OP_R = 6'b000000,
			OP_J = 6'b000010,
			OP_ADDI = 6'b001000,
			OP_BEQ = 6'b000100,
			OP_LW = 6'b100011,
			OP_SW = 6'b101011;

always @*
	begin 
		case(id_ex_operation)
			OP_R:
				//case(instruction_funct)
					//FUNCT_ADD: 
				begin
					rn1 = instruction_rs;
					rn2 = instruction_rt;
				end	
				//endcase
			OP_ADDI:
				begin 
					rn1 = instruction_rs;
				end
			OP_LW: 
				begin 
					rn1 = instruction_rs;
				end
			OP_SW: 
				begin 
					rn1 = instruction_rs;
					rn2 = instruction_rt;
				end
			OP_BEQ: 
				begin 
					rn1 = instruction_rs;
					rn2 = instruction_rt;				
				end
			OP_J: 
				begin
				end
		endcase 
	end

endmodule									








			
