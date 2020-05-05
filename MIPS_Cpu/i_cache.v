module i_cache#(parameter DATA_WIDHT = 32,
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
output o_mem_valid,
output [ADDRESS_WIDTH-1:0] o_mem_address,
output o_ready,
output o_valid,
output [DATA_WIDHT-1:0] o_data);

reg [TAG_WIDHT-1:0] r_i_tag; //21
reg [INDEX_WIDTH-1:0] r_i_index; //7
reg [OFFSET_WIDTH-1:0] r_i_offset; //4

wire [TAG_WIDHT-1:0] i_tag; //21
wire [INDEX_WIDTH-1:0] i_index; //7
wire [OFFSET_WIDTH-1:0] i_offset; //4

assign i_tag = i_address[31:11];
assign i_index = i_address[10:4];
assign i_offset = i_address[3:0];

reg [TAG_WIDHT-1:0] tag_array [0:127] [0:1]; //tag array
reg [(16*DATA_WIDHT)-1:0] data_array [0:127] [0:1]; //data array
reg valid_array [0:127] [0:1];

reg counter;

reg number_of_bank, r_number_of_bank;

reg [1:0] state, nextstate;

localparam STATE_READY = 2'b00,
		   STATE_MISS = 2'b01;

integer i,j;

always @* begin 
	if(tag_array[i_index][0] == i_tag) number_of_bank = 0;
	else if(tag_array[i_index][1] == i_tag) number_of_bank = 1;
	else number_of_bank = 1'bx;
end	

