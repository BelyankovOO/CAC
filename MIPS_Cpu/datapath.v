module datapath(input clk, input rst, input store, input w_reg, input w_data, input [5:0] op_alu, output zero, output [5:0] funct_control, output [5:0] op_control);

wire [31:0] dm_addr, dm_id, dm_od;
assign dm_id = (instruction_op == OP_SW) ? rd2 : 0; 

datamemory datamemory(.clk(clk), .addr(dm_addr), .id(dm_id), .w(w_data), .od(dm_od));	

reg [31:0] pc_next;
wire [31:0] pc;

comand comand(.clk(clk), .rst(rst), .in(pc_next), .store(store), .out(pc));

reg [4:0] rn1, rn2, wn;
wire [31:0] rd1, rd2, wd;
 
registerblock registerblock(.clk(clk), .rst(rst), .rn1(rn1), .rn2(rn2), .wn(wn), .w(w_reg) , .rd1(rd1), .rd2(rd2), .wd(wd));

wire [31:0] com;

instructionmemory instructionmemory(.addr(pc), .com(com));

wire [5:0] instruction_op;
assign instruction_op = com[31:26];
assign op_control = instruction_op;

wire [4:0] instruction_r_rs, instruction_r_rt, instruction_r_rd, instruction_r_shamt;
wire [5:0] instruction_r_funct;
assign instruction_r_rs = com[25:21];
assign instruction_r_rt = com[20:16];
assign instruction_r_rd = com[15:11];
//assign instruction_r_shamt = com[10:6];
assign instruction_r_funct = com[5:0];
assign funct_control = instruction_r_funct;

wire [4:0] instruction_i_rs, instruction_i_rt;
wire [15:0] instruction_i_imm;
assign instruction_i_rs = com[25:21];
assign instruction_i_rt = com[20:16];
assign instruction_i_imm = com[15:0];

wire [25:0] instruction_j_addr;
assign instruction_j_addr = com[25:0];

wire [31:0] alu_out;
assign dm_addr = alu_out;
assign wd = (instruction_op == OP_LW) ? dm_od : alu_out;

alu alu(.in1(rd1), .in2(rd2), .opcode(op_alu), .zero(zero), .out(alu_out), .imm(instruction_i_imm));

localparam  FUNCT_ADD = 6'b100000,
			OP_R = 6'b000000,
			OP_J = 6'b000010,
			OP_ADDI = 6'b001000,
			OP_BEQ = 6'b000100,
			OP_LW = 6'b100011,
			OP_SW = 6'b101011;

always @*
	begin 
		pc_next = pc + 4;
		case(instruction_op)
			OP_R:
				case(instruction_r_funct)
					FUNCT_ADD: 
						begin
							rn1 = instruction_r_rs;
							rn2 = instruction_r_rt;
							wn = instruction_r_rd;
						end	
				endcase
			OP_ADDI:
				begin 
					rn1 = instruction_i_rs;
					wn = instruction_i_rt;
				end
			OP_LW: 
				begin 
					rn1 = instruction_i_rs;
					wn = instruction_i_rt;
				end
			OP_SW: 
				begin 
					rn1 = instruction_i_rs;
					rn2 = instruction_i_rt;
				end
			OP_BEQ: 
				begin 
					rn1 = instruction_i_rs;
					rn2 = instruction_i_rt;
					if(zero) pc_next = instruction_i_imm; //?
				end
			OP_J: 
				begin
					pc_next = instruction_j_addr;
				end
		endcase 
	end

endmodule									








			
