`timescale 1ns/10ps
`timescale 1ns/10ps
module ssd1306_8x64bit_driver (
    clk,
    reset,
    reset_out,
    val0,
    val1,
    val2,
    val3,
    val4,
    val5,
    val6,
    val7,
    control_contrast,
    control_inversion,
    spi_csn,
    spi_clk,
    spi_dcn,
    spi_mosi
);
input clk;
input reset;
output reset_out;
reg reset_out;
input [63:0] val0;
input [63:0] val1;
input [63:0] val2;
input [63:0] val3;
input [63:0] val4;
input [63:0] val5;
input [63:0] val6;
input [63:0] val7;
input [7:0] control_contrast;
input control_inversion;
output spi_csn;
reg spi_csn;
output spi_clk;
reg spi_clk;
output spi_dcn;
reg spi_dcn;
output spi_mosi;
reg spi_mosi;
reg spi_busy;
reg dcn;
reg [6:0] char_rom_address;
reg [7:0] char_rom_data;
reg spi_latch;
reg [7:0] spi_data;
reg [63:0] ssd1306_8x64bit_fsm_1_val4_buffer;
reg [63:0] ssd1306_8x64bit_fsm_1_val6_buffer;
reg [7:0] ssd1306_8x64bit_fsm_1_char_buffer;
reg [24:0] ssd1306_8x64bit_fsm_1_state;
reg ssd1306_8x64bit_fsm_1_con_inversion_buffer;
reg [63:0] ssd1306_8x64bit_fsm_1_val3_buffer;
reg [63:0] ssd1306_8x64bit_fsm_1_val5_buffer;
reg [3:0] ssd1306_8x64bit_fsm_1_char_slice_counter;
reg [63:0] ssd1306_8x64bit_fsm_1_val0_buffer;
reg [63:0] ssd1306_8x64bit_fsm_1_val1_buffer;
reg [7:0] ssd1306_8x64bit_fsm_1_con_contrast_buffer;
reg [63:0] ssd1306_8x64bit_fsm_1_reset_delay;
reg [7:0] ssd1306_8x64bit_fsm_1_char_counter;
reg [63:0] ssd1306_8x64bit_fsm_1_val7_buffer;
reg [63:0] ssd1306_8x64bit_fsm_1_val2_buffer;
reg [7:0] ssd1306_spi_4_1_data_buffer;
reg [4:0] ssd1306_spi_4_1_state;
reg ssd1306_spi_4_1_dcn_buffer;
always @(posedge clk, negedge reset) begin: SSD1306_8X64BIT_DRIVER_SSD1306_8X64BIT_FSM_1_FSM_DR
    if (reset == 0) begin
        ssd1306_8x64bit_fsm_1_char_slice_counter <= 0;
        ssd1306_8x64bit_fsm_1_val7_buffer <= 0;
        spi_latch <= 0;
        dcn <= 0;
        ssd1306_8x64bit_fsm_1_val3_buffer <= 0;
        ssd1306_8x64bit_fsm_1_val4_buffer <= 0;
        ssd1306_8x64bit_fsm_1_val6_buffer <= 0;
        ssd1306_8x64bit_fsm_1_val0_buffer <= 0;
        ssd1306_8x64bit_fsm_1_val1_buffer <= 0;
        ssd1306_8x64bit_fsm_1_con_contrast_buffer <= 0;
        ssd1306_8x64bit_fsm_1_reset_delay <= 0;
        ssd1306_8x64bit_fsm_1_val2_buffer <= 0;
        ssd1306_8x64bit_fsm_1_char_counter <= 0;
        ssd1306_8x64bit_fsm_1_state <= 25'b0000000000000000000000001;
        ssd1306_8x64bit_fsm_1_char_buffer <= 0;
        ssd1306_8x64bit_fsm_1_con_inversion_buffer <= 0;
        ssd1306_8x64bit_fsm_1_val5_buffer <= 0;
        char_rom_address <= 0;
        spi_data <= 0;
        reset_out <= 0;
    end
    else begin
        casez (ssd1306_8x64bit_fsm_1_state)
            25'b????????????????????????1: begin
                ssd1306_8x64bit_fsm_1_state <= 25'b0000000000000000000000010;
                spi_latch <= 0;
                ssd1306_8x64bit_fsm_1_reset_delay <= 0;
            end
            25'b???????????????????????1?: begin
                ssd1306_8x64bit_fsm_1_reset_delay <= (ssd1306_8x64bit_fsm_1_reset_delay + 1);
                reset_out <= 0;
                if ((ssd1306_8x64bit_fsm_1_reset_delay > 120000)) begin
                    ssd1306_8x64bit_fsm_1_state <= 25'b0000000000000000000000100;
                end
                else begin
                    ssd1306_8x64bit_fsm_1_state <= 25'b0000000000000000000000010;
                end
            end
            25'b??????????????????????1??: begin
                reset_out <= 1;
                spi_data <= 32;
                dcn <= 0;
                ssd1306_8x64bit_fsm_1_state <= 25'b0000000000000000000001000;
            end
            25'b?????????????????????1???: begin
                if ((spi_busy == 0)) begin
                    spi_latch <= 1;
                    ssd1306_8x64bit_fsm_1_state <= 25'b0000000000000000000010000;
                end
                else begin
                    spi_latch <= 0;
                    ssd1306_8x64bit_fsm_1_state <= 25'b0000000000000000000001000;
                end
            end
            25'b????????????????????1????: begin
                spi_data <= 0;
                dcn <= 0;
                spi_latch <= 0;
                ssd1306_8x64bit_fsm_1_state <= 25'b0000000000000000000100000;
            end
            25'b???????????????????1?????: begin
                if ((spi_busy == 0)) begin
                    spi_latch <= 1;
                    ssd1306_8x64bit_fsm_1_state <= 25'b0000000000000000001000000;
                end
                else begin
                    spi_latch <= 0;
                    ssd1306_8x64bit_fsm_1_state <= 25'b0000000000000000000100000;
                end
            end
            25'b??????????????????1??????: begin
                spi_data <= 164;
                dcn <= 0;
                spi_latch <= 0;
                ssd1306_8x64bit_fsm_1_state <= 25'b0000000000000000010000000;
            end
            25'b?????????????????1???????: begin
                if ((spi_busy == 0)) begin
                    spi_latch <= 1;
                    ssd1306_8x64bit_fsm_1_state <= 25'b0000000000000000100000000;
                end
                else begin
                    spi_latch <= 0;
                    ssd1306_8x64bit_fsm_1_state <= 25'b0000000000000000010000000;
                end
            end
            25'b????????????????1????????: begin
                spi_data <= 141;
                dcn <= 0;
                spi_latch <= 0;
                ssd1306_8x64bit_fsm_1_state <= 25'b0000000000000001000000000;
            end
            25'b???????????????1?????????: begin
                if ((spi_busy == 0)) begin
                    spi_latch <= 1;
                    ssd1306_8x64bit_fsm_1_state <= 25'b0000000000000010000000000;
                end
                else begin
                    spi_latch <= 0;
                    ssd1306_8x64bit_fsm_1_state <= 25'b0000000000000001000000000;
                end
            end
            25'b??????????????1??????????: begin
                spi_data <= 20;
                dcn <= 0;
                spi_latch <= 0;
                ssd1306_8x64bit_fsm_1_state <= 25'b0000000000000100000000000;
            end
            25'b?????????????1???????????: begin
                if ((spi_busy == 0)) begin
                    spi_latch <= 1;
                    ssd1306_8x64bit_fsm_1_state <= 25'b0000000000001000000000000;
                end
                else begin
                    spi_latch <= 0;
                    ssd1306_8x64bit_fsm_1_state <= 25'b0000000000000100000000000;
                end
            end
            25'b????????????1????????????: begin
                spi_data <= 175;
                dcn <= 0;
                spi_latch <= 0;
                ssd1306_8x64bit_fsm_1_state <= 25'b0000000000010000000000000;
            end
            25'b???????????1?????????????: begin
                if ((spi_busy == 0)) begin
                    spi_latch <= 1;
                    ssd1306_8x64bit_fsm_1_state <= 25'b0000000000100000000000000;
                end
                else begin
                    spi_latch <= 0;
                    ssd1306_8x64bit_fsm_1_state <= 25'b0000000000010000000000000;
                end
            end
            25'b??????????1??????????????: begin
                ssd1306_8x64bit_fsm_1_con_contrast_buffer <= control_contrast;
                spi_data <= 129;
                dcn <= 0;
                spi_latch <= 0;
                ssd1306_8x64bit_fsm_1_state <= 25'b0000000001000000000000000;
            end
            25'b?????????1???????????????: begin
                if ((spi_busy == 0)) begin
                    spi_latch <= 1;
                    ssd1306_8x64bit_fsm_1_state <= 25'b0000000010000000000000000;
                end
                else begin
                    spi_latch <= 0;
                    ssd1306_8x64bit_fsm_1_state <= 25'b0000000001000000000000000;
                end
            end
            25'b????????1????????????????: begin
                spi_data <= ssd1306_8x64bit_fsm_1_con_contrast_buffer;
                dcn <= 0;
                spi_latch <= 0;
                ssd1306_8x64bit_fsm_1_state <= 25'b0000000100000000000000000;
            end
            25'b???????1?????????????????: begin
                if ((spi_busy == 0)) begin
                    spi_latch <= 1;
                    ssd1306_8x64bit_fsm_1_con_inversion_buffer <= control_inversion;
                    ssd1306_8x64bit_fsm_1_state <= 25'b0000001000000000000000000;
                end
                else begin
                    spi_latch <= 0;
                    ssd1306_8x64bit_fsm_1_state <= 25'b0000000100000000000000000;
                end
            end
            25'b??????1??????????????????: begin
                spi_data <= ssd1306_8x64bit_fsm_1_con_inversion_buffer;
                dcn <= 0;
                spi_latch <= 0;
                ssd1306_8x64bit_fsm_1_state <= 25'b0000010000000000000000000;
            end
            25'b?????1???????????????????: begin
                if ((spi_busy == 0)) begin
                    spi_latch <= 1;
                    ssd1306_8x64bit_fsm_1_state <= 25'b0000100000000000000000000;
                end
                else begin
                    spi_latch <= 0;
                    ssd1306_8x64bit_fsm_1_state <= 25'b0000010000000000000000000;
                end
            end
            25'b????1????????????????????: begin
                ssd1306_8x64bit_fsm_1_val0_buffer <= val0;
                ssd1306_8x64bit_fsm_1_val1_buffer <= val1;
                ssd1306_8x64bit_fsm_1_val2_buffer <= val2;
                ssd1306_8x64bit_fsm_1_val3_buffer <= val3;
                ssd1306_8x64bit_fsm_1_val4_buffer <= val4;
                ssd1306_8x64bit_fsm_1_val5_buffer <= val5;
                ssd1306_8x64bit_fsm_1_val6_buffer <= val6;
                ssd1306_8x64bit_fsm_1_val7_buffer <= val7;
                ssd1306_8x64bit_fsm_1_char_counter <= 0;
                ssd1306_8x64bit_fsm_1_char_slice_counter <= 0;
                ssd1306_8x64bit_fsm_1_state <= 25'b0001000000000000000000000;
            end
            25'b???1?????????????????????: begin
                ssd1306_8x64bit_fsm_1_char_slice_counter <= 0;
                case (ssd1306_8x64bit_fsm_1_char_counter)
                    'h0: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val0_buffer[64-1:60];
                    end
                    'h1: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val0_buffer[60-1:56];
                    end
                    'h2: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val0_buffer[56-1:52];
                    end
                    'h3: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val0_buffer[52-1:48];
                    end
                    'h4: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val0_buffer[48-1:44];
                    end
                    'h5: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val0_buffer[44-1:40];
                    end
                    'h6: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val0_buffer[40-1:36];
                    end
                    'h7: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val0_buffer[36-1:32];
                    end
                    'h8: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val0_buffer[32-1:28];
                    end
                    'h9: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val0_buffer[28-1:24];
                    end
                    'ha: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val0_buffer[24-1:20];
                    end
                    'hb: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val0_buffer[20-1:16];
                    end
                    'hc: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val0_buffer[16-1:12];
                    end
                    'hd: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val0_buffer[12-1:8];
                    end
                    'he: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val0_buffer[8-1:4];
                    end
                    'hf: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val0_buffer[4-1:0];
                    end
                    'h10: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val1_buffer[64-1:60];
                    end
                    'h11: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val1_buffer[60-1:56];
                    end
                    'h12: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val1_buffer[56-1:52];
                    end
                    'h13: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val1_buffer[52-1:48];
                    end
                    'h14: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val1_buffer[48-1:44];
                    end
                    'h15: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val1_buffer[44-1:40];
                    end
                    'h16: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val1_buffer[40-1:36];
                    end
                    'h17: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val1_buffer[36-1:32];
                    end
                    'h18: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val1_buffer[32-1:28];
                    end
                    'h19: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val1_buffer[28-1:24];
                    end
                    'h1a: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val1_buffer[24-1:20];
                    end
                    'h1b: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val1_buffer[20-1:16];
                    end
                    'h1c: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val1_buffer[16-1:12];
                    end
                    'h1d: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val1_buffer[12-1:8];
                    end
                    'h1e: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val1_buffer[8-1:4];
                    end
                    'h1f: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val1_buffer[4-1:0];
                    end
                    'h20: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val2_buffer[64-1:60];
                    end
                    'h21: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val2_buffer[60-1:56];
                    end
                    'h22: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val2_buffer[56-1:52];
                    end
                    'h23: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val2_buffer[52-1:48];
                    end
                    'h24: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val2_buffer[48-1:44];
                    end
                    'h25: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val2_buffer[44-1:40];
                    end
                    'h26: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val2_buffer[40-1:36];
                    end
                    'h27: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val2_buffer[36-1:32];
                    end
                    'h28: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val2_buffer[32-1:28];
                    end
                    'h29: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val2_buffer[28-1:24];
                    end
                    'h2a: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val2_buffer[24-1:20];
                    end
                    'h2b: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val2_buffer[20-1:16];
                    end
                    'h2c: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val2_buffer[16-1:12];
                    end
                    'h2d: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val2_buffer[12-1:8];
                    end
                    'h2e: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val2_buffer[8-1:4];
                    end
                    'h2f: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val2_buffer[4-1:0];
                    end
                    'h30: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val3_buffer[64-1:60];
                    end
                    'h31: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val3_buffer[60-1:56];
                    end
                    'h32: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val3_buffer[56-1:52];
                    end
                    'h33: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val3_buffer[52-1:48];
                    end
                    'h34: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val3_buffer[48-1:44];
                    end
                    'h35: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val3_buffer[44-1:40];
                    end
                    'h36: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val3_buffer[40-1:36];
                    end
                    'h37: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val3_buffer[36-1:32];
                    end
                    'h38: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val3_buffer[32-1:28];
                    end
                    'h39: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val3_buffer[28-1:24];
                    end
                    'h3a: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val3_buffer[24-1:20];
                    end
                    'h3b: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val3_buffer[20-1:16];
                    end
                    'h3c: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val3_buffer[16-1:12];
                    end
                    'h3d: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val3_buffer[12-1:8];
                    end
                    'h3e: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val3_buffer[8-1:4];
                    end
                    'h3f: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val3_buffer[4-1:0];
                    end
                    'h40: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val4_buffer[64-1:60];
                    end
                    'h41: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val4_buffer[60-1:56];
                    end
                    'h42: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val4_buffer[56-1:52];
                    end
                    'h43: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val4_buffer[52-1:48];
                    end
                    'h44: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val4_buffer[48-1:44];
                    end
                    'h45: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val4_buffer[44-1:40];
                    end
                    'h46: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val4_buffer[40-1:36];
                    end
                    'h47: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val4_buffer[36-1:32];
                    end
                    'h48: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val4_buffer[32-1:28];
                    end
                    'h49: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val4_buffer[28-1:24];
                    end
                    'h4a: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val4_buffer[24-1:20];
                    end
                    'h4b: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val4_buffer[20-1:16];
                    end
                    'h4c: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val4_buffer[16-1:12];
                    end
                    'h4d: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val4_buffer[12-1:8];
                    end
                    'h4e: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val4_buffer[8-1:4];
                    end
                    'h4f: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val4_buffer[4-1:0];
                    end
                    'h50: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val5_buffer[64-1:60];
                    end
                    'h51: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val5_buffer[60-1:56];
                    end
                    'h52: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val5_buffer[56-1:52];
                    end
                    'h53: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val5_buffer[52-1:48];
                    end
                    'h54: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val5_buffer[48-1:44];
                    end
                    'h55: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val5_buffer[44-1:40];
                    end
                    'h56: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val5_buffer[40-1:36];
                    end
                    'h57: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val5_buffer[36-1:32];
                    end
                    'h58: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val5_buffer[32-1:28];
                    end
                    'h59: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val5_buffer[28-1:24];
                    end
                    'h5a: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val5_buffer[24-1:20];
                    end
                    'h5b: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val5_buffer[20-1:16];
                    end
                    'h5c: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val5_buffer[16-1:12];
                    end
                    'h5d: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val5_buffer[12-1:8];
                    end
                    'h5e: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val5_buffer[8-1:4];
                    end
                    'h5f: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val5_buffer[4-1:0];
                    end
                    'h60: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val6_buffer[64-1:60];
                    end
                    'h61: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val6_buffer[60-1:56];
                    end
                    'h62: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val6_buffer[56-1:52];
                    end
                    'h63: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val6_buffer[52-1:48];
                    end
                    'h64: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val6_buffer[48-1:44];
                    end
                    'h65: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val6_buffer[44-1:40];
                    end
                    'h66: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val6_buffer[40-1:36];
                    end
                    'h67: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val6_buffer[36-1:32];
                    end
                    'h68: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val6_buffer[32-1:28];
                    end
                    'h69: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val6_buffer[28-1:24];
                    end
                    'h6a: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val6_buffer[24-1:20];
                    end
                    'h6b: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val6_buffer[20-1:16];
                    end
                    'h6c: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val6_buffer[16-1:12];
                    end
                    'h6d: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val6_buffer[12-1:8];
                    end
                    'h6e: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val6_buffer[8-1:4];
                    end
                    'h6f: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val6_buffer[4-1:0];
                    end
                    'h70: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val7_buffer[64-1:60];
                    end
                    'h71: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val7_buffer[60-1:56];
                    end
                    'h72: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val7_buffer[56-1:52];
                    end
                    'h73: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val7_buffer[52-1:48];
                    end
                    'h74: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val7_buffer[48-1:44];
                    end
                    'h75: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val7_buffer[44-1:40];
                    end
                    'h76: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val7_buffer[40-1:36];
                    end
                    'h77: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val7_buffer[36-1:32];
                    end
                    'h78: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val7_buffer[32-1:28];
                    end
                    'h79: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val7_buffer[28-1:24];
                    end
                    'h7a: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val7_buffer[24-1:20];
                    end
                    'h7b: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val7_buffer[20-1:16];
                    end
                    'h7c: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val7_buffer[16-1:12];
                    end
                    'h7d: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val7_buffer[12-1:8];
                    end
                    'h7e: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val7_buffer[8-1:4];
                    end
                    'h7f: begin
                        ssd1306_8x64bit_fsm_1_char_buffer <= ssd1306_8x64bit_fsm_1_val7_buffer[4-1:0];
                    end
                endcase
                ssd1306_8x64bit_fsm_1_state <= 25'b0010000000000000000000000;
            end
            25'b??1??????????????????????: begin
                char_rom_address <= ((ssd1306_8x64bit_fsm_1_char_buffer * 8) + ssd1306_8x64bit_fsm_1_char_slice_counter);
                ssd1306_8x64bit_fsm_1_state <= 25'b0100000000000000000000000;
            end
            25'b?1???????????????????????: begin
                spi_latch <= 0;
                spi_data <= char_rom_data;
                dcn <= 1;
                ssd1306_8x64bit_fsm_1_state <= 25'b1000000000000000000000000;
            end
            25'b1????????????????????????: begin
                if ((spi_busy == 0)) begin
                    spi_latch <= 1;
                    if ((ssd1306_8x64bit_fsm_1_char_slice_counter < 7)) begin
                        ssd1306_8x64bit_fsm_1_char_slice_counter <= (ssd1306_8x64bit_fsm_1_char_slice_counter + 1);
                        ssd1306_8x64bit_fsm_1_state <= 25'b0010000000000000000000000;
                    end
                    else begin
                        ssd1306_8x64bit_fsm_1_char_slice_counter <= 0;
                        if ((ssd1306_8x64bit_fsm_1_char_counter < 127)) begin
                            ssd1306_8x64bit_fsm_1_char_counter <= (ssd1306_8x64bit_fsm_1_char_counter + 1);
                            ssd1306_8x64bit_fsm_1_state <= 25'b0001000000000000000000000;
                        end
                        else begin
                            ssd1306_8x64bit_fsm_1_state <= 25'b0000000000100000000000000;
                            ssd1306_8x64bit_fsm_1_char_counter <= 0;
                        end
                    end
                end
                else begin
                    ssd1306_8x64bit_fsm_1_state <= 25'b1000000000000000000000000;
                end
            end
            default: begin
                $finish;
            end
        endcase
    end
