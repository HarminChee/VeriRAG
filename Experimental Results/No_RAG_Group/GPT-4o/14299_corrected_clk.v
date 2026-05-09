module clk_reset_corrected_clk(clk_in, reset_inout_n,
                               sdram_clk, sdram_fb,
                               clk, clk_ok, reset);
    input clk_in;
    inout reset_inout_n;
    output sdram_clk;
    input sdram_fb;
    output clk;
    output clk_ok;
    output reset;
    
    wire clk_in_buf;
    wire int_locked;
    wire ext_rst_n;
    wire ext_fb;
    wire ext_locked;
    reg reset_p_n;
    reg reset_s_n;
    reg [23:0] reset_counter;
    wire reset_counting;
    wire primary_clk; // New primary clock signal

    IBUFG clk_in_buffer(
        .I(clk_in),
        .O(clk_in_buf)
    );

    // Assign primary clock directly to the new primary_clk wire
    assign primary_clk = clk_in_buf;

    DCM int_dcm(
        .CLKIN(primary_clk), // Use primary clock
        .CLKFB(clk),
        .RST(1'b0),
        .CLK0(clk), // Directly use the output clock
        .LOCKED(int_locked)
    );

    SRL16 ext_dll_rst_gen(
        .CLK(primary_clk), // Use primary clock
        .D(int_locked),
        .Q(ext_rst_n),
        .A0(1'b1),
        .A1(1'b1),
        .A2(1'b1),
        .A3(1'b1)
    );
    defparam ext_dll_rst_gen.INIT = 16'h0000;

    IBUFG ext_fb_buffer(
        .I(sdram_fb),
        .O(ext_fb)
    );

    DCM ext_dcm(
        .CLKIN(primary_clk), // Use primary clock
        .CLKFB(ext_fb),
        .RST(~ext_rst_n),
        .CLK0(sdram_clk),
        .LOCKED(ext_locked)
    );

    assign clk_ok = int_locked & ext_locked;
    assign reset_counting = (reset_counter == 24'hFFFFFF) ? 0 : 1;
    assign reset_inout_n = (reset_counter[23] == 0) ? 1'b0 : 1'bz;

    always @(posedge primary_clk) begin // Use primary clock
        reset_p_n <= reset_inout_n;
        reset_s_n <= reset_p_n;
        if (reset_counting == 1) begin
            reset_counter <= reset_counter + 1;
        end else begin
            if (~reset_s_n | ~clk_ok) begin
                reset_counter <= 24'h000000;
            end
        end
    end

    assign reset = reset_counting;
endmodule