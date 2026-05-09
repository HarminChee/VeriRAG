module        commu_assist(
                           clk,
                           rst,
                           req_flit_in,  
                           req_rdy,    
                           req_ctrl_in, 
                           rep_flit_in,  
                           rep_rdy,    
                           rep_ctrl_in,
                           ack_rep,   
                           ack_req,   
                           OUT_req_rdy, 
                           OUT_rep_rdy, 
                           OUT_req_ctrl, 
                           OUT_req_flit, 
                           OUT_req_ack,  
                           OUT_rep_ctrl, 
                           OUT_rep_flit,
                           OUT_rep_ack,
                           v_flits_2_ic_req, 
                           flits_2_ic_req,   
                           v_req_i_m_areg,  
                           req_i_m_areg,     
                           v_inst_rep, 
                           inst_data,  
                           dcache_done_access, 
                           flits_dcache,    
                           v_flits_dcache,   
                           v_cpu_access, 
                           cpu_head,    
                           cpu_addr,   
                           cpu_data,   
                           ack_m_donwload,      
                           ack_d_m_donwload,    
                           ack_i_m_donwload,    
                           mem_access_done,
                           mem_ic_download,     
                           v_mem_ic_download,   
                           mem_m_d_areg,        
                           v_mem_m_d_areg,      
                           mem_m_req,          
                           v_mem_m_req,
                           mem_m_rep,
                           v_mem_m_rep,        
                           en_m_flits_max_rep,
                           m_flits_max_rep,
                           en_m_flits_max_req,
                           m_flits_max_req,
                           en_inv_ids,
                           inv_ids_in,
                           v_m_download,       
                           m_donwload,         
                           v_d_m_areg,         
                           d_m_areg,           
                           v_i_m_areg,
                           i_m_areg,
                           ic_download_fsm_state,  
                           m_d_areg_fsm_state,     
                           m_rep_fsm_state,
                           m_req_fsm_state,
                           dcache_d_m_areg,      
                           v_dcache_d_m_areg,     
                           dcache_dc_req,        
                           v_dcache_dc_req,      
                           dcache_dc_rep,        
                           v_dcache_dc_rep,
                           en_dc_flits_max_rep,
                           dc_flits_max_rep,
                           d_m_areg_fsm_state,    
                           dc_req_fsm_state,
                           dc_rep_fsm_state
                           ); 
          input                       clk;
          input                       rst;
          input      [15:0]           req_flit_in;  
          input                       req_rdy;  
          input      [1:0]            req_ctrl_in; 
          input      [15:0]           rep_flit_in;  
          input                       rep_rdy;
          input      [1:0]            rep_ctrl_in;
          output                      ack_rep;
          output                      ack_req; 
          input                       OUT_req_rdy; 
          input                       OUT_rep_rdy;
          output    [1:0]             OUT_req_ctrl;                               
          output    [15:0]            OUT_req_flit; 
          output                      OUT_req_ack; 
          output    [1:0]             OUT_rep_ctrl; 
          output    [15:0]            OUT_rep_flit;
          output                      OUT_rep_ack;
          input                       v_flits_2_ic_req; 
          input     [47:0]            flits_2_ic_req; 
          input                       v_req_i_m_areg; 
          input     [31:0]            req_i_m_areg;
          output                      v_inst_rep; 
          output    [127:0]            inst_data; 
          input                       dcache_done_access; 
          output    [143:0]           flits_dcache;
          output                      v_flits_dcache;  
          input                       v_cpu_access;
          input     [3:0]             cpu_head;  
          input     [31:0]            cpu_addr;   
          input     [31:0]            cpu_data;   
          input                       ack_m_donwload;    
          input                       ack_d_m_donwload;    
          input                       ack_i_m_donwload; 
          input                       mem_access_done;  
          input     [127:0]           mem_ic_download;     
          input                       v_mem_ic_download;  
          input     [143:0]           mem_m_d_areg;       
          input                       v_mem_m_d_areg;      
          input     [47:0]            mem_m_req;        
          input                       v_mem_m_req;
          input     [143:0]           mem_m_rep;
          input                       v_mem_m_rep;  
          input                       en_m_flits_max_rep;
          input     [3:0]             m_flits_max_rep;
          input                       en_m_flits_max_req;
          input     [1:0]             m_flits_max_req; 
          input                       en_inv_ids;               
          input                       inv_ids_in;
           output                     v_m_download;       
           output    [175:0]          m_donwload;         
           output                     v_d_m_areg;         
           output    [175:0]          d_m_areg;         
           output                     v_i_m_areg;
           output    [47:0]           i_m_areg;
           output    [1:0]            ic_download_fsm_state; 
           output                     m_d_areg_fsm_state; 
           output                     m_rep_fsm_state;
           output    [1:0]            m_req_fsm_state;
           input     [175:0]          dcache_d_m_areg;       
           input                      v_dcache_d_m_areg;    
           input     [47:0]           dcache_dc_req;       
           input                      v_dcache_dc_req;      
           input     [175:0]          dcache_dc_rep;        
           input                      v_dcache_dc_rep;
           input                      en_dc_flits_max_rep;
           input     [3:0]            dc_flits_max_rep;
           output                d_m_areg_fsm_state;    
           output                dc_req_fsm_state;
           output                dc_rep_fsm_state;
