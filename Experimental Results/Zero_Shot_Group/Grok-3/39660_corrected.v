<xaiArtifact artifact_id="a32ba760-53da-41f6-adcb-04ec6da9c383" artifact_version_id="1b073de5-ab98-48c0-9272-727ab2c922be" title="rfid_reader_rx.v" contentType="text/verilog">
module rfid_reader_rx (
    input reset, clk, tag_backscatter,
    output reg rx_done,
    output rx_timeout,
    input [2:0] miller,
    input trext,
    input divide_ratio,
    input [15:0] tari_counts,
    input [15:0] rtcal_counts,
    input [15:0] trcal_counts,
    output reg [1023:0] rx_data,
    output reg [9:0] rx_dataidx
);

reg [15:0] rx_period;
reg [15:0] rx_counter;
assign rx_timeout = (rx_counter > (rtcal_counts << 2));

reg previousbit;
reg edgeclk;
reg [15:0] count;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        previousbit <= 0;
        edgeclk     <= 0;
        count       <= 0;
        rx_counter  <= 0;
        rx_done     <= 0;
    end else begin
        if (tag_backscatter != previousbit) begin
            edgeclk     <= 1;
            previousbit <= tag_backscatter;
            count       <= 0;
        end else begin
            edgeclk    <= 0;
            count      <= count + 1;
            rx_counter <= rx_counter + 1;
        end
    end
end

reg [4:0] rx_state;
parameter STATE_CLK_UP   = 0;
parameter STATE_CLK_DN   = 1;
parameter STATE_PREAMBLE = 2;
parameter STATE_DATA1    = 3;
parameter STATE_DATA2    = 4;

wire isfm0, ism2, ism4, ism8;
assign isfm0 = (miller == 3'd0);
assign ism2  = (miller == 3'd1);
assign ism4  = (miller == 3'd2);
assign ism8  = (miller == 3'd3);

wire count_lessthan_period;
assign count_lessthan_period = (rx_counter <= rx_period);

wire fm0_preamble_done;
assign fm0_preamble_done = (rx_dataidx >= 10'd5);

wire [15:0] rx_counter_by2;
assign rx_counter_by2 = rx_counter >> 1;

always @(posedge edgeclk or posedge reset) begin
    if (reset) begin
        rx_state   <= STATE_CLK_UP;
        rx_dataidx <= 10'd0;
        rx_data    <= 1024'd0;
        rx_period  <= 16'd0;
    end else begin
        case (rx_state)
            STATE_CLK_UP: begin
                rx_state   <= STATE_CLK_DN;
                rx_dataidx <= 10'd0;
                rx_data    <= 1024'd0;
            end
            STATE_CLK_DN: begin
                if (isfm0 & ~trext) 
                    rx_period <= rx_counter_by2;
                else 
                    rx_period <= rx_counter;
                rx_state <= STATE_PREAMBLE;
            end
            STATE_PREAMBLE: begin
                if (isfm0) begin
                    if (fm0_preamble_done) begin
                        rx_state   <= STATE_DATA1;
                        rx_dataidx <= 10'd0;
                    end else begin
                        rx_dataidx <= rx_dataidx + 1'b1;
                    end
                end else if (ism2 || ism4 || ism8) begin
                    rx_state <= STATE_DATA1;
                end
            end
            STATE_DATA1: begin
                if (isfm0) begin
                    if (count_lessthan_period) begin
                        rx_state           <= STATE_DATA2;
                        rx_data[rx_dataidx] <= 1'b0;
                        rx_dataidx         <= rx_dataidx + 1'b1;
                    end else begin
                        rx_data[rx_dataidx] <= 1'b1;
                        rx_dataidx         <= rx_dataidx + 1'b1;
                    end
                end else if (ism2 || ism4 || ism8) begin
                    if (count_lessthan_period) begin
                        rx_state           <= STATE_DATA2;
                        rx_data[rx_dataidx] <= 1'b0;
                        rx_dataidx         <= rx_dataidx + 1'b1;
                    end else begin
                        rx_data[rx_dataidx] <= 1'b1;
                        rx_dataidx         <= rx_dataidx + 1'b1;
                    end
                end
                if (rx_dataidx >= 10'd1023)
                    rx_done <= 1'b1;
            end
            STATE_DATA2: begin
                rx_state <= STATE_DATA1;
            end
            default: begin
                rx_state <= STATE_CLK_UP;
            end
        endcase
    end
end

endmodule
</xaiArtifact>