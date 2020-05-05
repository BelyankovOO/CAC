module if_id(input clk, input rst, input flush, input write, input [31:0] i_pc_plus4, input [31:0] i_com, output [31:0] o_com, output [31:0] o_pc_plus4);

reg [31:0] o_com, o_pc_plus4;

always @(posedge clk or posedge rst)
begin 
	if(rst)
	begin 
		o_com <= 0;
		o_pc_plus4 <= 0;
	end
	else
	begin	
		if(flush)
		begin
			o_com <= 0;
			o_pc_plus4 <= 0;
		end
		else if(write)
		begin 
			o_com <= i_com;
			o_pc_plus4 <= i_pc_plus4;
		end	
	end			 
end	

endmodule