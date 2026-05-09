`timescale 1ns / 1ps
`timescale 1ns / 1ps
module altpciexpav_stif_cr_mailbox
  #(
    parameter INTENDED_DEVICE_FAMILY = "Stratix",
    parameter CG_NUM_MAILBOX = 8
    )
  (
   input             CraClk_i,           
   input             CraRstn_i,          
   input [13:2]      IcrAddress_i,       
   input [31:0]      IcrWriteData_i,     
   input [3:0]       IcrByteEnable_i,    
   input             MbWriteReqVld_i,    
   input             MbReadReqVld_i,     
   output reg [31:0] MbReadData_o,       
   output reg        MbReadDataVld_o,    
   output reg [7:0]  MbRuptReq_o,        
   input [3:0]       cg_num_mailbox_i   
   ) ;
   reg [31:0]        mailbox1_reg ;
   reg               mailbox1_rupt_reg ;
   reg [7:0]         ram_rupt_reg ;
   reg               reg1_write ;
   reg               ram_write ;
   reg [4:2]         qual_address ;
   wire [31:0]       ram_read_data ;
   reg               read_vld_q1 ;
   reg               read_vld_q2 ;
   always @*
     begin
        if ( (|IcrAddress_i[8:5] == 1'b1) ||
             (IcrAddress_i[4:2] >= cg_num_mailbox_i) )
          begin
             reg1_write = 1'b0 ;
             ram_write = 1'b0 ;
          end
        else
          begin
             if (cg_num_mailbox_i == 4'h1)
               begin
                  reg1_write = MbWriteReqVld_i ;
                  ram_write = 1'b0 ;
               end
             else
               begin        
                  reg1_write = 1'b0 ;
                  ram_write = MbWriteReqVld_i ;
               end
          end 
        case (cg_num_mailbox_i)
          4'h0 : 
            qual_address = 3'b000 ;
          4'h1, 4'h2 :
            qual_address = {2'b00,IcrAddress_i[2]} ;
          4'h3, 4'h4 :
            qual_address = {1'b0,IcrAddress_i[3:2]} ;
          default :
            qual_address = IcrAddress_i[4:2] ;
        endcase 
     end 
   generate
      if (CG_NUM_MAILBOX <= 1)
        begin
        	 assign ram_read_data = 32'h0;
           always @(posedge CraClk_i or negedge CraRstn_i)
             begin
                if (CraRstn_i == 1'b0)
                  begin
                     mailbox1_reg <= 32'h00000000 ;
                  end
                else
                  begin
                     if (reg1_write & IcrByteEnable_i[3])
                       mailbox1_reg[31:24] <= IcrWriteData_i[31:24] ;
                     else
                       mailbox1_reg[31:24] <= mailbox1_reg[31:24] ;
                     if (reg1_write & IcrByteEnable_i[2])
                       mailbox1_reg[23:16] <= IcrWriteData_i[23:16] ;
                     else
                       mailbox1_reg[23:16] <= mailbox1_reg[23:16] ;
                     if (reg1_write & IcrByteEnable_i[1])
                       mailbox1_reg[15:8] <= IcrWriteData_i[15:8] ;
                     else
                       mailbox1_reg[15:8] <= mailbox1_reg[15:8] ;
                     if (reg1_write & IcrByteEnable_i[0])
                       mailbox1_reg[7:0] <= IcrWriteData_i[7:0] ;
                     else
                       mailbox1_reg[7:0] <= mailbox1_reg[7:0] ;
                  end 
             end 
         end 
      else
        begin
         always @(posedge CraClk_i or negedge CraRstn_i)
             begin
                if (CraRstn_i == 1'b0)
                     mailbox1_reg <= 32'h00000000 ;
                else
                     mailbox1_reg <= 32'h00000000 ;
             end
           altsyncram 
             #(
               .intended_device_family(INTENDED_DEVICE_FAMILY),
               .operation_mode("SINGLE_PORT"),
               .width_a(32),
               .widthad_a(3),
               .numwords_a(8),
               .outdata_reg_a("CLOCK0"),
               .indata_aclr_a("CLEAR0"),
               .wrcontrol_aclr_a("CLEAR0"),
               .address_aclr_a("CLEAR0"),
               .outdata_aclr_a("CLEAR0"),
               .width_byteena_a(4),
               .byte_size(8),
               .byteena_aclr_b("CLEAR0"),
	           .lpm_hint("ENABLE_RUNTIME_MOD=NO"),
               .lpm_type("altsyncram")
               )
               altsyncram_component 
                                       (
                                        .wren_a (ram_write),
                                        .aclr0 (~CraRstn_i),
                                        .clock0 (CraClk_i),
                                        .byteena_a (IcrByteEnable_i),
                                        .address_a (qual_address),
                                        .data_a (IcrWriteData_i),
                                        .q_a (ram_read_data)
                                        ,
	                                    .aclr1 (),
	                                    .byteena_b (),
	                                    .rden_b (),
	                                    .clock1 (),
	                                    .data_b (),
	                                    .wren_b (),
	                                    .q_b (),
	                                    .clocken0 (),
	                                    .clocken1 (),
	                                    .address_b (),
	                                    .addressstall_a (),
	                                    .addressstall_b ()
                                        );
        end 
   endgenerate
   always @(posedge CraClk_i or negedge CraRstn_i)
     begin
        if (CraRstn_i == 1'b0)
          begin
             read_vld_q2 <= 1'b0 ;
             read_vld_q1 <= 1'b0 ;
          end
        else
          begin
             read_vld_q2 <= read_vld_q1 ;
             read_vld_q1 <= MbReadReqVld_i ;
          end
     end 
   always @(MbReadReqVld_i or read_vld_q2 or
            ram_read_data or mailbox1_reg or
            cg_num_mailbox_i)
     begin
        case(cg_num_mailbox_i)
          4'h0 :
            begin
               MbReadDataVld_o <= MbReadReqVld_i ;
               MbReadData_o <= 32'h00000000 ;
            end
          4'h1 :
            begin
               MbReadDataVld_o <= MbReadReqVld_i ;
               MbReadData_o <= mailbox1_reg ;
            end
          default :
            begin
               MbReadDataVld_o <= read_vld_q2 ;
               MbReadData_o <= ram_read_data ;
            end
        endcase 
     end 
   always @(reg1_write or ram_write or IcrByteEnable_i or 
            qual_address)
     begin
        MbRuptReq_o = 8'b0 ;
        if ( (reg1_write | ram_write) & (|IcrByteEnable_i) )
          MbRuptReq_o[qual_address] = 1'b1 ;
     end
endmodule 
