module   core_ras(
                   clk,
                   rst,
                   en_call_in, 
                   en_ret_in,
                   ret_addr_in,
                   recover_push,
                   recover_push_addr,
                   recover_pop,
                   ret_addr_out
                   );
parameter          ps2=2'b00;
parameter          ps1=2'b01;
parameter          pp1=2'b10;
parameter          pp2=2'b11;
input              clk;
input              rst;
input              en_call_in;
input              en_ret_in;
input     [29:0]   ret_addr_in;
input              recover_push;
input     [29:0]   recover_push_addr;
input              recover_pop;
output     [31:0]      ret_addr_out;
reg        en_RAS_ret;
reg        en_RAS_rec;
reg        en_pointer;
reg  [1:0] ret_addr_out_src;
reg   [29:0]   RAS_1;
reg   [29:0]   RAS_2;
reg   [29:0]   RAS_3;
reg   [29:0]   RAS_4;
reg   [29:0]   RAS_5;
reg   [29:0]   RAS_6;
reg   [29:0]   RAS_7;
reg   [29:0]   RAS_8;
reg   [2:0]    pointer; 
reg   [1:0]    pointer_src;
always@(posedge clk)
begin
  if(rst)
    pointer<=3'b000;
  else if(en_pointer&&(pointer_src==ps2))
    pointer<=pointer-3'b010;
  else if(en_pointer&&(pointer_src==ps1))
    pointer<=pointer-3'b001;
  else if(en_pointer&&(pointer_src==pp1))
    pointer<=pointer+3'b001;
  else if(en_pointer&&(pointer_src==pp2))
    pointer<=pointer+3'b010;
end
reg    [7:0]  en_pointer_P0;
reg    [7:0]  en_pointer_P1;
reg    [7:0]  en_pointer_P2;
always@(*)
begin
  case(pointer)
    3'b000:en_pointer_P0=8'b00000001;
    3'b001:en_pointer_P0=8'b00000010;
    3'b010:en_pointer_P0=8'b00000100;
    3'b011:en_pointer_P0=8'b00001000;
    3'b100:en_pointer_P0=8'b00010000;
    3'b101:en_pointer_P0=8'b00100000;
    3'b110:en_pointer_P0=8'b01000000;
    3'b111:en_pointer_P0=8'b10000000;
    default:en_pointer_P0=8'b00000000;
  endcase
  case(pointer)
    3'b111:en_pointer_P1=8'b00000001;
    3'b000:en_pointer_P1=8'b00000010;
    3'b001:en_pointer_P1=8'b00000100;
    3'b010:en_pointer_P1=8'b00001000;
    3'b011:en_pointer_P1=8'b00010000;
    3'b100:en_pointer_P1=8'b00100000;
    3'b101:en_pointer_P1=8'b01000000;
    3'b110:en_pointer_P1=8'b10000000;
    default:en_pointer_P1=8'b00000000;
  endcase
  case(pointer)
    3'b111:en_pointer_P2=8'b00000010;
    3'b000:en_pointer_P2=8'b00000100;
    3'b001:en_pointer_P2=8'b00001000;
    3'b010:en_pointer_P2=8'b00010000;
    3'b011:en_pointer_P2=8'b00100000;
    3'b100:en_pointer_P2=8'b01000000;
    3'b101:en_pointer_P2=8'b10000000;
    3'b110:en_pointer_P2=8'b00000001;
    default:en_pointer_P2=8'b00000000;
  endcase
end    
always@(*)
begin
  en_RAS_ret=1'b0;
  en_RAS_rec=1'b0;
  pointer_src=pp2;
  en_pointer=1'b0;
  ret_addr_out_src=2'b11;
  if(en_call_in&&recover_push)
    begin
      en_RAS_ret=1'b1;
      en_RAS_rec=1'b1;
      pointer_src=pp2;
      en_pointer=1'b1;
    end
  else if(en_call_in&&!recover_push&&!recover_pop) 
    begin
      en_RAS_ret=1'b1;
      pointer_src=pp1;
      en_pointer=1'b1;
    end
  else if(!en_ret_in&&!en_call_in&&recover_push)
    begin
      en_RAS_rec=1'b1;
      pointer_src=pp1;
      en_pointer=1'b1;
    end
  if(en_ret_in&&recover_push)
    begin
      ret_addr_out_src=2'b00;
    end
  else if(en_ret_in&&!recover_push&&!recover_pop)
    begin
      pointer_src=ps1;
      en_pointer=1'b1;
      ret_addr_out_src=2'b10;
    end
  if(en_call_in&&recover_pop)        
    begin
      en_RAS_ret=1'b1;
    end
  else if(!en_ret_in&&!en_call_in&&recover_pop)
    begin
      pointer_src=ps1;
      en_pointer=1'b1;
    end
  if(en_ret_in&&recover_pop)
    begin
      ret_addr_out_src=2'b01;
      pointer_src=ps2;
      en_pointer=1'b1;
    end
 end   
