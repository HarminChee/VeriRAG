module red_pitaya_iir_block
#(  parameter IIRBITS = 32, 
    parameter IIRSHIFT = 29, 
    parameter IIRSTAGES = 14, 
    parameter IIRSIGNALBITS= 32, 
    parameter SIGNALBITS = 14,      
    parameter SIGNALSHIFT = 3, 
    parameter LOOPBITS = 10, 
   parameter     FILTERSTAGES = 1,
   parameter     FILTERSHIFTBITS = 3,
   parameter     FILTERMINBW = 1000
   )
   (
   input                 clk_i           ,  
   input                 rstn_i          ,  
   input      [ 14-1: 0] dat_i           ,  
   output reg [ 14-1: 0] dat_o           ,  
   input      [ 16-1: 0] addr,
   input                 wen,
   input                 ren,
   output reg   		 ack,
   output reg [ 32-1: 0] rdata,
   input      [ 32-1: 0] wdata
);
reg [LOOPBITS-1:0]     loops;
reg     		on; 
reg     		shortcut;
reg [32-1:0]    overflow;   
wire [7-1:0]    overflow_i; 
reg [32-1:0]    iir_coefficients [0:IIRSTAGES*4*2-1];
reg [ 32-1: 0]  set_filter;   
always @(posedge clk_i) begin
   if (rstn_i == 1'b0) begin
      loops <= {LOOPBITS{1'b0}};
      on <= 1'b0;
      shortcut <= 1'b0;
      set_filter <= 32'd0;
   end
   else begin
      if (wen) begin
         if (addr==16'h100)   loops <= wdata[LOOPBITS-1:0];
         if (addr==16'h104)   {shortcut,on} <= wdata[2-1:0];
         if (addr==16'h120)   set_filter  <= wdata;
         if (addr[16-1]==1'b1)   iir_coefficients[addr[12-1:2]] <= wdata;
      end
	  casez (addr)
	     16'h100 : begin ack <= wen|ren; rdata <= {{32-LOOPBITS{1'b0}},loops}; end
	     16'h104 : begin ack <= wen|ren; rdata <= {{32-3{1'b0}},shortcut,on}; end
	     16'h108 : begin ack <= wen|ren; rdata <= overflow; end
         16'h120 : begin ack <= wen|ren; rdata <= set_filter; end
		 16'h200 : begin ack <= wen|ren; rdata <= IIRBITS; end
		 16'h204 : begin ack <= wen|ren; rdata <= IIRSHIFT; end
		 16'h208 : begin ack <= wen|ren; rdata <= IIRSTAGES; end
         16'h220 : begin ack <= wen|ren; rdata <= FILTERSTAGES; end
	     16'h224 : begin ack <= wen|ren; rdata <= FILTERSHIFTBITS; end
	     16'h228 : begin ack <= wen|ren; rdata <= FILTERMINBW; end
	     default: begin ack <= wen|ren;  rdata <=  32'h0; end 
	  endcase	     
   end
end
wire signed [SIGNALBITS+SIGNALSHIFT-1:0] dat_i_filtered;
red_pitaya_filter_block #(
     .STAGES(FILTERSTAGES),
     .SHIFTBITS(FILTERSHIFTBITS),
     .SIGNALBITS(SIGNALBITS+SIGNALSHIFT),
     .MINBW(FILTERMINBW)
  )
  iir_inputfilter
  (
  .clk_i(clk_i),
  .rstn_i(rstn_i),
  .set_filter(set_filter),
  .dat_i({dat_i,{SIGNALSHIFT{1'b0}}}),
  .dat_o(dat_i_filtered)
  );
wire signed [IIRBITS-1:0] b0_i [0:IIRSTAGES-1];
wire signed [IIRBITS-1:0] b1_i [0:IIRSTAGES-1];
wire signed [IIRBITS-1:0] a1_i [0:IIRSTAGES-1];
wire signed [IIRBITS-1:0] a2_i [0:IIRSTAGES-1];
integer i; 
genvar j;
generate for (j=0; j<IIRSTAGES; j=j+1) begin
    assign b0_i[j] = {iir_coefficients[8*j+1],iir_coefficients[8*j+0]};
    assign b1_i[j] = {iir_coefficients[8*j+3],iir_coefficients[8*j+2]};
    assign a1_i[j] = {iir_coefficients[8*j+5],iir_coefficients[8*j+4]};
    assign a2_i[j] = {iir_coefficients[8*j+7],iir_coefficients[8*j+6]};
    end
endgenerate
reg [LOOPBITS-1:0] stage0;
reg [LOOPBITS-1:0] stage1;
reg [LOOPBITS-1:0] stage2;
reg [LOOPBITS-1:0] stage3;
reg [LOOPBITS-1:0] stage4;
reg [LOOPBITS-1:0] stage5;
reg [LOOPBITS-1:0] stage6;
always @(posedge clk_i) begin
    if (on==1'b0) begin
        overflow <= 32'h00000000;
        stage0 <= loops;
        stage1 <= {LOOPBITS{1'b0}};
        stage2 <= {LOOPBITS{1'b0}};
        stage3 <= {LOOPBITS{1'b0}};
        stage4 <= {LOOPBITS{1'b0}};
        stage5 <= {LOOPBITS{1'b0}};
        stage6 <= {LOOPBITS{1'b0}};
    end
    else begin
        overflow <= overflow | overflow_i;
        if (stage0 == 8'h00)
            stage0 <= loops - {{LOOPBITS-1{1'b0}},1'b1};
        else
            stage0 <= stage0 - {{LOOPBITS-1{1'b0}},1'b1};
    end
    stage1 <= stage0;
    stage2 <= stage1;
    stage3 <= stage2;
    stage4 <= stage3;
    stage5 <= stage4;
    stage6 <= stage5;
end
reg signed [IIRBITS-1:0] a1;
reg signed [IIRBITS-1:0] a2;
reg signed [IIRBITS-1:0] b0;
reg signed [IIRBITS-1:0] b1;
reg signed [IIRSIGNALBITS-1:0] x0;
reg signed [IIRSIGNALBITS-1:0] y0;
reg signed [IIRSIGNALBITS-1:0] y1a;
reg signed [IIRSIGNALBITS-1:0] y2a;
reg signed [IIRSIGNALBITS-1:0] y1b;
reg signed [IIRSIGNALBITS-1:0] y1_i [0:IIRSTAGES-1];
reg signed [IIRSIGNALBITS-1:0] y2_i [0:IIRSTAGES-1];
wire signed [IIRSIGNALBITS-1:0] p_ay1_full;
wire signed [IIRSIGNALBITS-1:0] p_ay2_full;
red_pitaya_product_sat #( .BITS_IN1(IIRSIGNALBITS), .BITS_IN2(IIRBITS), .SHIFT(IIRSHIFT), .BITS_OUT(IIRSIGNALBITS))
 p_ay1_module (
  .factor1_i(y1a),
  .factor2_i(a1),
  .product_o(p_ay1_full),
  .overflow (overflow_i[0])
  );
red_pitaya_product_sat #( .BITS_IN1(IIRSIGNALBITS), .BITS_IN2(IIRBITS), .SHIFT(IIRSHIFT), .BITS_OUT(IIRSIGNALBITS))
   p_ay2_module (
    .factor1_i(y2a),
    .factor2_i(a2),
    .product_o(p_ay2_full),
    .overflow (overflow_i[1])
    );
reg signed [IIRSIGNALBITS-1:0] p_ay1;
reg signed [IIRSIGNALBITS-1:0] p_ay2;
wire signed [IIRSIGNALBITS+2-1:0] y0_sum;
assign y0_sum = x0 + p_ay1 + p_ay2;
wire signed [IIRSIGNALBITS-1:0] y0_full;
red_pitaya_saturate #( .BITS_IN (IIRSIGNALBITS+2), .SHIFT(0), .BITS_OUT(IIRSIGNALBITS))
   s_y0_module (
   .input_i(y0_sum),
   .output_o(y0_full),
   .overflow (overflow_i[2])
    );
wire signed [IIRSIGNALBITS-1:0] p_by0_full;
wire signed [IIRSIGNALBITS-1:0] p_by1_full;
red_pitaya_product_sat #( .BITS_IN1(IIRSIGNALBITS), .BITS_IN2(IIRBITS), .SHIFT(IIRSHIFT), .BITS_OUT(IIRSIGNALBITS))
 p_by0_module (
  .factor1_i(y0),
  .factor2_i(b0),
  .product_o(p_by0_full),
  .overflow (overflow_i[3])
   );
red_pitaya_product_sat #( .BITS_IN1(IIRSIGNALBITS), .BITS_IN2(IIRBITS), .SHIFT(IIRSHIFT), .BITS_OUT(IIRSIGNALBITS))
   p_by1_module (
    .factor1_i(y1b),
    .factor2_i(b1),
    .product_o(p_by1_full),
    .overflow (overflow_i[4])
     );
reg signed [IIRSIGNALBITS-1:0] p_by0;
reg signed [IIRSIGNALBITS-1:0] p_by1;
wire signed [IIRSIGNALBITS+2-1:0] z0_sum;
assign z0_sum = p_by0 + p_by1;
wire signed [IIRSIGNALBITS-1:0] z0_full;
red_pitaya_saturate #( 
    .BITS_IN (IIRSIGNALBITS+2), 
    .SHIFT(0), 
    .BITS_OUT(IIRSIGNALBITS)
    )
   s_z0_module (
   .input_i(z0_sum),
   .output_o(z0_full),
   .overflow (overflow_i[5])
   );   
reg signed [IIRSIGNALBITS-1:0] z0;
reg signed [IIRSIGNALBITS+4-1:0] dat_o_sum;
wire [SIGNALBITS-1:0] dat_o_full;
red_pitaya_saturate #( .BITS_IN (IIRSIGNALBITS+4), .SHIFT(SIGNALSHIFT), .BITS_OUT(SIGNALBITS))
   s_dat_o_module (
   .input_i(dat_o_sum),
   .output_o(dat_o_full),
   .overflow (overflow_i[6])
   );
reg signed [SIGNALBITS-1:0] signal_o;
always @(posedge clk_i) begin
    x0 <= dat_i_filtered;
    if (on==1'b0) begin
        for (i=0;i<IIRSTAGES;i=i+1) begin
            y1_i[i] <= {IIRSIGNALBITS{1'b0}};
            y2_i[i] <= {IIRSIGNALBITS{1'b0}};
        end
        y0  <= {IIRSIGNALBITS{1'b0}};
        y1a <= {IIRSIGNALBITS{1'b0}};
        y2a <= {IIRSIGNALBITS{1'b0}};
        y1b <= {IIRSIGNALBITS{1'b0}};
        z0 <= {IIRSIGNALBITS{1'b0}};
        a1 <= {IIRBITS{1'b0}};
        a2 <= {IIRBITS{1'b0}};
        b0 <= {IIRBITS{1'b0}};
        b1 <= {IIRBITS{1'b0}};
        p_ay1 <= {IIRSIGNALBITS{1'b0}};
        p_ay2 <= {IIRSIGNALBITS{1'b0}};
        p_by0 <= {IIRSIGNALBITS{1'b0}};
        p_by1 <= {IIRSIGNALBITS{1'b0}};
        signal_o <= {SIGNALBITS{1'b0}};
        end
    else begin
        if (stage0<IIRSTAGES) begin
            y1a <= y1_i[stage0];
            a1 <= a1_i[stage0];
            y2a <= y2_i[stage0];
            a2 <= a2_i[stage0];
            y2_i[stage0] <= y1_i[stage0]; 
        end
        if (stage1<IIRSTAGES) begin
            p_ay1 <= p_ay1_full;
            p_ay2 <= p_ay2_full;
        end
        if (stage2<IIRSTAGES) begin
            y0 <= y0_full;
            b0 <= b0_i[stage2];
            y1b <= y1_i[stage2];
            b1 <= b1_i[stage2];
            y1_i[stage2] <= y0_full; 
        end
        if (stage3<IIRSTAGES) begin
            p_by0 <= p_by0_full;
            p_by1 <= p_by1_full;
        end
        if (stage4<IIRSTAGES) begin
            z0 <= z0_full;
        end
        if (stage5 == (loops-1) || stage5 == (IIRSTAGES-1)) begin
            dat_o_sum <= z0;
        end
        else begin
            dat_o_sum <= dat_o_sum + z0;
        end
        if (stage6 == 0) begin
            signal_o <= dat_o_full;
        end
    end
    dat_o <= (shortcut==1'b1) ? dat_i_filtered[SIGNALSHIFT+SIGNALBITS-1:SIGNALSHIFT] : signal_o;
end
endmodule
