`timescale 1ns/1ns 
`timescale 1ns/1ns 
module axi_ad7091_dev_if
(
    fpga_clk_i,      
    adc_clk_i,       
    reset_i,       
    data_o,          
    data_rd_ready_o, 
    adc_status_o,   
    adc_sdo_i,
    adc_sclk_o,
    adc_cs_n_o,
    adc_convst_n_o
);
input               fpga_clk_i;      
input               adc_clk_i;       
input               reset_i;         
output     [15:0]   data_o;  
output  reg         data_rd_ready_o = 1'b0; 
output  reg         adc_status_o = 1'b0;   
input               adc_sdo_i;
output              adc_sclk_o;
output              adc_cs_n_o;
output              adc_convst_n_o;
reg [ 7:0]  adc_state;          
reg [ 7:0]  adc_next_state;     
reg [ 7:0]  adc_state_nc_m1;    
reg [ 7:0]  adc_state_pc_m1;    
reg [ 6:0]  adc_tcycle_cnt    = 7'b0;
reg [ 6:0]  adc_tconvst_cnt   = 7'b0;
reg [ 6:0]  adc_tconvert_cnt  = 7'b0;
reg [ 4:0]  sclk_clk_cnt      = 5'b0;
reg [ 4:0]  adc_dataready_cnt = 5'b0;
reg         adc_cnv_s       =  1'b0;
reg         adc_clk_en      =  1'b0;
reg         adc_cs_n_s      =  1'b0;
reg [15:0]  adc_data_s      = 12'b0;
reg         adc_sw_reset    =  1'b0;
reg         data_rd_ready_s =  1'b0;
parameter ADC_SW_RESET_STATE        = 8'b00000001;
parameter ADC_IDLE_STATE            = 8'b00000010;
parameter ADC_START_CNV_STATE       = 8'b00000100;
parameter ADC_WAIT_CNV_DONE_STATE   = 8'b00001000;
parameter ADC_WAIT_DATA_VALID_STATE = 8'b00010000;
parameter ADC_READ_CNV_RESULT       = 8'b00100000;
parameter ADC_END_CNV_STATE         = 8'b01000000;
parameter ADC_DATAREADY_STATE       = 8'b10000000;
parameter real FPGA_CLOCK_FREQ  = 100;    
parameter real ADC_CYCLE_TIME   = 1.000;  
parameter real ADC_CONVST_TIME  = 0.010;  
parameter real ADC_CONVERT_TIME = 0.650;  
parameter [6:0] ADC_CYCLE_CNT   = FPGA_CLOCK_FREQ * ADC_CYCLE_TIME - 1;
parameter [6:0] ADC_CONVST_CNT  = FPGA_CLOCK_FREQ * ADC_CONVST_TIME - 1;
parameter [6:0] ADC_CONVERT_CNT = FPGA_CLOCK_FREQ * ADC_CONVERT_TIME - 1;
parameter ADC_SCLK_PERIODS       = 5'd12;
parameter ADC_RESET_SCLK_PERIODS = 4'd3;
parameter ADC_DATAREADY_WIDTH    = 5'd1;
assign adc_sclk_o     = adc_clk_i & adc_clk_en;
assign adc_cs_n_o     = adc_cs_n_s;
assign adc_convst_n_o = adc_cnv_s;
assign data_o         = (data_rd_ready_o == 1'b1) ? adc_data_s : data_o;
always @(negedge fpga_clk_i)
begin
    if(reset_i == 1'b1)
    begin
        data_rd_ready_o <= 1'b0;
    end
    else
    begin
        data_rd_ready_o <= data_rd_ready_s;
    end
end
always @(posedge fpga_clk_i)
begin
    if(reset_i == 1'b1)
    begin
        adc_tcycle_cnt   <= 0;
        adc_tconvst_cnt  <= ADC_CONVST_CNT;
        adc_tconvert_cnt <= ADC_CONVERT_CNT;
    end
    else
    begin
        if(adc_tcycle_cnt != 1'b0)
        begin
            adc_tcycle_cnt <= adc_tcycle_cnt - 7'h1;
        end
        else if(adc_state == ADC_IDLE_STATE || adc_state == ADC_SW_RESET_STATE)
        begin
            adc_tcycle_cnt <= ADC_CYCLE_CNT;
        end
        if(adc_state == ADC_START_CNV_STATE)
        begin
            adc_tconvst_cnt <= adc_tconvst_cnt - 7'h1;
        end
        else
        begin
           adc_tconvst_cnt <= ADC_CONVST_CNT;
        end
        if(adc_state == ADC_WAIT_CNV_DONE_STATE)
        begin
            adc_tconvert_cnt <= adc_tconvert_cnt - 7'h1;
        end
        else
        begin
           adc_tconvert_cnt <= ADC_CONVERT_CNT;
        end
        if(adc_state == ADC_END_CNV_STATE)
        begin
            adc_dataready_cnt <= adc_dataready_cnt - 5'h1;
        end
        else
        begin
            adc_dataready_cnt <= ADC_DATAREADY_WIDTH;
        end
    end
end
always @(negedge adc_clk_i)
begin
    adc_state_nc_m1 <= adc_state;
    adc_clk_en      <= ((adc_state_nc_m1 == ADC_WAIT_DATA_VALID_STATE) || (adc_state_nc_m1 == ADC_READ_CNV_RESULT) && ( (sclk_clk_cnt != 0) || ((adc_sw_reset == 1'b1) && (sclk_clk_cnt == ADC_SCLK_PERIODS - ADC_RESET_SCLK_PERIODS)))) ? 1'b1 : 1'b0;
end
always @(negedge adc_clk_i)
begin
    adc_state_pc_m1 <= adc_state;
    if(adc_clk_en == 1'b1)
    begin
        adc_data_s   <= {4'b0, adc_data_s[10:0], adc_sdo_i};
        sclk_clk_cnt <= sclk_clk_cnt - 5'h1;
    end
    else if(adc_state_pc_m1 != ADC_READ_CNV_RESULT && adc_state_pc_m1 != ADC_END_CNV_STATE)
    begin
        adc_data_s      <= 16'h0;
        sclk_clk_cnt    <= ADC_SCLK_PERIODS;
    end
end
always @(posedge fpga_clk_i)
begin
    if(reset_i == 1'b1)
    begin
        adc_state <= ADC_SW_RESET_STATE;
        adc_status_o <= 0;
    end
    else
    begin
        adc_state <= adc_next_state;
        case (adc_state)
            ADC_SW_RESET_STATE:
            begin
                adc_cnv_s       <= 1'b1;
                adc_cs_n_s      <= 1'b1;
                data_rd_ready_s <= 1'b0;
                adc_sw_reset    <= 1'b1;
            end
            ADC_IDLE_STATE:
            begin
                adc_cnv_s       <= 1'b1;
                adc_cs_n_s      <= 1'b1;
                data_rd_ready_s <= 1'b0;
                adc_sw_reset    <= 1'b0;
            end
            ADC_START_CNV_STATE:
            begin
                adc_cnv_s       <= 1'b0;
                adc_cs_n_s      <= 1'b1;
                data_rd_ready_s <= 1'b0;
            end
            ADC_WAIT_CNV_DONE_STATE:
            begin
                adc_cnv_s       <= 1'b1;
                adc_cs_n_s      <= 1'b1;
                data_rd_ready_s <= 1'b0;
            end
            ADC_WAIT_DATA_VALID_STATE:
            begin
                adc_cnv_s       <= 1'b1;
                adc_cs_n_s      <= 1'b1;
                data_rd_ready_s <= 1'b0;
            end
            ADC_READ_CNV_RESULT:
            begin
                adc_cnv_s       <= 1'b1;
                adc_cs_n_s      <= 1'b0;
                data_rd_ready_s <= 1'b0;
            end
            ADC_END_CNV_STATE:
            begin
                adc_cnv_s       <= 1'b1;
                adc_cs_n_s      <= 1'b0;
                data_rd_ready_s <= 1'b0;
            end
            ADC_DATAREADY_STATE:
            begin
                adc_cnv_s       <= 1'b1;
                adc_cs_n_s      <= 1'b0;
                data_rd_ready_s <= 1'b1;
                adc_status_o    <= 1'b1;
            end
        endcase
    end
end
always @(adc_state, adc_tcycle_cnt, adc_tconvst_cnt, adc_tconvert_cnt, sclk_clk_cnt, adc_sw_reset)
begin
    adc_next_state <= adc_state;
    case (adc_state)
        ADC_SW_RESET_STATE:
        begin
            adc_next_state <= ADC_START_CNV_STATE;
        end
        ADC_IDLE_STATE:
        begin
            if(adc_tcycle_cnt == 0)
            begin
                adc_next_state <= ADC_START_CNV_STATE;
            end
        end
        ADC_START_CNV_STATE:
        begin
            if(adc_tconvst_cnt == 0)
            begin
                adc_next_state <= ADC_WAIT_CNV_DONE_STATE;
            end
        end
        ADC_WAIT_CNV_DONE_STATE:
        begin
            if(adc_tconvert_cnt == 0)
            begin
                adc_next_state <= ADC_WAIT_DATA_VALID_STATE;
            end
        end
        ADC_WAIT_DATA_VALID_STATE:
        begin
           adc_next_state <= ADC_READ_CNV_RESULT;
        end
        ADC_READ_CNV_RESULT:
        begin
            if((sclk_clk_cnt == 0) || ((adc_sw_reset == 1'b1) && (sclk_clk_cnt == ADC_SCLK_PERIODS - ADC_RESET_SCLK_PERIODS)))
            begin
                adc_next_state <= ADC_END_CNV_STATE;
            end
        end
        ADC_END_CNV_STATE:
        begin
            adc_next_state <= ADC_DATAREADY_STATE;
        end
        ADC_DATAREADY_STATE:
        begin
            adc_next_state <= ADC_IDLE_STATE;
        end
        default:
        begin
            adc_next_state <= ADC_IDLE_STATE;
        end
    endcase
end
endmodule
