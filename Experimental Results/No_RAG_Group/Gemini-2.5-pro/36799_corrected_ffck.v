`timescale 1 ns / 100 ps
module ad7401_corrected_ffc (
    input               fpga_clk_i,     // Primary clock input 1
    input               adc_clk_i,      // Primary clock input 2
    input               reset_i,
    output reg  [15:0]  data_o,
    output reg          data_rd_ready_o,
    output reg          adc_status_o,
    input               adc_mdata_i
);

// DFT Rule Compliance Note: All flip-flops in this module are clocked directly
// by the primary input 'fpga_clk_i', adhering to DFT guidelines against
// internally generated clocks (like FFCKNP). The 'filter' instance uses
// the primary input 'adc_clk_i'.

wire        data_rdy_s;
wire [15:0] data_s ;
reg [3:0]   present_state;
reg [3:0]   next_state;
reg         data_rdy_s_d1;
reg         data_rdy_s_d2;

// State definitions
localparam WAIT_DATA_RDY_HIGH_STATE = 4'b0001;
localparam ACQUIRE_DATA_STATE       = 4'b0010;
localparam TRANSFER_DATA_STATE      = 4'b0100;
localparam WAIT_DATA_RDY_LOW_STATE  = 4'b1000;

// Synchronizer for data_rdy_s from adc_clk_i domain to fpga_clk_i domain
// Both synchronizer flip-flops are clocked by the primary input fpga_clk_i.
always @(posedge fpga_clk_i)
begin
    data_rdy_s_d1 <= data_rdy_s;
    data_rdy_s_d2 <= data_rdy_s_d1;
end

// State register and output logic clocked by primary input fpga_clk_i
always @(posedge fpga_clk_i)
begin
    if(reset_i == 1'b1)
    begin
        present_state      <= WAIT_DATA_RDY_HIGH_STATE;
        adc_status_o       <= 1'b0;
        data_rd_ready_o    <= 1'b0; // Define reset state for output FF
        data_o             <= 16'b0; // Define reset state for output FF
    end
    else
    begin
        present_state <= next_state;
        // Mealy outputs based on present_state (registered on next clock edge)
        case (present_state)
            WAIT_DATA_RDY_HIGH_STATE:
            begin
                data_rd_ready_o  <= 1'b0;
            end
            ACQUIRE_DATA_STATE:
            begin
                data_o          <= data_s; // Capture data from filter
                data_rd_ready_o <= 1'b0;
                adc_status_o    <= 1'b1;
            end
            TRANSFER_DATA_STATE:
            begin
                data_rd_ready_o <= 1'b1; // Signal data ready
            end
            WAIT_DATA_RDY_LOW_STATE:
            begin
                data_rd_ready_o <= 1'b0;
                adc_status_o    <= 1'b0; // Deassert status after transfer
            end
            default: // Should not happen, but define behavior
            begin
                 data_rd_ready_o <= 1'b0;
            end
        endcase
    end
end

// Combinational logic for next state calculation
always @(present_state, data_rdy_s_d2)
begin
    next_state = present_state; // Default: stay in current state
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
        default:
        begin
            next_state      = WAIT_DATA_RDY_HIGH_STATE;
        end
    endcase
end

// Filter instance - Assumed to be clocked internally by adc_clk_i
// The interface signals data_rdy_s and data_s are generated in the adc_clk_i domain.
dec256sinc24b filter(
    .mclkout_i(adc_clk_i),   // Clock input from Primary Input
    .reset_i(reset_i),
    .mdata_i(adc_mdata_i),
    .data_rdy_o(data_rdy_s), // Output generated based on adc_clk_i
    .data_o(data_s)         // Output generated based on adc_clk_i
);

endmodule