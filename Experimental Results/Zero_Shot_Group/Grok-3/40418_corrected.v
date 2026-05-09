module camera_init (
    input clk,
    input reset_n,
    output reg ready,
    output wire sda_oe,
    output wire sda,
    input wire sda_in,
    output scl
);
parameter REGS_TO_INIT = 73;
localparam CAMERA_INIT_1 = 11;
localparam CAMERA_INIT_2 = 12;
localparam CAMERA_INIT_3 = 13;
localparam CAMERA_INIT_4 = 14;
localparam CAMERA_INIT_5 = 15;
localparam CAMERA_INIT_6 = 16;
localparam CAMERA_INIT_7 = 17;
localparam CAMERA_IDLE = 18;
localparam CONTROL_REG = 3'b000;
localparam SLAVE_ADDRESS = 3'b001;
localparam SLAVE_REG_ADDRESS = 3'b010;
localparam SLAVE_DATA_1 = 3'b011;
localparam SLAVE_DATA_2 = 3'b100;
reg [7:0] data_in_bus;
reg [2:0] reg_address;
reg bus_write;
wire ready_out;
wire success_out;

i2c_module i2c_write_module (
    .clk(clk), 
    .reset_n(reset_n), 
    .scl_out(scl),
    .writedata(data_in_bus), 
    .address(reg_address),
    .write(bus_write), 
    .ready(ready_out), 
    .success_out(success_out), 
    .sda_in(sda_in), 
    .sda(sda), 
    .sda_oe(sda_oe)
);

reg [7:0] counter;
reg [7:0] state_next;
wire [15:0] regs_data;
assign regs_data = 
    counter == 0 ? 16'h1280 :
    counter == 1 ? 16'hFFF0 :
    counter == 2 ? 16'h1204 :
    counter == 3 ? 16'h1180 :
    counter == 4 ? 16'h0C00 :
    counter == 5 ? 16'h3E00 :
    counter == 6 ? 16'h0400 :
    counter == 7 ? 16'h40D0 :
    counter == 8 ? 16'h3A04 :
    counter == 9 ? 16'h1418 :
    counter == 10 ? 16'h4FB3 :
    counter == 11 ? 16'h50B3 :
    counter == 12 ? 16'h5100 :
    counter == 13 ? 16'h523D :
    counter == 14 ? 16'h53A7 :
    counter == 15 ? 16'h54E4 :
    counter == 16 ? 16'h589E :
    counter == 17 ? 16'h3DC0 :
    counter == 18 ? 16'h1714 :
    counter == 19 ? 16'h1802 :
    counter == 20 ? 16'h3280 :
    counter == 21 ? 16'h1903 :
    counter == 22 ? 16'h1A7B :
    counter == 23 ? 16'h030A :
    counter == 24 ? 16'h0F41 :
    counter == 25 ? 16'h1E00 :
    counter == 26 ? 16'h330B :
    counter == 27 ? 16'h3C78 :
    counter == 28 ? 16'h6900 :
    counter == 29 ? 16'h7400 :
    counter == 30 ? 16'hB084 :
    counter == 31 ? 16'hB10C :
    counter == 32 ? 16'hB20E :
    counter == 33 ? 16'hB380 :
    counter == 34 ? 16'h703A :
    counter == 35 ? 16'h7135 :
    counter == 36 ? 16'h7211 :
    counter == 37 ? 16'h73F0 :
    counter == 38 ? 16'hA202 :
    counter == 39 ? 16'h7A20 :
    counter == 40 ? 16'h7B10 :
    counter == 41 ? 16'h7C1E :
    counter == 42 ? 16'h7D35 :
    counter == 43 ? 16'h7E5A :
    counter == 44 ? 16'h7F69 :
    counter == 45 ? 16'h8076 :
    counter == 46 ? 16'h8180 :
    counter == 47 ? 16'h8288 :
    counter == 48 ? 16'h838F :
    counter == 49 ? 16'h8496 :
    counter == 50 ? 16'h85A3 :
    counter == 51 ? 16'h86AF :
    counter == 52 ? 16'h87C4 :
    counter == 53 ? 16'h88D7 :
    counter == 54 ? 16'h89E8 :
    counter == 55 ? 16'h13E0 :
    counter == 56 ? 16'h0000 :
    counter == 57 ? 16'h1000 :
    counter == 58 ? 16'h0D40 :
    counter == 59 ? 16'h1418 :
    counter == 60 ? 16'hA505 :
    counter == 61 ? 16'hAB07 :
    counter == 62 ? 16'h2495 :
    counter == 63 ? 16'h2533 :
    counter == 64 ? 16'h26E3 :
    counter == 65 ? 16'h9F78 :
    counter == 66 ? 16'hA068 :
    counter == 67 ? 16'hA103 :
    counter == 68 ? 16'hA6D8 :
    counter == 69 ? 16'hA7D8 :
    counter == 70 ? 16'hA8F0 :
    counter == 71 ? 16'hA990 :
    counter == 72 ? 16'hAA94 :
    16'h13E5;

