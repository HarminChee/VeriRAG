// 1_corrected_clk.v
module ewrapper_io_rx_slow (
   CLK_DIV_OUT, DATA_IN_TO_DEVICE,
   CLK_IN_P, CLK_IN_N, CLK_RESET, IO_RESET, DATA_IN_FROM_PINS_P,
   DATA_IN_FROM_PINS_N, BITSLIP,
   // DFT Ports
   scan_en, scan_clk
   );

   input       CLK_IN_P;
   input       CLK_IN_N;
   input       CLK_RESET; // Functional reset for BUFR
   input       IO_RESET;  // Functional reset for logic
   input [8:0] DATA_IN_FROM_PINS_P;
   input [8:0] DATA_IN_FROM_PINS_N;
   input       BITSLIP; // Note: BITSLIP input is declared but not used in the original code.
   output      CLK_DIV_OUT;
   output [71:0] DATA_IN_TO_DEVICE;

   // DFT Inputs
   input       scan_en;   // Scan enable signal
   input       scan_clk;  // Scan clock signal

   reg [1:0] 	 clk_cnt;
   reg [8:0] 	 clk_even_reg;
   reg [8:0] 	 clk_odd_reg;
   reg [8:0] 	 clk0_even;
   reg [8:0] 	 clk1_even;
   reg [8:0] 	 clk2_even;
   reg [8:0] 	 clk3_even;
   reg [8:0] 	 clk0_odd;
   reg [8:0] 	 clk1_odd;
   reg [8:0] 	 clk2_odd;
   reg [8:0] 	 clk3_odd;
   reg [71:0] 	 rx_out_sync_pos;
   reg 		 rx_outclock_del_45;
   reg 		 rx_outclock_del_135;
   reg [71:0] 	 rx_out;

   wire          reset;
   wire          rx_outclock_func; // Functional divided clock
   wire          rx_outclock;      // Clock signal used for output port and potentially internal logic
   wire          rxi_lclk;         // Main clock derived from primary inputs
   wire [71:0] 	 rx_out_int;
   wire          rx_pedge_first;
   wire [8:0] 	 rx_in;
   wire [8:0] 	 clk_even;
   wire [8:0] 	 clk_odd;
   wire          rx_out_clk_muxed; // Muxed clock for rx_out register

   // Use IO_RESET for synchronous logic reset
   assign reset                   = IO_RESET;
   assign DATA_IN_TO_DEVICE[71:0] = rx_out[71:0];
   // Output the functional divided clock
   assign CLK_DIV_OUT             = rx_outclock_func;

   genvar 	 pin_count;
   generate
      for (pin_count = 0; pin_count < 9; pin_count = pin_count + 1) begin: pins
	 IBUFDS
	   #(.DIFF_TERM  ("TRUE"),
           .IOSTANDARD ("LVDS_25"))
	 ibufds_inst
	   (.I     (DATA_IN_FROM_PINS_P[pin_count]),
           .IB     (DATA_IN_FROM_PINS_N[pin_count]),
           .O      (rx_in[pin_count]));
      end
   endgenerate

   IBUFGDS
     #(.DIFF_TERM  ("TRUE"),
       .IOSTANDARD ("LVDS_25"))
   ibufds_clk_inst
     (.I          (CLK_IN_P),
      .IB         (CLK_IN_N),
      .O          (rxi_lclk)); // rxi_lclk is derived from primary inputs

   // BUFR generates the functional divided clock
   BUFR
     #(.SIM_DEVICE("7SERIES"),
     .BUFR_DIVIDE("4"))
   clkout_buf_inst
     (.O (rx_outclock_func), // Output functional clock
      .CE(1'b1),
      .CLR(CLK_RESET),       // Use CLK_RESET for BUFR reset
      .I (rxi_lclk));

   // DFT Clock Mux for rx_out register: Select scan_clk in test mode, functional clock otherwise
   // Note: For simplicity, using rxi_lclk as the test clock source.
   // A dedicated scan_clk input is provided for flexibility. If scan_clk is connected
   // to the same source as rxi_lclk during test, this works. Otherwise, scan_clk should be used.
   // Using scan_clk input as specified:
   assign rx_out_clk_muxed = scan_en ? scan_clk : rx_outclock_func;

   // Logic clocked by rxi_lclk (derived from primary input - generally DFT friendly)
   always @ (posedge rxi_lclk or posedge reset)
     if(reset)
       clk_cnt[1:0] <= 2'b00;
     else if(rx_pedge_first)
       clk_cnt[1:0] <= 2'b11;
     else
       clk_cnt[1:0] <= clk_cnt[1:0] + 2'b01;

   // These registers are clocked by negedge rxi_lclk. While derived from primary,
   // negedge clocks might require special handling in some DFT flows, but don't violate CLKNPI per se.
   always @ (negedge rxi_lclk) // Assuming reset is handled implicitly or not needed based on usage
     rx_outclock_del_45  <= rx_outclock_func; // Use functional clock for timing detection logic

   always @ (negedge rxi_lclk) // Assuming reset is handled implicitly or not needed based on usage
     rx_outclock_del_135 <= rx_outclock_del_45;

   // Combinational logic based on delayed clocks
   assign rx_pedge_first = rx_outclock_del_45 & ~rx_outclock_del_135;

   // This register synchronizes data to the rxi_lclk domain
   always @ (posedge rxi_lclk or posedge reset)
     if(reset)
       rx_out_sync_pos[71:0] <= {(72){1'b0}};
     else
       rx_out_sync_pos[71:0] <= rx_out_int[71:0];

   // This register was clocked by the divided clock rx_outclock (now rx_outclock_func).
   // Apply clock multiplexing for DFT.
   always @ (posedge rx_out_clk_muxed or posedge reset) // Use muxed clock
     if(reset)
       rx_out[71:0] <= {(72){1'b0}};
     else
       rx_out[71:0] <= rx_out_sync_pos[71:0]; // Data comes from rxi_lclk domain

   genvar 	 iddr_cnt;
   generate
      for (iddr_cnt = 0; iddr_cnt < 9; iddr_cnt = iddr_cnt + 1) begin: iddrs
	 // IDDR clocked by rxi_lclk (derived from primary input)
	 IDDR #(
		.DDR_CLK_EDGE  ("SAME_EDGE_PIPELINED"),
		.SRTYPE ("ASYNC")) // Async reset might need DFT handling (e.g., test mode control)
	 iddr_inst (
		    .Q1  (clk_even[iddr_cnt]),
		    .Q2  (clk_odd[iddr_cnt]),
		    .C   (rxi_lclk),
		    .CE  (1'b1),
		    .D   (rx_in[iddr_cnt]),
		    .R   (reset), // Use main logic reset
		    .S   (1'b0));
      end
   endgenerate

   // Registers clocked by rxi_lclk
   always @ (posedge rxi_lclk or posedge reset)
     if(reset)
       begin
	  clk_even_reg[8:0] <= {(9){1'b0}}; // Corrected width
	  clk_odd_reg[8:0]  <= {(9){1'b0}}; // Corrected width
       end
     else
       begin
	  clk_even_reg[8:0] <= clk_even[8:0];
	  clk_odd_reg[8:0]  <= clk_odd[8:0];
       end

   // Demux registers based on clk_cnt, all clocked by rxi_lclk
   always @ (posedge rxi_lclk or posedge reset)
     if(reset)
       clk0_even[8:0] <= {(9){1'b0}}; // Corrected width
     else if(clk_cnt[1:0] == 2'b00)
       clk0_even[8:0] <= clk_even_reg[8:0];
     // else retain value (implied latch - ensure this is intended or add 'else clk0_even <= clk0_even;')
     // Assuming hold is intended based on original code structure. For DFT, explicit hold is better.
     else
       clk0_even[8:0] <= clk0_even[8:0];


   always @ (posedge rxi_lclk or posedge reset)
     if(reset)
       clk1_even[8:0] <= {(9){1'b0}}; // Corrected width
     else if(clk_cnt[1:0] == 2'b01)
       clk1_even[8:0] <= clk_even_reg[8:0];
     else
       clk1_even[8:0] <= clk1_even[8:0]; // Explicit hold

   always @ (posedge rxi_lclk or posedge reset)
     if(reset)
       clk2_even[8:0] <= {(9){1'b0}}; // Corrected width
     else if(clk_cnt[1:0] == 2'b10)
       clk2_even[8:0] <= clk_even_reg[8:0];
     else
       clk2_even[8:0] <= clk2_even[8:0]; // Explicit hold

   always @ (posedge rxi_lclk or posedge reset)
     if(reset)
       clk3_even[8:0] <= {(9){1'b0}}; // Corrected width
     else if(clk_cnt[1:0] == 2'b11)
       clk3_even[8:0] <= clk_even_reg[8:0];
     else
       clk3_even[8:0] <= clk3_even[8:0]; // Explicit hold

   always @ (posedge rxi_lclk or posedge reset)
     if(reset)
       clk0_odd[8:0] <= {(9){1'b0}}; // Corrected width
     else if(clk_cnt[1:0] == 2'b00)
       clk0_odd[8:0] <= clk_odd_reg[8:0];
     else
       clk0_odd[8:0] <= clk0_odd[8:0]; // Explicit hold

   always @ (posedge rxi_lclk or posedge reset)
     if(reset)
       clk1_odd[8:0] <= {(9){1'b0}}; // Corrected width
     else if(clk_cnt[1:0] == 2'b01)
       clk1_odd[8:0] <= clk_odd_reg[8:0];
     else
       clk1_odd[8:0] <= clk1_odd[8:0]; // Explicit hold

   always @ (posedge rxi_lclk or posedge reset)
     if(reset)
       clk2_odd[8:0] <= {(9){1'b0}}; // Corrected width
     else if(clk_cnt[1:0] == 2'b10)
       clk2_odd[8:0] <= clk_odd_reg[8:0];
     else
       clk2_odd[8:0] <= clk2_odd[8:0]; // Explicit hold

   always @ (posedge rxi_lclk or posedge reset)
     if(reset)
       clk3_odd[8:0] <= {(9){1'b0}}; // Corrected width
     else if(clk_cnt[1:0] == 2'b11)
       clk3_odd[8:0] <= clk_odd_reg[8:0];
     else
       clk3_odd[8:0] <= clk3_odd[8:0]; // Explicit hold


   // Combinational logic for assembling output data
   // Corrected widths in concatenation source signals
   assign rx_out_int[71:64]={clk0_even[8],clk0_odd[8],clk1_even[8],clk1_odd[8],
			     clk2_even[8],clk2_odd[8],clk3_even[8],clk3_odd[8]};
   assign rx_out_int[63:56]={clk0_even[7],clk0_odd[7],clk1_even[7],clk1_odd[7],
			     clk2_even[7],clk2_odd[7],clk3_even[7],clk3_odd[7]};
   assign rx_out_int[55:48]={clk0_even[6],clk0_odd[6],clk1_even[6],clk1_odd[6],
			     clk2_even[6],clk2_odd[6],clk3_even[6],clk3_odd[6]};
   assign rx_out_int[47:40]={clk0_even[5],clk0_odd[5],clk1_even[5],clk1_odd[5],
			     clk2_even[5],clk2_odd[5],clk3_even[5],clk3_odd[5]};
   assign rx_out_int[39:32]={clk0_even[4],clk0_odd[4],clk1_even[4],clk1_odd[4],
			     clk2_even[4],clk2_odd[4],clk3_even[4],clk3_odd[4]};
   assign rx_out_int[31:24]={clk0_even[3],clk0_odd[3],clk1_even[3],clk1_odd[3],
			     clk2_even[3],clk2_odd[3],clk3_even[3],clk3_odd[3]};
   assign rx_out_int[23:16]={clk0_even[2],clk0_odd[2],clk1_even[2],clk1_odd[2],
			     clk2_even[2],clk2_odd[2],clk3_even[2],clk3_odd[2]};
   assign rx_out_int[15:8] ={clk0_even[1],clk0_odd[1],clk1_even[1],clk1_odd[1],
			     clk2_even[1],clk2_odd[1],clk3_even[1],clk3_odd[1]};
   assign rx_out_int[7:0]  ={clk0_even[0],clk0_odd[0],clk1_even[0],clk1_odd[0],
			     clk2_even[0],clk2_odd[0],clk3_even[0],clk3_odd[0]};

endmodule