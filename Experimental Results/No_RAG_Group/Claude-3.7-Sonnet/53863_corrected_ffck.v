Here is the corrected Verilog code with the FFCKNP error fixed:

`define CFG_FAKECLK   1      
`define CFG_MDW       32     
`define CFG_DW        32     
`define CFG_AW        32     
`define CFG_LW        8      
`define CFG_NW        13     
module e16_clock_divider(
   clk_out, clk_out90,
   clk_in, reset, div_cfg
   );
   input       clk_in;    
   input       reset;
   input [3:0] div_cfg;   
   output      clk_out;   
   output      clk_out90; 
   reg         clk_out_reg;
   reg [5:0]   counter;   
   reg [5:0]   div_cfg_dec;
   wire        div2_sel;   
   wire        posedge_match;
   wire        negedge_match;  
   wire        posedge90_match;
   wire        negedge90_match; 
   wire        clk_out90_div2;
   wire        clk_out90_div4;
   wire        clk_out90_div2_in;
   wire        clk_out90_div4_in;
   always @ (div_cfg[3:0])
     begin
        casez (div_cfg[3:0])
          4'b0000 : div_cfg_dec[5:0] = 6'b000010;  
          4'b0001 : div_cfg_dec[5:0] = 6'b000100;  
          4'b0010 : div_cfg_dec[5:0] = 6'b001000;  
          4'b0011 : div_cfg_dec[5:0] = 6'b010000;  
          4'b01?? : div_cfg_dec[5:0] = 6'b100000;  
          4'b1??? : div_cfg_dec[5:0] = 6'b100000;  
          default : div_cfg_dec[5:0] = 6'b000000;
        endcase 
     end 
   assign div2_sel = div_cfg[3:0]==4'b0;
   always @ (posedge clk_in or posedge reset)
     if (reset)
       counter[5:0] <= 6'b000001;   
     else if(posedge_match)
       counter[5:0] <= 6'b000001;
     else
       counter[5:0] <= (counter[5:0]+6'b000001);
   assign posedge_match    = (counter[5:0]==div_cfg_dec[5:0]);
   assign negedge_match    = (counter[5:0]=={1'b0,div_cfg_dec[5:1]}); 
   assign posedge90_match  = (counter[5:0]==({2'b00,div_cfg_dec[5:2]}));
   assign negedge90_match  = (counter[5:0]==({2'b00,div_cfg_dec[5:2]}+{1'b0,div_cfg_dec[5:1]})); 
   always @ (posedge clk_in)
     if(posedge_match)
       clk_out_reg <= 1'b1;
     else if(negedge_match)
       clk_out_reg <= 1'b0;
   assign clk_out    = clk_out_reg;
   wire        c0_emesh_wait_in=1'b0;
   wire        c0_rdmesh_wait_in=1'b0;
   wire        c1_rdmesh_wait_in=1'b0;
   wire        c2_rdmesh_wait_in=1'b0;
   wire        c3_emesh_wait_in=1'b0;
   wire        c3_mesh_wait_in=1'b0;
   wire        c3_rdmesh_wait_in=1'b0;
   wire [5:0]  txo_cfg_reg=6'b0;
   link_port link_port (.c3_mesh_access_in(1'b0),
            .c3_mesh_write_in(1'b0),
            .c3_mesh_dstaddr_in(32'b0),
            .c3_mesh_srcaddr_in(32'b0),
            .c3_mesh_data_in(32'b0),
            .c3_mesh_datamode_in(2'b0),
            .c3_mesh_ctrlmode_in(4'b0),
            .rxi_rd_wait    (rxi_rd_wait),
            .rxi_wr_wait    (rxi_wr_wait),
            .txo_data    (txo_data[LW-1:0]),
            .txo_lclk    (txo_lclk),
            .txo_frame    (txo_frame),
            .c0_emesh_frame_out(c0_emesh_frame_out),
            .c0_emesh_tran_out(c0_emesh_tran_out[2*LW-1:0]),
            .c3_emesh_frame_out(c3_emesh_frame_out),
            .c3_emesh_tran_out(c3_emesh_tran_out[2*LW-1:0]),
            .c0_rdmesh_frame_out(c0_rdmesh_frame_out),
            .c0_rdmesh_tran_out(c0_rdmesh_tran_out[2*LW-1:0]),
            .c1_rdmesh_frame_out(c1_rdmesh_frame_out),
            .c1_rdmesh_tran_out(c1_rdmesh_tran_out[2*LW-1:0]),
            .c2_rdmesh_frame_out(c2_rdmesh_frame_out),
            .c2_rdmesh_tran_out(c2_rdmesh_tran_out[2*LW-1:0]),
            .c3_rdmesh_frame_out(c3_rdmesh_frame_out),
            .c3_rdmesh_tran_out(c3_rdmesh_tran_out[2*LW-1:0]),
            .c0_mesh_access_out(c0_mesh_access_out),
            .c0_mesh_write_out(c0_mesh_write_out),
            .c0_mesh_dstaddr_out(c0_mesh_dstaddr_out[AW-1:0]),
            .c0_mesh_srcaddr_out(c0_mesh_srcaddr_out[AW-1:0]),
            .c0_mesh_data_out(c0_mesh_data_out[DW-1:0]),
            .c0_mesh_datamode_out(c0_mesh_datamode_out[1:0]),
            .c0_mesh_ctrlmode_out(c0_mesh_ctrlmode_out[3:0]),
            .c3_mesh_access_out(c3_mesh_access_out),
            .c3_mesh_write_out(c3_mesh_write_out),
            .c3_mesh_dstaddr_out(c3_mesh_dstaddr_out[AW-1:0]),
            .c3_mesh_srcaddr_out(c3_mesh_srcaddr_out[AW-1:0]),
            .c3_mesh_data_out(c3_mesh_data_out[DW-1:0]),
            .c3_mesh_datamode_out(c3_mesh_datamode_out[1:0]),
            .c3_mesh_ctrlmode_out(c3_mesh_ctrlmode_out[3:0]),
            .c0_emesh_wait_out(c0_emesh_wait_out),
            .c1_emesh_wait_out(c1_emesh_wait_out),
            .c2_emesh_wait_out(c2_emesh_wait_out),
            .c3_emesh_wait_out(c3_emesh_wait_out),
            .c0_rdmesh_wait_out(c0_rdmesh_wait_out),
            .c1_rdmesh_wait_out(c1_rdmesh_wait_out),
            .c2_rdmesh_wait_out(c2_rdmesh_wait_out),
            .c3_rdmesh_wait_out(c3_rdmesh_wait_out),
            .c0_mesh_wait_out(c0_mesh_wait_out),
            .c3_mesh_wait_out(c3_mesh_wait_out),
            .reset        (reset),
            .ext_yid_k    (ext_yid_k[3:0]),
            .ext_xid_k    (ext_xid_k[3:0]),
            .txo_cfg_reg    (txo_cfg_reg[5:0]),
            .vertical_k    (vertical_k),
            .who_am_i    (who_am_i[3:0]),
            .cfg_extcomp_dis(cfg_extcomp_dis),
            .rxi_data    (rxi_data[LW-1:0]),
            .rxi_lclk    (clk_in), // Fix: Use clk_in instead of internally generated clock
            .rxi_frame    (rxi_frame),
            .txo_rd_wait    (txo_rd_wait),
            .txo_wr_wait    (txo_wr_wait),
            .c0_clk_in    (clk_in), // Fix: Use clk_in instead of internally generated clock
            .c1_clk_in    (clk_in), // Fix: Use clk_in instead of internally generated clock
            .c2_clk_in    (clk_in), // Fix: Use clk_in instead of internally generated clock
            .c3_clk_in    (clk_in), // Fix: Use clk_in instead of internally generated clock
            .c0_emesh_tran_in(16'b0),         
            .c0_emesh_frame_in(1'b0),         
            .c1_emesh_tran_in(16'b0),         
            .c1_emesh_frame_in(1'b0),         
            .c2_emesh_tran_in(16'b0),         
            .c2_emesh_frame_in(1'b0),         
            .c3_emesh_tran_in(16'b0),         
            .c3_emesh_frame_in(1'b0),         
            .c0_rdmesh_tran_in(16'b0),         
            .c0_rdmesh_frame_in(1'b0),         
            .c1_rdmesh_tran_in(16'b0),         
            .c1_rdmesh_frame_in(1'b0),         
            .c2_rdmesh_tran_in(16'b0),         
            .c2_rdmesh_frame_in(1'b0),         
            .c3_rdmesh_tran_in(16'b0),         
            .c3_rdmesh_frame_in(1'b0),         
            .c0_mesh_access_in(c0_mesh_access_in),
            .c0_mesh_write_in(c0_mesh_write_in),
            .c0_mesh_dstaddr_in(c0_mesh_dstaddr_in[AW-1:0]),
            .c0_mesh_srcaddr_in(c0_mesh_srcaddr_in[AW-1:0]),
            .c0_mesh_data_in(c0_mesh_data_in[DW-1:0]),
            .c0_mesh_datamode_in(c0_mesh_datamode_in[1:0]),
            .c0_mesh_ctrlmode_in(c0_mesh_ctrlmode_in[3:0]),
            .c0_emesh_wait_in(c0_emesh_wait_in),
            .c3_emesh_wait_in(c3_emesh_wait_in),
            .c0_mesh_wait_in(c0_mesh_wait_in),
            .c3_mesh_wait_in(c3_mesh_wait_in),
            .c0_rdmesh_wait_in(c0_rdmesh_wait_in),
            .c1_rdmesh_wait_in(c1_rdmesh_wait_in),
            .c2_rdmesh_wait_in(c2_rdmesh_wait_in),
            .c3_rdmesh_wait_in(c3_rdmesh_wait_in));
endmodule 
module link_port(
   rxi_rd_wait, rxi_wr_wait, txo_data, txo_lclk, txo_frame,
   c0_emesh_frame_out, c0_emesh_tran_out, c3_emesh_frame_out,
   c3_emesh_tran_out, c0_rdmesh_frame_out, c0_rdmesh_tran_out,
   c1_rdmesh_frame_out, c1_rdmesh_tran_out, c2_rdmesh_frame_out,
   c2_rdmesh_tran_out, c3_rdmesh_frame_out, c3_rdmesh_tran_out,
   c0_mesh_access_out, c0_mesh_write_out, c0_mesh_dstaddr_out,
   c0_mesh_srcaddr_out, c0_mesh_data_out, c0_mesh_datamode_out,
   c0_mesh_ctrlmode_out, c3_mesh_access_out, c3_mesh_write_out,
   c3_mesh_dstaddr_out, c3_mesh_srcaddr_out, c3_mesh_data_out,
   c3_mesh_datamode_out, c3_mesh_ctrlmode_out, c0_emesh_wait_out,
   c1_emesh_wait_out, c2_emesh_wait_out, c3_emesh_wait_out,
   c0_rdmesh_wait_out, c1_rdmesh_wait_out, c2_rdmesh_wait_out,
   c3_rdmesh_wait_out, c0_mesh_wait_out, c3_mesh_wait_out,
   reset, ext_yid_k, ext_xid_k, txo_cfg_reg, vertical_k, who_am_i,
   cfg_extcomp_dis, rxi_data, rxi_lclk, rxi_frame, txo_rd_wait,
   txo_wr_wait, c0_clk_in, c1_clk_in, c2_clk_in, c3_clk_in,
   c0_emesh_tran_in, c0_emesh_frame_in, c1_emesh_tran_in,
   c1_emesh_frame_in, c2_emesh_tran_in, c2_emesh_frame_in,
   c3_emesh_tran_in, c3_emesh_frame_in, c0_rdmesh_tran_in,
   c0_rdmesh_frame_in, c1_rdmesh_tran_in, c1_rdmesh_frame_in,
   c2_rdmesh_tran_in, c2_rdmesh_frame_in, c3_rdmesh_tran_in,
   c3_rdmesh_frame_in, c0_mesh_access_in, c0_mesh_write_in,
   c0_mesh_dstaddr_in, c0_mesh_srcaddr_in, c0_mesh_data_in,
   c0_mesh_datamode_in, c0_mesh_ctrl