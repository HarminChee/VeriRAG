`timescale 1ns/1ns
`timescale 1ns/1ns
module key_logic_fsm (
    clock,reset,k[3:0],lcd_busy,reg_busy,
    run_timer,reset_timer,insert_value,clear_value);
    input clock;
    input reset;
    input [3:0] k;
    input lcd_busy;
    input reg_busy;
    tri0 reset;
    tri0 [3:0] k;
    tri0 lcd_busy;
    tri0 reg_busy;
    output run_timer;
    output reset_timer;
    output insert_value;
    output clear_value;
    reg run_timer;
    reg reset_timer;
    reg insert_value;
    reg clear_value;
    reg [10:0] fstate;
    reg [10:0] reg_fstate;
    parameter s_pre_start=0,s_run=1,s_pre_pause=2,s_pause=3,s_idle=4,s_pre_reset=5,s_reset=6,s_retrieve=7,s_save=8,s_pre_clear=9,s_clear=10;
    always @(posedge clock)
    begin
        if (clock) begin
            fstate <= reg_fstate;
        end
    end
    always @(fstate or reset or k or lcd_busy or reg_busy)
    begin
        if (reset) begin
            reg_fstate <= s_idle;
            run_timer <= 1'b0;
            reset_timer <= 1'b0;
            insert_value <= 1'b0;
            clear_value <= 1'b0;
        end
        else begin
            run_timer <= 1'b0;
            reset_timer <= 1'b0;
            insert_value <= 1'b0;
            clear_value <= 1'b0;
            case (fstate)
                s_pre_start: begin
                    if ((k[3:0] != 4'b0000))
                        reg_fstate <= s_pre_start;
                    else if ((k[3:0] == 4'b0000))
                        reg_fstate <= s_run;
                    else
                        reg_fstate <= s_pre_start;
                    run_timer <= 1'b1;
                end
                s_run: begin
                    if ((k[3:0] == 4'b0000))
                        reg_fstate <= s_run;
                    else if ((k[3:0] == 4'b1000))
                        reg_fstate <= s_pre_pause;
                    else if ((k[3:0] == 4'b0100))
                        reg_fstate <= s_retrieve;
                    else if ((k[3:0] == 4'b0010))
                        reg_fstate <= s_pre_reset;
                    else
                        reg_fstate <= s_run;
                    run_timer <= 1'b1;
                end
                s_pre_pause: begin
                    if ((k[3:0] != 4'b0000))
                        reg_fstate <= s_pre_pause;
                    else if ((k[3:0] == 4'b0000))
                        reg_fstate <= s_pause;
                    else
                        reg_fstate <= s_pre_pause;
                end
                s_pause: begin
                    if ((k[3:0] == 4'b0000))
                        reg_fstate <= s_pause;
                    else if ((k[3:0] == 4'b1000))
                        reg_fstate <= s_pre_start;
                    else if ((k[3:0] == 4'b0010))
                        reg_fstate <= s_pre_reset;
                    else if ((k[3:0] == 4'b0001))
                        reg_fstate <= s_pre_clear;
                    else
                        reg_fstate <= s_pause;
                end
                s_idle: begin
                    if ((k[3:0] == 4'b0000))
                        reg_fstate <= s_idle;
                    else if ((k[3:0] == 4'b1000))
                        reg_fstate <= s_pre_start;
                    else if ((k[3:0] == 4'b0010))
                        reg_fstate <= s_pre_reset;
                    else if ((k[3:0] == 4'b0001))
                        reg_fstate <= s_pre_clear;
                    else
                        reg_fstate <= s_idle;
                end
                s_pre_reset: begin
                    if ((k[3:0] != 4'b0000))
                        reg_fstate <= s_pre_reset;
                    else if ((k[3:0] == 4'b0000))
                        reg_fstate <= s_reset;
                    else
                        reg_fstate <= s_pre_reset;
                end
                s_reset: begin
                    if (reg_busy)
                        reg_fstate <= s_reset;
                    else if (~(reg_busy))
                        reg_fstate <= s_idle;
                    else
                        reg_fstate <= s_reset;
                    reset_timer <= 1'b1;
                end
                s_retrieve: begin
                    reg_fstate <= s_save;
                    insert_value <= 1'b1;
                end
                s_save: begin
                    if ((lcd_busy | (k[3:0] != 4'b0000)))
                        reg_fstate <= s_save;
                    else if ((~(lcd_busy) & (k[3:0] == 4'b0000)))
                        reg_fstate <= s_run;
                    else
                        reg_fstate <= s_save;
                    run_timer <= 1'b1;
                end
                s_pre_clear: begin
                    if ((k[3:0] != 4'b0000))
                        reg_fstate <= s_pre_clear;
                    else if ((k[3:0] == 4'b0000))
                        reg_fstate <= s_clear;
                    else
                        reg_fstate <= s_pre_clear;
                end
                s_clear: begin
                    if (lcd_busy)
                        reg_fstate <= s_clear;
                    else if (~(lcd_busy))
                        reg_fstate <= s_pause;
                    else
                        reg_fstate <= s_clear;
                    clear_value <= 1'b1;
                end
                default: begin
                    run_timer <= 1'bx;
                    reset_timer <= 1'bx;
                    insert_value <= 1'bx;
                    clear_value <= 1'bx;
                    $display ("Reach undefined state");
                end
            endcase
        end
    end
endmodule 
