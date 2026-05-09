module ewrapper_io_rx_slow (
   CLK_DIV_OUT, DATA_IN_TO_DEVICE,
   CLK_IN_P, CLK_IN_N, CLK_RESET, IO_RESET, DATA_IN_FROM_PINS_P,
   DATA_IN_FROM_PINS_N, BITSLIP
   );
   input       CLK_IN_P;
   input       CLK_IN_N;
   input       CLK_RESET;
   input       IO_RESET;
   input [8:0] DATA_IN_FROM_PINS_P;
   input [8:0] DATA_IN_FROM_PINS_N;
   input       BITSLIP; // Note: BITSLIP is declared but not used in this logic
   output      CLK_DIV_OUT;
   output [71:0] DATA_IN_TO_DEVICE;

   reg [1:0]  clk_cnt;
   reg [8:0]  clk_even_reg;
   reg [8:0]  clk_odd_reg;
   reg [8:0]  clk0_even;
   reg [8:0]  clk1_even;
   reg [8:0]  clk2_even;
   reg [8:0]  clk3_even;
   reg [8:0]  clk0_odd;
   reg [8:0]  clk1_odd;
   reg [8:0]  clk2_odd;
   reg [8:0]  clk3_odd;
   reg [71:0] rx_out_sync_pos;
   reg        rx_outclock_del_45;
   reg        rx_outclock_del_135;
   reg [71:0] rx_out;

   wire       reset;
   wire       rx_outclock;
   wire       rxi_lclk;
   wire [71:0] rx_out_int;
   wire       rx_pedge_first;
   wire [8:0] rx_in;
   wire [8:0] clk_even;
   wire [8:0] clk_odd;

   assign reset                   = IO_RESET;
   assign DATA_IN_TO_DEVICE       = rx_out; // Simplified assignment
   assign CLK_DIV_OUT             = rx_outclock;

   genvar    pin_count;
   generate
      for (pin_count = 0; pin_count < 9; pin_count = pin_count + 1) begin: pins
         IBUFDS
           #(.DIFF_TERM  ("TRUE"),
             .IOSTANDARD ("LVDS_25"))
         ibufds_inst
           (.I     (DATA_IN_FROM_PINS_P[pin_count]),
            .IB    (DATA_IN_FROM_PINS_N[pin_count]),
            .O     (rx_in[pin_count]));
      end
   endgenerate

   IBUFGDS
     #(.DIFF_TERM  ("TRUE"),
       .IOSTANDARD ("LVDS_25"))
   ibufds_clk_inst
     (.I          (CLK_IN_P),
      .IB         (CLK_IN_N),
      .O          (rxi_lclk));

   BUFR
     #(.SIM_DEVICE("7SERIES"),
     .BUFR_DIVIDE("4"))
   clkout_buf_inst
     (.O   (rx_outclock),
      .CE  (1'b1),
      .CLR (CLK_RESET), // Use CLK_RESET for BUFR clear
      .I   (rxi_lclk));

   // Clock Counter Logic
   always @ (posedge rxi_lclk or posedge reset) begin
     if(reset)
       clk_cnt <= 2'b00;
     // This condition seems intended to align the counter, exact purpose depends on system timing
     else if(rx_pedge_first)
       clk_cnt <= 2'b11; // Jump to last phase on detected edge?
     else
       clk_cnt <= clk_cnt + 2'b01;
   end

   // Edge Detection Logic (relative phases of rx_outclock sampled by rxi_lclk)
   always @ (negedge rxi_lclk) // Changed sensitivity edge for clarity if sampling rx_outclock
     rx_outclock_del_45  <= rx_outclock;

   always @ (negedge rxi_lclk) // Changed sensitivity edge for clarity if sampling rx_outclock
     rx_outclock_del_135 <= rx_outclock_del_45;

   assign rx_pedge_first = rx_outclock_del_45 & ~rx_outclock_del_135;

   // IDDR Instantiation
   genvar    iddr_cnt;
   generate
      for (iddr_cnt = 0; iddr_cnt < 9; iddr_cnt = iddr_cnt + 1) begin: iddrs
         IDDR #(
            .DDR_CLK_EDGE  ("SAME_EDGE_PIPELINED"), // Captures D on rising C, previous D on falling C
            .SRTYPE        ("ASYNC"))              // Asynchronous reset
         iddr_inst (
            .Q1  (clk_even[iddr_cnt]), // Data captured on rising edge of C
            .Q2  (clk_odd[iddr_cnt]),  // Data captured on falling edge of C
            .C   (rxi_lclk),
            .CE  (1'b1),
            .D   (rx_in[iddr_cnt]),
            .R   (reset),              // Use the common IO reset
            .S   (1'b0));              // Set is unused
      end
   endgenerate

   // Register IDDR outputs
   always @ (posedge rxi_lclk or posedge reset) begin
     if(reset) begin
        clk_even_reg <= {($size(clk_even_reg)){1'b0}}; // Corrected reset width
        clk_odd_reg  <= {($size(clk_odd_reg)){1'b0}};  // Corrected reset width
     end
     else begin
        clk_even_reg <= clk_even;
        clk_odd_reg  <= clk_odd;
     end
   end

   // De-serialize based on clock counter phase
   always @ (posedge rxi_lclk or posedge reset) begin
     if(reset)
       clk0_even <= {($size(clk0_even)){1'b0}}; // Corrected reset width
     else if(clk_cnt == 2'b00)
       clk0_even <= clk_even_reg;
     // No else needed, maintains value otherwise
   end

   always @ (posedge rxi_lclk or posedge reset) begin
     if(reset)
       clk1_even <= {($size(clk1_even)){1'b0}}; // Corrected reset width
     else if(clk_cnt == 2'b01)
       clk1_even <= clk_even_reg;
   end

   always @ (posedge rxi_lclk or posedge reset) begin
     if(reset)
       clk2_even <= {($size(clk2_even)){1'b0}}; // Corrected reset width
     else if(clk_cnt == 2'b10)
       clk2_even <= clk_even_reg;
   end

   always @ (posedge rxi_lclk or posedge reset) begin
     if(reset)
       clk3_even <= {($size(clk3_even)){1'b0}}; // Corrected reset width
     else if(clk_cnt == 2'b11)
       clk3_even <= clk_even_reg;
   end

   always @ (posedge rxi_lclk or posedge reset) begin
     if(reset)
       clk0_odd <= {($size(clk0_odd)){1'b0}}; // Corrected reset width
     else if(clk_cnt == 2'b00)
       clk0_odd <= clk_odd_reg;
   end

   always @ (posedge rxi_lclk or posedge reset) begin
     if(reset)
       clk1_odd <= {($size(clk1_odd)){1'b0}}; // Corrected reset width
     else if(clk_cnt == 2'b01)
       clk1_odd <= clk_odd_reg;
   end

   always @ (posedge rxi_lclk or posedge reset) begin
     if(reset)
       clk2_odd <= {($size(clk2_odd)){1'b0}}; // Corrected reset width
     else if(clk_cnt == 2'b10)
       clk2_odd <= clk_odd_reg;
   end

   always @ (posedge rxi_lclk or posedge reset) begin
     if(reset)
       clk3_odd <= {($size(clk3_odd)){1'b0}}; // Corrected reset width
     else if(clk_cnt == 2'b11)
       clk3_odd <= clk_odd_reg;
   end

   // Combine deserialized data
   // rx_out_int combines 8 bits per input lane (4 phases * 2 edges) = 8 bits
   // Total 9 lanes * 8 bits/lane = 72 bits
   assign rx_out_int[71:64] = {clk3_odd[8], clk3_even[8], clk2_odd[8], clk2_even[8],
                               clk1_odd[8], clk1_even[8], clk0_odd[8], clk0_even[8]}; // Order might depend on desired output format
   assign rx_out_int[63:56] = {clk3_odd[7], clk3_even[7], clk2_odd[7], clk2_even[7],
                               clk1_odd[7], clk1_even[7], clk0_odd[7], clk0_even[7]};
   assign rx_out_int[55:48] = {clk3_odd[6], clk3_even[6], clk2_odd[6], clk2_even[6],
                               clk1_odd[6], clk1_even[6], clk0_odd[6], clk0_even[6]};
   assign rx_out_int[47:40] = {clk3_odd[5], clk3_even[5], clk2_odd[5], clk2_even[5],
                               clk1_odd[5], clk1_even[5], clk0_odd[5], clk0_even[5]};
   assign rx_out_int[39:32] = {clk3_odd[4], clk3_even[4], clk2_odd[4], clk2_even[4],
                               clk1_odd[4], clk1_even[4], clk0_odd[4], clk0_even[4]};
   assign rx_out_int[31:24] = {clk3_odd[3], clk3_even[3], clk2_odd[3], clk2_even[3],
                               clk1_odd[3], clk1_even[3], clk0_odd[3], clk0_even[3]};
   assign rx_out_int[23:16] = {clk3_odd[2], clk3_even[2], clk2_odd[2], clk2_even[2],
                               clk1_odd[2], clk1_even[2], clk0_odd[2], clk0_even[2]};
   assign rx_out_int[15:8]  = {clk3_odd[1], clk3_even[1], clk2_odd[1], clk2_even[1],
                               clk1_odd[1], clk1_even[1], clk0_odd[1], clk0_even[1]};
   assign rx_out_int[7:0]   = {clk3_odd[0], clk3_even[0], clk2_odd[0], clk2_even[0],
                               clk1_odd[0], clk1_even[0], clk0_odd[0], clk0_even[0]};


   // Clock Domain Crossing (Fast clock -> Slow clock)
   // Stage 1: Capture on fast clock
   always @ (posedge rxi_lclk or posedge reset) begin
     if(reset)
       rx_out_sync_pos <= {($size(rx_out_sync_pos)){1'b0}}; // Use $size for robustness
     else
       rx_out_sync_pos <= rx_out_int;
   end

   // Stage 2: Capture on slow clock
   always @ (posedge rx_outclock or posedge reset) begin
     if(reset)
       rx_out <= {($size(rx_out)){1'b0}}; // Use $size for robustness
     else
       rx_out <= rx_out_sync_pos;
   end

endmodule