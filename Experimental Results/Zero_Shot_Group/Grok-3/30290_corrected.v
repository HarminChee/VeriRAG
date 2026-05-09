module VGA1(clock, reset, inst, inst_en, vga_hsync, vga_vsync, vga_r, vga_g, vga_b);
   input wire        clock;
   input wire        reset;
   input wire [11:0] inst;
   input wire        inst_en;
   output wire       vga_hsync;
   output wire       vga_vsync;
   output wire       vga_r;
   output wire       vga_g;
   output wire       vga_b;
   reg [1:0]         s_State;
   reg [63:0]        s_FrameBuffer;
   wire [3:0]        w_InstCode;
   wire [7:0]        w_InstImm;
   reg [256*8-1:0]   d_Input;
   reg [256*8-1:0]   d_State;
   assign w_InstCode = inst[11:8];
   assign w_InstImm = inst[7:0];
   
   VGA1Interface vgaint (
      .clock(clock),
      .reset(reset),
      .framebuffer(s_FrameBuffer),
      .vga_hsync(vga_hsync),
      .vga_vsync(vga_vsync),
      .vga_r(vga_r),
      .vga_g(vga_g),
      .vga_b(vga_b)
   );
   
   always @(posedge clock) begin
      if (reset) begin
         s_State       <= 2'h0;  // `VGA1_State_Reset
         s_FrameBuffer <= 64'b0;
      end
      else begin
         case (s_State)
           2'h0: begin  // `VGA1_State_Reset
              s_State       <= 2'h1;  // `VGA1_State_Ready
              s_FrameBuffer <= 64'b0;
           end
           2'h1: begin  // `VGA1_State_Ready
              if (inst_en) begin
                 case (w_InstCode)
                   4'h0: begin  // `VGA1_NOP
                      s_State       <= 2'h1;  // `VGA1_State_Ready
                      s_FrameBuffer <= s_FrameBuffer;
                   end
                   4'h1: begin  // `VGA1_LD0
                      s_State       <= 2'h1;  // `VGA1_State_Ready
                      s_FrameBuffer <= {s_FrameBuffer[63:8], w_InstImm};
                   end
                   4'h2: begin  // `VGA1_LD1
                      s_State       <= 2'h1;  // `VGA1_State_Ready
                      s_FrameBuffer <= {s_FrameBuffer[63:16], w_InstImm, s_FrameBuffer[7:0]};
                   end
                   4'h3: begin  // `VGA1_LD2
                      s_State       <= 2'h1;  // `VGA1_State_Ready
                      s_FrameBuffer <= {s_FrameBuffer[63:24], w_InstImm, s_FrameBuffer[15:0]};
                   end
                   4'h4: begin  // `VGA1_LD3
                      s_State       <= 2'h1;  // `VGA1_State_Ready
                      s_FrameBuffer <= {s_FrameBuffer[63:32], w_InstImm, s_FrameBuffer[23:0]};
                   end
                   4'h5: begin  // `VGA1_LD4
                      s_State       <= 2'h1;  // `VGA1_State_Ready
                      s_FrameBuffer <= {s_FrameBuffer[63:40], w_InstImm, s_FrameBuffer[31:0]};
                   end
                   4'h6: begin  // `VGA1_LD5
                      s_State       <= 2'h1;  // `VGA1_State_Ready
                      s_FrameBuffer <= {s_FrameBuffer[63:48], w_InstImm, s_FrameBuffer[39:0]};
                   end
                   4'h7: begin  // `VGA1_LD6
                      s_State       <= 2'h1;  // `VGA1_State_Ready
                      s_FrameBuffer <= {s_FrameBuffer[63:56], w_InstImm, s_FrameBuffer[47:0]};
                   end
                   4'h8: begin  // `VGA1_LD7
                      s_State       <= 2'h1;  // `VGA1_State_Ready
                      s_FrameBuffer <= {w_InstImm, s_FrameBuffer[55:0]};
                   end
                   default: begin
                      s_State       <= 2'h2;  // `VGA1_State_Error
                      s_FrameBuffer <= 64'b0;
                   end
                 endcase
              end
              else begin
                 s_State       <= 2'h1;  // `VGA1_State_Ready
                 s_FrameBuffer <= s_FrameBuffer;
              end
           end
           2'h2: begin  // `VGA1_State_Error
              s_State       <= 2'h2;  // `VGA1_State_Error
              s_FrameBuffer <= 64'b0;
           end
           default: begin
              s_State       <= 2'h2;  // `VGA1_State_Error
              s_FrameBuffer <= 64'b0;
           end
         endcase
      end
   end
   
`ifdef SIM
   always @(*) begin
      if (inst_en) begin
         case (w_InstCode)
           4'h0: $sformat(d_Input, "EN NOP");
           4'h1: $sformat(d_Input, "EN (LD0 %8B)", w_InstImm);
           4'h2: $sformat(d_Input, "EN (LD1 %8B)", w_InstImm);
           4'h3: $sformat(d_Input, "EN (LD2 %8B)", w_InstImm);
           4'h4: $sformat(d_Input, "EN (LD3 %8B)", w_InstImm);
           4'h5: $sformat(d_Input, "EN (LD4 %8B)", w_InstImm);
           4'h6: $sformat(d_Input, "EN (LD6 %8B)", w_InstImm);
           4'h7: $sformat(d_Input, "EN (LD6 %8B)", w_InstImm);
           4'h8: $sformat(d_Input, "EN (LD7 %8B)", w_InstImm);
           default: $sformat(d_Input, "EN (? %8B)", w_InstImm);
         endcase
      end
      else begin
         $sformat(d_Input, "NN");
      end
   end
   
   always @(*) begin
      case (s_State)
        2'h0: $sformat(d_State, "X");
        2'h1: $sformat(d_State, "R %8X", s_FrameBuffer);
        2'h2: $sformat(d_State, "E");
        default: $sformat(d_State, "?");
      endcase
   end
`endif
endmodule