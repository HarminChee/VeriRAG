module user_mux(
    input clk,
    input rst_n,
    input disp2usermux_data_wr,
    input [133:0] disp2usermux_data,
    input disp2usermux_valid_wr,
    input disp2usermux_valid,
    output usermux2disp_alf,
    input up2usermux_data_wr,
    input [133:0] up2usermux_data,
    input up2usermux_valid_wr,
    input up2usermux_valid,
    output usermux2up_alf,
    output reg usermux2down_data_wr,
    output reg [133:0] usermux2down_data,
    output reg usermux2down_valid_wr,
    output usermux2down_valid,
    input down2usermux_alf
);
reg up_dfifo_rd;
wire [133:0] up_dfifo_rdata;
wire [7:0] up_dfifo_usedw;
reg up_vfifo_rd;
wire up_vfifo_rdata;
wire up_vfifo_empty;
reg disp_dfifo_rd;
wire [133:0] disp_dfifo_rdata;
wire [7:0] disp_dfifo_usedw;
reg disp_vfifo_rd;
wire disp_vfifo_rdata;
wire disp_vfifo_empty;
reg last_select;
reg grant_bit;
reg has_pkt;
reg [1:0] usermux_state;
always @ * begin
    case({disp_vfifo_empty,up_vfifo_empty})
        2'b00: begin has_pkt = 1'b1; grant_bit = ~last_select; end
        2'b01: begin has_pkt = 1'b1; grant_bit = 1'b1; end
        2'b10: begin has_pkt = 1'b1; grant_bit = 1'b0; end
        2'b11: begin has_pkt = 1'b0; grant_bit = last_select; end
    endcase
end
assign usermux2disp_alf = disp_dfifo_usedw[7];
assign usermux2up_alf = up_dfifo_usedw[7];
assign usermux2down_valid = usermux2down_valid_wr;
localparam  IDLE_S = 2'd0,
            SEND_EXE_S = 2'd1,
            SEND_UP_S = 2'd2;
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        last_select <= 1'b0;
        usermux2down_data_wr <= 1'b0;
        usermux2down_valid_wr <= 1'b0;
        up_dfifo_rd <= 1'b0;
        up_vfifo_rd <= 1'b0;
        disp_dfifo_rd <= 1'b0;
        disp_vfifo_rd <= 1'b0;
        usermux_state <= IDLE_S;
    end
    else begin
        case(usermux_state)
            IDLE_S: begin
                usermux2down_data_wr <= 1'b0;
                usermux2down_valid_wr <= 1'b0;
                if((down2usermux_alf == 1'b0) && (has_pkt == 1'b1)) begin
                    last_select <= grant_bit;
                    if(grant_bit == 1'b0) begin
                        up_dfifo_rd <= 1'b1;
                        up_vfifo_rd <= 1'b1;
                        disp_dfifo_rd <= 1'b0;
                        disp_vfifo_rd <= 1'b0;
                        usermux_state <= SEND_UP_S;
                    end
                    else begin
                        up_dfifo_rd <= 1'b0;
                        up_vfifo_rd <= 1'b0;
                        disp_dfifo_rd <= 1'b1;
                        disp_vfifo_rd <= 1'b1;
                        usermux_state <= SEND_EXE_S;
                    end
                end
                else begin
                    up_dfifo_rd <= 1'b0;
                    up_vfifo_rd <= 1'b0;
                    disp_dfifo_rd <= 1'b0;
                    disp_vfifo_rd <= 1'b0;
                    usermux_state <= IDLE_S;
                end
            end
            SEND_UP_S:begin
                up_vfifo_rd <= 1'b0;
                usermux2down_data_wr <= 1'b1;
                usermux2down_data <= up_dfifo_rdata;
                if(up_dfifo_rdata[133:132] == 2'b10)begin
                    up_dfifo_rd <= 1'b0;
                    usermux2down_valid_wr <= 1'b1;
                    usermux_state <= IDLE_S;
                end
                else begin
                    up_dfifo_rd <= 1'b1;
                    usermux2down_valid_wr <= 1'b0;
                    usermux_state <= SEND_UP_S;
                end
            end
            SEND_EXE_S:begin
                disp_vfifo_rd <= 1'b0;
                usermux2down_data_wr <= 1'b1;
                usermux2down_data <= disp_dfifo_rdata;
                if(disp_dfifo_rdata[133:132] == 2'b10)begin
                    disp_dfifo_rd <= 1'b0;
                    usermux2down_valid_wr <= 1'b1;
                    usermux_state <= IDLE_S;
                end
                else begin
                    disp_dfifo_rd <= 1'b1;
                    usermux2down_valid_wr <= 1'b0;
                    usermux_state <= SEND_EXE_S;
                end
            end
            default: begin
                last_select <= 1'b0;
                usermux2down_data_wr <= 1'b0;
                usermux2down_valid_wr <= 1'b0;
                up_dfifo_rd <= 1'b0;
                up_vfifo_rd <= 1'b0;
                disp_dfifo_rd <= 1'b0;
                disp_vfifo_rd <= 1'b0;
                usermux_state <= IDLE_S;
            end
        endcase
    end
end
fifo_256_134 up_dfifo(
    .aclr(~rst_n),
    .clock(clk),
    .wrreq(up2usermux_data_wr),
    .data(up2usermux_data),
    .rdreq(up_dfifo_rd),
    .q(up_dfifo_rdata),
    .usedw(up_dfifo_usedw)
);
fifo_64_1 up_vfifo(
    .aclr(~rst_n),
    .clock(clk),
    .wrreq(up2usermux_valid_wr),
    .data(up2usermux_valid),
    .rdreq(up_vfifo_rd),
    .q(up_vfifo_rdata),
    .empty(up_vfifo_empty)
);
fifo_256_134 disp_dfifo(
    .aclr(~rst_n),
    .clock(clk),
    .wrreq(disp2usermux_data_wr),
    .data(disp2usermux_data),
    .rdreq(disp_dfifo_rd),
    .q(disp_dfifo_rdata),
    .usedw(disp_dfifo_usedw)
);
fifo_64_1 disp_vfifo(
    .aclr(~rst_n),
    .clock(clk),
    .wrreq(disp2usermux_valid_wr),
    .data(disp2usermux_valid),
    .rdreq(disp_vfifo_rd),
    .q(disp_vfifo_rdata),
    .empty(disp_vfifo_empty)
);
endmodule
