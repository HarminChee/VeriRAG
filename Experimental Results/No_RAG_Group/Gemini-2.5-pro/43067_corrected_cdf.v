`timescale 1ns/1ps
`timescale 1ns/1ps
module corrected_cdf ( // Port list corrected for style
    input clk,
    input rst_n,
    inout sda,
    output scl,
    input RD_EN,
    input WR_EN,
    output reg receive_status, // Made output reg directly
    output tx_start, // Assuming output from check_pin
    output [7:0] tx_data, // Assuming output from check_pin
    input tx_complete,
    input bps_start_t,
    input capture_rst
);

    // Internal signals
    reg WR, RD;
    reg scl_clk;
    reg [7:0] clk_div;
    reg [9:0] send_count; // Increased width to hold 32
    wire [7:0] data;
    reg [7:0] data_reg;
    reg end_ready;
    wire ack;
    wire tx_end; // Assuming output from check_pin instance
    reg [7:0] send_memory [31:0];
    reg [7:0] receive_memory [31:0];

    // Instantiate check_pin - Assuming tx_start, tx_data, tx_end are outputs of check_pin
    check_pin check_pin_instance (
        .clk(clk),
        .rst_n(rst_n),
        .tx_start(tx_start), // Output connected
        .capture_ready((send_count == 10'd32) && RD_EN && end_ready),
        .tx_data(tx_data), // Output connected
        .tx_complete(tx_complete),
        .tx_end(tx_end), // Output connected
        .bps_start_t(bps_start_t),
        .receive_status(receive_status), // Input to check_pin?
        .capture_rst(capture_rst)
    );

    // end_ready logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            end_ready <= 1'b0;
        else
            end_ready <= tx_end ? 1'b0 : 1'b1;
    end

    // scl_clk generation (Generated clock - DFT issue, but not CDFDAT)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            scl_clk <= 1'b0;
            clk_div <= 8'h0; // Use explicit width
            // Initialize send_memory (can use a loop for clarity)
            for (integer i = 0; i < 32; i = i + 1) begin
                 send_memory[i] <= i[7:0]; // Simplified initialization
            end
        end else begin
            // Using 200 requires 8 bits minimum for clk_div
            if (clk_div >= 8'd200) begin // Use >= for robustness
                scl_clk <= ~scl_clk;
                clk_div <= 8'h0;
            end else begin
                clk_div <= clk_div + 1'b1;
            end
        end
    end

    // send_count and receive_memory update (Clocked by ack - DFT issue)
    // *** Applying CDFDAT Fix Here ***
    // Removed '&& ack' condition from the data path logic inside the always block
    // clocked by 'ack' itself to resolve CDFDAT violation.
    always @(posedge ack or negedge rst_n) begin
        if (!rst_n) begin
            send_count <= 10'h0; // Use explicit width
             // Also reset receive_memory? Assuming yes based on context.
             for (integer i = 0; i < 32; i = i + 1) begin
                 receive_memory[i] <= 8'h0;
             end
        end else begin
            // The '&& ack' condition was removed here.
            if (send_count < 10'd32) begin
                send_count <= send_count + 1'b1;
                // Update memory for the *current* count index before it increments
                receive_memory[send_count] <= RD_EN ? data : 8'h0;
            end
            // No else needed, send_count holds value if condition is false
        end
    end

    // receive_status logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            receive_status <= 1'b0;
        else
            // Check if the last received byte matches the expected value (31)
            receive_status <= (receive_memory[31] == 8'd31) ? 1'b1 : 1'b0; // Corrected comparison
    end

    // WR, RD, data_reg logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            WR <= 1'b0;
            RD <= 1'b0;
            data_reg <= 8'h0; // Use explicit width
        end else begin
            // Corrected condition: use 10 bits for send_count comparison
            if (send_count == 10'd32) begin
                WR <= 1'b0;
                RD <= 1'b0;
            end else begin // When send_count < 32
                if (RD_EN) begin
                    RD <= 1'b1;
                    WR <= 1'b0; // Ensure WR goes low on RD
                end else if (WR_EN) begin
                    WR <= 1'b1;
                    RD <= 1'b0; // Ensure RD goes low on WR
                    data_reg <= send_memory[send_count];
                end else begin // Neither RD_EN nor WR_EN active
                    WR <= 1'b0;
                    RD <= 1'b0;
                end
            end
        end
    end

    // Data output logic for I2C_wr instance
    assign data = data_reg; // Provide data_reg content to I2C_wr when WR is active

    // Instantiate I2C_wr
    // Assuming I2C_wr handles sda direction based on WR/RD inputs.
    I2C_wr I2C_wr_instance (
        .sda(sda),
        .scl(scl), // scl is output of I2C_wr
        .ack(ack), // ack is output of I2C_wr
        .rst_n(rst_n),
        .clk(scl_clk), // Uses generated clock scl_clk
        .WR(WR),
        .RD(RD),
        .data(data) // Data to be written
    );

endmodule