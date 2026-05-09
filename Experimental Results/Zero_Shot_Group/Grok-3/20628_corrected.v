module LED2Spartan3StarterKit(
    input         CLK50MHZ,
    input         SOCKET,
    output [17:0] SRAM_A,
    output        SRAM_WE_X,
    output        SRAM_OE_X,
    inout  [15:0] SRAM_IO_A,
    output        SRAM_CE_A_X,
    output        SRAM_LB_A_X,
    output        SRAM_UB_A_X,
    inout  [15:0] SRAM_IO_B,
    output        SRAM_CE_B_X,
    output        SRAM_LB_B_X,
    output        SRAM_UB_B_X,
    output [3:0]  LED_AN,
    output        LED_A,
    output        LED_B,
    output        LED_C,
    output        LED_D,
    output        LED_E,
    output        LED_F,
    output        LED_G,
    output        LED_DP,
    input  [7:0]  SW,
    input  [3:0]  BTN,
    output [7:0]  LD,
    output        VGA_R,
    output        VGA_G,
    output        VGA_B,
    output        VGA_HS,
    output        VGA_VS,
    input         PS2C,
    input         PS2D,
    input         RXD,
    output        TXD,
    input         RXDA,
    output        TXDA,
    input         DIN,
    output        INIT_B,
    output        RCLK
);

    wire          clk;
    wire          rst_x;
    wire   [3:0]  w_data0;
    wire   [3:0]  w_data1;
    wire   [3:0]  w_data2;
    wire   [3:0]  w_data3;
    wire          w_dp0;
    wire          w_dp1;
    wire          w_dp2;
    wire          w_dp3;
    wire          w_clk3hz;
    wire          w_clk49khz;
    reg    [24:0] r_clock;
    reg    [3:0]  r_count;

    assign SRAM_A      = 18'h00000;
    assign SRAM_WE_X   = 1'b0;
    assign SRAM_OE_X   = 1'b1;
    assign SRAM_IO_A   = 16'hzzzz;
    assign SRAM_CE_A_X = 1'b1;
    assign SRAM_LB_A_X = 1'b1;
    assign SRAM_UB_A_X = 1'b1;
    assign SRAM_IO_B   = 16'hzzzz;
    assign SRAM_CE_B_X = 1'b1;
    assign SRAM_LB_B_X = 1'b1;
    assign SRAM_UB_B_X = 1'b1;
    assign LD          = SW | {1'b0, BTN, PS2D, PS2C, SOCKET};
    assign VGA_R       = 1'b0;
    assign VGA_G       = 1'b0;
    assign VGA_B       = 1'b0;
    assign VGA_HS      = 1'b1;
    assign VGA_VS      = 1'b1;
    assign TXD         = RXD;
    assign TXDA        = RXDA;
    assign INIT_B      = DIN;
    assign RCLK        = DIN;
    assign clk         = CLK50MHZ;
    assign rst_x       = ~BTN[3];
    assign w_data0     = r_count;
    assign w_data1     = r_count + 4'h1;
    assign w_data2     = r_count + 4'h2;
    assign w_data3     = r_count + 4'h3;
    assign w_dp0       = (r_count[1:0] != 2'b00);
    assign w_dp1       = (r_count[1:0] != 2'b01);
    assign w_dp2       = (r_count[1:0] != 2'b10);
    assign w_dp3       = (r_count[1:0] != 2'b11);
    assign w_clk3hz    = r_clock[24];
    assign w_clk49khz  = r_clock[9];

    always @(posedge clk or negedge rst_x) begin
        if (~rst_x) begin
            r_clock <= 25'b0;
        end else begin
            r_clock <= r_clock + 1'b1;
        end
    end

    always @(posedge w_clk3hz or negedge rst_x) begin
        if (~rst_x) begin
            r_count <= 4'b0;
        end else begin
            r_count <= r_count + 1'b1;
        end
    end

    FourDigitSevenSegmentLED led (
        .clk(w_clk49khz),
        .rst_x(rst_x),
        .i_data3(w_data3),
        .i_data2(w_data2),
        .i_data1(w_data1),
        .i_data0(w_data0),
        .i_dp3(w_dp3),
        .i_dp2(w_dp2),
        .i_dp1(w_dp1),
        .i_dp0(w_dp0),
        .o_a(LED_A),
        .o_b(LED_B),
        .o_c(LED_C),
        .o_d(LED_D),
        .o_e(LED_E),
        .o_f(LED_F),
        .o_g(LED_G),
        .o_dp(LED_DP),
        .o_select(LED_AN)
    );

endmodule

module FourDigitSevenSegmentLED (
    input        clk,
    input        rst_x,
    input  [3:0] i_data3,
    input  [3:0] i_data2,
    input  [3:0] i_data1,
    input  [3:0] i_data0,
    input        i_dp3,
    input        i_dp2,
    input        i_dp1,
    input        i_dp0,
    output reg   o_a,
    output reg   o_b,
    output reg   o_c,
    output reg   o_d,
    output reg   o_e,
    output reg   o_f,
    output reg   o_g,
    output reg   o_dp,
    output reg [3:0] o_select
);

    reg [1:0] r_digit;
    reg [3:0] r_data;

    always @(posedge clk or negedge rst_x) begin
        if (~rst_x) begin
            r_digit <= 2'b00;
        end else begin
            r_digit <= r_digit + 1'b1;
        end
    end

    always @(*) begin
        case (r_digit)
            2'b00: begin
                r_data = i_data0;
                o_select = 4'b1110;
                o_dp = ~i_dp0;
            end
            2'b01: begin
                r_data = i_data1;
                o_select = 4'b1101;
                o_dp = ~i_dp1;
            end
            2'b10: begin
                r_data = i_data2;
                o_select = 4'b1011;
                o_dp = ~i_dp2;
            end
            2'b11: begin
                r_data = i_data3;
                o_select = 4'b0111;
                o_dp = ~i_dp3;
            end
            default: begin
                r_data = 4'b0000;
                o_select = 4'b1111;
                o_dp = 1'b1;
            end
        endcase
    end

    always @(*) begin
        case (r_data)
            4'h0: {o_a, o_b, o_c, o_d, o_e, o_f, o_g} = 7'b0000001;
            4'h1: {o_a, o_b, o_c, o_d, o_e, o_f, o_g} = 7'b1001111;
            4'h2: {o_a, o_b, o_c, o_d, o_e, o_f, o_g} = 7'b0010010;
            4'h3: {o_a, o_b, o_c, o_d, o_e, o_f, o_g} = 7'b0000110;
            4'h4: {o_a, o_b, o_c, o_d, o_e, o_f, o_g} = 7'b1001100;
            4'h5: {o_a, o_b, o_c, o_d, o_e, o_f, o_g} = 7'b0100100;
            4'h6: {o_a, o_b, o_c, o_d, o_e, o_f, o_g} = 7'b0100000;
            4'h7: {o_a, o_b, o_c, o_d, o_e, o_f, o_g} = 7'b0001111;
            4'h8: {o_a, o_b, o_c, o_d, o_e, o_f, o_g} = 7'b0000000;
            4'h9: {o_a, o_b, o_c, o_d, o_e, o_f, o_g} = 7'b0000100;
            4'hA: {o_a, o_b, o_c, o_d, o_e, o_f, o_g} = 7'b0001000;
            4'hB: {o_a, o_b, o_c, o_d, o_e, o_f, o_g} = 7'b1100000;
            4'hC: {o_a, o_b, o_c, o_d, o_e, o_f, o_g} = 7'b0110001;
            4'hD: {o_a, o_b, o_c, o_d, o_e, o_f, o_g} = 7'b1000010;
            4'hE: {o_a, o_b, o_c, o_d, o_e, o_f, o_g} = 7'b0110000;
            4'hF: {o_a, o_b, o_c, o_d, o_e, o_f, o_g} = 7'b0111000;
            default: {o_a, o_b, o_c, o_d, o_e, o_f, o_g} = 7'b1111111;
        endcase
    end

endmodule