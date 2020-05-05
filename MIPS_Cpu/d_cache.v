module d_cache#(parameter DATA_WIDHT = 32,
parameter ADDRESS_WIDTH = 32,
parameter TAG_WIDHT = 21,
parameter INDEX_WIDTH = 7,
parameter OFFSET_WIDTH = 4)
(input clk,
input rst, 
input i_valid,
input [ADDRESS_WIDTH-1:0] i_address, 
input i_mem_valid,
input i_mem_last,
input [DATA_WIDHT-1:0] i_mem_data, 
input i_read_marker,
input i_write_marker,
input [DATA_WIDHT-1:0] i_write_data,
input i_mem_data_read,
output o_mem_valid,
output [ADDRESS_WIDTH-1:0] o_mem_address,
output o_ready,
output o_valid,
output [DATA_WIDHT-1:0] o_data,
output o_mem_read_write,
output [DATA_WIDHT-1:0] o_mem_data);

reg [ADDRESS_WIDTH-1:0] r_i_address;
reg [TAG_WIDHT-1:0] r_i_tag;
reg [INDEX_WIDTH-1:0] r_i_index;
reg [OFFSET_WIDTH-1:0] r_i_offset;


wire [TAG_WIDHT-1:0] i_tag;
wire [INDEX_WIDTH-1:0] i_index;
wire [OFFSET_WIDTH-1:0] i_offset;
assign i_tag = i_address[31:11];
assign i_index = i_address[10:4];
assign i_offset = i_address[3:0];

reg [TAG_WIDHT-1:0] tag_array [0:127]; 
reg [(16*DATA_WIDHT)-1:0] data_array [0:127];
reg valid_array [0:127];
reg dirty_array [0:127];

reg r_i_read_write; //1 - read, 0 - write

wire cache_hit, cache_read_hit, cache_write_hit, cache_miss;
assign cache_hit = i_valid && valid_array[i_index] && (tag_array[i_index] == i_tag) && !o_valid; //
assign cache_read_hit = cache_hit && i_read_marker && (state == STATE_READY);
assign cache_write_hit = cache_hit && i_write_marker && (state == STATE_READY);
assign cache_miss = !cache_hit && i_valid && !o_valid;

reg [1:0] state;

localparam STATE_READY = 2'b00,
		   STATE_PAUSE = 2'b01,
		   STATE_INCLUDE = 2'b10,
		   STATE_OUT = 2'b11;

always@(posedge clk or posedge rst) begin
	if(rst) 
	begin
		state <= STATE_READY;
		o_mem_valid <= 0;
	end	
	else 
	begin
		case(state)
			STATE_READY: 
			begin
				if(cache_read_hit) 
				begin 
					r_i_read_write <= 1;
					o_valid <= 1;
					r_i_offset = i_offset;
				end
				else 
				if(cache_write_hit)
				begin
					r_i_read_write <= 0;
					o_valid <= 1;
					dirty_array[i_index] <= 1;
				end	
				if(cache_miss) 
				begin
					r_i_address <= i_address;
					r_i_offset <= i_offset;
					r_i_index <= i_index;
					r_i_tag <= i_tag;
					r_i_read_write <= (i_read_marker == 1) ? 1 : 0;
					o_mem_valid <= 1;
					if(!valid_array[i_index] || !dirty_array[i_index])
					begin
						state <= STATE_INCLUDE;
						o_mem_read_write <= 1;
						o_mem_address <= {i_tag, i_index, i_offset};
					end	
					else if(dirty_array[i_index])
					begin
						state <= STATE_OUT;
						o_mem_address <= {i_tag, i_index, i_offset};
					end	
				end	
			end	
			STATE_OUT: 
			begin
				o_mem_read_write <= 0;
				if(i_read_marker)
			end
	end	

end



endmodule