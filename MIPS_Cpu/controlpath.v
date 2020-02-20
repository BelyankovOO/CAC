module controlpath(input clk, input rst, input zero, input [5:0] funct, input [5:0] op, output reg w_data, output reg w_reg, output reg store, output reg [5:0] op_alu);

localparam  FUNCT_ADD = 6'b100000,
			OP_R = 6'b000000,
			OP_J = 6'b000010,
			OP_ADDI = 6'b001000,
			OP_BEQ = 6'b000100,
			OP_LW = 6'b100011,
			OP_SW = 6'b101011;

always @(funct, op) 
	begin
		w_data = 0;
		w_reg = 0;
		store = 0;
		op_alu = 0;

		case(op) 
			OP_R:
				case(funct) 
					FUNCT_ADD:
						begin
							w_reg = 1;
							store = 1;
							op_alu = 6'b000000; //sum
						end	
				endcase
			OP_ADDI: 
				begin 
					w_reg = 1;
					store = 1;
					op_alu = 6'b000001;
				end
			OP_LW: 
				begin
					store = 1; 
					w_reg = 1;
					op_alu = 6'b000010;
				end	
			OP_SW:
				begin
					store = 1;
					w_data = 1;
					op_alu = 6'b000011;
				end
			OP_BEQ:
				begin 
					store = 1;
					op_alu = 6'b000100;
				end	
		endcase
	end

endmodule						 		


