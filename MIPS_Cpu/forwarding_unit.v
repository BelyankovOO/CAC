module forwarding_unit(input [4:0] ex_mem_rd, input [4:0] mem_wb_rd, input [4:0] id_ex_rs, input [4:0] id_ex_rt, input ex_mem_wb, input mem_wb_wb, output [1:0] forwardA, output [1:0] forwardB);

reg [1:0] forwardA, forwardB;

always@ (ex_mem_wb or ex_mem_rd or id_ex_rs or mem_wb_wb or mem_wb_rd)
begin 
if((ex_mem_wb) && (ex_mem_rd != 0) && (ex_mem_rd == id_ex_rs))
	forwardA = 2;
else if((mem_wb_wb) && (mem_wb_rd != 0) && (mem_wb_rd == id_ex_rs) && (ex_mem_rd != id_ex_rs))
	forwardA = 1;
else forwardA = 0;
end

always@ (mem_wb_wb or mem_wb_rd or id_ex_rt or ex_mem_rd or ex_mem_wb)
begin
if((mem_wb_wb) && (mem_wb_rd != 0) && (mem_wb_rd == id_ex_rt) && (ex_mem_rd != id_ex_rt))
	forwardB = 1;
else if((ex_mem_wb) && (ex_mem_rd !=0) && (ex_mem_rd == id_ex_rt))
	forwardB = 2;
else forwardB = 0;
end

endmodule