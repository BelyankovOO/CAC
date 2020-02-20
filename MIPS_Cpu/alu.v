module alu(input [31:0] in1, input [31:0] in2, input [5:0] opcode, output zero, output reg [31:0] out, input [15:0] imm);
	
wire [31:0] extend_imm;
assign extend_imm = {{16{imm[15]}},imm};

always @(in1,in2,opcode) begin
	case(opcode)
		6'b000000: out = in1 + in2; //sum
		6'b000001: out = in1 + extend_imm; //addi
		6'b000010: out = in1 + extend_imm; //lw
		6'b000011: out = in1 + extend_imm; //sw
		6'b000100: out = in1 - in2; //beq
		//6'b000101: 
	endcase
end	 
	
assign zero = out == 0;

endmodule		