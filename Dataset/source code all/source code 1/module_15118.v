`timescale 1ps/1ps
`ifdef ALTERNATE_READ
`else
  `define ALTERNATE_READ 1'b1
`endif
`timescale 1ps/1ps
`ifdef ALTERNATE_READ
`else
  `define ALTERNATE_READ 1'b1
`endif
module iodrp_mcb_controller(
  input   wire  [7:0] memcell_address,
  input   wire  [7:0] write_data,
  output  reg   [7:0] read_data = 0,
  input   wire        rd_not_write,
  input   wire        cmd_valid,
  output  wire        rdy_busy_n,
  input   wire        use_broadcast,
  input   wire  [4:0] drp_ioi_addr,
  input   wire        sync_rst,
  input   wire        DRP_CLK,
  output  reg         DRP_CS,
  output  wire        DRP_SDI,  
  output  reg         DRP_ADD,
  output  reg         DRP_BKST,
  input   wire        DRP_SDO,   
  output  reg         MCB_UIREAD = 1'b0
  );
   reg [7:0]          memcell_addr_reg;     
   reg [7:0]          data_reg;             
   reg [8:0]          shift_through_reg;    
   reg                load_shift_n;         
   reg                addr_data_sel_n;      
   reg [2:0]          bit_cnt= 3'b0;        
   reg                rd_not_write_reg;
   reg                AddressPhase;         
   reg                DRP_CS_pre;
   reg                extra_cs;
   (* FSM_ENCODING="GRAY" *) reg [3:0] state, nextstate;
   wire [8:0]   data_out;
   reg  [8:0]   data_out_mux; 
   wire DRP_SDI_pre;          
   localparam READY             = 4'h0;
   localparam DECIDE            = 4'h1;
   localparam ADDR_PHASE        = 4'h2;
   localparam ADDR_TO_DATA_GAP  = 4'h3;
   localparam ADDR_TO_DATA_GAP2 = 4'h4;
   localparam ADDR_TO_DATA_GAP3 = 4'h5;
   localparam DATA_PHASE        = 4'h6;
   localparam ALMOST_READY      = 4'h7;
   localparam ALMOST_READY2     = 4'h8;
   localparam ALMOST_READY3     = 4'h9;
   localparam IOI_DQ0           = 5'h01;
   localparam IOI_DQ1           = 5'h00;
   localparam IOI_DQ2           = 5'h03;
   localparam IOI_DQ3           = 5'h02;
   localparam IOI_DQ4           = 5'h05;
   localparam IOI_DQ5           = 5'h04;
   localparam IOI_DQ6           = 5'h07;
   localparam IOI_DQ7           = 5'h06;
   localparam IOI_DQ8           = 5'h09;
   localparam IOI_DQ9           = 5'h08;
   localparam IOI_DQ10          = 5'h0B;
   localparam IOI_DQ11          = 5'h0A;
   localparam IOI_DQ12          = 5'h0D;
   localparam IOI_DQ13          = 5'h0C;
   localparam IOI_DQ14          = 5'h0F;
   localparam IOI_DQ15          = 5'h0E;
   localparam IOI_UDQS_CLK      = 5'h1D;
   localparam IOI_UDQS_PIN      = 5'h1C;
   localparam IOI_LDQS_CLK      = 5'h1F;
   localparam IOI_LDQS_PIN      = 5'h1E;
   reg [32*8-1:0] state_ascii;
   always @ (state) begin
      case (state)
  READY     :state_ascii<="READY";
  DECIDE      :state_ascii<="DECIDE";
  ADDR_PHASE    :state_ascii<="ADDR_PHASE";
  ADDR_TO_DATA_GAP  :state_ascii<="ADDR_TO_DATA_GAP";
  ADDR_TO_DATA_GAP2 :state_ascii<="ADDR_TO_DATA_GAP2";
  ADDR_TO_DATA_GAP3 :state_ascii<="ADDR_TO_DATA_GAP3";
  DATA_PHASE    :state_ascii<="DATA_PHASE";
  ALMOST_READY    :state_ascii<="ALMOST_READY";
  ALMOST_READY2   :state_ascii<="ALMOST_READY2";
  ALMOST_READY3   :state_ascii<="ALMOST_READY3";
      endcase 
   end
   always @ (posedge DRP_CLK) begin
      if(state == READY) begin
        memcell_addr_reg <= memcell_address;
        data_reg <= write_data;
        rd_not_write_reg <= rd_not_write;
      end
   end
   assign rdy_busy_n = (state == READY);
