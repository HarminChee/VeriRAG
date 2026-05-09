module memory (
    input clk,
    input [15:0] in,
    input [14:0] address,
    input [12:0] screen_read_address,
    input load,
    input [7:0] keyboard,
    output [15:0] out,
    output [15:0] read_value,
    output ready
);
    reg [31:0]  timer = 32'b0;
    reg r_ready = 1'b0;
    assign ready = r_ready; 
    reg r_screen_we;
    wire screen_we;
    reg [12:0] r_screen_write_address = 13'b0;
    wire [12:0] screen_write_address;
    assign screen_write_address = r_screen_write_address;
    reg [14:0] r_screen_address;
    reg [15:0] r_screen_data;
    assign screen_we      = r_screen_we;
    reg [15:0] r_out = 16'b0;
    assign out = r_out;
    reg [15:0] r_in;
    reg[15:0] r_mem_ram;
    wire [13:0] write_address, read_address;
    wire [15:0] ram_q;
    reg ram_we;
    ram_16 ram16(
        .q(ram_q), 
        .d(in), 
        .write_address(address[13:0]), 
        .read_address(address[13:0]), 
        .we(ram_we), 
        .clk(clk)
    );
    vga_ram vgaram(
        .q(read_value), 
        .d(in), 
        .write_address(address[12:0]), 
        .read_address(screen_read_address), 
        .we(screen_we), 
        .clk(clk)
    );
     always @(posedge clk) begin
        if (timer == 32'd25000000) begin
            r_ready <= 1'b1;
        end else begin
            timer <= timer + 32'b1;
        end
    end
    always @(posedge clk) begin
        if (address == 15'd24576) begin
            r_out <= keyboard;
        end if (address < 15'd16384) begin
            r_out <= ram_q;
        end
    end
    always @ (posedge clk) begin
        ram_we = 1'b0;
        if (load) begin
            if (address < 15'd16384) begin
                ram_we = 1'b1;
            end
        end
    end
    always @ (posedge clk) begin
        if (load) begin
            if (address >= 15'd16384) begin
                r_screen_we <= 1'b1;
                r_screen_write_address <= address - 15'd16384;
            end else begin
                r_screen_we <= 1'b0;
            end
        end else begin
            r_screen_we <= 1'b0;
        end
    end
endmodule