always @* begin
	//need add default 
	case(state)
		STATE_READY: 
		begin
			if(i_valid)
			begin
				if(valid_array[i_index][number_of_bank] && (tag_array[i_index][number_of_bank] == i_tag))
				begin
					o_valid <= 1; //hit
					case(i_offset)
						0:	o_data <= data_array[i_index][number_of_bank][(DATA_WIDHT*1)-1:0];
						1:	o_data <= data_array[i_index][number_of_bank][(DATA_WIDHT*2)-1:(DATA_WIDHT*1)];
						2:	o_data <= data_array[i_index][number_of_bank][(DATA_WIDHT*3)-1:(DATA_WIDHT*2)];
						3:	o_data <= data_array[i_index][number_of_bank][(DATA_WIDHT*4)-1:(DATA_WIDHT*3)];
						4:	o_data <= data_array[i_index][number_of_bank][(DATA_WIDHT*5)-1:(DATA_WIDHT*4)];
						5:	o_data <= data_array[i_index][number_of_bank][(DATA_WIDHT*6)-1:(DATA_WIDHT*5)];
						6:	o_data <= data_array[i_index][number_of_bank][(DATA_WIDHT*7)-1:(DATA_WIDHT*6)];
						7:	o_data <= data_array[i_index][number_of_bank][(DATA_WIDHT*8)-1:(DATA_WIDHT*7)];
						8:  o_data <= data_array[i_index][number_of_bank][(DATA_WIDHT*9)-1:(DATA_WIDHT*8)];
						9:	o_data <= data_array[i_index][number_of_bank][(DATA_WIDHT*10)-1:(DATA_WIDHT*9)];
						10: o_data <= data_array[i_index][number_of_bank][(DATA_WIDHT*11)-1:(DATA_WIDHT*10)];
						11:	o_data <= data_array[i_index][number_of_bank][(DATA_WIDHT*12)-1:(DATA_WIDHT*11)];	
						12:	o_data <= data_array[i_index][number_of_bank][(DATA_WIDHT*13)-1:(DATA_WIDHT*12)];
						13:	o_data <= data_array[i_index][number_of_bank][(DATA_WIDHT*14)-1:(DATA_WIDHT*13)];
						14: o_data <= data_array[i_index][number_of_bank][(DATA_WIDHT*15)-1:(DATA_WIDHT*14)];
						15: o_data <= data_array[i_index][number_of_bank][(DATA_WIDHT*16)-1:(DATA_WIDHT*15)];
						default: o_data <= {32{1'bx}};
					endcase	
				end
				else
				begin
					nextstate <= STATE_MISS;
				end				
			end	
		end

		STATE_MISS: 
		begin
			o_mem_valid <= 1;
			o_mem_address <= {r_i_tag, r_i_index, r_i_offset};
			if(i_mem_valid)
			begin
				if(couter == r_i_offset)
				begin
					o_valid <= 1;
					o_data <= i_mem_data;
				end 

				if(i_mem_last)//check this
				begin
					nextstate <= STATE_READY;
				end	
			end
		end	

	endcase 	
end

always@(posedge clk or posedge rst) begin
	if(rst)
	begin 
		for(i=0; i<2; i=i+1)
		begin
			for(j=0; j<128; j=j+1)
			begin
				valid_array[j][i] = 0;
			end
		end		
		state <= STATE_READY;
	end 
	else 
	begin
		state <= nextstate;
		case(state)
			STATE_READY: 
			begin
				if(nextstate == STATE_MISS)
				begin
					counter <= 0;
					r_i_tag <= i_tag;
					r_i_index <= i_index;
					r_i_offset <= i_offset;
					r_number_of_bank <= number_of_bank;
				end	
			end

			STATE_MISS: 
			begin
				if(nextstate == STATE_READY)
				begin
					tag_array[r_i_index][r_number_of_bank] <= r_i_tag;
					valid_array[r_i_index][r_number_of_bank] <= 1;
				end	

				if(i_mem_valid)
				begin
					case(counter)
						0:	data_array[r_i_index][r_number_of_bank][(DATA_WIDHT*1)-1:0] <= i_mem_data;
						1:	data_array[r_i_index][r_number_of_bank][(DATA_WIDHT*2)-1:(DATA_WIDHT*1)] <= i_mem_data;
						2:	data_array[r_i_index][r_number_of_bank][(DATA_WIDHT*3)-1:(DATA_WIDHT*2)] <= i_mem_data;
						3:	data_array[r_i_index][r_number_of_bank][(DATA_WIDHT*4)-1:(DATA_WIDHT*3)] <= i_mem_data;
						4:	data_array[r_i_index][r_number_of_bank][(DATA_WIDHT*5)-1:(DATA_WIDHT*4)] <= i_mem_data;
						5:	data_array[r_i_index][r_number_of_bank][(DATA_WIDHT*6)-1:(DATA_WIDHT*5)] <= i_mem_data;
						6:	data_array[r_i_index][r_number_of_bank][(DATA_WIDHT*7)-1:(DATA_WIDHT*6)] <= i_mem_data;
						7:	data_array[r_i_index][r_number_of_bank][(DATA_WIDHT*8)-1:(DATA_WIDHT*7)] <= i_mem_data;
						8:  data_array[r_i_index][r_number_of_bank][(DATA_WIDHT*9)-1:(DATA_WIDHT*8)] <= i_mem_data;
						9:	data_array[r_i_index][r_number_of_bank][(DATA_WIDHT*10)-1:(DATA_WIDHT*9)] <= i_mem_data;
						10: data_array[r_i_index][r_number_of_bank][(DATA_WIDHT*11)-1:(DATA_WIDHT*10)] <= i_mem_data;
						11:	data_array[r_i_index][r_number_of_bank][(DATA_WIDHT*12)-1:(DATA_WIDHT*11)] <= i_mem_data;	
						12:	data_array[r_i_index][r_number_of_bank][(DATA_WIDHT*13)-1:(DATA_WIDHT*12)] <= i_mem_data;
						13:	data_array[r_i_index][r_number_of_bank][(DATA_WIDHT*14)-1:(DATA_WIDHT*13)] <= i_mem_data;
						14: data_array[r_i_index][r_number_of_bank][(DATA_WIDHT*15)-1:(DATA_WIDHT*14)] <= i_mem_data;
						15: data_array[r_i_index][r_number_of_bank][(DATA_WIDHT*16)-1:(DATA_WIDHT*15)] <= i_mem_data;
					endcase
					counter <= 0;
				end	
			end	
	end	
end

endmodule 

