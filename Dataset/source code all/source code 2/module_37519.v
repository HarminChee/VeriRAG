module nf2_dma_sync 
  #(parameter DMA_DATA_WIDTH = 32, 
    parameter NUM_CPU_QUEUES = 4)
    (
     output reg [NUM_CPU_QUEUES-1:0] cpci_cpu_q_dma_pkt_avail,
     output reg [NUM_CPU_QUEUES-1:0] cpci_cpu_q_dma_nearly_full, 
     output cpci_txfifo_full,
     output cpci_txfifo_nearly_full, 
     input cpci_txfifo_wr,
     input [DMA_DATA_WIDTH +3:0] cpci_txfifo_wr_data, 
     output cpci_rxfifo_empty,
     input cpci_rxfifo_rd_inc,
     output [DMA_DATA_WIDTH +2:0] cpci_rxfifo_rd_data, 
     input [NUM_CPU_QUEUES-1:0] sys_cpu_q_dma_pkt_avail,
     input [NUM_CPU_QUEUES-1:0] sys_cpu_q_dma_nearly_full, 
     output sys_txfifo_empty,
     output [DMA_DATA_WIDTH +3:0] sys_txfifo_rd_data,
     input sys_txfifo_rd_inc,
     output sys_rxfifo_full,
     output sys_rxfifo_nearly_full, 
     input sys_rxfifo_wr,
     input [DMA_DATA_WIDTH +2:0] sys_rxfifo_wr_data,
     input cpci_clk,
     input cpci_reset,
     input sys_clk,
     input sys_reset
   );
   reg [NUM_CPU_QUEUES-1:0] cpci_sync_cpu_q_dma_pkt_avail;
   reg [NUM_CPU_QUEUES-1:0] cpci_sync_cpu_q_dma_nearly_full;
   always @(posedge cpci_clk)
     if (cpci_reset) begin
	cpci_sync_cpu_q_dma_pkt_avail <= 'h 0;
	cpci_sync_cpu_q_dma_nearly_full <= 'h 0;
	cpci_cpu_q_dma_pkt_avail <= 'h 0;
	cpci_cpu_q_dma_nearly_full <= 'h 0;
     end
     else begin
	cpci_sync_cpu_q_dma_pkt_avail <= sys_cpu_q_dma_pkt_avail;
	cpci_sync_cpu_q_dma_nearly_full <= sys_cpu_q_dma_nearly_full;
	cpci_cpu_q_dma_pkt_avail <= cpci_sync_cpu_q_dma_pkt_avail;
	cpci_cpu_q_dma_nearly_full <= cpci_sync_cpu_q_dma_nearly_full;
     end
   small_async_fifo #(.DSIZE(DMA_DATA_WIDTH +4), 
		      .ASIZE(3), 
		      .ALMOST_FULL_SIZE(5), 
		      .ALMOST_EMPTY_SIZE(3)) 
     tx_async_fifo (
		    .wfull ( cpci_txfifo_full ),
		    .w_almost_full ( cpci_txfifo_nearly_full ),
		    .wdata ( cpci_txfifo_wr_data ),
		    .winc ( cpci_txfifo_wr ), 
		    .wclk ( cpci_clk ), 
		    .wrst_n ( ~cpci_reset ),
		    .rdata ( sys_txfifo_rd_data ),
		    .rempty ( sys_txfifo_empty ),
		    .r_almost_empty (  ),
		    .rinc ( sys_txfifo_rd_inc ), 
		    .rclk ( sys_clk ), 
		    .rrst_n ( ~sys_reset )
		    );
   small_async_fifo #(.DSIZE(DMA_DATA_WIDTH +3), 
		      .ASIZE(3), 
		      .ALMOST_FULL_SIZE(5), 
		      .ALMOST_EMPTY_SIZE(3)) 
     rx_async_fifo (
		    .wfull ( sys_rxfifo_full ),
		    .w_almost_full ( sys_rxfifo_nearly_full ),
		    .wdata ( sys_rxfifo_wr_data ),
		    .winc ( sys_rxfifo_wr ), 
		    .wclk ( sys_clk ), 
		    .wrst_n ( ~sys_reset ),
		    .rdata ( cpci_rxfifo_rd_data ),
		    .rempty ( cpci_rxfifo_empty ),
		    .r_almost_empty (  ),
		    .rinc ( cpci_rxfifo_rd_inc ), 
		    .rclk ( cpci_clk ), 
		    .rrst_n ( ~cpci_reset )
		    );
endmodule 
