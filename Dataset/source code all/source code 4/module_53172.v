module button (
    clk,
    pin_in,
    press,
    );
    input clk;
    input pin_in;
    output press;
    wire pin_din;
    SB_IO #(
        .PIN_TYPE(6'b0000_01),
        .PULLUP(1'b1)
    ) pin_in_config (
        .PACKAGE_PIN(pin_in),
        .D_IN_0(pin_din)
    );
    reg [31:0] debounce_timer = 32'b0;
    parameter DEBOUNCE_PERIOD = 32'd120000;
    reg debouncing = 1'b0;
    reg buttonpress = 1'b0;
    assign press = buttonpress;
    always @ (posedge clk) begin
        if (~debouncing && ~pin_din) begin
            buttonpress <= 1;
            debouncing <= 1;
        end else if (debouncing && ~pin_din) begin
            debounce_timer <= 32'b0;
        end else if (debouncing && debounce_timer < DEBOUNCE_PERIOD) begin
            debounce_timer <= debounce_timer + 1;
        end else if (debouncing) begin
            debounce_timer <= 32'b0;
            debouncing <= 1'b0;
            buttonpress <= 0;
        end
    end
endmodule
