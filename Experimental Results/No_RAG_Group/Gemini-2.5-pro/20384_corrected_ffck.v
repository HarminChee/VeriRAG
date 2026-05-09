module tdm_to_i2s_converter_corrected_ffc (
    rst_i,
    sck_i,
    fsync_i,
    dat_i,
    mck_o,
    bck_o,
    lrck_o,
    dat_o
);
    input rst_i;
    input sck_i;    // Primary Clock
    input fsync_i;
    input dat_i;
    output mck_o;
    output bck_o;
    output lrck_o;
    output reg [3:0] dat_o;

    // Removed redundant wire: assign rst = rst_i; Use rst_i directly.

    reg s_fsync;
    // s_fsync FF - Clocked by primary input sck_i
    always @ (posedge sck_i or posedge rst_i) begin
        if(rst_i) begin
            s_fsync <= 1'b0;
        end
        else begin
            s_fsync <= fsync_i;
        end
    end

    reg [8:0] bit_cnt;
    // bit_cnt FF - Clocked by primary input sck_i
    always @ (negedge sck_i or posedge rst_i) begin
        if(rst_i) begin
            bit_cnt <= 9'b111111111;
        end
        else begin
            if(s_fsync) begin // Use registered s_fsync
                bit_cnt <= {~bit_cnt[8], 8'b0};
            end
            else begin
                bit_cnt <= bit_cnt + 1'b1;
            end
        end
    end

    reg [63:0] dat_0_a, dat_0_b;
    reg [63:0] dat_1_a, dat_1_b;
    reg [63:0] dat_2_a, dat_2_b;
    reg [63:0] dat_3_a, dat_3_b;
    // Data storage FFs - Clocked by primary input sck_i
    always @ (posedge sck_i or posedge rst_i) begin
        if(rst_i) begin
            dat_0_a <= 64'b0;
            dat_1_a <= 64'b0;
            dat_2_a <= 64'b0;
            dat_3_a <= 64'b0;
            dat_0_b <= 64'b0;
            dat_1_b <= 64'b0;
            dat_2_b <= 64'b0;
            dat_3_b <= 64'b0;
        end
        else begin
            // Uses bit_cnt value from previous negedge sck_i cycle
            if(bit_cnt[8]) begin
                case(bit_cnt[7:6])
                    2'b00: dat_0_a[63-bit_cnt[5:0]] <= dat_i;
                    2'b01: dat_1_a[63-bit_cnt[5:0]] <= dat_i;
                    2'b10: dat_2_a[63-bit_cnt[5:0]] <= dat_i;
                    2'b11: dat_3_a[63-bit_cnt[5:0]] <= dat_i;
                endcase
            end
            else begin
                case(bit_cnt[7:6])
                    2'b00: dat_0_b[63-bit_cnt[5:0]] <= dat_i;
                    2'b01: dat_1_b[63-bit_cnt[5:0]] <= dat_i;
                    2'b10: dat_2_b[63-bit_cnt[5:0]] <= dat_i;
                    2'b11: dat_3_b[63-bit_cnt[5:0]] <= dat_i;
                endcase
            end
        end
    end

    // Output assignments based on FF outputs (combinational)
    assign mck_o = sck_i;
    assign bck_o = bit_cnt[1]; // Generated signal based on FF output
    assign lrck_o = bit_cnt[7]; // Generated signal based on FF output

    // --- DFT Fix for dat_o ---
    // Register to store the previous value of bit_cnt[1] to detect falling edge
    reg bit_cnt_1_prev;
    always @(negedge sck_i or posedge rst_i) begin
        if (rst_i) begin
            bit_cnt_1_prev <= 1'b1; // bit_cnt[1] is 1 after reset
        end else begin
            bit_cnt_1_prev <= bit_cnt[1]; // Capture current bit_cnt[1] before it updates
        end
    end

    // Enable signal: Active when bit_cnt[1] transitions from 1 to 0 (falling edge)
    // This check uses the value of bit_cnt *after* the negedge update and the value *before* the update
    wire dat_o_enable = bit_cnt_1_prev & ~bit_cnt[1];

    // dat_o FF - Now clocked by primary input sck_i with enable logic
    always @ (negedge sck_i or posedge rst_i) begin
        if(rst_i) begin
            dat_o <= 4'b0;
        end
        else if (dat_o_enable) begin // Update only when original bck_o would have fallen
            // Use the value of bit_cnt *after* the negedge update
            if(bit_cnt[8]) begin
                dat_o <= {dat_3_b[63-bit_cnt[7:2]], dat_2_b[63-bit_cnt[7:2]], dat_1_b[63-bit_cnt[7:2]], dat_0_b[63-bit_cnt[7:2]]};
            end
            else begin
                dat_o <= {dat_3_a[63-bit_cnt[7:2]], dat_2_a[63-bit_cnt[7:2]], dat_1_a[63-bit_cnt[7:2]], dat_0_a[63-bit_cnt[7:2]]};
            end
        end
        // If dat_o_enable is not active, dat_o retains its previous value implicitly
    end
    // --- End DFT Fix ---

endmodule