wire         ack_req;
wire         ack_rep;
wire         v_ic_net;
wire [15:0]  flit_ic_net;
wire [1:0]   ctrl_ic_net;
wire         v_dc_net;
wire [15:0]  flit_dc_net;
wire [1:0]   ctrl_dc_net;
wire         v_mem_net;
wire [15:0]  flit_mem_net;
wire [1:0]   ctrl_mem_net;
wire [143:0] flits_dcache_abter;
wire         v_flits_dcache_abter;
wire         re_dc_download_flits;
wire         re_cpu_access_flits;
wire         re_m_d_areg_flits;
wire         cpu_done_access;
wire         dc_download_done_access;
wire         m_d_areg_done_access;
wire  ack_m_download_net;
wire  ack_d_m_areg_net;
wire  ack_i_m_areg_net;
wire  v_m_download_m_net;
wire  v_d_m_areg_m_net;
wire  v_i_m_areg_m_net; 
wire       OUT_rep_ack;
wire       ack_dc_rep_net;
wire       ack_mem_rep_net;
wire [1:0] select2_net;
wire       OUT_req_ack;
wire       ack_ic_req_net;
wire       ack_dc_req_net;
wire       ack_mem_req_net;
wire [1:0] select3_net  ;
wire [1:0]   ic_download_state_net;
wire         v_inst_rep;
wire         v_flits_dcache;
wire [143:0] flits_dcache;
wire [1:0]   dc_download_state_net;
wire         v_m_download;
wire [175:0] m_donwload;
wire [1:0]   mem_download_state_net;
wire [143:0] m_d_areg_flits_net;
wire         v_m_d_areg_flits_net;
wire         m_d_areg_fsm_state;
wire [175:0] d_m_areg;
wire         v_d_m_areg;
wire         d_m_areg_fsm_state;
wire [47:0] i_m_areg;
wire        v_i_m_areg;
wire  [15:0]  m_rep_flit_net;
wire          v_m_rep_flit_net;
wire          m_rep_fsm_state;
wire [1:0]    m_rep_ctrl_net;
wire [15:0] dc_rep_flit_net;
wire        v_dc_rep_flit_net;
wire        dc_rep_fsm_state;
wire [1:0]  dc_rep_ctrl_net;
wire [15:0] ic_req_flit_net;
wire        v_ic_req_flit_net;                       
wire [1:0]  ic_download_fsm_state;
wire [1:0]  ic_req_ctrl_net;
wire [1:0]  m_req_ctrl_net;
wire [15:0] m_req_flit_net;
wire [1:0]  m_req_fsm_state;
wire        v_m_req_flit_net;
wire  [15:0] dc_req_flit_net;
wire         v_dc_req_flit_net;
wire         dc_req_fsm_state;
wire  [1:0]  dc_req_ctrl_net;  
reg  [15:0]  OUT_req_flit;
reg  [1:0]   OUT_req_ctrl;
always@(*)
begin
  case(select3_net)
  3'b001:
     begin
	  OUT_req_ctrl=m_req_ctrl_net;
	  OUT_req_flit=m_req_flit_net;
	  end
  3'b010:
     begin
	  OUT_req_ctrl=dc_req_ctrl_net;
     OUT_req_flit=dc_req_flit_net;
	  end
  3'b100:
     begin
	  OUT_req_ctrl=ic_req_ctrl_net;
     OUT_req_flit=ic_req_flit_net;
	  end
	default:
     begin
	  OUT_req_ctrl=2'b00;
     OUT_req_flit=ic_req_ctrl_net;
	  end
	endcase
