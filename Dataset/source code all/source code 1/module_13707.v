module Read_FIFO
    #(parameter FIFO_DEPTH=32, FIFO_DEPTH_LOG2=5) 
(
    input wire clock,
    input wire reset_n,
    input wire z_active, 
    input wire [63:0] read_readdata,
    input wire read_readdatavalid,
    input wire enqueue,
    input wire [28:0] color_address,
    input wire [63:0] color,
    input wire [28:0] z_address,
    input wire [63:0] z,
    input wire [1:0] pixel_active, 
    output wire [FIFO_DEPTH_LOG2-1:0] size,
    output reg write_enqueue,
    output reg [28:0] write_color_address,
    output reg [63:0] write_color,
    output reg [28:0] write_z_address,
    output reg [63:0] write_z,
    output reg [1:0] write_pixel_active 
);
    reg [63:0] memory_z;
    reg [63:0] memory_z_delayed;
    wire [187:0] fifo_write_data = {
        pixel_active,
        z,
        z_address,
        color,
        color_address
    };
    wire [187:0] fifo_read_data;
    wire [28:0] fifo_color_address = fifo_read_data[28:0];
    wire [63:0] fifo_color = fifo_read_data[92:29];
    wire [28:0] fifo_z_address = fifo_read_data[121:93];
    wire [63:0] fifo_z = fifo_read_data[185:122];
    wire [1:0] fifo_pixel_active = fifo_read_data[187:186];
    wire [31:0] fifo_z_0 = fifo_z[31:0];
    wire [31:0] fifo_z_1 = fifo_z[63:32];
    wire [31:0] memory_z_0 = memory_z_delayed[31:0];
    wire [31:0] memory_z_1 = memory_z_delayed[63:32];
    wire z_pass_0 = fifo_z_0 <= memory_z_0;
    wire z_pass_1 = fifo_z_1 <= memory_z_1;
    wire [1:0] new_pixel_active = fifo_pixel_active & { z_pass_1, z_pass_0 };
    wire fifo_empty;
    wire fifo_full;
    reg fifo_read;
    reg got_fifo_data;
    scfifo #(.add_ram_output_register("OFF"),
             .intended_device_family("CYCLONEV"),
             .lpm_numwords(FIFO_DEPTH),
             .lpm_showahead("OFF"),
             .lpm_type("scfifo"),
             .lpm_width(188),
             .lpm_widthu(FIFO_DEPTH_LOG2),
             .overflow_checking("ON"),
             .underflow_checking("ON"),
             .use_eab("ON")) fifo(
            .aclr(!reset_n),
            .clock(clock),
            .data(fifo_write_data),
            .empty(fifo_empty),
            .full(fifo_full),
            .usedw(size),
            .q(fifo_read_data),
            .rdreq(fifo_read),
            .wrreq(enqueue));
    always @(posedge clock or negedge reset_n) begin
        if (!reset_n) begin
            fifo_read <= 1'b0;
            got_fifo_data <= 1'b0;
            write_enqueue <= 1'b0;
            memory_z <= 1'b0;
            memory_z_delayed <= 1'b0;
        end else begin
            fifo_read <= !z_active || read_readdatavalid;
            memory_z <= read_readdata;
            got_fifo_data <= fifo_read && !fifo_empty;
            memory_z_delayed <= memory_z;
            write_enqueue <= got_fifo_data && (!z_active || |new_pixel_active);
            write_color_address <= fifo_color_address;
            write_color <= fifo_color;
            write_z_address <= fifo_z_address;
            write_z <= fifo_z;
            write_pixel_active <= z_active ? new_pixel_active : fifo_pixel_active;
        end
    end
endmodule
