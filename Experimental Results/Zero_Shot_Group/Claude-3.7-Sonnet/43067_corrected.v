`timescale 1ns/1ps
module I2C_MASTER(
    clk,
    rst_n,
    sda,
    scl,
    RD_EN,
    WR_EN,
    receive_status,
    tx_start,
    tx_data,
    tx_complete,
    bps_start_t,
    capture_rst
);

input clk;
input rst_n;
input RD_EN;
input WR_EN; 
input tx_complete;
input bps_start_t;
input capture_rst;
reg WR, RD;
output scl;
output receive_status;
output tx_start;
output [7:0] tx_data;
wire [7:0] tx_data;
inout sda;
reg scl_clk;
reg receive_status;
reg [7:0] clk_div;
reg [7:0] send_count;
wire [7:0] data;
reg [7:0] data_reg;
reg end_ready;
wire ack;
wire tx_end;
reg [7:0] send_memory[31:0];
reg [7:0] receive_memory[31:0];

check_pin check_pin_instance(
    .clk(clk),
    .rst_n(rst_n),
    .tx_start(tx_start),
    .capture_ready((send_count == 8'd32) && RD_EN && end_ready),
    .tx_data(tx_data),
    .tx_complete(tx_complete),
    .tx_end(tx_end),
    .bps_start_t(bps_start_t),
    .receive_status(receive_status),
    .capture_rst(capture_rst)
);

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        end_ready <= 1'b0;
    else        
        end_ready <= tx_end ? 1'b0 : 1'b1;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        scl_clk <= 1'b0;
        clk_div <= 8'h0;
        for(integer i=0; i<32; i=i+1) begin
            send_memory[i] <= i;
        end
    end
    else begin 
        if(clk_div > 8'd200) begin
            scl_clk <= ~scl_clk;
            clk_div <= 8'h0;
        end
        else
            clk_div <= clk_div + 1'b1;
    end
end

always @(posedge ack or negedge rst_n) begin
    if(!rst_n) begin
        send_count <= 8'h0;
    end
    else begin
        if((send_count < 8'd32) && ack) begin
            send_count <= send_count + 1'b1;
            receive_memory[send_count] <= RD_EN ? data : 8'h0;
        end    
        else begin
            send_count <= send_count;
        end
    end    
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        receive_status <= 1'b0;
    else        
        receive_status <= (receive_memory[31] == 8'd31) ? 1'b1 : 1'b0;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin    
        WR <= 1'b0;
        RD <= 1'b0;
        data_reg <= 8'h0;
    end
    else begin
        if(send_count == 8'd32) begin
            WR <= 1'b0;
            RD <= 1'b0;
        end
        else begin
            if(RD_EN)
                RD <= 1'b1;
            else if(WR_EN) begin
                WR <= 1'b1;
                data_reg <= send_memory[send_count];
            end
        end
    end
end

assign data = WR_EN ? data_reg : 8'hz;

I2C_wr I2C_wr_instance(
    .sda(sda),
    .scl(scl),
    .ack(ack),
    .rst_n(rst_n),
    .clk(scl_clk),
    .WR(WR),
    .RD(RD),
    .data(data)
);

endmodule