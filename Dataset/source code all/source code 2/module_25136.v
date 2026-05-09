module spu_ma_mon (
   clk, wrmi_mamul_1sthalf, wrmi_mamul_2ndhalf, 
        wrmi_maaeqb_1sthalf, wrmi_maaeqb_2ndhalf,
        iptr, iminus_lenminus1, mul_data
   );
input clk;
input wrmi_mamul_1sthalf;
input wrmi_mamul_2ndhalf;
input wrmi_maaeqb_1sthalf;
input wrmi_maaeqb_2ndhalf;
input [6:0] iptr;
input [6:0] iminus_lenminus1;
input [63:0] mul_data;
always @(negedge clk)
begin
  if (wrmi_mamul_1sthalf | wrmi_maaeqb_1sthalf) begin
   $display("%0d:spu_ma> ",$time,"M[",iptr,"] = %h",mul_data);
`ifdef MODELSIM   
   $display(0,"SPU_MON_M[",iptr,"] = %h",mul_data);
`else
   $info(0,"SPU_MON_M[",iptr,"] = %h",mul_data);
`endif
  end
  if (wrmi_mamul_2ndhalf | wrmi_maaeqb_2ndhalf) begin
   $display("%0d:spu_ma> ",$time,"M[",iminus_lenminus1,"] = %h",mul_data);
`ifdef MODELSIM
   $display(0,"SPU_MON_M[",iminus_lenminus1,"] = %h",mul_data);
`else
   $info(0,"SPU_MON_M[",iminus_lenminus1,"] = %h",mul_data);
`endif
  end
end 
endmodule