end
reg  [15:0]  OUT_rep_flit;
reg  [1:0]   OUT_rep_ctrl;
always@(*)
begin
  case(select2_net)
  2'b01:
     begin
	  OUT_rep_ctrl=dc_rep_ctrl_net;
     OUT_rep_flit=dc_rep_flit_net;
	  end
  2'b10:
     begin
	  OUT_rep_ctrl=m_rep_ctrl_net;
     OUT_rep_flit=m_rep_flit_net;
	  end
	default:
     begin
	  OUT_rep_ctrl=2'b00;
     OUT_rep_flit=m_rep_flit_net;
	  end
	endcase
end
  arbiter_IN_node    arbiter_IN_node_dut(
                           .clk(clk),
                           .rst(rst),
                           .in_req_rdy(req_rdy),
                           .in_rep_rdy(rep_rdy),
                           .req_ctrl_in(req_ctrl_in),
                           .rep_ctrl_in(rep_ctrl_in),
                           .req_flit_in(req_flit_in),
                           .rep_flit_in(rep_flit_in),
                           .ic_download_state_in(ic_download_state_net),  
                           .dc_download_state_in(dc_download_state_net),  
                           .mem_download_state_in(mem_download_state_net), 
                           .ack_req(ack_req),    
                           .ack_rep(ack_rep),    
                           .v_ic(v_ic_net),      
                           .flit_ic(flit_ic_net), 
                           .ctrl_ic(ctrl_ic_net),
                           .v_dc(v_dc_net),       
                           .flit_dc(flit_dc_net),
                           .ctrl_dc(ctrl_dc_net),
                           .v_mem(v_mem_net),      
                           .flit_mem(flit_mem_net),
                           .ctrl_mem(ctrl_mem_net)
                           );    
arbiter_for_dcache      arbiter_for_dcache_dut (
                              .clk(clk),
                              .rst(rst),
                              .dcache_done_access(dcache_done_access),  
                              .v_dc_download(v_flits_dcache),       
                              .dc_download_flits(flits_dcache),
                              .v_cpu(v_cpu_access),                    
                              .cpu_access_flits({cpu_head,cpu_addr,cpu_data}),
                              .v_m_d_areg(v_m_d_areg_flits_net),             
                              .m_d_areg_flits(m_d_areg_flits_net),
                              .flits_dc(flits_dcache_abter),                  
                              .v_flits_dc(v_flits_dcache_abter),
                              .re_dc_download_flits(re_dc_download_flits),  
                              .re_cpu_access_flits(re_cpu_access_flits),    
                              .re_m_d_areg_flits(re_m_d_areg_flits),        
                              .cpu_done_access(cpu_done_access),            
                              .dc_download_done_access(dc_download_done_access),
                              .m_d_areg_done_access(m_d_areg_done_access)
                              );     
  arbiter_for_mem    arbiter_for_mem_dut(
                            .clk(clk),
                            .rst(rst),
                            .v_mem_download(v_m_download),  
                            .v_d_m_areg(v_d_m_areg),          
                            .v_i_m_areg(v_i_m_areg),          
                            .mem_access_done(mem_access_done),    
                            .ack_m_download(ack_m_download_net),  
                            .ack_d_m_areg(ack_d_m_areg_net),      
                            .ack_i_m_areg(ack_i_m_areg_net), 
                            .v_m_download_m(v_m_download_m_net),   
                            .v_d_m_areg_m(v_d_m_areg_m_net),
                            .v_i_m_areg_m(v_i_m_areg_m_net)
                            );    
 arbiter_for_OUT_rep   arbiter_for_OUT_rep_dut(
                               .clk(clk),
                               .rst(rst),
                               .OUT_rep_rdy(OUT_rep_rdy),    
                               .v_dc_rep(v_dc_rep_flit_net),  
                               .v_mem_rep(v_m_rep_flit_net),  
                               .dc_rep_flit(dc_rep_flit_net), 
                               .mem_rep_flit(m_rep_flit_net),
                               .dc_rep_ctrl(dc_rep_ctrl_net),
                               .mem_rep_ctrl(m_rep_ctrl_net),
                               .ack_OUT_rep(OUT_rep_ack),     
                               .ack_dc_rep(ack_dc_rep_net),   
                               .ack_mem_rep(ack_mem_rep_net),  
                               .select(select2_net)  
                               );
