`timescale 1 ns / 100 ps

module ad7401
(
    input               fpga_clk_i,
    input               adc_clk_i,
    input               reset_i,
    output reg  [15:0]  data_o,
    output reg          data_rd_ready_o,
    output reg          adc_status_o,
    input               adc_mdata_i
);

// Internal signals
wire        data_rdy_s;
wire [15:0] data_s ;
reg  [3:0]  present_state;
reg  [3:0]  next_state;
reg         data_rdy_s_d1;
reg         data_rdy_s_d2;

// State parameters
localparam WAIT_DATA_RDY_HIGH_STATE = 4'b0001;
localparam ACQUIRE_DATA_STATE       = 4'b0010;
localparam TRANSFER_DATA_STATE      = 4'b0100;
localparam WAIT_DATA_RDY_LOW_STATE  = 4'b1000;

// Synchronize data_rdy_s to fpga_clk_i domain
always @(posedge fpga_clk_i or posedge reset_i)
begin
    if (reset_i == 1'b1) begin
        data_rdy_s_d1 <= 1'b0;
        data_rdy_s_d2 <= 1'b0;
    end
    else begin
        data_rdy_s_d1 <= data_rdy_s;
        data_rdy_s_d2 <= data_rdy_s_d1;
    end
end

// State Register and Output Logic
always @(posedge fpga_clk_i or posedge reset_i)
begin
    if(reset_i == 1'b1)
    begin
        present_state      <= WAIT_DATA_RDY_HIGH_STATE;
        adc_status_o       <= 1'b0;
        data_o             <= 16'b0;
        data_rd_ready_o    <= 1'b0;
    end
    else
    begin
        present_state <= next_state;

        // Default assignments for outputs
        data_rd_ready_o <= 1'b0;
        adc_status_o    <= 1'b0; // Default to low unless in specific states

        // State-based output assignments (Moore/Mealy combination)
        case (present_state)
            WAIT_DATA_RDY_HIGH_STATE:
            begin
                // Outputs keep default values (data_rd_ready_o=0, adc_status_o=0)
                // data_o holds previous value
            end
            ACQUIRE_DATA_STATE:
            begin
                data_o          <= data_s; // Capture data
                adc_status_o    <= 1'b1;   // Status high during acquisition
                // data_rd_ready_o keeps default (0)
            end
            TRANSFER_DATA_STATE:
            begin
                data_rd_ready_o <= 1'b1;   // Indicate data is ready for one cycle
                adc_status_o    <= 1'b1;   // Status high while data ready is asserted
                // data_o holds value captured in previous state
            end
            WAIT_DATA_RDY_LOW_STATE:
            begin
                 // Outputs keep default values (data_rd_ready_o=0, adc_status_o=0)
                 // data_o holds previous value
            end
            default: // Should not happen with defined reset, but good practice
            begin
                data_rd_ready_o <= 1'b0;
                adc_status_o    <= 1'b0;
            end
        endcase
    end
end

// Next State Logic (Combinational)
// Using Verilog-2001 sensitivity list style as in original code
always @(present_state or data_rdy_s_d2) // Removed reset_i as next_state logic doesn't depend on it directly
begin
    // Default assignment to avoid inferred latches in case branches don't cover all conditions
    next_state = present_state;

    case (present_state)
        WAIT_DATA_RDY_HIGH_STATE:
        begin
            if(data_rdy_s_d2 == 1'b1)
            begin
                next_state  = ACQUIRE_DATA_STATE;
            end
        end
        ACQUIRE_DATA_STATE:
        begin
            next_state      = TRANSFER_DATA_STATE;
        end
        TRANSFER_DATA_STATE:
        begin
            next_state      = WAIT_DATA_RDY_LOW_STATE;
        end
        WAIT_DATA_RDY_LOW_STATE:
        begin
            if(data_rdy_s_d2 == 1'b0)
            begin
                next_state  = WAIT_DATA_RDY_HIGH_STATE;
            end
        end
        default: // Assign a safe state in case of unknown state
        begin
            next_state      = WAIT_DATA_RDY_HIGH_STATE;
        end
    endcase
end

// Instantiate the filter/ADC interface block
// Assuming dec256sinc24b is the correct module name and ports
dec256sinc24b filter(
    .mclkout_i(adc_clk_i),      // Connect adc_clk_i to filter's clock input
    .reset_i(reset_i),          // Pass reset through
    .mdata_i(adc_mdata_i),      // Connect ADC data input
    .data_rdy_o(data_rdy_s),    // Receive data ready signal from filter
    .data_o(data_s)             // Receive data output from filter
);

endmodule