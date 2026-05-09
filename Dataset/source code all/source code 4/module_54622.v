module SEG7_IF(	
					s_clk,
					s_address,
					s_read,
					s_readdata,
					s_write,
					s_writedata,
					s_reset,
					SEG7
				 );
parameter	SEG7_NUM		=   8;
parameter	ADDR_WIDTH		=	3;		
parameter	DEFAULT_ACTIVE  =   1;
parameter	LOW_ACTIVE  	=   1;
reg		[7:0]				base_index;
reg		[7:0]				write_data;
reg		[7:0]				read_data;
reg		[(SEG7_NUM*8-1):0]  reg_file;
input						s_clk;
input	[(ADDR_WIDTH-1):0]	s_address;
input						s_read;
output	[7:0]				s_readdata;
input						s_write;
input	[7:0]				s_writedata;
input						s_reset;
output	[(SEG7_NUM*8-1):0]  SEG7;
always @ (negedge s_clk)
begin
	if (s_reset)
	begin
		integer i;
		for(i=0;i<SEG7_NUM*8;i=i+1)
		begin
			reg_file[i] = (DEFAULT_ACTIVE)?1'b1:1'b0; 
		end
	end
	else if (s_write)
	begin
		integer j;
		write_data = s_writedata;
		base_index = s_address;
		base_index = base_index << 3;
		for(j=0;j<8;j=j+1)
		begin
			reg_file[base_index+j] = write_data[j];
		end
	end
	else if (s_read)
	begin
		integer k;
		base_index = s_address;
		base_index = base_index << 3;
		for(k=0;k<8;k=k+1)
		begin
			read_data[k] = reg_file[base_index+k];
		end
	end	
end
assign SEG7 = (LOW_ACTIVE)?~reg_file:reg_file;
assign s_readdata = read_data;
endmodule
