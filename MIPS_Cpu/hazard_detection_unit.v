module hazard_detection_unit(input stall, input [4:0] if_id_rs, input [4:0] if_id_rt, input [4:0] id_ex_rt, input id_ex_m, output pc_store, output if_id_write, output hazard_check, output id_ex_write, output ex_mem_write, output mem_wb_write);

reg pc_store, if_id_write, hazard_check, id_ex_write, ex_mem_write, mem_wb_write;

always@(if_id_rs or if_id_rt or id_ex_rt or id_ex_m or stall)
if(stall)
begin
	id_ex_write = 0;
	ex_mem_write = 0;
	mem_wb_write = 0;
	pc_store = 0;
	if_id_write = 0;
	hazard_check = 0;
end
else if(id_ex_m & ((id_ex_rt == if_id_rs) | (id_ex_rt == if_id_rt)))
begin
	id_ex_write = 1;
	ex_mem_write = 1;
	mem_wb_write = 1;
	pc_store = 0;
	if_id_write = 0;
	hazard_check = 0;
end
else
begin 
	id_ex_write = 1;
	ex_mem_write = 1;
	mem_wb_write = 1;
	pc_store = 1;
	if_id_write = 1;
	hazard_check = 1;
end

endmodule	