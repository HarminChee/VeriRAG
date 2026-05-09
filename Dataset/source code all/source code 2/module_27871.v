module parser(
    input clk,
    input rst_n,
    input port2parser_data_wr,
    input [133:0] port2parser_data,
    input port2parser_valid_wr,
    input port2parser_valid,
    output parser2port_alf,
    output reg parser2lookup_key_wr,
    output [287:0] parser2lookup_key,
    output parser2next_data_wr,
    output [133:0] parser2next_data,
    input next2parser_alf
);
reg [7:0] pkt_step_count,pkt_step_count_inc;
reg [7:0] INPORT;
reg [47:0] DMAC;
reg [47:0] SMAC;
reg [15:0] ETH_TYPE;
reg [7:0] IP_PROTO;
reg [31:0] SIP;
reg [31:0] DIP;
reg [15:0] SPORT;
reg [15:0] DPORT;
wire is_ipv4;
wire is_tcp;
wire is_udp;
assign parser2next_data_wr = port2parser_data_wr;
assign parser2next_data = port2parser_data;
assign parser2port_alf = next2parser_alf;
always @* begin
    if(port2parser_data_wr == 1'b1) begin
        if(port2parser_data[133:132] == 2'b01) begin
            pkt_step_count_inc = 8'b0;
        end
        else begin
            pkt_step_count_inc = pkt_step_count + 8'd1;
        end
    end
    else begin
        pkt_step_count_inc = pkt_step_count;
    end
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        pkt_step_count <= 8'b0;
    end
    else begin
        pkt_step_count <= pkt_step_count_inc;
    end
end
always @(posedge clk) begin
    if((port2parser_data_wr == 1'b1) && (pkt_step_count_inc == 8'd0)) begin
        INPORT <= {5'b0,port2parser_data[110],port2parser_data[59:58]};
    end
    else begin
        INPORT <= INPORT;
    end
end
always @(posedge clk) begin
    if((port2parser_data_wr == 1'b1) && (pkt_step_count_inc == 8'd2)) begin
        DMAC <= port2parser_data[127:80];
        SMAC <= port2parser_data[79:32];
        ETH_TYPE <= port2parser_data[31:16]; 
    end
    else begin
        DMAC <= DMAC;
        SMAC <= SMAC;
        ETH_TYPE <= ETH_TYPE; 
    end
end
assign is_ipv4 = (ETH_TYPE == 16'h0800);
always @(posedge clk) begin
    if((port2parser_data_wr == 1'b1) && (pkt_step_count_inc == 8'd3)) begin
        IP_PROTO <= port2parser_data[71:64];
        SIP <= port2parser_data[47:16];
        DIP[31:16] <= port2parser_data[15:0];
    end
    else if((port2parser_data_wr == 1'b1) && (pkt_step_count_inc == 8'd4)) begin
        DIP[15:0] <= port2parser_data[127:112];
    end
    else begin
        IP_PROTO <= IP_PROTO;
        SIP <= SIP;
        DIP <= DIP;
    end
end
assign is_tcp = (is_ipv4) && (IP_PROTO == 16'h6);
assign is_udp = (is_ipv4) && (IP_PROTO == 16'h11);
always @(posedge clk) begin
    if((port2parser_data_wr == 1'b1) && (pkt_step_count_inc == 8'd4)) begin
        SPORT <= port2parser_data[111:96];
        DPORT <= port2parser_data[95:80];
    end
    else begin
        SPORT <= SPORT;
        DPORT <= DPORT;
    end
end
assign parser2lookup_key[287:240] = SMAC;
assign parser2lookup_key[239:192] = DMAC;
assign parser2lookup_key[191:176] = ETH_TYPE;
assign parser2lookup_key[175:144] = (is_ipv4) ? SIP : 32'hffff_ffff;
assign parser2lookup_key[143:112] = (is_ipv4) ? DIP : 32'hffff_ffff;
assign parser2lookup_key[111:104] = (is_ipv4) ? IP_PROTO : 8'hff;
assign parser2lookup_key[103:88]  = (is_tcp || is_udp) ? SPORT : 16'hffff;
assign parser2lookup_key[87:72]   = (is_tcp || is_udp) ? DPORT : 16'hffff;
assign parser2lookup_key[71:64]   = INPORT;
assign parser2lookup_key[63:0]    = 64'hffff_ffff_ffff_ffff;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        parser2lookup_key_wr <= 1'b0;
    end
    else begin
        if(port2parser_valid_wr == 1'b1) begin
            parser2lookup_key_wr <= 1'b1;
        end
        else begin
            parser2lookup_key_wr <= 1'b0;
        end
    end
end
endmodule
