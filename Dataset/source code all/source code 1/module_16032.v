module ws2812b_out_module (
    input            clk,
    input            resetn,
    input            bitstream_available,
    input [23:0]     bitstream,
    output reg       bitstream_read,
    output reg       ws2812b_data,
    output reg [3:0] debug_info
);
    parameter CYCLES_SHORT =   3; 
    parameter CYCLES_LONG  =   5; 
    parameter CYCLES_RET   = 450; 
    localparam CYCLES_WIDTH = $clog2(CYCLES_RET > CYCLES_LONG ? CYCLES_RET
                                                              : CYCLES_LONG);
    reg  [4:0] bitnum = 0;     
    reg  [CYCLES_WIDTH-1:0] counter = 0;    
    reg  [23:0] bitstream_int; 
    reg  [0:0] idle = 0;
    always @(posedge clk) begin
        if (!resetn) begin
            counter <= 0;
            bitstream_read <= 0;
            bitnum <= 0;
        end else begin
            bitstream_read <= 0; 
            if (counter != 0) begin
                counter <= counter - 1;
            end else begin
                if (!bitnum && !ws2812b_data) begin
                    if (bitstream_available) begin
                        bitstream_read <= 1; 
                        bitstream_int <= bitstream; 
                        ws2812b_data <= 1;
                        bitnum <= 24;
                        counter <= bitstream[23] ? CYCLES_LONG : CYCLES_SHORT;
                        idle <= 0;
                    end else begin
                        ws2812b_data <= 0;
                        counter <= CYCLES_RET;            
                        idle <= 1;
                    end
                end else if (bitnum) begin
                    if (!ws2812b_data) begin
                        ws2812b_data <= 1;
                        counter <= bitstream_int[23] ? CYCLES_LONG : CYCLES_SHORT;
                    end else begin
                        ws2812b_data <= 0;
                        counter <= (bitstream_int[23]) ? CYCLES_SHORT : CYCLES_LONG;
                        bitstream_int <= {bitstream_int[22:0], bitstream_int[23]};
                        bitnum <= bitnum - 1;
                    end
                end
            end
        end
    end
    assign debug_info = {ws2812b_data, bitstream_read, bitstream_available, clk};
endmodule