end
always @(posedge clk, negedge reset) begin: SSD1306_8X64BIT_DRIVER_SSD1306_SPI_4_1_FSM_SPI
    if (reset == 0) begin
        spi_clk <= 0;
        spi_busy <= 0;
        ssd1306_spi_4_1_state <= 5'b00000;
        ssd1306_spi_4_1_data_buffer <= 0;
        spi_dcn <= 0;
        spi_csn <= 0;
        spi_mosi <= 0;
        ssd1306_spi_4_1_dcn_buffer <= 0;
    end
    else begin
        case (ssd1306_spi_4_1_state)
            5'b00000: begin
                spi_clk <= 0;
                spi_mosi <= 0;
                spi_busy <= 0;
                spi_csn <= 1;
                if ((spi_latch == 1)) begin
                    ssd1306_spi_4_1_data_buffer <= spi_data;
                    ssd1306_spi_4_1_dcn_buffer <= dcn;
                    spi_busy <= 1;
                    ssd1306_spi_4_1_state <= 5'b00001;
                end
            end
            5'b00001: begin
                spi_csn <= 0;
                ssd1306_spi_4_1_state <= 5'b00010;
            end
            5'b00010: begin
                spi_clk <= 0;
                spi_mosi <= ssd1306_spi_4_1_data_buffer[8-1:7];
                ssd1306_spi_4_1_state <= 5'b00011;
            end
            5'b00011: begin
                spi_clk <= 1;
                ssd1306_spi_4_1_state <= 5'b00100;
            end
            5'b00100: begin
                spi_clk <= 0;
                spi_mosi <= ssd1306_spi_4_1_data_buffer[7-1:6];
                ssd1306_spi_4_1_state <= 5'b00101;
            end
            5'b00101: begin
                spi_clk <= 1;
                ssd1306_spi_4_1_state <= 5'b00110;
            end
            5'b00110: begin
                spi_clk <= 0;
                spi_mosi <= ssd1306_spi_4_1_data_buffer[6-1:5];
                ssd1306_spi_4_1_state <= 5'b00111;
            end
            5'b00111: begin
                spi_clk <= 1;
                ssd1306_spi_4_1_state <= 5'b01000;
            end
            5'b01000: begin
                spi_clk <= 0;
                spi_mosi <= ssd1306_spi_4_1_data_buffer[5-1:4];
                ssd1306_spi_4_1_state <= 5'b01001;
            end
            5'b01001: begin
                spi_clk <= 1;
                ssd1306_spi_4_1_state <= 5'b01010;
            end
            5'b01010: begin
                spi_clk <= 0;
                spi_mosi <= ssd1306_spi_4_1_data_buffer[4-1:3];
                ssd1306_spi_4_1_state <= 5'b01011;
            end
            5'b01011: begin
                spi_clk <= 1;
                ssd1306_spi_4_1_state <= 5'b01100;
            end
            5'b01100: begin
                spi_clk <= 0;
                spi_mosi <= ssd1306_spi_4_1_data_buffer[3-1:2];
                ssd1306_spi_4_1_state <= 5'b01101;
            end
            5'b01101: begin
                spi_clk <= 1;
                ssd1306_spi_4_1_state <= 5'b01110;
            end
            5'b01110: begin
                spi_clk <= 0;
                spi_mosi <= ssd1306_spi_4_1_data_buffer[2-1:1];
                ssd1306_spi_4_1_state <= 5'b01111;
            end
            5'b01111: begin
                spi_clk <= 1;
                ssd1306_spi_4_1_state <= 5'b10000;
            end
            5'b10000: begin
                spi_clk <= 0;
                spi_mosi <= ssd1306_spi_4_1_data_buffer[1-1:0];
                spi_dcn <= ssd1306_spi_4_1_dcn_buffer;
                ssd1306_spi_4_1_state <= 5'b10001;
            end
            5'b10001: begin
                spi_clk <= 1;
                ssd1306_spi_4_1_state <= 5'b10010;
            end
            5'b10010: begin
                spi_clk <= 0;
                spi_csn <= 1;
                ssd1306_spi_4_1_state <= 5'b00000;
            end
            default: begin
                $finish;
            end
        endcase
    end