always @(posedge clk) begin
    if (state_next == CAMERA_IDLE)
        ready <= 1'b1;
    else
        ready <= 1'b0;
end

always @(posedge clk) begin
    if (reset_n == 1'b0) begin
        state_next <= CAMERA_INIT_1;
    end
    else begin
        case (state_next)
            CAMERA_INIT_1: state_next <= CAMERA_INIT_2;
            CAMERA_INIT_2: state_next <= CAMERA_INIT_3;
            CAMERA_INIT_3: state_next <= CAMERA_INIT_4;
            CAMERA_INIT_4: state_next <= CAMERA_INIT_7;
            CAMERA_INIT_7: begin
                if (ready_out == 1'b0)
                    state_next <= CAMERA_INIT_5;
            end
            CAMERA_INIT_5: begin
                if (ready_out == 1'b1) begin
                    if (success_out == 1'b1) begin
                        if (counter == REGS_TO_INIT - 1)
                            state_next <= CAMERA_IDLE;
                        else
                            state_next <= CAMERA_INIT_6;
                    end
                    else
                        state_next <= CAMERA_INIT_2;
                end
            end
            CAMERA_INIT_6: state_next <= CAMERA_INIT_2;
            CAMERA_IDLE: state_next <= CAMERA_IDLE;
            default: state_next <= CAMERA_INIT_1;
        endcase
    end
end

always @(posedge clk) begin
    if (reset_n == 1'b0) begin
        reg_address <= 0;
        data_in_bus <= 0;
        bus_write <= 1'b0;
        counter <= 0;
    end
    else begin
        case (state_next)
            CAMERA_INIT_1: begin
                reg_address <= SLAVE_ADDRESS;
                data_in_bus <= 8'h42;
                bus_write <= 1'b1;
            end
            CAMERA_INIT_2: begin
                reg_address <= SLAVE_REG_ADDRESS;
                data_in_bus <= regs_data[15:8];
                bus_write <= 1'b1;
            end
            CAMERA_INIT_3: begin
                reg_address <= SLAVE_DATA_1;
                data_in_bus <= regs_data[7:0];
                bus_write <= 1'b1;
            end
            CAMERA_INIT_4: begin
                reg_address <= CONTROL_REG;
                data_in_bus <= 3'b001;
                bus_write <= 1'b1;
            end
            CAMERA_INIT_5: begin
                reg_address <= 0;
                data_in_bus <= 0;
                bus_write <= 1'b0;
            end
            CAMERA_INIT_6: begin
                bus_write <= 1'b0;
                reg_address <= 0;
                data_in_bus <= 0;
                counter <= counter + 1'b1;
            end
            CAMERA_INIT_7: begin
                reg_address <= 0;
                data_in_bus <= 0;
                bus_write <= 1'b0;
            end
            CAMERA_IDLE: begin
                reg_address <= 0;
                data_in_bus <= 0;
                bus_write <= 1'b0;
            end
            default: begin
                bus_write <= 1'b0;
                reg_address <= 3'd0;
                data_in_bus <= 8'd0;
            end
        endcase
    end
end

endmodule