always@(posedge clk)
begin
  if(rst)
    RAS_1<=30'h00000000;
 else if(en_RAS_ret&&(en_pointer_P0[0]||en_pointer_P1[0]||en_pointer_P2[0]))
    RAS_1<=ret_addr_in;
 else if(en_RAS_rec&&(en_pointer_P2[0]||en_pointer_P1[0]))
    RAS_1<=recover_push_addr;
end
always@(posedge clk)
begin
  if(rst)
    RAS_2<=30'h00000000;
 else if(en_RAS_ret&&(en_pointer_P0[1]||en_pointer_P1[1]||en_pointer_P2[1]))
    RAS_2<=ret_addr_in;
 else if(en_RAS_rec&&(en_pointer_P2[1]||en_pointer_P1[1]))
    RAS_2<=recover_push_addr;
end
always@(posedge clk)
begin
  if(rst)
    RAS_3<=30'h00000000;
 else if(en_RAS_ret&&(en_pointer_P0[2]||en_pointer_P1[2]||en_pointer_P2[2]))
    RAS_3<=ret_addr_in;
 else if(en_RAS_rec&&(en_pointer_P2[2]||en_pointer_P1[2]))
    RAS_3<=recover_push_addr;
end
always@(posedge clk)
begin
  if(rst)
    RAS_4<=30'h00000000;
 else if(en_RAS_ret&&(en_pointer_P0[3]||en_pointer_P1[3]||en_pointer_P2[3]))
    RAS_4<=ret_addr_in;
 else if(en_RAS_rec&&(en_pointer_P2[3]||en_pointer_P1[3]))
    RAS_4<=recover_push_addr;
end
always@(posedge clk)
begin
  if(rst)
    RAS_5<=30'h00000000;
 else if(en_RAS_ret&&(en_pointer_P0[4]||en_pointer_P1[4]||en_pointer_P2[4]))
    RAS_5<=ret_addr_in;
 else if(en_RAS_rec&&(en_pointer_P2[4]||en_pointer_P1[4]))
    RAS_5<=recover_push_addr;
end
always@(posedge clk)
begin
  if(rst)
    RAS_6<=30'h00000000;
 else if(en_RAS_ret&&(en_pointer_P0[5]||en_pointer_P1[5]||en_pointer_P2[5]))
    RAS_6<=ret_addr_in;
 else if(en_RAS_rec&&(en_pointer_P2[5]||en_pointer_P1[5]))
    RAS_6<=recover_push_addr;
end
always@(posedge clk)
begin
  if(rst)
    RAS_7<=30'h00000000;
 else if(en_RAS_ret&&(en_pointer_P0[6]||en_pointer_P1[6]||en_pointer_P2[6]))
    RAS_7<=ret_addr_in;
 else if(en_RAS_rec&&(en_pointer_P2[6]||en_pointer_P1[6]))
    RAS_7<=recover_push_addr;
end
always@(posedge clk)
begin
  if(rst)
    RAS_8<=30'h00000000;
 else if(en_RAS_ret&&(en_pointer_P0[7]||en_pointer_P1[7]||en_pointer_P2[7]))
    RAS_8<=ret_addr_in;
 else if(en_RAS_rec&&(en_pointer_P2[7]||en_pointer_P1[7]))
    RAS_8<=recover_push_addr;
end
reg  [29:0] pointer_rd_ras;
always@(*)
begin
  case(pointer)
    3'b000:pointer_rd_ras=RAS_1;
    3'b001:pointer_rd_ras=RAS_2;
    3'b010:pointer_rd_ras=RAS_3;
    3'b011:pointer_rd_ras=RAS_4;
    3'b100:pointer_rd_ras=RAS_5;
    3'b101:pointer_rd_ras=RAS_6;
    3'b110:pointer_rd_ras=RAS_7;
    3'b111:pointer_rd_ras=RAS_8;
    default:pointer_rd_ras=30'hzzzzzzzz;
  endcase
end
reg  [29:0] pointerP1_rd_ras;
always@(*)
begin
  case(pointer)
    3'b000:pointerP1_rd_ras=RAS_2;
    3'b001:pointerP1_rd_ras=RAS_3;
    3'b010:pointerP1_rd_ras=RAS_4;
    3'b011:pointerP1_rd_ras=RAS_5;
    3'b100:pointerP1_rd_ras=RAS_6;
    3'b101:pointerP1_rd_ras=RAS_7;
    3'b110:pointerP1_rd_ras=RAS_8;
    3'b111:pointerP1_rd_ras=RAS_1;
    default:pointerP1_rd_ras=30'hzzzzzzzz;
  endcase
end
wire  [29:0]   ret_addr_out_temp;
assign ret_addr_out_temp=(ret_addr_out_src==2'b00)?recover_push_addr:
                    (ret_addr_out_src==2'b01)?pointer_rd_ras:
                    (ret_addr_out_src==2'b10)?pointerP1_rd_ras:30'hzzzzzzzz;
assign  ret_addr_out={ret_addr_out_temp,2'b00};
endmodule
