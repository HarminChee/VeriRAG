`timescale 1 ns / 100 ps 
module ad7401
(
    input               test_i,
    input               fpga_clk_i,     
    input               adc_clk_i,      
    input               reset_i,        
    output reg  [15:0]  data_o,          
    output reg          data_rd_ready_o, 
    output reg          adc_status_o,
    input               adc_mdata_i    
);
wire        data_rdy_s;
wire [15:0] data_s ;
reg [3:0]   present_state;
reg [3:0]   next_state;
reg         data_rdy_s_d1;
reg         data_rdy_s_d2;
wire        dft_adc_clk;
localparam WAIT_DATA_RDY_HIGH_STATE = 4'b0001;
localparam ACQUIRE_DATA_STATE       = 4'b0010;
localparam TRANSFER_DATA_STATE      = 4'b0100;
localparam WAIT_DATA_RDY_LOW_STATE  = 4'b1000;
assign dft_adc_clk = test_i ? fpga_clk_i : adc_clk_i;
always @(posedge fpga_clk_i)
begin
    data_rdy_s_d1 <= data_rdy_s;
    data_rdy_s_d2 <= data_rdy_s_d1;
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
always @(present_state, data_rdy_s_d2)
begin
    next_state <= present_state;
    case (present_state)
        WAIT_DATA_RDY_HIGH_STATE:
        begin
            if(data_rdy_s_d2 == 1'b1)
            begin
                next_state  <= ACQUIRE_DATA_STATE;
            end
        end
        ACQUIRE_DATA_STATE:
        begin
            next_state      <= TRANSFER_DATA_STATE;
        end
        TRANSFER_DATA_STATE:
        begin
            next_state      <= WAIT_DATA_RDY_LOW_STATE;
        end
        WAIT_DATA_RDY_LOW_STATE:
        begin
            if(data_rdy_s_d2 == 1'b0)
            begin
                next_state  <= WAIT_DATA_RDY_HIGH_STATE;
            end
        end
        default:
        begin
            next_state      <= WAIT_DATA_RDY_HIGH_STATE;
        end
    endcase
end
dec256sinc24b filter(
    .mclkout_i(dft_adc_clk),
    .reset_i(reset_i),
    .mdata_i(adc_mdata_i),
    .data_rdy_o(data_rdy_s),
    .data_o(data_s));
endmodule