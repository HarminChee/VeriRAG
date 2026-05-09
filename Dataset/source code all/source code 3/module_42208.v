module rule_access(
    input clk,
    input rst_n,
    input lookup2rule_index_wr,
    input [15:0] lookup2rule_index,
    output rule2lookup_data_wr,
    output [31:0] rule2lookup_data,
    input cfg2rule_cs,
    output rule2cfg_ack,
    input cfg2rule_rw,
    input [15:0] cfg2rule_addr,
    input [31:0] cfg2rule_wdata,
    output [31:0] rule2cfg_rdata
);
reg index_fifo_rd;
wire [15:0] index_fifo_rdata;
wire index_fifo_empty;
wire rule_ram_wr;
wire rule_ram_rd;
wire [7:0] rule_ram_waddr;
reg [7:0] rule_ram_raddr;
wire [31:0] rule_ram_wdata;
wire [31:0] rule_ram_rdata;
reg lookup_ram_rd,cfg_ram_rd;
reg cfg2rule_rack;
wire cfg2rule_wack;
wire sync_cfg2rule_cs;
wire cfg_read_req,cfg_write_req;
sync_sig #(2)sync_cfgcs(
    .clk(clk),
    .rst_n(rst_n),
    .in_sig(cfg2rule_cs),
    .out_sig(sync_cfg2rule_cs)
);
assign cfg_read_req = (sync_cfg2rule_cs == 1'b1) && (cfg2rule_rw == 1'b0);
assign cfg_write_req = (sync_cfg2rule_cs == 1'b1) && (cfg2rule_rw == 1'b1);
assign rule2cfg_ack = cfg2rule_rack || cfg2rule_wack; 
assign rule_ram_waddr = cfg2rule_addr[7:0];
assign rule_ram_wdata = cfg2rule_wdata;
reg cfg_write_req_dly;
always @(posedge clk) begin
    cfg_write_req_dly <= cfg_write_req;
end
assign rule_ram_wr = cfg_write_req && (~cfg_write_req_dly);
assign cfg2rule_wack = cfg_write_req;
assign rule2cfg_rdata = rule_ram_rdata;
assign rule2lookup_data = rule_ram_rdata;
assign rule_ram_rd = lookup_ram_rd || cfg_ram_rd;
reg [1:0] lookup_read_dly;
always @(posedge clk) begin
    lookup_read_dly[0] <= lookup_ram_rd;
    lookup_read_dly[1] <= lookup_read_dly[0];
end
assign rule2lookup_data_wr = lookup_read_dly[1];
reg [1:0] cfg_read_dly;
wire cfg_read_valid;
always @(posedge clk) begin
    cfg_read_dly[0] <= cfg_ram_rd;
    cfg_read_dly[1] <= cfg_read_dly[0];
end
assign cfg_read_valid = cfg_read_dly[1];
reg [1:0] read_state;
localparam  R_IDLE_S = 2'd0,
            R_LOOKUP_S = 2'd1,
            R_CFGWAIT_S = 2'd2,
            R_HANDSHAKE_S = 2'd3;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        lookup_ram_rd <= 1'b0;
        cfg_ram_rd <= 1'b0;
        cfg2rule_rack <= 1'b0;
        index_fifo_rd <= 1'b0;
        read_state <= R_IDLE_S;
    end
    else begin
        case(read_state)
            R_IDLE_S: begin
                lookup_ram_rd <= 1'b0;
                cfg_ram_rd <= 1'b0;
                cfg2rule_rack <= 1'b0;
                index_fifo_rd <= 1'b0;
                if(cfg_read_req == 1'b1) begin
                    cfg_ram_rd <= 1'b1;
                    rule_ram_raddr <= cfg2rule_addr[7:0];
                    read_state <= R_CFGWAIT_S;
                end
                else if(index_fifo_empty == 1'b0) begin
                    index_fifo_rd <= 1'b1;
                    read_state <= R_LOOKUP_S;
                end
                else begin
                    read_state <= R_IDLE_S;
                end
            end
            R_LOOKUP_S: begin
                index_fifo_rd <= 1'b0;
                lookup_ram_rd <= 1'b1;
                rule_ram_raddr <= index_fifo_rdata[7:0];
                read_state <= R_IDLE_S;
            end
            R_CFGWAIT_S: begin
                cfg_ram_rd <= 1'b0;
                if(cfg_read_valid == 1'b1) begin
                    cfg2rule_rack <= 1'b1;
                    read_state <= R_HANDSHAKE_S;
                end
                else begin
                    cfg2rule_rack <= 1'b0;
                    read_state <= R_CFGWAIT_S;
                end
            end
            R_HANDSHAKE_S: begin
                if(cfg_read_req == 1'b1) begin
                    cfg2rule_rack <= 1'b1;
                    read_state <= R_HANDSHAKE_S;
                end
                else begin
                    cfg2rule_rack <= 1'b0;
                    read_state <= R_IDLE_S;
                end
            end
            default: begin
                lookup_ram_rd <= 1'b0;
                cfg_ram_rd <= 1'b0;
                cfg2rule_rack <= 1'b0;
                index_fifo_rd <= 1'b0;
                read_state <= R_IDLE_S;
            end
        endcase
    end
end
fifo_64_16 index_fifo(
    .aclr(~rst_n),
    .clock(clk),
    .wrreq(lookup2rule_index_wr),
    .data(lookup2rule_index),
    .rdreq(index_fifo_rd),
    .q(index_fifo_rdata),
    .empty(index_fifo_empty)
);
ram_32_256 rule_ram(
	.aclr(~rst_n),
	.clock(clk),
	.wraddress(rule_ram_waddr),
	.rdaddress(rule_ram_raddr),
	.data(rule_ram_wdata),
	.rden(rule_ram_rd),
	.wren(rule_ram_wr),	
	.q(rule_ram_rdata)
);
endmodule
