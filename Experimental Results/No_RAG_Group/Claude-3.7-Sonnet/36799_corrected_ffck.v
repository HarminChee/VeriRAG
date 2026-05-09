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

wire        data_rdy_s;
wire [15:0] data_s;
reg [3:0]   present_state;
reg [3:0]   next_state;

localparam WAIT_DATA_RDY_HIGH_STATE = 4'b0001;
localparam ACQUIRE_DATA_STATE       = 4'b0010;
localparam TRANSFER_DATA_STATE      = 4'b0100;
localparam WAIT_DATA_RDY_LOW_STATE  = 4'b1000;

wire data_rdy_sync;
reg data_rdy_meta;

// Synchronize data_rdy_s to fpga_clk domain using 2-FF synchronizer
always @(posedge fpga_clk_i) begin
    if (reset_i) begin
        data_rdy_meta <= 1'b0;
        data_rdy_sync <= 1'b0;
    end else begin
        data_rdy_meta <= data_rdy_s;
        data_rdy_sync <= data_rdy_meta;
    end
end

always @(posedge fpga_clk_i)
begin
    if(reset_i == 1'b1)
    begin
        present_state      <= WAIT_DATA_RDY_HIGH_STATE;
        adc_status_o       <= 1'b0;
    end
    else
    begin
        present_state <= next_state;
        case (present_state)
            WAIT_DATA_RDY_HIGH_STATE:
            begin
                data_rd_ready_o  <= 1'b0;
            end
            ACQUIRE_DATA_STATE:             
            begin
                data_o          <= data_s;
                data_rd_ready_o <= 1'b0;
                adc_status_o    <= 1'b1;
            end
            TRANSFER_DATA_STATE:            
            begin
                data_rd_ready_o <= 1'b1;
            end
            WAIT_DATA_RDY_LOW_STATE:
            begin
                data_rd_ready_o <= 1'b0;
            end
        endcase
    end
end

always @(*)
begin
    next_state = present_state;
    case (present_state)
        WAIT_DATA_RDY_HIGH_STATE:
        begin
            if(data_rdy_sync == 1'b1)
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
            if(data_rdy_sync == 1'b0)
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

dec256sinc24b filter(
    .mclkout_i(adc_clk_i),
    .reset_i(reset_i),
    .mdata_i(adc_mdata_i),
    .data_rdy_o(data_rdy_s),
    .data_o(data_s));

endmodule