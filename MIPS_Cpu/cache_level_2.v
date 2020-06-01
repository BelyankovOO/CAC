module cache_level_2
	(input clk,
	input rst,
	input write_index,
	input read_index,
	input [31:0] write_data, 
	input [31:0] data_from_mem,
	input [31:0] addr,
	output stall,
	output [31:0] data_to_mem,
	output [31:0] addr_to_mem,
	output mem_write_index,
	output mem_read_index,
	output [127:0] block_of_data_for_cache_level_1
	);

assign stall = read_index & !hit; 

reg [31:0] data_to_mem, addr_to_mem;
reg mem_read_index, mem_write_index;

reg [24:0] cache_bank [0:15]; 
reg [(8*32)-1:0] data_cache_bank [0:15];
reg valid_bank [0:15];

wire [24:0] tag;	
wire [3:0] index;
wire [2:0] offset;

assign tag = addr[31:7];
assign index = addr[6:3];
assign offset = addr[2:0];

wire [24:0] current_tag;  
wire [(8*32)-1:0] current_data_position;
assign current_tag = cache_bank[index];
assign current_data_position = data_cache_bank[index];

assign block_of_data_for_cache_level_1 = (offset > 3) ? current_data_position[255:128] : current_data_position[127:0];


wire current_verific_bit;

assign current_verific_bit = valid_bank[index];

wire hit;

assign hit = current_verific_bit & (current_tag == tag);

integer i;

reg [4:0] counter;

wire [31:0] addr_to_read;
assign addr_to_read = {addr[31:3], 3'b000};

wire [24:0] check1;
assign check1 = cache_bank[0];

always @(posedge clk or posedge rst) begin
	if(rst)
	begin
		for(i=0; i<15; i=i+1)
		begin
			cache_bank[i] <= 0;
			data_cache_bank[i] <= 0;
			valid_bank[i] <= 0; 
		end
		counter <= 8;	
		data_to_mem <= 0;
		addr_to_mem <= 0;
		mem_write_index <= 0;
		mem_read_index <= 0;
	end	
	else 
	if(read_index & !hit)
	begin
		case(counter)
			8:  begin
					valid_bank[index] <= 0;
					counter <= counter - 1;
				end 
			7: 	begin
					valid_bank[index] <= 0;
					data_cache_bank[index][31:0] <= data_from_mem;
					counter <= counter - 1;
				end
			6:	begin
					valid_bank[index] <= 0;
					data_cache_bank[index][63:32] <= data_from_mem;
					counter <= counter - 1;
				end
			5:	begin
					valid_bank[index] <= 0;
					data_cache_bank[index][95:64] <= data_from_mem;
					counter <= counter - 1;
				end
			4:	begin 
					valid_bank[index] <= 0;
					data_cache_bank[index][127:96] <= data_from_mem;
					counter <= counter - 1;
			   	end
			3:  begin
					valid_bank[index] <= 0;
					data_cache_bank[index][159:128] <= data_from_mem;
					counter <= counter - 1;
				end 
			2: 	begin
					valid_bank[index] <= 0;
					data_cache_bank[index][191:169] <= data_from_mem;
					counter <= counter - 1;
				end
			1:	begin
					valid_bank[index] <= 0;
					data_cache_bank[index][223:192] <= data_from_mem;
					counter <= counter - 1;
				end
			0:	begin
					valid_bank[index] <= 1;
					data_cache_bank[index][255:224] <= data_from_mem;
					counter <= 8;
					cache_bank[index] <= tag;
				end
		endcase		
	end
	else counter <= 8;				
end

always @*
if(read_index & !hit)
begin
	mem_read_index <= 1;
	mem_write_index <= 0;
	case(counter)
		8:	addr_to_mem <= addr_to_read;
		7:	addr_to_mem <= addr_to_read + 1;
		6:	addr_to_mem <= addr_to_read + 2;
		5:	addr_to_mem <= addr_to_read + 3;
		4:	addr_to_mem <= addr_to_read + 4;
		3:	addr_to_mem <= addr_to_read + 5;
		2:	addr_to_mem <= addr_to_read + 6;
		1:	addr_to_mem <= addr_to_read + 7;
	endcase	
	//addr_to_mem <= addr;
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
		4: data_cache_bank[index][159:128] <= write_data;
		5: data_cache_bank[index][191:160] <= write_data;
		6: data_cache_bank[index][223:192] <= write_data;
		7: data_cache_bank[index][255:224] <= write_data;
	endcase	
end	

endmodule