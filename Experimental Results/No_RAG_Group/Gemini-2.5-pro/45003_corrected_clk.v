// 1_corrected_clk.v
module red_pitaya_daisy_rx
(
   input                 ser_clk_i       ,
   input                 ser_dat_i       ,
   input                 cfg_en_i        ,
   input                 cfg_train_i     ,
   output                cfg_trained_o   ,
   input                 dly_clk_i       ,
   output                par_clk_o       ,
   output                par_rstn_o      ,
   output wire           par_dv_o        ,  // Changed to wire
   output wire [ 16-1: 0] par_dat_o       ,  // Changed to wire

   // DFT Ports
   input                 test_mode_i     , // DFT test mode enable
   input                 test_clk_i        // DFT test clock
);

wire           ser_clk     ;
wire           ser_clk_dly = ser_clk_i;
wire           par_clk     ; // Functional divided clock
reg  [16-1: 0] par_rstn_r  ;
reg            par_rstn    ;
wire           dly_rdy     = 1'b1;

// DFT Clock Mux
wire           scan_clk;
assign scan_clk = test_mode_i ? test_clk_i : par_clk;

BUFIO i_BUFIO_clk
(
  .O (  ser_clk      ),
  .I (  ser_clk_dly  )
);

BUFR #(.SIM_DEVICE("7SERIES"), .BUFR_DIVIDE("2")) i_BUFR_clk
(
  .O   (  par_clk      ), // This remains the functional clock source
  .CE  (  1'b1         ),
  .CLR ( !cfg_en_i     ), // Note: Asynchronous clear might be another DFT issue (ASYNCRST)
  .I   (  ser_clk_dly  )
);

// Use scan_clk for user logic flip-flops, keep async reset from original
always @(posedge scan_clk or negedge cfg_en_i) begin // Changed par_clk to scan_clk
   if (cfg_en_i == 1'b0) begin
      par_rstn_r <= 16'h0 ;
      par_rstn   <=  1'b0 ;
   end
   else begin
      par_rstn_r <= {par_rstn_r[16-2:0], dly_rdy} ;
      par_rstn   <=  par_rstn_r[16-1];
   end
end

reg            bitslip      ;
reg  [ 5-1: 0] bitslip_cnt  ;
reg  [ 3-1: 0] nibslip_cnt  ;
wire [ 8-1: 0] rxp_dat      ;
reg  [ 4-1: 0] rxp_dat_1r   ;
reg  [ 4-1: 0] rxp_dat_2r   ;
reg  [ 4-1: 0] rxp_dat_3r   ;
reg            par_dv       ;
reg  [16-1: 0] par_dat      ;
reg            par_ok       ;
reg  [ 2-1: 0] par_cnt      ;
reg            par_val      ;

// ISERDESE2 uses functional clocks ser_clk and par_clk
ISERDESE2
#(
  .DATA_RATE         ( "DDR"          ),
  .DATA_WIDTH        (  4             ),
  .INTERFACE_TYPE    ( "NETWORKING"   ),
  .DYN_CLKDIV_INV_EN ( "FALSE"        ),
  .DYN_CLK_INV_EN    ( "FALSE"        ),
  .NUM_CE            (  2             ),
  .OFB_USED          ( "FALSE"        ),
  .IOBDELAY          ( "NONE"         ),
  .SERDES_MODE       ( "MASTER"       )
)
i_iserdese
(
  .Q1                (  rxp_dat[7]    ),
  .Q2                (  rxp_dat[6]    ),
  .Q3                (  rxp_dat[5]    ),
  .Q4                (  rxp_dat[4]    ),
  .Q5                (  rxp_dat[3]    ),
  .Q6                (  rxp_dat[2]    ),
  .Q7                (  rxp_dat[1]    ),
  .Q8                (  rxp_dat[0]    ),
  .SHIFTOUT1         (),
  .SHIFTOUT2         (),
  .BITSLIP           (  bitslip       ),  // Driven by logic clocked by scan_clk
  .CE1               (  cfg_en_i      ),
  .CE2               (  cfg_en_i      ),
  .CLK               (  ser_clk       ),  // High-speed clock (functional)
  .CLKB              ( !ser_clk       ),  // High-speed clock inverted (functional)
  .CLKDIV            (  par_clk       ),  // Divided clock (functional) - ISERDES needs this
  .CLKDIVP           (  1'b0          ),
  .D                 (  ser_dat_i     ),
  .DDLY              (  1'b0          ),
  .RST               ( !par_rstn      ),  // Driven by logic clocked by scan_clk
  .SHIFTIN1          (  1'b0          ),
  .SHIFTIN2          (  1'b0          ),
  .DYNCLKDIVSEL      (  1'b0          ),
  .DYNCLKSEL         (  1'b0          ),
  .OFB               (  1'b0          ),
  .OCLK              (  1'b0          ),
  .OCLKB             (  1'b0          ),
  .O                 ()
);

reg  [ 2-1: 0] par_train_r ;
reg            par_train   ;

// Use scan_clk for user logic flip-flops
// Note: Using par_rstn as synchronous reset condition. par_rstn itself has async reset.
always @(posedge scan_clk) begin // Changed par_clk to scan_clk
   if (par_rstn == 1'b0) begin
      par_train_r <= 2'h0 ;
      par_train   <= 1'b0 ;
   end
   else begin
      par_train_r <= {par_train_r[0], cfg_train_i} ;
      par_train   <=  par_train_r[1];
   end
end

// Use scan_clk for user logic flip-flops
always @(posedge scan_clk) begin // Changed par_clk to scan_clk
   if (par_rstn == 1'b0) begin
      bitslip     <=  1'b0 ;
      bitslip_cnt <=  5'b0 ;
      nibslip_cnt <=  3'h0 ;
      par_ok      <=  1'b0 ;
      par_cnt     <=  2'h0 ;
      par_val     <=  1'b0 ;
   end
   else begin
      if (par_train)
         bitslip_cnt <= bitslip_cnt + 5'h1 ;
      else
         bitslip_cnt <= 5'h0 ;
      // Corrected comparison width from 3'b10 to 2'b10
      bitslip <= (bitslip_cnt[3:2] == 2'b10) && (par_dat != 16'h00FF) && par_dv && !par_ok ;
      if (par_train && bitslip && !par_ok)
         nibslip_cnt <= nibslip_cnt + 3'h1 ;
      else if (!par_train || par_ok)
         nibslip_cnt <= 3'h0 ;
      if ((nibslip_cnt == 3'h7) && bitslip)
         par_cnt <= par_cnt ;
      else
         par_cnt <= par_cnt + 2'h1 ;
      par_val <= (par_cnt==2'b01) ;
      if (par_train && (par_dat == 16'h00FF) && par_dv)
         par_ok <= 1'b1 ;
      // Corrected comparison width from 3'b10 to 2'b10
      else if ((bitslip_cnt[3:2] == 2'b10) && (par_dat != 16'h00FF) && par_dv)
         par_ok <= 1'b0 ;
   end
end

// Use scan_clk for user logic flip-flops
always @(posedge scan_clk) begin // Changed par_clk to scan_clk
   if (par_rstn == 1'b0) begin
      rxp_dat_1r <=  4'h0 ;
      rxp_dat_2r <=  4'h0 ;
      rxp_dat_3r <=  4'h0 ;
      par_dv     <=  1'b0 ;
      par_dat    <= 16'h0 ;
   end
   else begin
      // Note: rxp_dat comes from ISERDES (functional clocks) - potential timing issue across clock domains during functional mode.
      rxp_dat_1r <= rxp_dat[3:0];
      rxp_dat_2r <= rxp_dat_1r  ;
      rxp_dat_3r <= rxp_dat_2r  ;
      par_dv  <=  par_val ;
      if (par_val)
         par_dat <= {rxp_dat, rxp_dat_1r, rxp_dat_2r, rxp_dat_3r};
   end
end

// Assign outputs based on the registers clocked by scan_clk
// Changed output declarations to wire