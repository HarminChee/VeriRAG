module keyboard(
    input wire test_i,
    input wire keyboard_clk,
    input wire keyboard_data,
    input wire clock50,
    input wire reset,
    input wire read,
    output wire scan_ready,
    output wire [7:0] scan_code
);
    reg ready_set;
    reg [7:0] scan_code_reg;
    reg scan_ready_reg;
    reg read_char;
    reg [3:0] incnt;
    reg [8:0] shiftin;
    reg [7:0] filter;
    reg keyboard_clk_filtered;
    wire dft_clock;
    wire dft_reset;

    assign dft_clock = test_i ? clock50 : keyboard_clk;
    assign dft_reset = test_i ? reset : reset;
    assign scan_ready = scan_ready_reg;
    assign scan_code = scan_code_reg;

    always @(posedge ready_set or posedge read)
        if (read == 1)
            scan_ready_reg <= 0;
        else
            scan_ready_reg <= 1;

    always @(posedge clock50)
        filter <= {keyboard_clk, filter[7:1]};

    always @(posedge dft_clock)
        if (filter == 8'b11111111)
            keyboard_clk_filtered <= 1;
        else if (filter == 8'b00000000)
            keyboard_clk_filtered <= 0;

    always @(posedge keyboard_clk_filtered or posedge dft_reset)
        if (dft_reset == 1)
            begin
                incnt <= 4'b0000;
                read_char <= 0;
            end
        else if (keyboard_data == 0 && read_char == 0)
            begin
                read_char <= 1;
                ready_set <= 0;
            end
        else if (read_char == 1)
            begin
                if (incnt < 9)
                    begin
                        incnt <= incnt + 1'b1;
                        shiftin <= {keyboard_data, shiftin[8:1]};
                        ready_set <= 0;
                    end
                else
                    begin
                        incnt <= 0;
                        scan_code_reg <= shiftin[7:0];
                        read_char <= 0;
                        ready_set <= 1;
                    end
            end
endmodule