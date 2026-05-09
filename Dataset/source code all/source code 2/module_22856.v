module ws2812b_out_parallel_module #(
    parameter STRIPECOUNT =      2, 
    parameter CYCLES_SHORT =     3, 
    parameter CYCLES_LONG =      9, 
    parameter CYCLES_RET =       0  
    ) (
    input                        clk,
    input                        resetn,
    input                        bitstream_available,
    input [STRIPECOUNT*24-1:0]   bitstream,
    output reg                   bitstream_read,
    output reg [STRIPECOUNT-1:0] ws2812b_data,
    output reg [3:0]             debug_info
);
    localparam CYCLES_WIDTH = $clog2(CYCLES_RET > CYCLES_LONG ? CYCLES_RET
                                                              : CYCLES_LONG);
    reg  [4:0] bitnum = 0;     
    reg  [1:0] bitstate;       
    reg  [CYCLES_WIDTH-1:0] counter = 0;    
    reg  [STRIPECOUNT*24-1:0] bitstream_int; 
    reg  [$clog2(STRIPECOUNT):0] i;
    always @(posedge clk) begin
        if (!resetn) begin
            counter        <= 0;
            bitstream_read <= 0;
            bitnum         <= 0;
            ws2812b_data   <= 0;
        end else begin
            bitstream_read <= 0; 
            if (|counter) begin
                counter <= counter - 1;
            end else begin
                if (!bitnum && bitstream_available) begin
                    bitstream_int <= bitstream; 
                    bitstream_read <= 1; 
                    bitnum <= 24;
                    bitstate <= 0;
                end else if (bitnum) begin
                    counter <= CYCLES_SHORT;
                    bitstate <= bitstate + 1;
                    if (bitstate == 0) begin
                        ws2812b_data <= STRIPECOUNT*{1'b1};
                    end else if (bitstate == 1) begin
                        for (i = 0; i < STRIPECOUNT; i = i+1) begin
                            ws2812b_data[i] <= bitstream_int[24*i];
                        end
                    end else if (bitstate == 2) begin
                        ws2812b_data <= STRIPECOUNT*{1'b0};
                        bitnum   <= bitnum - 1;
                        bitstate <= 0;
                        bitstream_int <= {1'b0, bitstream_int[STRIPECOUNT*24-1:1]};
                        if (! bitnum) counter <= CYCLES_RET;
                    end
                end
            end
        end
    end
    assign debug_info = {ws2812b_data, bitstream_read, bitstream_available};
endmodule
