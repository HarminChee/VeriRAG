`timescale 1ns / 1ps
`timescale 1ns / 1ps
module altpcierd_cplerr_lmi  (
   input             clk_in,
   input             rstn,
   input [127:0]     err_desc,            
   input [6:0]       cpl_err_in,          
   input             lmi_ack,             
   output reg[31:0]  lmi_din,             
   output reg[11:0]  lmi_addr,            
   output reg        lmi_wren,            
   output reg [6:0]  cpl_err_out,         
   output            lmi_rden,            
   output reg        cplerr_lmi_busy      
        );
   localparam        IDLE             = 3'h0;
   localparam        WAIT_LMI_WR_AER81C = 3'h1;
   localparam        WAIT_LMI_WR_AER820 = 3'h2;
   localparam        WAIT_LMI_WR_AER824 = 3'h3;
   localparam        WAIT_LMI_WR_AER828 = 3'h4;
   localparam        DRIVE_CPL_ERR    = 3'h5;
   reg [2:0]   cplerr_lmi_sm;
   reg [6:0]   cpl_err_reg;
   reg [127:0] err_desc_reg;
   reg         lmi_ack_reg;    
   assign lmi_rden = 1'b0;   
   wire[6:0] cpl_err_in_assert;
   assign cpl_err_in_assert = ~cpl_err_reg &  cpl_err_in;
   always @ (posedge clk_in or negedge rstn) begin
       if (rstn==1'b0) begin
           cplerr_lmi_sm   <= IDLE;
           cpl_err_reg     <= 7'h0;
           lmi_din         <= 32'h0;
           lmi_addr        <= 12'h0;
           lmi_wren        <= 1'b0;
           cpl_err_out     <= 7'h0;
           err_desc_reg    <= 128'h0;
           cplerr_lmi_busy <= 1'b0;
           lmi_ack_reg     <= 1'b0;
       end
       else begin
           lmi_ack_reg <= lmi_ack;
           case (cplerr_lmi_sm)
               IDLE: begin
                   lmi_addr     <= 12'h81C;
                   lmi_din      <= err_desc[127:96];
                   cpl_err_reg  <= cpl_err_in;
                   err_desc_reg <= err_desc;
                   cpl_err_out  <= 7'h0;
                   if (cpl_err_in_assert[6]==1'b1) begin
                        cplerr_lmi_sm   <= WAIT_LMI_WR_AER81C;
                        lmi_wren        <= 1'b1;
                        cplerr_lmi_busy <= 1'b1;
                   end
                   else if (cpl_err_in_assert != 7'h0) begin
                        cplerr_lmi_sm   <= DRIVE_CPL_ERR;
                        lmi_wren        <= 1'b0;
                        cplerr_lmi_busy <= 1'b1;
                   end
                   else begin
                       cplerr_lmi_sm   <= cplerr_lmi_sm;
                       lmi_wren        <= 1'b0;
                       cplerr_lmi_busy <= 1'b0;
                   end
               end
               WAIT_LMI_WR_AER81C: begin
                   if (lmi_ack_reg==1'b1) begin
                       cplerr_lmi_sm <= WAIT_LMI_WR_AER820;
                       lmi_addr      <= 12'h820;
                       lmi_din       <= err_desc_reg[95:64];
                       lmi_wren      <= 1'b1;
                   end
                   else begin
                       cplerr_lmi_sm <= cplerr_lmi_sm;
                       lmi_addr      <= lmi_addr;
                       lmi_din       <= lmi_din;
                       lmi_wren      <= 1'b0;
                   end
               end
               WAIT_LMI_WR_AER820: begin
                   if (lmi_ack_reg==1'b1) begin
                       cplerr_lmi_sm <= WAIT_LMI_WR_AER824;
                       lmi_addr      <= 12'h824;
                       lmi_din       <= err_desc_reg[63:32];
                       lmi_wren      <= 1'b1;
                   end
                   else begin
                       cplerr_lmi_sm <= cplerr_lmi_sm;
                       lmi_addr      <= lmi_addr;
                       lmi_din       <= lmi_din;
                       lmi_wren      <= 1'b0;
                   end
               end
               WAIT_LMI_WR_AER824: begin
                   if (lmi_ack_reg==1'b1) begin
                       cplerr_lmi_sm <= WAIT_LMI_WR_AER828;
                       lmi_addr      <= 12'h828;
                       lmi_din       <= err_desc_reg[31:0];
                       lmi_wren      <= 1'b1;
                   end
                   else begin
                       cplerr_lmi_sm <= cplerr_lmi_sm;
                       lmi_addr      <= lmi_addr;
                       lmi_din       <= lmi_din;
                       lmi_wren      <= 1'b0;
                   end
               end
               WAIT_LMI_WR_AER828: begin
                   lmi_addr      <= lmi_addr;
                   lmi_din       <= lmi_din;
                   lmi_wren      <= 1'b0;
                   if (lmi_ack_reg==1'b1) begin
                       cplerr_lmi_sm <= DRIVE_CPL_ERR;
                   end
                   else begin
                       cplerr_lmi_sm <= cplerr_lmi_sm;
                   end
               end
               DRIVE_CPL_ERR: begin
                   cpl_err_out     <= cpl_err_reg;
                   cplerr_lmi_sm   <= IDLE;
                   cplerr_lmi_busy <= 1'b0;
               end
           endcase
       end
   end
endmodule