end
always @(char_rom_address) begin: SSD1306_8X64BIT_DRIVER_ROM_1_READ
    case (char_rom_address)
        0: char_rom_data = 0;
        1: char_rom_data = 0;
        2: char_rom_data = 62;
        3: char_rom_data = 81;
        4: char_rom_data = 73;
        5: char_rom_data = 69;
        6: char_rom_data = 62;
        7: char_rom_data = 0;
        8: char_rom_data = 0;
        9: char_rom_data = 0;
        10: char_rom_data = 0;
        11: char_rom_data = 66;
        12: char_rom_data = 127;
        13: char_rom_data = 64;
        14: char_rom_data = 0;
        15: char_rom_data = 0;
        16: char_rom_data = 0;
        17: char_rom_data = 0;
        18: char_rom_data = 66;
        19: char_rom_data = 97;
        20: char_rom_data = 81;
        21: char_rom_data = 73;
        22: char_rom_data = 70;
        23: char_rom_data = 0;
        24: char_rom_data = 0;
        25: char_rom_data = 0;
        26: char_rom_data = 34;
        27: char_rom_data = 65;
        28: char_rom_data = 73;
        29: char_rom_data = 73;
        30: char_rom_data = 93;
        31: char_rom_data = 54;
        32: char_rom_data = 0;
        33: char_rom_data = 31;
        34: char_rom_data = 16;
        35: char_rom_data = 16;
        36: char_rom_data = 124;
        37: char_rom_data = 16;
        38: char_rom_data = 16;
        39: char_rom_data = 0;
        40: char_rom_data = 0;
        41: char_rom_data = 0;
        42: char_rom_data = 71;
        43: char_rom_data = 69;
        44: char_rom_data = 69;
        45: char_rom_data = 109;
        46: char_rom_data = 57;
        47: char_rom_data = 0;
        48: char_rom_data = 0;
        49: char_rom_data = 60;
        50: char_rom_data = 110;
        51: char_rom_data = 75;
        52: char_rom_data = 73;
        53: char_rom_data = 73;
        54: char_rom_data = 49;
        55: char_rom_data = 0;
        56: char_rom_data = 0;
        57: char_rom_data = 0;
        58: char_rom_data = 65;
        59: char_rom_data = 97;
        60: char_rom_data = 49;
        61: char_rom_data = 25;
        62: char_rom_data = 15;
        63: char_rom_data = 0;
        64: char_rom_data = 0;
        65: char_rom_data = 0;
        66: char_rom_data = 54;
        67: char_rom_data = 73;
        68: char_rom_data = 73;
        69: char_rom_data = 73;
        70: char_rom_data = 54;
        71: char_rom_data = 0;
        72: char_rom_data = 0;
        73: char_rom_data = 0;
        74: char_rom_data = 70;
        75: char_rom_data = 77;
        76: char_rom_data = 73;
        77: char_rom_data = 105;
        78: char_rom_data = 57;
        79: char_rom_data = 30;
        80: char_rom_data = 0;
        81: char_rom_data = 120;
        82: char_rom_data = 30;
        83: char_rom_data = 9;
        84: char_rom_data = 9;
        85: char_rom_data = 9;
        86: char_rom_data = 30;
        87: char_rom_data = 120;
        88: char_rom_data = 0;
        89: char_rom_data = 127;
        90: char_rom_data = 73;
        91: char_rom_data = 73;
        92: char_rom_data = 73;
        93: char_rom_data = 73;
        94: char_rom_data = 54;
        95: char_rom_data = 0;
        96: char_rom_data = 0;
        97: char_rom_data = 60;
        98: char_rom_data = 102;
        99: char_rom_data = 67;
        100: char_rom_data = 65;
        101: char_rom_data = 65;
        102: char_rom_data = 99;
        103: char_rom_data = 0;
        104: char_rom_data = 0;
        105: char_rom_data = 0;
        106: char_rom_data = 127;
        107: char_rom_data = 65;
        108: char_rom_data = 65;
        109: char_rom_data = 99;
        110: char_rom_data = 62;
        111: char_rom_data = 0;
        112: char_rom_data = 0;
        113: char_rom_data = 0;
        114: char_rom_data = 127;
        115: char_rom_data = 73;
        116: char_rom_data = 73;
        117: char_rom_data = 65;
        118: char_rom_data = 65;
        119: char_rom_data = 0;
        120: char_rom_data = 0;
        121: char_rom_data = 0;
        122: char_rom_data = 127;
        123: char_rom_data = 9;
        124: char_rom_data = 9;
        125: char_rom_data = 1;
        126: char_rom_data = 1;
        default: char_rom_data = 0;
    endcase
end
endmodule
