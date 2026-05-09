`define PIPELINED
`define PIPELINED
module Write_FIFO
    #(parameter FIFO_DEPTH=32, FIFO_DEPTH_LOG2=5)
(
    input wire clock,
    input wire reset_n,
    output reg [28:0] write_color_address,
    output wire [7:0] write_color_burstcount,
    input wire write_color_waitrequest,
    output reg [63:0] write_color_writedata,
    output reg [7:0] write_color_byteenable,
    output reg write_color_write,
    output reg [28:0] write_z_address,
    output wire [7:0] write_z_burstcount,
    input wire write_z_waitrequest,
    output reg [63:0] write_z_writedata,
    output reg [7:0] write_z_byteenable,
    output reg write_z_write,
    input wire enqueue,
    input wire [28:0] color_address,
    input wire [63:0] color,
    input wire [28:0] z_address,
    input wire [63:0] z,
    input wire [1:0] pixel_active, 
    output wire [FIFO_DEPTH_LOG2-1:0] size,
    output reg [7:0] error
);
    assign write_color_burstcount = 8'h01;
    assign write_z_burstcount = 8'h01;
`ifdef PIPELINED
    reg [187:0] slot1;
    wire [28:0] slot1_color_address = slot1[28:0];
    wire [63:0] slot1_color = slot1[92:29];
    wire [28:0] slot1_z_address = slot1[121:93];
    wire [63:0] slot1_z = slot1[185:122];
    wire [1:0] slot1_pixel_active = slot1[187:186];
    wire [7:0] slot1_byte_enable = {{4{slot1_pixel_active[1]}}, {4{slot1_pixel_active[0]}}};
    reg slot1_full;
    reg [187:0] slot2;
    reg slot2_full;
    wire color_wait = write_color_write && write_color_waitrequest;
    wire z_wait = write_z_write && write_z_waitrequest;
    reg got_queue_data;
`else
    localparam STATE_INIT = 2'h0;
    localparam STATE_READ = 2'h1;
    localparam STATE_WRITE = 2'h2;
    localparam STATE_WAIT = 2'h3;
    reg [1:0] state;
`endif
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
    wire [7:0] fifo_byte_enable = {{4{fifo_pixel_active[1]}}, {4{fifo_pixel_active[0]}}};
    wire fifo_empty;
    wire fifo_full;
    reg fifo_read;
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
            write_color_address <= 1'b0;
            write_color_writedata <= 1'b0;
            write_color_byteenable <= 1'b0;
            write_color_write <= 1'b0;
            write_z_address <= 1'b0;
            write_z_writedata <= 1'b0;
            write_z_byteenable <= 1'b0;
            write_z_write <= 1'b0;
            fifo_read <= 1'b0;
`ifdef PIPELINED
            slot1 <= 1'b0;
            slot1_full <= 1'b0;
            slot2 <= 1'b0;
            slot2_full <= 1'b0;
            error <= 1'b0;
            got_queue_data <= 1'b0;
`else
            state <= STATE_INIT;
`endif
        end else begin
