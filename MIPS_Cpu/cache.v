module cache
	(input clk,
	input rst,
	input write_index,
	input read_index,
	input [31:0] write_data, 
	input [31:0] addr,
	input stall_level_2,
	input [127:0] block_of_data_from_cache_level_2,
	output stall,
	output [31:0] read_data,
	output [31:0] data_to_mem,
	output [31:0] addr_to_mem,
	output mem_write_index,
	output mem_read_index
	);

assign stall = stall_level_2;

reg [31:0] read_data, data_to_mem, addr_to_mem;
reg mem_read_index, mem_write_index;	

reg [26:0] cache_bank [0:7]; 
reg [(4*32)-1:0] data_cache_bank [0:7];
reg valid_bank [0:7];

wire [26:0] tag;	
wire [2:0] index;
wire [1:0] offset;

assign tag = addr[31:5];//27
assign index = addr[4:2];//3
assign offset = addr[1:0];//2

wire [26:0] current_tag; //tag 
wire [(4*32)-1:0] current_data_position;
assign current_tag = cache_bank[index];
assign current_data_position = data_cache_bank[index];

wire current_verific_bit;

assign current_verific_bit = valid_bank[index];

wire hit;
assign hit = current_verific_bit & (current_tag == tag);

integer i;

wire v0, v1, v2, v3, v4, v5, v6 , v7;
assign v0 = valid_bank[0];
assign v1 = valid_bank[1];
assign v2 = valid_bank[2];
assign v3 = valid_bank[3];
assign v4 = valid_bank[4];
assign v5 = valid_bank[5];
assign v6 = valid_bank[6];
assign v7 = valid_bank[7];

reg [1:0] check;
wire check1;
assign check1 = read_index & !hit;

always @* begin
case(offset)
	0: read_data <= current_data_position[31:0];
	1: read_data <= current_data_position[63:32];
	2: read_data <= current_data_position[95:64];
	3: read_data <= current_data_position[127:96];
endcase 
end

always @(posedge clk or posedge rst) begin
if(rst)
begin
	for(i=0; i<8; i=i+1)
	begin
		cache_bank[i] <= 0;
		data_cache_bank[i] <= 0;
		valid_bank[i] <= 0; 
	end	
	data_to_mem <= 0;
	addr_to_mem <= 0;
	mem_write_index <= 0;
	mem_read_index <= 0;
end	
end
				

always @* begin
if(read_index & !hit)
begin
	mem_read_index <= 1;
	mem_write_index <= 0;
	addr_to_mem <= addr;
end	
else if(read_index & hit)
begin
	mem_read_index <= 0;
	mem_write_index <= 0;
end
else if(write_index & !hit)
begin
	addr_to_mem <= addr;
	data_to_mem <= write_data;
	mem_read_index <= 0;
	mem_write_index <= 1;
end
else if(write_index & hit)
begin
	addr_to_mem <= addr;
	data_to_mem <= write_data;
	mem_read_index <= 0;
	mem_write_index <= 1;
	case(offset)
		0: data_cache_bank[index][31:0] <= write_data;
		1: data_cache_bank[index][63:32] <= write_data;
		2: data_cache_bank[index][95:64] <= write_data;
		3: data_cache_bank[index][127:96] <= write_data;
	endcase	
end	
end

always @* 
if(read_index & !hit) 
	if(stall_level_2)
	begin
		valid_bank[index] <= 1;
		check <= 1;
	end
	else 
	begin
		check <= 2;
		valid_bank[index] <= 0;
		data_cache_bank[index] <= block_of_data_from_cache_level_2;
		cache_bank[index] <= current_tag;
	end	

endmodule
