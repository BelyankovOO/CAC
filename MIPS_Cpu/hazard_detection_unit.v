module hazard_detection_unit(input [4:0] if_id_rs, input [4:0] if_id_rt, input [4:0] id_ex_rt, input id_ex_m, output pc_store, output if_id_write, output hazard_check);

reg pc_store, if_id_write, hazard_check;

always@(if_id_rs or if_id_rt or id_ex_rt or id_ex_m)
if(id_ex_m & ((id_ex_rt == if_id_rs) | (id_ex_rt == if_id_rt)))
begin
pc_store = 0;
if_id_write = 0;
hazard_check = 0;
end
else
begin 
pc_store = 1;
if_id_write = 1;
hazard_check = 1;
end

endmodule	