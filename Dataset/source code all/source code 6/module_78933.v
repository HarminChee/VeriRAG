`define VD 1'b1
`define IN 1'b0
`define VD 1'b1
`define IN 1'b0
module decode_core(
 collated_instr,
 collate_done,
 collate_required,
 fu,
 opcode,
 imm_value0,
 imm_value1,
 s1_field,
 s2_field,
 s3_field,
 s4_field,
 dest1_field,
 dest2_field
);
input [63:0] collated_instr;
input collate_done;
output collate_required;
output [1:0] fu;
output [31:0] opcode;
output [15:0] imm_value0;
output [31:0] imm_value1;
output [9:0] s1_field;
output [9:0] s2_field;
output [9:0] s3_field;
output [9:0] s4_field;
output [9:0] dest1_field;
output [9:0] dest2_field;
reg collate_required;
reg wf_halt;
reg wf_barrier;
reg wf_branch;
reg [1:0] fu;
reg [31:0] opcode;
reg [15:0] imm_value0;
reg [31:0] imm_value1;
reg scc_write;
reg scc_read;
reg vcc_write;
reg vcc_read;
reg exec_read;
reg [9:0] s1_field;
reg [9:0] s2_field;
reg [9:0] s3_field;
reg [9:0] s4_field;
reg [9:0] dest1_field;
reg [9:0] dest2_field;
always @(collated_instr or collate_done)
begin
  casex(collated_instr[31:0]) 
    32'b1011_1111_1???_????_????_????_????_????:
      begin
        collate_required <= 1'b0;
        fu <= 2'b10;
        opcode[31:24] <= 8'd1;
        opcode[23:0] <= {17'b0,collated_instr[22:16]};
        imm_value0 <= collated_instr[15:0];
        imm_value1 <= {32{1'bx}};
        s1_field <= {`IN,{9{1'bx}}};
        s2_field <= {`IN,{9{1'bx}}};
        s3_field <= {`IN,{9{1'bx}}};
        s4_field <= {`IN,{9{1'bx}}};
        dest1_field <= {`IN,{9{1'bx}}};
        dest2_field <= {`IN,{9{1'bx}}};
      end
    32'b1011_1110_1???_????_????_????_????_????:
      begin
        collate_required <= 1'b0;
        fu <= 2'b10;
        opcode[31:24] <= 8'd2;
        opcode[23:0] <= {16'b0,collated_instr[15:8]};
        imm_value0 <= {16{1'bx}};
        imm_value1 <= collate_done ? collated_instr[63:32] : {32{1'bx}};
        s1_field <= {`VD,1'b0,collated_instr[7:0]}; 
        s2_field <= {`IN,{9{1'bx}}};
        s3_field <= {`IN,{9{1'bx}}};
        s4_field <= {`IN,{9{1'bx}}};
        dest1_field <= {`VD,2'b0,collated_instr[22:16]}; 
        dest2_field <= {`IN,{9{1'bx}}};
      end
    32'b1011_1111_0???_????_????_????_????_????:
      begin
        collate_required <= 1'b0;
        fu <= 2'b10;
        opcode[31:24] <= 8'd4;
        opcode[23:0] <= {17'b0,collated_instr[22:16]};
        imm_value0 <= {16{1'bx}};
        imm_value1 <= collate_done ? collated_instr[63:32] : {32{1'bx}};
        s1_field <= {`VD,1'b0,collated_instr[7:0]}; 
        s2_field <= {`VD,1'b0,collated_instr[15:8]}; 
        s3_field <= {`IN,{9{1'bx}}};
        s4_field <= {`IN,{9{1'bx}}};
        dest1_field <= {`IN,{9{1'bx}}};
        dest2_field <= {`IN,{9{1'bx}}};
      end
    32'b1011_????_????_????_????_????_????_????:
      begin
        collate_required <= 1'b0;
        fu <= 2'b10;
        opcode[31:24] <= 8'd16;
        opcode[23:0] <= {19'b0,collated_instr[27:23]};
        imm_value0 <= collated_instr[15:0];
        imm_value1 <= {32{1'bx}};
        s1_field <= {`IN,{9{1'bx}}};
        s2_field <= {`IN,{9{1'bx}}};
        s3_field <= {`IN,{9{1'bx}}};
        s4_field <= {`IN,{9{1'bx}}};
        dest1_field <= {`VD,2'b0,collated_instr[22:16]}; 
        dest2_field <= {`IN,{9{1'bx}}};
      end
    32'b10??_????_????_????_????_????_????_????:
      begin
        collate_required <= 1'b0;
        fu <= 2'b10;
        opcode[31:24] <= 8'd8;
        opcode[23:0] <= {17'b0,collated_instr[29:23]};
        imm_value0 <= {16{1'bx}};
        imm_value1 <= collate_done ? collated_instr[63:32] : {32{1'bx}};
        s1_field <= {`VD,1'b0,collated_instr[7:0]}; 
        s2_field <= {`VD,1'b0,collated_instr[15:8]}; 
        s3_field <= {`IN,{9{1'bx}}};
        s4_field <= {`IN,{9{1'bx}}};
        dest1_field <= {`VD,2'b0,collated_instr[22:16]}; 
        dest2_field <= {`IN,{9{1'bx}}};
      end
    32'b0111_110?_????_????_????_????_????_????:
      begin
        collate_required <= 1'b0;
        fu <= 2'b01;
        opcode[31:24] <= 8'd1;
        opcode[23:0] <= {16'b0,collated_instr[24:17]};
        imm_value0 <= {16{1'bx}};
        imm_value1 <= collate_done ? collated_instr[63:32] : {32{1'bx}};
        s1_field <= {`VD,collated_instr[8:0]}; 
        s2_field <= {`VD,1'b1,collated_instr[16:9]}; 
        s3_field <= {`IN,{9{1'bx}}};
        s4_field <= {`IN,{9{1'bx}}};
        dest1_field <= {`IN,{9{1'bx}}};
        dest2_field <= {`IN,{9{1'bx}}};
      end
    32'b0111_111?_????_????_????_????_????_????:
      begin
        collate_required <= 1'b0;
        fu <= 2'b01;
        opcode[31:24] <= 8'd2;
        opcode[23:0] <= {16'b0,collated_instr[16:9]};
        imm_value0 <= {16{1'bx}};
        imm_value1 <= collate_done ? collated_instr[63:32] : {32{1'bx}};
        s1_field <= {`VD,collated_instr[8:0]}; 
        s2_field <= {`IN,{9{1'bx}}};
        s3_field <= {`IN,{9{1'bx}}};
        s4_field <= {`IN,{9{1'bx}}};
        dest1_field <= {`VD,1'b1,collated_instr[24:17]}; 
        dest2_field <= {`IN,{9{1'bx}}};
      end
    32'b0???_????_????_????_????_????_????_????:
      begin
        collate_required <= 1'b0;
        fu <= 2'b01;
        opcode[31:24] <= 8'd4;
        opcode[23:0] <= {18'b0,collated_instr[30:25]};
        imm_value0 <= {16{1'bx}};
        imm_value1 <= collate_done ? collated_instr[63:32] : {32{1'bx}};
        s1_field <= {`VD,collated_instr[8:0]}; 
        s2_field <= {`VD,1'b1,collated_instr[16:9]}; 
        s3_field <= {`IN,{9{1'bx}}};
        s4_field <= {`IN,{9{1'bx}}};
        dest1_field <= {`VD,1'b1,collated_instr[24:17]}; 
        dest2_field <= {`IN,{9{1'bx}}};
      end
    32'b1101_00??_????_????_????_????_????_????:
      begin
        casex(collate_done)
          1'b0:
            begin
              collate_required <= 1'b1;
              fu <= 2'b0; 
              opcode[31:24] <= {8{1'bx}};
              opcode[23:0] <= {24{1'bx}};
              imm_value0 <= {16{1'bx}};
              imm_value1 <= {32{1'bx}};
              s1_field <= {`IN,{9{1'bx}}};
              s2_field <= {`IN,{9{1'bx}}};
              s3_field <= {`IN,{9{1'bx}}};
              s4_field <= {`IN,{9{1'bx}}};
              dest1_field <= {`IN,{9{1'bx}}};
              dest2_field <= {`IN,{9{1'bx}}};
            end
           1'b1:
             begin
               if((collated_instr[25:17] >= 9'h125) && (collated_instr[25:17] <= 9'h12a))
                 begin
                   collate_required <= 1'b0;
                   fu <= 2'b01;
                   opcode[31:24] <= 8'd8;
                   opcode[23:0] <= {collated_instr[63:59],10'b0,collated_instr[25:17]};
                   imm_value0 <= {16{1'bx}};
                   imm_value1 <= {32{1'bx}};
                   s1_field <= {`VD,collated_instr[40:32]}; 
                   s2_field <= {`VD,collated_instr[49:41]}; 
                   s3_field <= {`VD,collated_instr[58:50]}; 
                   s4_field <= {`IN,{9{1'bx}}};
                   dest1_field <= {`VD,1'b1,collated_instr[7:0]}; 
                   dest2_field <= {`VD,2'b0,collated_instr[14:8]}; 
                 end
               else
                 begin
                   collate_required <= 1'b0;
                   fu <= 2'b01;
                   opcode[31:24] <= 8'd16;
                   opcode[23:0] <= {collated_instr[63:59],collated_instr[11:8],6'b0,collated_instr[25:17]};
                   imm_value0 <= {16{1'bx}};
                   imm_value1 <= {32{1'bx}};
                   s1_field <= {`VD,collated_instr[40:32]}; 
                   s2_field <= {`VD,collated_instr[49:41]}; 
                   s3_field <= {`VD,collated_instr[58:50]}; 
                   s4_field <= {`IN,{9{1'bx}}};
                   dest1_field <= {`VD,1'b1,collated_instr[7:0]}; 
                   dest2_field <= {`IN,{9{1'bx}}};
                 end
             end
           default:
             begin
              collate_required <= 1'bx;
              fu <= {2{1'bx}};
              opcode[31:24] <= {8{1'bx}};
              opcode[23:0] <= {24{1'bx}};
              imm_value0 <= {16{1'bx}};
              imm_value1 <= {32{1'bx}};
              s1_field <= {10{1'bx}};
              s2_field <= {10{1'bx}};
              s3_field <= {10{1'bx}};
              s4_field <= {10{1'bx}};
              dest1_field <= {10{1'bx}};
              dest2_field <= {10{1'bx}};
             end
        endcase
      end
    32'b1100_0???_????_????_????_????_????_????:
      begin
        collate_required <= 1'b0;
        fu <= 2'b11;
        opcode[31:24] <= 8'd1;
        opcode[23:0] <= {collated_instr[8],18'b0,collated_instr[26:22]};
        imm_value0 <= collated_instr[8] ? {8'b0,collated_instr[7:0]} : {16{1'bx}}; 
        imm_value1 <= collate_done ? collated_instr[63:32] : {32{1'bx}};
        s1_field <= collated_instr[8] ? {`IN,{9{1'bx}}} : {`VD,1'b0,collated_instr[7:0]}; 
        s2_field <= {`VD,2'b0,collated_instr[14:9],1'b0}; 
        s3_field <= {`IN,{9{1'bx}}};
        s4_field <= {`IN,{9{1'bx}}};
        dest1_field <= {`VD,2'b0,collated_instr[21:15]}; 
        dest2_field <= {`IN,{9{1'bx}}};
      end
    32'b1101_10??_????_????_????_????_????_????:
      begin
        casex(collate_done)
          1'b0:
            begin
              collate_required <= 1'b1;
              fu <= 2'b0; 
              opcode[31:24] <= {8{1'bx}};
              opcode[23:0] <= {24{1'bx}};
              imm_value0 <= {16{1'bx}};
              imm_value1 <= {32{1'bx}};
              s1_field <= {`IN,{9{1'bx}}};
              s2_field <= {`IN,{9{1'bx}}};
              s3_field <= {`IN,{9{1'bx}}};
              s4_field <= {`IN,{9{1'bx}}};
              dest1_field <= {`IN,{9{1'bx}}};
              dest2_field <= {`IN,{9{1'bx}}};
            end
           1'b1:
             begin
               collate_required <= 1'b0;
               fu <= 2'b11;
               opcode[31:24] <= 8'd2;
               opcode[23:0] <= {collated_instr[17],15'b0,collated_instr[25:18]};
               imm_value0 <= collated_instr[7:0];
               imm_value1 <= collated_instr[15:8];
               s1_field <= {`VD,1'b1,collated_instr[39:32]}; 
               s2_field <= {`VD,1'b1,collated_instr[47:40]}; 
               s3_field <= {`VD,1'b1,collated_instr[55:48]}; 
               s4_field <= {`IN,{9{1'bx}}};
               dest1_field <= {`VD,1'b1,collated_instr[63:56]}; 
               dest2_field <= {`IN,{9{1'bx}}};
             end
           default:
             begin
              collate_required <= 1'bx;
              fu <= {2{1'bx}};
              opcode[31:24] <= {8{1'bx}};
              opcode[23:0] <= {24{1'bx}};
              imm_value0 <= {16{1'bx}};
              imm_value1 <= {32{1'bx}};
              s1_field <= {10{1'bx}};
              s2_field <= {10{1'bx}};
              s3_field <= {10{1'bx}};
              s4_field <= {10{1'bx}};
              dest1_field <= {10{1'bx}};
              dest2_field <= {10{1'bx}};
             end
        endcase
      end
    32'b1110_10??_????_????_????_????_????_????:
      begin
        casex(collate_done)
          1'b0:
            begin
              collate_required <= 1'b1;
              fu <= 2'b0; 
              opcode[31:24] <= {8{1'bx}};
              opcode[23:0] <= {24{1'bx}};
              imm_value0 <= {16{1'bx}};
              imm_value1 <= {32{1'bx}};
              s1_field <= {`IN,{9{1'bx}}};
              s2_field <= {`IN,{9{1'bx}}};
              s3_field <= {`IN,{9{1'bx}}};
              s4_field <= {`IN,{9{1'bx}}};
              dest1_field <= {`IN,{9{1'bx}}};
              dest2_field <= {`IN,{9{1'bx}}};
            end
           1'b1:
             begin
               collate_required <= 1'b0;
               fu <= 2'b11;
               opcode[31:24] <= 8'd4;
               opcode[23:0] <= {collated_instr[55:54],collated_instr[25:19],collated_instr[15:12],8'b0,collated_instr[18:16]};
               imm_value0 <= collated_instr[12] ? {16{1'bx}} : {5'b0,collated_instr[11:0]};
               imm_value1 <= {24'b0,collated_instr[63:56]};
               s1_field <= {`VD,1'b0,collated_instr[63:56]}; 
               s2_field <= {`VD,1'b1,collated_instr[47:40]}; 
               s3_field <= {`VD,1'b1,collated_instr[39:32]}; 
               s4_field <= {`VD,2'b0,collated_instr[52:48],2'b0}; 
               dest1_field <= {`VD,1'b1,collated_instr[47:40]}; 
               dest2_field <= {`IN,{9{1'bx}}};
             end
           default:
             begin
              collate_required <= 1'bx;
              fu <= {2{1'bx}};
              opcode[31:24] <= {8{1'bx}};
              opcode[23:0] <= {24{1'bx}};
              imm_value0 <= {16{1'bx}};
              imm_value1 <= {32{1'bx}};
              s1_field <= {10{1'bx}};
              s2_field <= {10{1'bx}};
              s3_field <= {10{1'bx}};
              s4_field <= {10{1'bx}};
              dest1_field <= {10{1'bx}};
              dest2_field <= {10{1'bx}};
             end
        endcase
      end
    default:
      begin
        collate_required <= 1'bx;
        fu <= {2{1'bx}};
        opcode[31:24] <= {8{1'bx}};
        opcode[23:0] <= {24{1'bx}};
        imm_value0 <= {16{1'bx}};
        imm_value1 <= {32{1'bx}};
        s1_field <= {10{1'bx}};
        s2_field <= {10{1'bx}};
        s3_field <= {10{1'bx}};
        s4_field <= {10{1'bx}};
        dest1_field <= {10{1'bx}};
        dest2_field <= {10{1'bx}};
      end
  endcase
end
endmodule
