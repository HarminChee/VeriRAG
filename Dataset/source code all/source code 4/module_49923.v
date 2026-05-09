`timescale 1ps/1ps
`timescale 1ps/1ps
module PIO #(
  parameter C_DATA_WIDTH = 64,            
  parameter KEEP_WIDTH = C_DATA_WIDTH / 8,              
  parameter TCQ        = 1
)(
  input                         user_clk,
  input                         user_reset,
  input                         user_lnk_up,
  input                         s_axis_tx_tready,
  output  [C_DATA_WIDTH-1:0]    s_axis_tx_tdata,
  output  [KEEP_WIDTH-1:0]      s_axis_tx_tkeep,
  output                        s_axis_tx_tlast,
  output                        s_axis_tx_tvalid,
  output                        tx_src_dsc,
  input  [C_DATA_WIDTH-1:0]     m_axis_rx_tdata,
  input  [KEEP_WIDTH-1:0]       m_axis_rx_tkeep,
  input                         m_axis_rx_tlast,
  input                         m_axis_rx_tvalid,
  output                        m_axis_rx_tready,
  input    [21:0]               m_axis_rx_tuser,
  input                         cfg_to_turnoff,
  output                        cfg_turnoff_ok,
  input [15:0]                  cfg_completer_id
); 
  wire          req_compl;
  wire          compl_done;
  reg           pio_reset_n;
  always @(posedge user_clk) begin
    if (user_reset)
        pio_reset_n <= #TCQ 1'b0;
    else
        pio_reset_n <= #TCQ user_lnk_up;
  end
  PIO_EP  #(
    .C_DATA_WIDTH( C_DATA_WIDTH ),
    .KEEP_WIDTH( KEEP_WIDTH ),
    .TCQ( TCQ )
  ) PIO_EP_inst (
    .clk( user_clk ),                             
    .rst_n( pio_reset_n ),                        
    .s_axis_tx_tready( s_axis_tx_tready ),        
    .s_axis_tx_tdata( s_axis_tx_tdata ),          
    .s_axis_tx_tkeep( s_axis_tx_tkeep ),          
    .s_axis_tx_tlast( s_axis_tx_tlast ),          
    .s_axis_tx_tvalid( s_axis_tx_tvalid ),        
    .tx_src_dsc( tx_src_dsc ),                    
    .m_axis_rx_tdata( m_axis_rx_tdata ),          
    .m_axis_rx_tkeep( m_axis_rx_tkeep ),          
    .m_axis_rx_tlast( m_axis_rx_tlast ),          
    .m_axis_rx_tvalid( m_axis_rx_tvalid ),        
    .m_axis_rx_tready( m_axis_rx_tready ),        
    .m_axis_rx_tuser ( m_axis_rx_tuser ),         
    .req_compl(req_compl),                        
    .compl_done(compl_done),                      
    .cfg_completer_id ( cfg_completer_id )        
  );
  PIO_TO_CTRL #(
    .TCQ( TCQ )
  ) PIO_TO_inst  (
    .clk( user_clk ),                       
    .rst_n( pio_reset_n ),                  
    .req_compl( req_compl ),                
    .compl_done( compl_done ),              
    .cfg_to_turnoff( cfg_to_turnoff ),      
    .cfg_turnoff_ok( cfg_turnoff_ok )       
  );
endmodule 
