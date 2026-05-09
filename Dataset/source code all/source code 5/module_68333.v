`timescale 1ps/1ps
`timescale 1ps/1ps
module serdes_1_to_5_diff_data_nok # (
  parameter DIFF_TERM = "TRUE",
  parameter SIM_TAP_DELAY = 49,
  parameter BITSLIP_ENABLE = "FALSE"
)(
  input  wire        use_phase_detector,  
  input  wire        datain_p,            
  input  wire        datain_n,            
  input  wire        rxioclk,             
  input  wire        rxserdesstrobe,      
  input  wire        reset,               
  input  wire        gclk,                
  input  wire        bitslip,             
  output wire [4:0]  data_out             
);  
  wire       ddly_m;
  wire       ddly_s;
  wire       busys;
  wire       rx_data_in;
  wire       cascade;
  wire       pd_edge;
  reg  [8:0] counter;
  reg  [3:0] state;
  reg        cal_data_sint;
  wire       busy_data;
  reg        busy_data_d;
  wire       cal_data_slave;
  reg        enable;
  reg        cal_data_master;
  reg        rst_data;
  reg        inc_data_int;
  wire       inc_data;
  reg        ce_data;
  reg        valid_data_d;
  reg        incdec_data_d;
  reg  [4:0] pdcounter;
  wire       valid_data;
  wire       incdec_data;
  reg        flag;
  reg        mux;
  reg        ce_data_inta ;
  wire [1:0] incdec_data_or;
  wire       incdec_data_im;
  wire [1:0] valid_data_or;
  wire       valid_data_im;
  wire [1:0] busy_data_or;
  wire       all_ce;
  wire [1:0] debug_in = 2'b00;
  assign busy_data = busys ;
  assign cal_data_slave = cal_data_sint ;
  always @ (posedge gclk or posedge reset)
  begin
  if (reset == 1'b1) begin
    state <= 0 ;
    cal_data_master <= 1'b0 ;
    cal_data_sint <= 1'b0 ;
    counter <= 9'h000 ;
    enable <= 1'b0 ;
    mux <= 1'h1 ;
  end
  else begin
      counter <= counter + 9'h001 ;
      if (counter[8] == 1'b1) begin
      counter <= 9'h000 ;
      end
      if (counter[5] == 1'b1) begin
      enable <= 1'b1 ;
      end
      if (state == 0 && enable == 1'b1) begin       
      cal_data_master <= 1'b0 ;
      cal_data_sint <= 1'b0 ;
      rst_data <= 1'b0 ;
        if (busy_data_d == 1'b0) begin
        state <= 1 ;
      end
      end
      else if (state == 1) begin          
        cal_data_master <= 1'b1 ;
        cal_data_sint <= 1'b1 ;
        if (busy_data_d == 1'b1) begin        
          state <= 2 ;
        end
      end
      else if (state == 2) begin          
        cal_data_master <= 1'b0 ;
        cal_data_sint <= 1'b0 ;
        if (busy_data_d == 1'b0) begin
          rst_data <= 1'b1 ;
          state <= 3 ;
        end
      end
      else if (state == 3) begin          
        rst_data <= 1'b0 ;
        if (busy_data_d == 1'b0) begin
          state <= 4 ;
        end
      end
      else if (state == 4) begin          
        if (counter[8] == 1'b1) begin
          state <= 5 ;
        end
        end
        else if (state == 5) begin          
        if (busy_data_d == 1'b0) begin
          cal_data_sint <= 1'b1 ;
          state <= 6 ;
        end
      end
        else if (state == 6) begin          
        cal_data_sint <= 1'b0 ;
        if (busy_data_d == 1'b1) begin
          state <= 7 ;
        end
      end
      else if (state == 7) begin          
          cal_data_sint <= 1'b0 ;
        if (busy_data_d == 1'b0) begin
          state <= 4 ;
        end
      end
  end
  end
always @ (posedge gclk or posedge reset)        
begin
if (reset == 1'b1) begin
  pdcounter <= 5'b1000 ;
  ce_data_inta <= 1'b0 ;
  flag <= 1'b0 ;              
end
else begin
  busy_data_d <= busy_data_or[1] ;
    if (use_phase_detector == 1'b1) begin       
    incdec_data_d <= incdec_data_or[1] ;
    valid_data_d <= valid_data_or[1] ;
    if (ce_data_inta == 1'b1) begin
      ce_data <= mux ;
    end
    else begin
      ce_data <= 64'h0000000000000000 ;
    end
      if (state == 7) begin
      flag <= 1'b0 ;
    end
      else if (state != 4 || busy_data_d == 1'b1) begin 
      pdcounter <= 5'b10000 ;
        ce_data_inta <= 1'b0 ;
      end
      else if (pdcounter == 5'b11111 && flag == 1'b0) begin 
        ce_data_inta <= 1'b1 ;
        inc_data_int <= 1'b1 ;
      pdcounter <= 5'b10000 ;
      flag <= 1'b1 ;
    end
        else if (pdcounter == 5'b00000 && flag == 1'b0) begin 
        ce_data_inta <= 1'b1 ;
        inc_data_int <= 1'b0 ;
      pdcounter <= 5'b10000 ;
      flag <= 1'b1 ;
      end
    else if (valid_data_d == 1'b1) begin      
        ce_data_inta <= 1'b0 ;
      if (incdec_data_d == 1'b1 && pdcounter != 5'b11111) begin
        pdcounter <= pdcounter + 5'b00001 ;
      end
      else if (incdec_data_d == 1'b0 && pdcounter != 5'b00000) begin  
        pdcounter <= pdcounter + 5'b11111 ;
      end
      end
      else begin
        ce_data_inta <= 1'b0 ;
      end
    end
    else begin
    ce_data <= all_ce ;
    inc_data_int <= debug_in[1] ;
    end
end
end
assign inc_data = inc_data_int ;
assign incdec_data_or[0] = 1'b0 ;             
assign valid_data_or[0] = 1'b0 ;
assign busy_data_or[0] = 1'b0 ;
assign incdec_data_im = incdec_data & mux;          
assign incdec_data_or[1] = incdec_data_im | incdec_data_or;      
assign valid_data_im = valid_data & mux;          
assign valid_data_or[1] = valid_data_im | valid_data_or;     
assign busy_data_or[1] = busy_data | busy_data_or;       
assign all_ce = debug_in[0] ;
IBUFDS #(
  .DIFF_TERM    (DIFF_TERM)) 
data_in (
  .I            (datain_p),
  .IB           (datain_n),
  .O            (rx_data_in)
);
IODELAY2 #(
  .DATA_RATE            ("SDR"),
  .IDELAY_VALUE         (0),
  .IDELAY2_VALUE        (0),
  .IDELAY_MODE          ("NORMAL" ),
  .ODELAY_VALUE         (0),
  .IDELAY_TYPE          ("DIFF_PHASE_DETECTOR"),
  .COUNTER_WRAPAROUND   ("STAY_AT_LIMIT"), 
  .DELAY_SRC            ("IDATAIN"),
  .SERDES_MODE          ("MASTER"),
  .SIM_TAPDELAY_VALUE   (SIM_TAP_DELAY)
) iodelay_m (
  .IDATAIN              (rx_data_in),      
  .TOUT                 (),                
  .DOUT                 (),                
  .T                    (1'b1),            
  .ODATAIN              (1'b0),            
  .DATAOUT              (ddly_m),          
  .DATAOUT2             (),                
  .IOCLK0               (rxioclk),         
  .IOCLK1               (1'b0),            
  .CLK                  (gclk),            
  .CAL                  (cal_data_master), 
  .INC                  (inc_data),        
  .CE                   (ce_data),         
  .RST                  (rst_data),        
  .BUSY                 ()                 
);
IODELAY2 #(
  .DATA_RATE            ("SDR"),
  .IDELAY_VALUE         (0),
  .IDELAY2_VALUE        (0),
  .IDELAY_MODE          ("NORMAL" ),
  .ODELAY_VALUE         (0),
  .IDELAY_TYPE          ("DIFF_PHASE_DETECTOR"),
  .COUNTER_WRAPAROUND   ("WRAPAROUND"),
  .DELAY_SRC            ("IDATAIN"),
  .SERDES_MODE          ("SLAVE"),
  .SIM_TAPDELAY_VALUE   (SIM_TAP_DELAY)
) iodelay_s (
  .IDATAIN              (rx_data_in),  
  .TOUT                 (),            
  .DOUT                 (),            
  .T                    (1'b1),        
  .ODATAIN              (1'b0),        
  .DATAOUT              (ddly_s),      
  .DATAOUT2             (),            
  .IOCLK0               (rxioclk),     
  .IOCLK1               (1'b0),
  .CLK                  (gclk),        
  .CAL                  (cal_data_slave), 
  .INC                  (inc_data),       
  .CE                   (ce_data),        
  .RST                  (rst_data),       
  .BUSY                 (busys)        
);
ISERDES2 #(
  .DATA_WIDTH       (5),
  .DATA_RATE        ("SDR"),
  .BITSLIP_ENABLE   (BITSLIP_ENABLE),
  .SERDES_MODE      ("MASTER"),
  .INTERFACE_TYPE   ("RETIMED"))
iserdes_m (
  .D                (ddly_m),
  .CE0              (1'b1),
  .CLK0             (rxioclk),
  .CLK1             (1'b0),
  .IOCE             (rxserdesstrobe),
  .RST              (reset),
  .CLKDIV           (gclk),
  .SHIFTIN          (pd_edge),
  .BITSLIP          (bitslip),
  .FABRICOUT        (),
  .Q4               (data_out[4]),
  .Q3               (data_out[3]),
  .Q2               (data_out[2]),
  .Q1               (data_out[1]),
  .DFB              (),
  .CFB0             (),
  .CFB1             (),
  .VALID            (valid_data),
  .INCDEC           (incdec_data),
  .SHIFTOUT         (cascade));
ISERDES2 #(
  .DATA_WIDTH       (5),
  .DATA_RATE        ("SDR"),
  .BITSLIP_ENABLE   (BITSLIP_ENABLE),
  .SERDES_MODE      ("SLAVE"),
  .INTERFACE_TYPE   ("RETIMED")
) iserdes_s (
  .D                (ddly_s),
  .CE0              (1'b1),
  .CLK0             (rxioclk),
  .CLK1             (1'b0),
  .IOCE             (rxserdesstrobe),
  .RST              (reset),
  .CLKDIV           (gclk),
  .SHIFTIN          (cascade),
  .BITSLIP          (bitslip),
  .FABRICOUT        (),
  .Q4               (data_out[0]),
  .Q3               (),
  .Q2               (),
  .Q1               (),
  .DFB              (),
  .CFB0             (),
  .CFB1             (),
  .VALID            (),
  .INCDEC           (),
  .SHIFTOUT         (pd_edge));
reg [7:0] rxpdcntr = 8'h7f;
always @ (posedge gclk or posedge reset) begin
  if (reset)
    rxpdcntr <= 8'h7f;
  else if (ce_data)
    if (inc_data)
      rxpdcntr <= rxpdcntr + 1'b1;
    else
      rxpdcntr <= rxpdcntr - 1'b1;
end
endmodule
