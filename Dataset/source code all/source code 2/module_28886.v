`default_nettype none
`default_nettype wire
`default_nettype none
module zap_mem_inv_block #(
        parameter DEPTH = 32,
        parameter WIDTH = 32   
)(  
        input wire                           i_clk,
        input wire                           i_reset,
        input wire   [WIDTH-1:0]             i_wdata,
        input wire                           i_wen, 
        input wire                           i_ren,
        input wire                           i_inv,
        input wire   [$clog2(DEPTH)-1:0]     i_raddr, 
        input wire   [$clog2(DEPTH)-1:0]     i_waddr,
        output wire [WIDTH-1:0]              o_rdata,
        output reg                           o_rdav
);
reg [DEPTH-1:0] dav_ff;
wire [$clog2(DEPTH)-1:0] addr_r;
wire en_r;
assign addr_r = i_raddr;
assign en_r   = i_ren;
zap_ram_simple #(.WIDTH(WIDTH), .DEPTH(DEPTH)) u_ram_simple (
        .i_clk     ( i_clk ),
        .i_wr_en   ( i_wen ),
        .i_rd_en   ( en_r ),
        .i_wr_data ( i_wdata ),
        .o_rd_data ( o_rdata ),
        .i_wr_addr ( i_waddr ),
        .i_rd_addr ( addr_r )
);
always @ (posedge i_clk)
begin: flip_flops
        if ( i_reset | i_inv )
        begin
               dav_ff <=  {DEPTH{1'd0}};
               o_rdav <= 1'd0;
        end
        else
        begin
                if ( i_wen )
                        dav_ff [ i_waddr ] <= 1'd1;
                if ( en_r )
                        o_rdav <= dav_ff [ addr_r ]; 
        end
end
endmodule 
`default_nettype wire
