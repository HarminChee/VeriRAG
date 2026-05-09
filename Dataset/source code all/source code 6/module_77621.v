module generic_sram_byte_en
#(
parameter DATA_WIDTH    = 32,
parameter ADDRESS_WIDTH = 4
)
(
input                           i_clk,
input      [DATA_WIDTH-1:0]     i_write_data,
input                           i_write_enable,
input      [ADDRESS_WIDTH-1:0]  i_address,
input      [DATA_WIDTH/8-1:0]   i_byte_enable,
output reg [DATA_WIDTH-1:0]     o_read_data
    );
reg [DATA_WIDTH-1:0]   mem  [0:2**ADDRESS_WIDTH-1];
integer i;
always @(posedge i_clk)
    begin
    o_read_data <= i_write_enable ? {DATA_WIDTH{1'd0}} : mem[i_address];
    if (i_write_enable)
        for (i=0;i<DATA_WIDTH/8;i=i+1)
            begin
            mem[i_address][i*8+0] <= i_byte_enable[i] ? i_write_data[i*8+0] : mem[i_address][i*8+0] ;
            mem[i_address][i*8+1] <= i_byte_enable[i] ? i_write_data[i*8+1] : mem[i_address][i*8+1] ;
            mem[i_address][i*8+2] <= i_byte_enable[i] ? i_write_data[i*8+2] : mem[i_address][i*8+2] ;
            mem[i_address][i*8+3] <= i_byte_enable[i] ? i_write_data[i*8+3] : mem[i_address][i*8+3] ;
            mem[i_address][i*8+4] <= i_byte_enable[i] ? i_write_data[i*8+4] : mem[i_address][i*8+4] ;
            mem[i_address][i*8+5] <= i_byte_enable[i] ? i_write_data[i*8+5] : mem[i_address][i*8+5] ;
            mem[i_address][i*8+6] <= i_byte_enable[i] ? i_write_data[i*8+6] : mem[i_address][i*8+6] ;
            mem[i_address][i*8+7] <= i_byte_enable[i] ? i_write_data[i*8+7] : mem[i_address][i*8+7] ;
            end
    end
endmodule