`ifdef PIPELINED
            fifo_read <= !color_wait && !z_wait && !slot1_full;
            got_queue_data <= fifo_read && !fifo_empty;
            error <= 1'b0;
            casez ({got_queue_data, color_wait, z_wait, slot1_full, slot2_full})
                5'b0_00_00: begin
                    write_color_write <= 1'b0;
                    write_z_write <= 1'b0;
                end
                5'b?_??_01: begin
                    error <= 8'h80;
                end
                5'b0_00_10: begin
                    write_color_address <= slot1_color_address;
                    write_color_writedata <= slot1_color;
                    write_color_byteenable <= slot1_byte_enable;
                    write_color_write <= slot1_color_address != 1'b0;
                    write_z_address <= slot1_z_address;
                    write_z_writedata <= slot1_z;
                    write_z_byteenable <= slot1_byte_enable;
                    write_z_write <= slot1_z_address != 1'b0;
                    slot1_full <= 1'b0;
                end
                5'b0_00_11: begin
                    write_color_address <= slot1_color_address;
                    write_color_writedata <= slot1_color;
                    write_color_byteenable <= slot1_byte_enable;
                    write_color_write <= slot1_color_address != 1'b0;
                    write_z_address <= slot1_z_address;
                    write_z_writedata <= slot1_z;
                    write_z_byteenable <= slot1_byte_enable;
                    write_z_write <= slot1_z_address != 1'b0;
                    slot1 <= slot2;
                    slot2_full <= 1'b0;
                end
                5'b0_11_00, 5'b0_01_00, 5'b0_10_00,
                5'b0_11_10, 5'b0_01_10, 5'b0_10_10,
                5'b0_11_11, 5'b0_01_11, 5'b0_10_11: begin
                    write_color_write <= color_wait;
                    write_z_write <= z_wait;
                end
                5'b1_00_00: begin
                    write_color_address <= fifo_color_address;
                    write_color_writedata <= fifo_color;
                    write_color_byteenable <= fifo_byte_enable;
                    write_color_write <= fifo_color_address != 1'b0;
                    write_z_address <= fifo_z_address;
                    write_z_writedata <= fifo_z;
                    write_z_byteenable <= fifo_byte_enable;
                    write_z_write <= fifo_z_address != 1'b0;
                end
                5'b1_00_10: begin
                    write_color_address <= slot1_color_address;
                    write_color_writedata <= slot1_color;
                    write_color_byteenable <= slot1_byte_enable;
                    write_color_write <= slot1_color_address != 1'b0;
                    write_z_address <= slot1_z_address;
                    write_z_writedata <= slot1_z;
                    write_z_byteenable <= slot1_byte_enable;
                    write_z_write <= slot1_z_address != 1'b0;
                    slot1 <= fifo_read_data;
                end
                5'b1_00_11: begin
                    write_color_address <= slot1_color_address;
                    write_color_writedata <= slot1_color;
                    write_color_byteenable <= slot1_byte_enable;
                    write_color_write <= slot1_color_address != 1'b0;
                    write_z_address <= slot1_z_address;
                    write_z_writedata <= slot1_z;
                    write_z_byteenable <= slot1_byte_enable;
                    write_z_write <= slot1_z_address != 1'b0;
                    slot1 <= slot2;
                    slot2 <= fifo_read_data;
                end
                5'b1_11_00, 5'b1_01_00, 5'b1_10_00: begin
                    slot1 <= fifo_read_data;
                    slot1_full <= 1'b1;
                    write_color_write <= color_wait;
                    write_z_write <= z_wait;
                end
                5'b1_11_10, 5'b1_01_10, 5'b1_10_10: begin
                    slot2 <= fifo_read_data;
                    slot2_full <= 1'b1;
                    write_color_write <= color_wait;
                    write_z_write <= z_wait;
                end
                5'b1_11_11, 5'b1_01_11, 5'b1_10_11: begin
                    error <= 8'h40 | {got_queue_data, color_wait, z_wait, slot1_full, slot2_full};
                end
                default: begin
                    error <= {got_queue_data, color_wait, z_wait, slot1_full, slot2_full};
                end
            endcase
`else
            case (state)
                STATE_INIT: begin
                    if (!fifo_empty) begin
                        fifo_read <= 1'b1;
                        state <= STATE_READ;
                    end
                end
                STATE_READ: begin
                    fifo_read <= 1'b0;
                    state <= STATE_WRITE;
                end
                STATE_WRITE: begin
                    write_color_address <= fifo_color_address;
                    write_color_writedata <= fifo_color;
                    write_color_byteenable <= fifo_byte_enable;
                    write_color_write <= fifo_color_address != 1'b0;
                    write_z_address <= fifo_z_address;
                    write_z_writedata <= fifo_z;
                    write_z_byteenable <= fifo_byte_enable;
                    write_z_write <= fifo_z_address != 1'b0;
                    state <= STATE_WAIT;
                end
                STATE_WAIT: begin
                    if (write_color_write && !write_color_waitrequest) begin
                        write_color_write <= 1'b0;
                    end
                    if (write_z_write && !write_z_waitrequest) begin
                        write_z_write <= 1'b0;
                    end
                    if ((!write_color_write || !write_color_waitrequest) &&
                        (!write_z_write || !write_z_waitrequest)) begin
                        state <= STATE_INIT;
                    end
                end
                default: begin
                    state <= STATE_INIT;
                end
            endcase
`endif
        end
    end
endmodule
