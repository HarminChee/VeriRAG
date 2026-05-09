module buffer2axis #(
    parameter DWIDTH = 32,
    parameter WIDTH = 4,
    parameter HEIGHT = 4
)( 
    clk,
    rstn,
    alive_color,
    dead_color,
    M_AXIS_TDATA,
    M_AXIS_TVALID,
    M_AXIS_TREADY,
    M_AXIS_TLAST,
    in_data,
    in_valid,
    in_ready
);
    input clk;
    input rstn;
    input [DWIDTH-1:0] alive_color;
    input [DWIDTH-1:0] dead_color;
    output [DWIDTH-1:0] M_AXIS_TDATA;
    output M_AXIS_TVALID;
    output M_AXIS_TLAST;
    input M_AXIS_TREADY;
    input [WIDTH*HEIGHT-1:0] in_data;
    input in_valid;
    output in_ready;
    reg state;
    localparam Wait = 0;
    localparam Write = 1;
    reg [DWIDTH - 1:0] buffer [WIDTH*HEIGHT-1:0];
    reg [31:0] counter;
    assign M_AXIS_TVALID = (state == Write);
    assign M_AXIS_TDATA = buffer[counter];
    assign in_ready = (state == Wait);
    always @(posedge clk) begin
        if (!rstn) begin
            counter <= 32'h00000000;
            state <= Wait;
        end else begin
            case (state)
            Wait: begin
                if (in_valid == 1) begin
                    state <= Write;
                end else begin
                    state <= Wait;
                end
            end
            Write: begin
                if (M_AXIS_TREADY == 1) begin
                    if (counter == WIDTH*HEIGHT-1) begin
                        counter <= 0;
                        state <= Wait;
                    end else begin
                        counter <= counter + 1;
                    end
                end else begin
                    counter <= counter;
                end
            end
            endcase
        end
    end
    genvar i;
    generate 
        for (i = 0; i < WIDTH*HEIGHT; i=i+1) begin : converter_block
            always @(posedge clk) begin
                if (state == Wait && in_valid == 1) begin
                    buffer[i] <= (in_data[i] == 1)? alive_color : dead_color;
                end
            end
        end
    endgenerate
endmodule
