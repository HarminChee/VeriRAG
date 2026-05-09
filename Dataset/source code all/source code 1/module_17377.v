module nf2_dma_que_intfc
  #( parameter NUM_CPU_QUEUES = 4,
     parameter DMA_DATA_WIDTH = 32,
     parameter DMA_CTRL_WIDTH=DMA_DATA_WIDTH/8,
     parameter USER_DATA_PATH_WIDTH=64,
     parameter CPCI_NF2_DATA_WIDTH=32
     )
   (
    output reg cpu_q_dma_rd_0,
    input [DMA_DATA_WIDTH-1:0] cpu_q_dma_rd_data_0, 
    input [DMA_CTRL_WIDTH-1:0] cpu_q_dma_rd_ctrl_0,
    output reg cpu_q_dma_rd_1,
    input [DMA_DATA_WIDTH-1:0] cpu_q_dma_rd_data_1, 
    input [DMA_CTRL_WIDTH-1:0] cpu_q_dma_rd_ctrl_1,
    output reg cpu_q_dma_rd_2,
    input [DMA_DATA_WIDTH-1:0] cpu_q_dma_rd_data_2, 
    input [DMA_CTRL_WIDTH-1:0] cpu_q_dma_rd_ctrl_2,
    output reg cpu_q_dma_rd_3,
    input [DMA_DATA_WIDTH-1:0] cpu_q_dma_rd_data_3, 
    input [DMA_CTRL_WIDTH-1:0] cpu_q_dma_rd_ctrl_3,
    input [NUM_CPU_QUEUES-1:0] cpu_q_dma_nearly_full,
    output reg cpu_q_dma_wr_0,
    output reg [DMA_DATA_WIDTH-1:0] cpu_q_dma_wr_data_0, 
    output reg [DMA_CTRL_WIDTH-1:0] cpu_q_dma_wr_ctrl_0,
    output reg cpu_q_dma_wr_1,
    output reg [DMA_DATA_WIDTH-1:0] cpu_q_dma_wr_data_1, 
    output reg [DMA_CTRL_WIDTH-1:0] cpu_q_dma_wr_ctrl_1,
    output reg cpu_q_dma_wr_2,
    output reg [DMA_DATA_WIDTH-1:0] cpu_q_dma_wr_data_2, 
    output reg [DMA_CTRL_WIDTH-1:0] cpu_q_dma_wr_ctrl_2,
    output reg cpu_q_dma_wr_3,
    output reg [DMA_DATA_WIDTH-1:0] cpu_q_dma_wr_data_3, 
    output reg [DMA_CTRL_WIDTH-1:0] cpu_q_dma_wr_ctrl_3,
    input txfifo_empty,
    input [DMA_DATA_WIDTH +3:0] txfifo_rd_data,
    output reg txfifo_rd_inc,
    input rxfifo_full,
    input rxfifo_nearly_full, 
    output reg rxfifo_wr,
    output reg [DMA_DATA_WIDTH +2:0] rxfifo_wr_data,
    input        enable_dma,
    input        reset,
    input        clk
    );
   reg [3:0] queue_id, queue_id_nxt; 
   reg [DMA_DATA_WIDTH-1:0]    dma_wr_data;
   reg [DMA_CTRL_WIDTH-1:0]    dma_wr_ctrl;
   reg 			       dma_rd_vld, dma_rd_vld_nxt;
   reg [DMA_DATA_WIDTH-1:0]    dma_rd_data;
   reg [DMA_CTRL_WIDTH-1:0]    dma_rd_ctrl;
   reg 			       cpu_q_dma_wr_0_nxt;
   reg [DMA_DATA_WIDTH-1:0]    cpu_q_dma_wr_data_0_nxt; 
   reg [DMA_CTRL_WIDTH-1:0]    cpu_q_dma_wr_ctrl_0_nxt;
   reg 			       cpu_q_dma_wr_1_nxt;
   reg [DMA_DATA_WIDTH-1:0]    cpu_q_dma_wr_data_1_nxt; 
   reg [DMA_CTRL_WIDTH-1:0]    cpu_q_dma_wr_ctrl_1_nxt;
   reg 			       cpu_q_dma_wr_2_nxt;
   reg [DMA_DATA_WIDTH-1:0]    cpu_q_dma_wr_data_2_nxt; 
   reg [DMA_CTRL_WIDTH-1:0]    cpu_q_dma_wr_ctrl_2_nxt;
   reg 			       cpu_q_dma_wr_3_nxt;
   reg [DMA_DATA_WIDTH-1:0]    cpu_q_dma_wr_data_3_nxt; 
   reg [DMA_CTRL_WIDTH-1:0]    cpu_q_dma_wr_ctrl_3_nxt;
   reg [3:0] align_cnt, align_cnt_nxt;
   wire [3:0] align_cnt_plus_1 = 
	      ((align_cnt+'h 1)==(USER_DATA_PATH_WIDTH / DMA_DATA_WIDTH)) ?
	      'h 0 : align_cnt+'h 1;
   reg [2:0] state, state_nxt;
   parameter IDLE_STATE = 3'h 0,
	     TX_STATE = 3'h 1,
	     TX_PAD_STATE = 3'h 2,
	     RX_STATE = 3'h 3,
	     RX_PAD_STATE = 3'h 4;
   always @(*) begin
      state_nxt = state;
      queue_id_nxt = queue_id;
      dma_rd_vld_nxt = 1'b 0;
      align_cnt_nxt = align_cnt;
      txfifo_rd_inc = 1'b 0;
      dma_wr_ctrl = 'h 0;
      dma_wr_data = 'h 0;
      cpu_q_dma_wr_0_nxt = 1'b 0;
      cpu_q_dma_wr_data_0_nxt = 'h 0;
      cpu_q_dma_wr_ctrl_0_nxt = 'h 0;
      cpu_q_dma_wr_1_nxt = 1'b 0;
      cpu_q_dma_wr_data_1_nxt = 'h 0;
      cpu_q_dma_wr_ctrl_1_nxt = 'h 0;
      cpu_q_dma_wr_2_nxt = 1'b 0;
      cpu_q_dma_wr_data_2_nxt = 'h 0;
      cpu_q_dma_wr_ctrl_2_nxt = 'h 0;
      cpu_q_dma_wr_3_nxt = 1'b 0;
      cpu_q_dma_wr_data_3_nxt = 'h 0;
      cpu_q_dma_wr_ctrl_3_nxt = 'h 0;
      cpu_q_dma_rd_0 = 1'b 0;
      cpu_q_dma_rd_1 = 1'b 0;
      cpu_q_dma_rd_2 = 1'b 0;
      cpu_q_dma_rd_3 = 1'b 0;
      dma_rd_data = 'h 0;
      dma_rd_ctrl = 'h 0;
      rxfifo_wr = 1'b 0;
      rxfifo_wr_data = 'h 0;
      case (state)
	IDLE_STATE:
	  if (enable_dma) begin
	   if (! txfifo_empty) begin
	      txfifo_rd_inc = 1'b 1;
	      case (txfifo_rd_data[DMA_DATA_WIDTH +3])
		1'b 0: begin 
		   #1 if (txfifo_rd_data[DMA_DATA_WIDTH +3]) begin
		      $display("%t %m ERROR: expect req format, but got data format!", $time);
		   end
		end
		1'b 1: begin
		   align_cnt_nxt = 'h 0;
		   queue_id_nxt = txfifo_rd_data;
		   case (txfifo_rd_data[DMA_DATA_WIDTH +2])
		     1'b 0: begin
			state_nxt = TX_STATE;
		     end
		     1'b 1: begin
			state_nxt = RX_STATE;
		     end
  	           endcase 
		end 
	      endcase 
	   end 
	  end 
	TX_STATE:
	  if (! txfifo_empty) begin
	     case (txfifo_rd_data[DMA_DATA_WIDTH +2])
	       1'b 0: 
		 dma_wr_ctrl = 'b 0;
	       1'b 1: begin 
		  case (txfifo_rd_data[DMA_DATA_WIDTH +1:DMA_DATA_WIDTH])
		    2'b 00:
		      dma_wr_ctrl = 'b 1000;
		    2'b 01:
		      dma_wr_ctrl = 'b 0001;
		    2'b 10:
		      dma_wr_ctrl = 'b 0010;
		    2'b 11:
		      dma_wr_ctrl = 'b 0100;
		  endcase
	       end 
	     endcase 
	     dma_wr_data = txfifo_rd_data[DMA_DATA_WIDTH -1:0];
	     case (queue_id)
	       4'h 0: 
		  if (! cpu_q_dma_nearly_full[0]) begin
		     txfifo_rd_inc = 1'b 1;
		     cpu_q_dma_wr_0_nxt = 1'b 1;
		     cpu_q_dma_wr_data_0_nxt = dma_wr_data;
		     cpu_q_dma_wr_ctrl_0_nxt = dma_wr_ctrl;
		     align_cnt_nxt = align_cnt_plus_1;
		     if (| dma_wr_ctrl) begin 
			if (align_cnt_nxt != 'h 0)
			  state_nxt = TX_PAD_STATE;
			else 
			  state_nxt = IDLE_STATE;
		     end
		  end
		4'h 1: 
		   if (! cpu_q_dma_nearly_full[1]) begin 
		     txfifo_rd_inc = 1'b 1;
		     cpu_q_dma_wr_1_nxt = 1'b 1;
		     cpu_q_dma_wr_data_1_nxt = dma_wr_data;
		     cpu_q_dma_wr_ctrl_1_nxt = dma_wr_ctrl;
		     align_cnt_nxt = align_cnt_plus_1;
		     if (| dma_wr_ctrl) begin 
			if (align_cnt_nxt != 'h 0)
			  state_nxt = TX_PAD_STATE;
			else 
			  state_nxt = IDLE_STATE;
		     end
		   end
	       4'h 2: 
		  if (! cpu_q_dma_nearly_full[2]) begin 
		     txfifo_rd_inc = 1'b 1;
		     cpu_q_dma_wr_2_nxt = 1'b 1;
		     cpu_q_dma_wr_data_2_nxt = dma_wr_data;
		     cpu_q_dma_wr_ctrl_2_nxt = dma_wr_ctrl;
		     align_cnt_nxt = align_cnt_plus_1;
		     if (| dma_wr_ctrl) begin 
			if (align_cnt_nxt != 'h 0)
			  state_nxt = TX_PAD_STATE;
			else 
			  state_nxt = IDLE_STATE;
		     end
		  end
		4'h 3: 
		   if (! cpu_q_dma_nearly_full[3]) begin 
		     txfifo_rd_inc = 1'b 1;
		     cpu_q_dma_wr_3_nxt = 1'b 1;
		     cpu_q_dma_wr_data_3_nxt = dma_wr_data;
		     cpu_q_dma_wr_ctrl_3_nxt = dma_wr_ctrl;
		     align_cnt_nxt = align_cnt_plus_1;
		     if (| dma_wr_ctrl) begin 
			if (align_cnt_nxt != 'h 0)
			  state_nxt = TX_PAD_STATE;
			else 
			  state_nxt = IDLE_STATE;
		     end
		   end
	       default: begin
		  txfifo_rd_inc = 1'b 1;
		  if (| dma_wr_ctrl) state_nxt = IDLE_STATE;
	       end
	     endcase 
	  end 
	TX_PAD_STATE: begin
	     case (queue_id)
	       4'h 0: 
		  if (! cpu_q_dma_nearly_full[0]) begin
		     cpu_q_dma_wr_0_nxt = 1'b 1;
		     align_cnt_nxt = align_cnt_plus_1;
		     if (align_cnt_nxt == 'h 0)
		       state_nxt = IDLE_STATE;
		  end
		4'h 1: 
		   if (! cpu_q_dma_nearly_full[1]) begin 
		     cpu_q_dma_wr_1_nxt = 1'b 1;
		     align_cnt_nxt = align_cnt_plus_1;
		      if (align_cnt_nxt == 'h 0)
			state_nxt = IDLE_STATE;
		   end
	       4'h 2: 
		  if (! cpu_q_dma_nearly_full[2]) begin 
		     cpu_q_dma_wr_2_nxt = 1'b 1;
		     align_cnt_nxt = align_cnt_plus_1;
		     if (align_cnt_nxt == 'h 0)
		       state_nxt = IDLE_STATE;
		  end
		4'h 3: 
		   if (! cpu_q_dma_nearly_full[3]) begin 
		     cpu_q_dma_wr_3_nxt = 1'b 1;
		     align_cnt_nxt = align_cnt_plus_1;
		      if (align_cnt_nxt == 'h 0)
			state_nxt = IDLE_STATE;
		   end
	     endcase 
	end 
	RX_STATE: begin
	   if (!rxfifo_nearly_full) begin
	      case (queue_id)
		4'h 0: cpu_q_dma_rd_0 = 1'b 1;
		4'h 1: cpu_q_dma_rd_1 = 1'b 1;
		4'h 2: cpu_q_dma_rd_2 = 1'b 1;
		4'h 3: cpu_q_dma_rd_3 = 1'b 1;
	      endcase 
	      align_cnt_nxt = align_cnt_plus_1;
	      case (queue_id)
		4'h 0: begin 
		   dma_rd_data = cpu_q_dma_rd_data_0;
		   dma_rd_ctrl = cpu_q_dma_rd_ctrl_0;
		end
		4'h 1: begin 
		   dma_rd_data = cpu_q_dma_rd_data_1;
		   dma_rd_ctrl = cpu_q_dma_rd_ctrl_1;
		end
		4'h 2: begin 
		   dma_rd_data = cpu_q_dma_rd_data_2;
		   dma_rd_ctrl = cpu_q_dma_rd_ctrl_2;
		end
		4'h 3: begin 
		   dma_rd_data = cpu_q_dma_rd_data_3;
		   dma_rd_ctrl = cpu_q_dma_rd_ctrl_3;
		end
	      endcase 
	      rxfifo_wr = 1'b 1;
	      rxfifo_wr_data[DMA_DATA_WIDTH -1:0] = dma_rd_data;
	      if (dma_rd_ctrl == 'h 0) begin 
		 rxfifo_wr_data[DMA_DATA_WIDTH +2]=1'b 0;
		 rxfifo_wr_data[DMA_DATA_WIDTH +1:DMA_DATA_WIDTH]=2'b 0;
	      end
	      else begin 
		 rxfifo_wr_data[DMA_DATA_WIDTH +2]=1'b 1;
		 case (dma_rd_ctrl)
		   'b 0001: 
		     rxfifo_wr_data[DMA_DATA_WIDTH +1:DMA_DATA_WIDTH]=2'h 1;
		   'b 0010: 
		     rxfifo_wr_data[DMA_DATA_WIDTH +1:DMA_DATA_WIDTH]=2'h 2;
		   'b 0100: 
		     rxfifo_wr_data[DMA_DATA_WIDTH +1:DMA_DATA_WIDTH]=2'h 3;
		   'b 1000: 
		     rxfifo_wr_data[DMA_DATA_WIDTH +1:DMA_DATA_WIDTH]=2'h 0;
		   default:
		     rxfifo_wr_data[DMA_DATA_WIDTH +1:DMA_DATA_WIDTH]=2'h 0;
		 endcase 
		 if (align_cnt_nxt != 'h 0)
		   state_nxt = RX_PAD_STATE;
		 else 
		   state_nxt = IDLE_STATE;
	      end 
	   end 
	end 
	RX_PAD_STATE: begin
	   case (queue_id)
	     4'h 0: cpu_q_dma_rd_0 = 1'b 1;
	     4'h 1: cpu_q_dma_rd_1 = 1'b 1;
	     4'h 2: cpu_q_dma_rd_2 = 1'b 1;
	     4'h 3: cpu_q_dma_rd_3 = 1'b 1;
	   endcase 
	   align_cnt_nxt = align_cnt_plus_1;
	   if (align_cnt_nxt == 'h 0)
             state_nxt = IDLE_STATE;
	end 
      endcase 
   end 
   parameter 
     DMA_QUE_WR_IDLE_STATE = 'h 0,
     DMA_QUE_WR_PAD_STATE = 'h 1;
   reg dma_que_wr_state, dma_que_wr_state_nxt;
   reg [3:0] dma_que_wr_align_cnt, dma_que_wr_align_cnt_nxt;
   reg [3:0] dma_que_wr_queue_id, dma_que_wr_queue_id_nxt;
   wire [3:0] dma_que_wr_align_cnt_plus_1 = 
	      ((dma_que_wr_align_cnt+'h 1)==(USER_DATA_PATH_WIDTH/DMA_DATA_WIDTH)) ?
	      'h 0 : dma_que_wr_align_cnt + 'h 1;
   always @(posedge clk) begin
     if (reset) begin
	state <= IDLE_STATE;
	queue_id <= 'h 0;
	dma_rd_vld <= 'h 0;
	align_cnt <= 'h 0;
	dma_que_wr_state <= DMA_QUE_WR_IDLE_STATE;
	dma_que_wr_align_cnt <= 'h 0;
	dma_que_wr_queue_id <= 'h 0;
	cpu_q_dma_wr_0 <= 1'b 0;
	cpu_q_dma_wr_data_0 <= 'h 0;
	cpu_q_dma_wr_ctrl_0 <= 'h 0;
	cpu_q_dma_wr_1 <= 1'b 0;
	cpu_q_dma_wr_data_1 <= 'h 0;
	cpu_q_dma_wr_ctrl_1 <= 'h 0;
	cpu_q_dma_wr_2 <= 1'b 0;
	cpu_q_dma_wr_data_2 <= 'h 0;
	cpu_q_dma_wr_ctrl_2 <= 'h 0;
	cpu_q_dma_wr_3 <= 1'b 0;
	cpu_q_dma_wr_data_3 <= 'h 0;
	cpu_q_dma_wr_ctrl_3 <= 'h 0;
     end
     else begin
	state <= state_nxt;
	queue_id <= queue_id_nxt;
	dma_rd_vld <= dma_rd_vld_nxt;
	align_cnt <= align_cnt_nxt;
	dma_que_wr_state <= dma_que_wr_state_nxt;
	dma_que_wr_align_cnt <= dma_que_wr_align_cnt_nxt;
	dma_que_wr_queue_id <= dma_que_wr_queue_id_nxt;
	cpu_q_dma_wr_0 <= cpu_q_dma_wr_0_nxt;
	cpu_q_dma_wr_data_0 <= cpu_q_dma_wr_data_0_nxt;
	cpu_q_dma_wr_ctrl_0 <= cpu_q_dma_wr_ctrl_0_nxt;
	cpu_q_dma_wr_1 <= cpu_q_dma_wr_1_nxt;
	cpu_q_dma_wr_data_1 <= cpu_q_dma_wr_data_1_nxt;
	cpu_q_dma_wr_ctrl_1 <= cpu_q_dma_wr_ctrl_1_nxt;
	cpu_q_dma_wr_2 <= cpu_q_dma_wr_2_nxt;
	cpu_q_dma_wr_data_2 <= cpu_q_dma_wr_data_2_nxt;
	cpu_q_dma_wr_ctrl_2 <= cpu_q_dma_wr_ctrl_2_nxt;
	cpu_q_dma_wr_3 <= cpu_q_dma_wr_3_nxt;
	cpu_q_dma_wr_data_3 <= cpu_q_dma_wr_data_3_nxt;
	cpu_q_dma_wr_ctrl_3 <= cpu_q_dma_wr_ctrl_3_nxt;
     end
   end 
endmodule 
