`timescale 1ps/1ps
`default_nettype none
`timescale 1ps/1ps
`default_nettype none
module gpac_adc_iobuf (
    input ADC_CLK,
    input ADC_DCO_P, ADC_DCO_N,
    output reg ADC_DCO,
    input ADC_FCO_P, ADC_FCO_N,
    output reg ADC_FCO,
    input ADC_ENC,
    output ADC_ENC_P, ADC_ENC_N,
    input [3:0] ADC_IN_P, ADC_IN_N,
    output [13:0] ADC_IN0, ADC_IN1, ADC_IN2, ADC_IN3
);
wire ADC_DCO_BUF;
wire ADC_FCO_BUF;
wire [3:0] ADC_IN_BUF;
wire ADC_ENC_BUF;
reg [3:0] ADC_IN;
always @(negedge ADC_CLK)
    ADC_DCO <= ADC_DCO_BUF;
always @(negedge ADC_CLK)
    ADC_FCO <= ADC_FCO_BUF;
always @(negedge ADC_CLK)
    ADC_IN <= ADC_IN_BUF;
assign ADC_ENC_BUF = ADC_ENC;
IBUFDS #(
    .DIFF_TERM("TRUE"),    
    .IOSTANDARD("LVDS_25")  
) IBUFGDS_ADC_FCO (
    .O(ADC_FCO_BUF),  
    .I(ADC_FCO_P),  
    .IB(ADC_FCO_N) 
);
IBUFGDS #(    
    .DIFF_TERM("TRUE"),    
    .IOSTANDARD("LVDS_25")  
)
IBUFDS_ADC_DCO (
    .O(ADC_DCO_BUF),  
    .I(ADC_DCO_P),  
    .IB(ADC_DCO_N) 
);
OBUFDS #(
    .IOSTANDARD("LVDS_25") 
) OBUFDS_ADC_ENC (
    .O(ADC_ENC_P),     
    .OB(ADC_ENC_N),   
    .I(ADC_ENC_BUF)      
);
IBUFDS #(
    .DIFF_TERM("TRUE"),    
    .IOSTANDARD("LVDS_25")  
) IBUFGDS_ADC_OUT_0 (
    .O(ADC_IN_BUF[0]),  
    .I(ADC_IN_P[0]),  
    .IB(ADC_IN_N[0]) 
);
IBUFDS #(
    .DIFF_TERM("TRUE"),    
    .IOSTANDARD("LVDS_25")  
) IBUFGDS_ADC_OUT_1 (
    .O(ADC_IN_BUF[1]),  
    .I(ADC_IN_P[1]),  
    .IB(ADC_IN_N[1]) 
);
IBUFDS #(
    .DIFF_TERM("TRUE"),    
    .IOSTANDARD("LVDS_25")  
) IBUFGDS_ADC_OUT_2 (
    .O(ADC_IN_BUF[2]),  
    .I(ADC_IN_P[2]),  
    .IB(ADC_IN_N[2]) 
);
IBUFDS #(
    .DIFF_TERM("TRUE"),    
    .IOSTANDARD("LVDS_25")  
) IBUFGDS_ADC_OUT_3 (
    .O(ADC_IN_BUF[3]),  
    .I(ADC_IN_P[3]),  
    .IB(ADC_IN_N[3]) 
);
reg [1:0] fco_sync;
always @(negedge ADC_CLK) begin
    fco_sync <= {fco_sync[0],ADC_FCO};
end
wire adc_des_rst;
assign adc_des_rst = fco_sync[0] & !fco_sync[1];
reg [15:0] adc_des_cnt;
always @(negedge ADC_CLK) begin
    if(adc_des_rst)
        adc_des_cnt[0] <= 1;
    else
        adc_des_cnt <= {adc_des_cnt[14:0],1'b0};
end
wire adc_load;
assign adc_load = adc_des_cnt[12];
reg [13:0] adc_out_sync [3:0];
genvar i;
generate
    for (i = 0; i < 4; i = i + 1) begin: gen
        reg [13:0] adc_des;
        always @(negedge ADC_CLK) begin
            adc_des <= {adc_des[12:0],ADC_IN[i]};
        end
        reg [13:0] adc_des_syn;
        always @(negedge ADC_CLK) begin
            if(adc_load)
                adc_des_syn <= adc_des;
        end
        always @(posedge ADC_ENC)
            adc_out_sync[i] <= adc_des_syn;
    end
endgenerate
assign ADC_IN0 = adc_out_sync[0];
assign ADC_IN1 = adc_out_sync[1];
assign ADC_IN2 = adc_out_sync[2];
assign ADC_IN3 = adc_out_sync[3];
`ifdef SYNTHESIS_
    wire [35:0] control_bus;
    chipscope_icon ichipscope_icon
    (
        .CONTROL0(control_bus)
    );
    chipscope_ila ichipscope_ila
    (
        .CONTROL(control_bus),
        .CLK(ADC_CLK),
        .TRIG0({ADC_IN0, adc_load, adc_des_rst, fco_sync, ADC_IN[0]})
    );
`endif
endmodule