task shift_n_expand (
  input   [7:0] data_in,
  output  [8:0] data_out
  );
  begin
    if (data_in[0])
      data_out[1:0]  = 2'b11;
    else
      data_out[1:0]  = 2'b00;
    if (data_in[1:0] == 2'b10)
      data_out[2:1]  = 2'b11;
    else
      data_out[2:1]  = {data_in[1], data_out[1]};
    if (data_in[2:1] == 2'b10)
      data_out[3:2]  = 2'b11;
    else
      data_out[3:2]  = {data_in[2], data_out[2]};
    if (data_in[3:2] == 2'b10)
      data_out[4:3]  = 2'b11;
    else
      data_out[4:3]  = {data_in[3], data_out[3]};
    if (data_in[4:3] == 2'b10)
      data_out[5:4]  = 2'b11;
    else
      data_out[5:4]  = {data_in[4], data_out[4]};
    if (data_in[5:4] == 2'b10)
      data_out[6:5]  = 2'b11;
    else
      data_out[6:5]  = {data_in[5], data_out[5]};
    if (data_in[6:5] == 2'b10)
      data_out[7:6]  = 2'b11;
    else
      data_out[7:6]  = {data_in[6], data_out[6]};
    if (data_in[7:6] == 2'b10)
      data_out[8:7]  = 2'b11;
    else
      data_out[8:7]  = {data_in[7], data_out[7]};
  end
endtask
   always @(*) begin
    case(drp_ioi_addr)
`ifdef DRP_v1_0_FIX
      IOI_DQ0       : data_out_mux  = data_out<<1;
      IOI_DQ1       : data_out_mux  = data_out;
      IOI_DQ2       : data_out_mux  = data_out<<1;
      IOI_DQ3       : data_out_mux  = data_out;
      IOI_DQ4       : data_out_mux  = data_out;
      IOI_DQ5       : data_out_mux  = data_out;
      IOI_DQ6       : shift_n_expand (data_out, data_out_mux);
      IOI_DQ7       : data_out_mux  = data_out;
      IOI_DQ8       : data_out_mux  = data_out<<1;
      IOI_DQ9       : data_out_mux  = data_out;
      IOI_DQ10      : data_out_mux  = data_out<<1;
      IOI_DQ11      : data_out_mux  = data_out;
      IOI_DQ12      : data_out_mux  = data_out<<1;
      IOI_DQ13      : data_out_mux  = data_out;
      IOI_DQ14      : data_out_mux  = data_out<<1;
      IOI_DQ15      : data_out_mux  = data_out;
      IOI_UDQS_CLK  : data_out_mux  = data_out<<1;
      IOI_UDQS_PIN  : data_out_mux  = data_out<<1;
      IOI_LDQS_CLK  : data_out_mux  = data_out;
      IOI_LDQS_PIN  : data_out_mux  = data_out;
`else
`endif
      IOI_DQ0       : data_out_mux  = data_out;
      IOI_DQ1       : data_out_mux  = data_out;
      IOI_DQ2       : data_out_mux  = data_out;
      IOI_DQ3       : data_out_mux  = data_out;
      IOI_DQ4       : data_out_mux  = data_out;
      IOI_DQ5       : data_out_mux  = data_out;
      IOI_DQ6       : data_out_mux  = data_out;
      IOI_DQ7       : data_out_mux  = data_out;
      IOI_DQ8       : data_out_mux  = data_out;
      IOI_DQ9       : data_out_mux  = data_out;
      IOI_DQ10      : data_out_mux  = data_out;
      IOI_DQ11      : data_out_mux  = data_out;
      IOI_DQ12      : data_out_mux  = data_out;
      IOI_DQ13      : data_out_mux  = data_out;
      IOI_DQ14      : data_out_mux  = data_out;
      IOI_DQ15      : data_out_mux  = data_out;
      IOI_UDQS_CLK  : data_out_mux  = data_out;
      IOI_UDQS_PIN  : data_out_mux  = data_out;
      IOI_LDQS_CLK  : data_out_mux  = data_out;
      IOI_LDQS_PIN  : data_out_mux  = data_out;
      default       : data_out_mux  = data_out;
    endcase
   end
   assign     data_out = (addr_data_sel_n)? {1'b0, memcell_addr_reg} : {1'b0, data_reg};
   always @ (posedge DRP_CLK) begin
      if(sync_rst)
        shift_through_reg <= 9'b0;
      else begin
        if (load_shift_n)     
          shift_through_reg <= data_out_mux;
        else
          shift_through_reg <= {1'b0, DRP_SDO, shift_through_reg[7:1]};
      end
   end
   always @ (posedge DRP_CLK) begin
      if (((state == ADDR_PHASE) | (state == DATA_PHASE)) & !sync_rst)
        bit_cnt <= bit_cnt + 1;
      else
        bit_cnt <= 3'b0;
   end
  always @ (posedge DRP_CLK) begin
    if(sync_rst) begin
      read_data <= 8'h00;
    end
    else begin
      if(state == ALMOST_READY3)
        read_data <= shift_through_reg;
    end
  end
  always @ (posedge DRP_CLK) begin
    if(sync_rst) begin
      AddressPhase  <= 1'b0;
    end
    else begin
      if (AddressPhase) begin
        AddressPhase <= AddressPhase && ~(state == ALMOST_READY2);
      end
      else begin
        AddressPhase <= (state == ADDR_PHASE) && (bit_cnt == 3'b111);
      end
    end
  end
   always @ (posedge DRP_CLK) begin
      DRP_ADD     <= (nextstate == ADDR_PHASE);
      DRP_CS      <= (nextstate == ADDR_PHASE) | (nextstate == DATA_PHASE);
      MCB_UIREAD  <= (nextstate == DATA_PHASE) && rd_not_write_reg;
      if (state == READY)
        DRP_BKST  <= use_broadcast;
   end
   assign DRP_SDI_pre = (DRP_CS)? shift_through_reg[0] : 1'b0;  
   assign DRP_SDI = (rd_not_write_reg & DRP_CS & !DRP_ADD)? DRP_SDO : DRP_SDI_pre; 
  always @ (*) begin
    addr_data_sel_n = 1'b0;
    load_shift_n = 1'b0;
    case (state)
      READY:  begin
         load_shift_n = 0;
         if(cmd_valid)
          nextstate = DECIDE;
         else
          nextstate = READY;
        end
      DECIDE: begin
          load_shift_n = 1;
          addr_data_sel_n = 1;
          nextstate = ADDR_PHASE;
        end
      ADDR_PHASE: begin
         load_shift_n = 0;
         if(&bit_cnt[2:0])
           if (`ALTERNATE_READ && rd_not_write_reg)
             if (AddressPhase)
               nextstate = ALMOST_READY;
             else
               nextstate = DECIDE;
           else
            nextstate = ADDR_TO_DATA_GAP;
         else
          nextstate = ADDR_PHASE;
        end
      ADDR_TO_DATA_GAP: begin
          load_shift_n = 1;
          nextstate = ADDR_TO_DATA_GAP2;
        end
      ADDR_TO_DATA_GAP2: begin
         load_shift_n = 1;
         nextstate = ADDR_TO_DATA_GAP3;
        end
      ADDR_TO_DATA_GAP3: begin
         load_shift_n = 1;
         nextstate = DATA_PHASE;
        end
      DATA_PHASE: begin
         load_shift_n = 0;
         if(&bit_cnt)
            nextstate = ALMOST_READY;
         else
          nextstate = DATA_PHASE;
        end
      ALMOST_READY: begin
         load_shift_n = 0;
         nextstate = ALMOST_READY2;
         end
      ALMOST_READY2: begin
         load_shift_n = 0;
         nextstate = ALMOST_READY3;
         end
      ALMOST_READY3: begin
         load_shift_n = 0;
         nextstate = READY;
         end
      default: begin
         load_shift_n = 0;
         nextstate = READY;
       end
    endcase
  end
  always @ (posedge DRP_CLK) begin
    if(sync_rst)
      state <= READY;
    else
      state <= nextstate;
   end
endmodule
