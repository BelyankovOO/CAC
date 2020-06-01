module alu(input [31:0] in1, input [31:0] in2, input [5:0] opcode, output zero, output reg [31:0] out);
	
always @(in1,in2,opcode) begin
	case(opcode)
		6'b000000, 6'b000001, 6'b000010, 6'b000011 : out = in1 + in2; //sum, addi, lw, sw
		6'b000100: out = in1 - in2; //beq
		default: out = in1 + in2; 
	endcase
end	 
	
assign zero = out == 0;

endmodule		