module controlpath(input clk, input rst, input zero, input [5:0] funct, input [5:0] op, input [5:0] op_mem, input [5:0] op_wb, output w_data, output r_data, output w_reg, output reg [5:0] op_alu);

localparam  FUNCT_ADD = 6'b100000,
			OP_R = 6'b000000,
			OP_J = 6'b000010,
			OP_ADDI = 6'b001000,
			OP_BEQ = 6'b000100,
			OP_LW = 6'b100011,
			OP_SW = 6'b101011;

assign w_data = (op_mem == OP_SW) ? 1 : 0;	
assign r_data = (op_mem == OP_LW) ? 1 : 0;
assign w_reg  = (op_wb == OP_R || op_wb == OP_ADDI || op_wb == OP_LW) ? 1 : 0;		

always @(op) 
	begin
		op_alu = 0;
		case(op) 
			OP_R:
				begin
					op_alu = 6'b000000; //sum
				end	
			OP_ADDI: 
				begin 
					op_alu = 6'b000001;
				end
			OP_LW: 
				begin 
					op_alu = 6'b000010;
				end	
			OP_SW:
				begin
					op_alu = 6'b000011;
				end
			OP_BEQ:
				begin 
					op_alu = 6'b000100;
				end	
			OP_J: 
				begin
				end	
			default: 
				begin 
				end		
		endcase
	end

endmodule						 		


