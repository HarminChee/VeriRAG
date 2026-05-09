`timescale 1 ps / 1 ps
`timescale 1 ps / 1 ps
module mig_7series_v2_0_tempmon #
(
  parameter TCQ                 = 100,        
  parameter TEMP_MON_CONTROL    = "INTERNAL", 
  parameter XADC_CLK_PERIOD     = 5000,       
  parameter tTEMPSAMPLE         = 10000000    
)
(
  input           clk,                      
  input           xadc_clk,
  input           rst,                      
  input   [11:0]  device_temp_i,            
  output  [11:0]  device_temp               
);
  function integer cdiv (input integer num, input integer div);
    begin
      cdiv = (num/div) + (((num%div)>0) ? 1 : 0);
    end
  endfunction 
  function integer clogb2 (input integer size);
    begin
      size = size - 1;
      for (clogb2 = 1; size > 1; clogb2 = clogb2 + 1)
      size = size >> 1;
    end
  endfunction 
  (* ASYNC_REG = "TRUE" *)  reg   [11:0]  device_temp_sync_r1;
  (* ASYNC_REG = "TRUE" *)  reg   [11:0]  device_temp_sync_r2;
  (* ASYNC_REG = "TRUE" *)  reg   [11:0]  device_temp_sync_r3 ;
  (* ASYNC_REG = "TRUE" *)  reg   [11:0]  device_temp_sync_r4;
  (* ASYNC_REG = "TRUE" *)  reg   [11:0]  device_temp_sync_r5;
  (* ASYNC_REG = "TRUE" *)  reg   [11:0]  device_temp_r;
  wire                            [11:0]  device_temp_lcl;
  reg                             [3:0]   sync_cntr = 4'b0000;
  reg                                     device_temp_sync_r4_neq_r3;
  always @(posedge clk) begin
    device_temp_sync_r1 <= #TCQ device_temp_lcl;
    device_temp_sync_r2 <= #TCQ device_temp_sync_r1;
    device_temp_sync_r3 <= #TCQ device_temp_sync_r2;
    device_temp_sync_r4 <= #TCQ device_temp_sync_r3;
    device_temp_sync_r5 <= #TCQ device_temp_sync_r4;
    device_temp_sync_r4_neq_r3 <= #TCQ (device_temp_sync_r4 != device_temp_sync_r3) ? 1'b1 : 1'b0;
  end
  always @(posedge clk)
    if(rst || (device_temp_sync_r4_neq_r3))
      sync_cntr <= #TCQ 4'b0000;
    else if(~&sync_cntr)
      sync_cntr <= #TCQ sync_cntr + 4'b0001;
  always @(posedge clk)
    if(&sync_cntr)
      device_temp_r <= #TCQ device_temp_sync_r5;
  assign device_temp = device_temp_r;
  generate
    if(TEMP_MON_CONTROL == "EXTERNAL") begin : user_supplied_temperature
      assign device_temp_lcl = device_temp_i;
    end else begin : xadc_supplied_temperature
      localparam nTEMPSAMP = cdiv(tTEMPSAMPLE, XADC_CLK_PERIOD);
      localparam nTEMPSAMP_CLKS = nTEMPSAMP;
      localparam nTEMPSAMP_CLKS_M6 = nTEMPSAMP - 6;
      localparam nTEMPSAMP_CNTR_WIDTH = clogb2(nTEMPSAMP_CLKS);
      localparam INIT_IDLE                                = 2'b00;
      localparam REQUEST_READ_TEMP                        = 2'b01;
      localparam WAIT_FOR_READ                            = 2'b10;
      localparam READ                                     = 2'b11;
      reg [nTEMPSAMP_CNTR_WIDTH-1:0]  sample_timer = {nTEMPSAMP_CNTR_WIDTH{1'b0}};
      reg                             sample_timer_en     = 1'b0;
      reg                             sample_timer_clr    = 1'b0;
      reg                             sample_en           = 1'b0;
      reg [2:0]                       tempmon_state       = INIT_IDLE;
      reg [2:0]                       tempmon_next_state  = INIT_IDLE;
      reg                             xadc_den            = 1'b0;
      wire                            xadc_drdy;
      wire  [15:0]                    xadc_do;
      reg                             xadc_drdy_r         = 1'b0;
      reg   [15:0]                    xadc_do_r           = 1'b0;
      reg   [11:0]                    temperature         = 12'b0;
      (* ASYNC_REG = "TRUE" *)  reg rst_r1;
      (* ASYNC_REG = "TRUE" *)  reg rst_r2;
      always @(posedge xadc_clk) begin
        rst_r1 <= rst;
        rst_r2 <= rst_r1;
      end
      always @ (posedge xadc_clk)
        if(rst_r2 || sample_timer_clr)
          sample_timer <= #TCQ {nTEMPSAMP_CNTR_WIDTH{1'b0}};
        else if(sample_timer_en)
          sample_timer <= #TCQ sample_timer + 1'b1;
      always @(posedge xadc_clk)
        if(rst_r2)
          tempmon_state <= #TCQ INIT_IDLE;
        else
          tempmon_state <= #TCQ tempmon_next_state;
      always @(posedge xadc_clk)
        sample_en <= #TCQ (sample_timer == nTEMPSAMP_CLKS_M6) ? 1'b1 : 1'b0;
      always @(tempmon_state or sample_en or xadc_drdy_r) begin
        tempmon_next_state = tempmon_state;
        case(tempmon_state)
          INIT_IDLE:
            if(sample_en)
              tempmon_next_state = REQUEST_READ_TEMP;
          REQUEST_READ_TEMP:
            tempmon_next_state = WAIT_FOR_READ;
          WAIT_FOR_READ:
            if(xadc_drdy_r)
              tempmon_next_state = READ;
          READ:
            tempmon_next_state = INIT_IDLE;
          default:
            tempmon_next_state = INIT_IDLE;
        endcase
      end
      always @(posedge xadc_clk)
        if(rst_r2 || (tempmon_state == WAIT_FOR_READ))
          sample_timer_clr <= #TCQ 1'b0;
        else if(tempmon_state == REQUEST_READ_TEMP)
          sample_timer_clr <= #TCQ 1'b1;
      always @(posedge xadc_clk)
        if(rst_r2 || (tempmon_state == REQUEST_READ_TEMP))
          sample_timer_en <= #TCQ 1'b0;
        else if((tempmon_state == INIT_IDLE) || (tempmon_state == READ))
          sample_timer_en <= #TCQ 1'b1;
      always @(posedge xadc_clk)
        if(rst_r2 || (tempmon_state == WAIT_FOR_READ))
          xadc_den <= #TCQ 1'b0;
        else if(tempmon_state == REQUEST_READ_TEMP)
          xadc_den <= #TCQ 1'b1;
      always @(posedge xadc_clk)
        if(rst_r2) begin
          xadc_drdy_r <= #TCQ 1'b0;
          xadc_do_r <= #TCQ 16'b0;
        end
        else begin
          xadc_drdy_r <= #TCQ xadc_drdy;
          xadc_do_r <= #TCQ xadc_do;
        end
      always @(posedge xadc_clk)
        if(rst_r2)
          temperature <= #TCQ 12'b0;
        else if(tempmon_state == READ)
          temperature <= #TCQ xadc_do_r[15:4];
      assign device_temp_lcl = temperature;
      XADC #(
        .INIT_40(16'h1000), 
        .INIT_41(16'h2fff), 
        .INIT_42(16'h0800), 
        .INIT_48(16'h0101), 
        .INIT_49(16'h0000), 
        .INIT_4A(16'h0100), 
        .INIT_4B(16'h0000), 
        .INIT_4C(16'h0000), 
        .INIT_4D(16'h0000), 
        .INIT_4E(16'h0000), 
        .INIT_4F(16'h0000), 
        .INIT_50(16'hb5ed), 
        .INIT_51(16'h57e4), 
        .INIT_52(16'ha147), 
        .INIT_53(16'hca33), 
        .INIT_54(16'ha93a), 
        .INIT_55(16'h52c6), 
        .INIT_56(16'h9555), 
        .INIT_57(16'hae4e), 
        .INIT_58(16'h5999), 
        .INIT_5C(16'h5111), 
        .SIM_DEVICE("7SERIES")  
      )
      XADC_inst (
        .ALM(),                     
        .OT(),                      
        .DO(xadc_do),               
        .DRDY(xadc_drdy),           
        .BUSY(),                    
        .CHANNEL(),                 
        .EOC(),                     
        .EOS(),                     
        .JTAGBUSY(),                
        .JTAGLOCKED(),              
        .JTAGMODIFIED(),            
        .MUXADDR(),                 
        .VAUXN(16'b0),              
        .VAUXP(16'b0),              
        .CONVST(1'b0),              
        .CONVSTCLK(1'b0),           
        .RESET(1'b0),               
        .VN(1'b0),                  
        .VP(1'b0),                  
        .DADDR(7'b0),               
        .DCLK(xadc_clk),            
        .DEN(xadc_den),             
        .DI(16'b0),                 
        .DWE(1'b0)                  
      );
    end
  endgenerate
endmodule