arbiter_for_OUT_req   arbiter_for_OUT_req_dut(
                               .clk(clk),
                               .rst(rst),
                               .OUT_req_rdy(OUT_req_rdy),       
                               .v_ic_req(v_ic_req_flit_net),    
                               .v_dc_req(v_dc_req_flit_net),    
                               .v_mem_req(v_m_req_flit_net),    
                               .ic_req_ctrl(ic_req_ctrl_net),
                               .dc_req_ctrl(dc_req_ctrl_net),
                               .mem_req_ctrl(m_req_ctrl_net),
                               .ack_OUT_req(OUT_req_ack),       
                               .ack_ic_req(ack_ic_req_net),     
                               .ack_dc_req(ack_dc_req_net),     
                               .ack_mem_req(ack_mem_req_net),   
                               .select(select3_net)
                               );
 ic_download      ic_download_dut(
                    .clk(clk),
                    .rst(rst),
                    .rep_flit_ic(flit_ic_net),           
                    .v_rep_flit_ic(v_ic_net),
                    .rep_ctrl_ic(ctrl_ic_net),
                    .mem_flits_ic(mem_ic_download),      
                    .v_mem_flits_ic(v_mem_ic_download),
                    .ic_download_state(ic_download_state_net), 
                    .inst_word_ic(inst_data),                  
                    .v_inst_word(v_inst_rep)                   
                    );        
 dc_download   dc_download_dut(
                    .clk(clk),
                    .rst(rst),
                    .IN_flit_dc(flit_dc_net),    
                    .v_IN_flit_dc(v_dc_net),    
                    .In_flit_ctrl_dc(ctrl_dc_net),
                    .dc_done_access(dcache_done_access), 
                    .v_dc_download(v_flits_dcache),      
                    .dc_download_flits(flits_dcache),
                    .dc_download_state(dc_download_state_net) 
                   );        
 m_download      m_download_dut(
                    .clk(clk),
                    .rst(rst),
                    .IN_flit_mem(flit_mem_net),  
                    .v_IN_flit_mem(v_mem_net),
                    .In_flit_ctrl(ctrl_mem_net),
                    .mem_done_access(mem_access_done),  
                    .v_m_download(v_m_download),    
                    .m_download_flits(m_donwload),
                    .m_download_state(mem_download_state_net) 
                    );         
  m_d_areg       m_d_areg_dut(
                   .clk(clk),
                   .rst(rst),
                   .m_flits_d(mem_m_d_areg),  
                   .v_m_flits_d(v_mem_m_d_areg),
                   .dc_done_access(dcache_done_access), 
                   .m_d_areg_flits(m_d_areg_flits_net),  
                   .v_m_d_areg_flits(v_m_d_areg_flits_net),
                   .m_d_areg_state( m_d_areg_fsm_state)  
                   );           
 d_m_areg      d_m_areg_dut(
                   .clk(clk),               
                   .rst(rst),
                   .d_flits_m(dcache_d_m_areg),    
                   .v_d_flits_m(v_dcache_d_m_areg), 
                   .mem_done_access(mem_access_done), 
                   .d_m_areg_flits(d_m_areg),      
                   .v_d_m_areg_flits(v_d_m_areg),
                   .d_m_areg_state(d_m_areg_fsm_state)  
                   );           
 i_m_areg       i_m_areg_dut(
                   .clk(clk),
                   .rst(rst),
                   .i_flits_m(req_i_m_areg),  
                   .v_i_flits_m(v_req_i_m_areg),
                   .mem_done_access(mem_access_done), 
                   .i_m_areg_flits(i_m_areg),   
                   .v_i_areg_m_flits(v_i_m_areg)
                   );           
  m_rep_upload     m_rep_upload_dut (
                        .clk(clk),
                        .rst(rst),
                        .m_flits_rep(mem_m_rep),  
                        .v_m_flits_rep(v_mem_m_rep),
                        .flits_max(m_flits_max_rep),
                        .en_flits_max(en_m_flits_max_rep),
                        .rep_fifo_rdy(ack_mem_rep_net),  
                        .m_flit_out(m_rep_flit_net),   
                        .v_m_flit_out(v_m_rep_flit_net),
								.m_ctrl_out(m_rep_ctrl_net),
                        .m_rep_upload_state(m_rep_fsm_state) 
                        );       
 dc_rep_upload        dc_rep_upload_dut(
                          .clk(clk),
                          .rst(rst),
                          .dc_flits_rep(dcache_dc_rep), 
                          .v_dc_flits_rep(v_dcache_dc_rep),
                          .flits_max(dc_flits_max_rep),
                          .en_flits_max(en_dc_flits_max_rep),
                          .rep_fifo_rdy(ack_dc_rep_net),  
                          .dc_flit_out(dc_rep_flit_net),  
                          .v_dc_flit_out(v_dc_rep_flit_net),
								  .dc_ctrl_out(dc_rep_ctrl_net),
                          .dc_rep_upload_state(dc_rep_fsm_state) 
                          );      
 ic_req_upload     ic_req_upload_dut(
                         .clk(clk),
                         .rst(rst),
                         .ic_flits_req(flits_2_ic_req),
                         .v_ic_flits_req(v_flits_2_ic_req),
                         .ic_flit_out(ic_req_flit_net),  
                         .v_ic_flit_out(v_ic_req_flit_net),
								 .ic_ctrl_out(ic_req_ctrl_net),
                         .ic_req_upload_state(ic_download_fsm_state) 
                         );      
 m_req_upload      m_req_upload_dut(
                             .clk(clk),
                             .rst(rst),
                             .v_flits_in(v_mem_m_req), 
                             .out_req_fifo_rdy_in(ack_mem_req_net), 
                             .en_inv_ids(en_inv_ids),               
                             .inv_ids_in(inv_ids_in),
                             .flits_max_in(m_flits_max_req),
                             .head_flit(mem_m_req[47:32]),
                             .addrhi(mem_m_req[31:16]),
                             .addrlo(mem_m_req[15:0]),
                             .ctrl_out(m_req_ctrl_net),     
                             .flit_out(m_req_flit_net),
                             .fsm_state(m_req_fsm_state),     
                             .v_flit_to_req_fifo(v_m_req_flit_net)  
                             );       
dc_req_upload      dc_req_upload_dut(
                          .clk(clk),
                          .rst(rst),
                          .dc_flits_req(dcache_dc_req),  
                          .v_dc_flits_req(v_dcache_dc_req),
                          .req_fifo_rdy(ack_dc_req_net),  
                          .dc_flit_out(dc_req_flit_net),  
                          .v_dc_flit_out(v_dc_req_flit_net),
								  .dc_ctrl_out(dc_req_ctrl_net),
                          .dc_req_upload_state(dc_req_fsm_state)   
                          );      
endmodule
