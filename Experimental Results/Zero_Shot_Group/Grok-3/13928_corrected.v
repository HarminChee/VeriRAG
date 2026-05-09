<xaiArtifact artifact_id="7fcdfb83-c49c-4915-8a22-415ed098d697" artifact_version_id="da89c36e-00cb-41ef-8c90-c90168415770" title="ps2_keyboard.v" contentType="text/verilog">
module ps2_keyboard (
    output reg RESET_N,
    input CLK,
    output reg PS2_CLK,
    output reg PS2_DATA,
    output reg RX_SCAN,
    output reg RX_PRESSED,
    output reg RX_EXTENDED
);

    reg [10:0] shift_reg;
    reg [3:0] bit_count;
    reg [24:0] clk_div;
    reg sending;

    // Clock divider for PS/2 timing (~20kHz from 50MHz CLK)
    always @(posedge CLK) begin
        clk_div <= clk_div + 1;
    end

    // PS/2 clock generation
    always @(posedge CLK) begin
        if (clk_div[14]) begin  // ~20kHz
            PS2_CLK <= ~PS2_CLK;
        end
    end

    // Initial state
    initial begin
        RESET_N = 1;
        PS2_CLK = 1;
        PS2_DATA = 1;
        RX_SCAN = 0;
        RX_PRESSED = 0;
        RX_EXTENDED = 0;
        bit_count = 0;
        sending = 0;
        shift_reg = 11'b11111111111;
    end

    // Simple state machine to send a scan code
    always @(posedge CLK) begin
        if (!sending && bit_count == 0) begin
            // Start sending a sample key press (e.g., 'A' key = 0x1C)
            shift_reg <= {1'b1, ~^8'h1C, 8'h1C, 1'b0}; // Stop, Parity, Data, Start
            sending <= 1;
            bit_count <= 11;
        end
        else if (sending && clk_div[14] && !PS2_CLK) begin
            if (bit_count > 0) begin
                PS2_DATA <= shift_reg[0];
                shift_reg <= shift_reg >> 1;
                bit_count <= bit_count - 1;
            end
            else begin
                sending <= 0;
                PS2_DATA <= 1;
                RX_SCAN <= 1;
                RX_PRESSED <= 1;
                RX_EXTENDED <= 0;
            end
        end
    end

endmodule
</xaiArtifact>