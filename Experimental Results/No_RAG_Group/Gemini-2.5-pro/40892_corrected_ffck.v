module i2c_module_corrected_ffc (
    input clk,
    input reset_n,
    output reg sda_oe = 1,
    input wire sda_in,
    output reg sda = 1,
    output reg scl_out = 1, // Initialize scl_out
    input[7:0] writedata,
    input write,
    input[2:0] address,
    output reg ready = 1,
    output reg success_out = 0
);

    // State definitions
    localparam STATE_IDLE = 0;
    localparam STATE_ADDRESS_START = 1;
    localparam STATE_ADDRESS_START_2 = 111;
    localparam STATE_ADDRESS_START_3 = 112;
    localparam STATE_ADDRESS_BIT_1 = 2;
    localparam STATE_ADDRESS_BIT_2 = 3;
    localparam STATE_ADDRESS_BIT_3 = 4;
    localparam STATE_ADDRESS_BIT_4 = 5;
    localparam STATE_ADDRESS_BIT_5 = 6;
    localparam STATE_ADDRESS_BIT_6 = 7;
    localparam STATE_ADDRESS_BIT_7 = 8;
    localparam STATE_ADDRESS_BIT_8 = 9;
    localparam STATE_ADDRESS_ACK = 10;
    localparam STATE_TRANSIT_1 = 102;
    localparam STATE_REG_BIT_1 = 11;
    localparam STATE_REG_BIT_2 = 12;
    localparam STATE_REG_BIT_3 = 13;
    localparam STATE_REG_BIT_4 = 14;
    localparam STATE_REG_BIT_5 = 15;
    localparam STATE_REG_BIT_6 = 16;
    localparam STATE_REG_BIT_7 = 17;
    localparam STATE_REG_BIT_8 = 18;
    localparam STATE_REG_ACK = 19;
    localparam STATE_TRANSIT_2 = 192;
    localparam STATE_DATA_BIT_1 = 20;
    localparam STATE_DATA_BIT_2 = 21;
    localparam STATE_DATA_BIT_3 = 22;
    localparam STATE_DATA_BIT_4 = 23;
    localparam STATE_DATA_BIT_5 = 24;
    localparam STATE_DATA_BIT_6 = 25;
    localparam STATE_DATA_BIT_7 = 26;
    localparam STATE_DATA_BIT_8 = 27;
    localparam STATE_DATA_ACK = 28;
    localparam STATE_STOP = 29;
    localparam STATE_STOP_1 = 30;
    localparam STATE_STOP_2 = 31;

    // Internal registers clocked by primary clock 'clk'
    reg [7:0] state_next = STATE_IDLE; // Current state register
    reg [7:0] divider2 = 0;
    reg clk_div = 0;
    reg [7:0] control_reg = 0;
    reg [7:0] slave_address = 0;
    reg [7:0] slave_reg_address = 0;
    reg [7:0] slave_data_1 = 0;
    reg [7:0] slave_data_2 = 0;
    reg scl_output_enable = 0;
    reg scl_output_zero = 0;
    reg success = 0;
    reg ack_ok = 0;
    reg sda_in_sync; // Synchronized version of sda_in

    // Generate clock enable signals synchronous to 'clk'
    // clk_en pulses high for one 'clk' cycle when divider2 reaches 127
    wire clk_en = (divider2 == 8'd127);
    // clk_en_negedge pulses high for one 'clk' cycle when divider2 reaches 255
    wire clk_en_negedge = (divider2 == 8'd255);

    // Counter for generating enable signals
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            divider2 <= 8'b0;
        end else begin
            divider2 <= divider2 + 8'b1;
        end
    end

    // Register block for CPU interface (already synchronous to clk)
    always @(posedge clk or negedge reset_n) begin
        if (reset_n == 0) begin
            control_reg <= 0;
            slave_address <= 0;
            slave_reg_address <= 0;
            slave_data_1 <= 0;
            slave_data_2 <= 0;
        end else begin
            // Check write strobe first
            if (write == 1'b1) begin
                case (address)
                    3'b000: control_reg <= writedata;
                    3'b001: slave_address <= writedata;
                    3'b010: slave_reg_address <= writedata;
                    3'b011: slave_data_1 <= writedata;
                    3'b100: slave_data_2 <= writedata;
                    default: ; // No action for other addresses
                endcase
            end
             // Control register bit 0 is self-clearing once state machine starts
             // Ensure this happens only if write is not active in the same cycle
            else if (state_next != STATE_IDLE) begin
                 control_reg[0] <= 1'b0; // Clear start bit
            end
        end
    end

    // clk_div logic, updated based on clk_en
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            clk_div <= 1'b0;
        end else if (clk_en) begin // Enable corresponds to original posedge clk_div_2
            clk_div <= ~clk_div;
        end
    end

    // scl_out logic, updated based on clk_en
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            scl_out <= 1'b1; // SCL high in idle/reset
        end else if (clk_en) begin // Enable corresponds to original posedge clk_div_2
            if (scl_output_enable == 1) begin
                scl_out <= ~scl_out; // Toggle SCL if enabled
            end else begin
                if (scl_output_zero == 0)
                    scl_out <= 1'b1; // Drive SCL high
                else
                    scl_out <= 1'b0; // Drive SCL low (clock stretching)
            end
        end
    end

    // Synchronize sda_in
     always @(posedge clk or negedge reset_n) begin
         if (!reset_n) begin
             sda_in_sync <= 1'b1; // Assume high impedance = high
         end else begin
             sda_in_sync <= sda_in;
         end
     end

    // ack_ok logic, updated based on clk_en
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            ack_ok <= 1'b0;
        end else begin
             // Default assignment: Hold value
            ack_ok <= ack_ok;
            if (clk_en) begin // Enable corresponds to original posedge clk_div_2
                // Check conditions using synchronized inputs and current state
                if ((state_next == STATE_ADDRESS_ACK || state_next == STATE_REG_ACK || state_next == STATE_DATA_ACK) && sda_in_sync == 1'b0 && clk_div == 1) begin
                    ack_ok <= 1'b1;
                end else begin
                    ack_ok <= 1'b0;
                end
            end
        end
    end

    // success_out logic, updated based on clk_en_negedge
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            success_out <= 1'b0;
        end else begin
            // Default assignment: hold value
            success_out <= success_out;
            if (clk_en_negedge) begin // Enable corresponds to original negedge clk_div_2
                if (state_next == STATE_ADDRESS_START) begin // Reset condition
                    success_out <= 1'b0;
                end else if (clk_div == 1 && state_next == STATE_STOP && success == 1'b1) begin // Set condition
                    success_out <= 1'b1;
                end else if (clk_div == 1 && state_next == STATE_STOP && success == 1'b0) begin // Ensure reset if stop state reached without success
                    success_out <= 1'b0;
                 end else if (state_next != STATE_STOP) begin // Reset if not in stop state (and not address start)
                     // This condition might be too broad, depends on exact desired behavior
                     // Let's stick closer to original: only reset on ADDRESS_START or if STOP condition fails
                     // If clk_div == 0 while in STATE_STOP, success_out should hold based on default.
                 end

                 // Refined original logic: Reset only happens explicitly at ADDRESS_START
                 // or implicitly if the SET condition isn't met during the specific check window.
                 // Consider if success_out should be cleared elsewhere, e.g., when starting a new transaction.
                 // The ADDRESS_START check covers starting a new transaction.
            end
        end
    end


    // State machine logic, updated based on clk_en_negedge
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n