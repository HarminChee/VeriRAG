`define VGA1_NOP 4'h0
`define VGA1_LD0 4'h1
`define VGA1_LD1 4'h2
`define VGA1_LD2 4'h3
`define VGA1_LD3 4'h4
`define VGA1_LD4 4'h5
`define VGA1_LD5 4'h6
`define VGA1_LD6 4'h7
`define VGA1_LD7 4'h8
`define VGA1_State_Reset 2'h0
`define VGA1_State_Ready 2'h1
`define VGA1_State_Error 2'h2
module VGA1_corrected_ffc(clock, reset, inst, inst_en, vga_hsync, vga_vsync, vga_r, vga_g, vga_b, scan_in, scan_en, scan_out);
   input wire        clock;
   input wire        reset;
   input wire [11:0] inst;
   input wire        inst_en;
   output wire       vga_hsync;
   output wire       vga_vsync;
   output wire       vga_r;
   output wire       vga_g;
   output wire       vga_b;
   input wire        scan_in;
   input wire        scan_en;
   output wire       scan_out;
   reg [1:0]         s_State;
   reg [63:0]        s_FrameBuffer;
   wire [3:0]        w_InstCode;
   wire [7:0]        w_InstImm;
   reg [256*8-1:0]   d_Input;
   reg [256*8-1:0]   d_State;
   assign w_InstCode = inst[11:8];
   assign w_InstImm = inst[7:0];
   VGA1Interface
   vgaint (.clock(clock),
           .reset(reset),
           .framebuffer(s_FrameBuffer),
           .vga_hsync(vga_hsync),
           .vga_vsync(vga_vsync),
           .vga_r(vga_r),
           .vga_g(vga_g),
           .vga_b(vga_b));
   always @ (posedge clock or posedge reset) begin
      if (reset) begin
         s_State       <= `VGA1_State_Reset;
         s_FrameBuffer <= 0;
      end
      else begin
         if (scan_en) begin
            s_State       <= {s_State[0], scan_in};
            s_FrameBuffer <= {s_FrameBuffer[62:0], s_State[1]};
         end
         else begin
            case (s_State)
              `VGA1_State_Reset: begin
                 s_State       <= `VGA1_State_Ready;
                 s_FrameBuffer <= 0;
              end
              `VGA1_State_Ready: begin
                 if (inst_en) begin
                    case (w_InstCode)
                      `VGA1_NOP: begin
                         s_State       <= `VGA1_State_Ready;
                         s_FrameBuffer <= s_FrameBuffer;
                      end
                      `VGA1_LD0: begin
                         s_State       <= `VGA1_State_Ready;
                         s_FrameBuffer <= {s_FrameBuffer[63:8],w_InstImm};
                      end
                      `VGA1_LD1: begin
                         s_State       <= `VGA1_State_Ready;
                         s_FrameBuffer <= {s_FrameBuffer[63:16],w_InstImm,s_FrameBuffer[7:0]};
                      end
                      `VGA1_LD2: begin
                         s_State       <= `VGA1_State_Ready;
                         s_FrameBuffer <= {s_FrameBuffer[63:24],w_InstImm,s_FrameBuffer[15:0]};
                      end
                      `VGA1_LD3: begin
                         s_State       <= `VGA1_State_Ready;
                         s_FrameBuffer <= {s_FrameBuffer[63:32],w_InstImm,s_FrameBuffer[23:0]};
                      end
                      `VGA1_LD4: begin
                         s_State       <= `VGA1_State_Ready;
                         s_FrameBuffer <= {s_FrameBuffer[63:40],w_InstImm,s_FrameBuffer[31:0]};
                      end
                      `VGA1_LD5: begin
                         s_State       <= `VGA1_State_Ready;
                         s_FrameBuffer <= {s_FrameBuffer[63:48],w_InstImm,s_FrameBuffer[39:0]};
                      end
                      `VGA1_LD6: begin
                         s_State       <= `VGA1_State_Ready;
                         s_FrameBuffer <= {s_FrameBuffer[63:56],w_InstImm,s_FrameBuffer[47:0]};
                      end
                      `VGA1_LD7: begin
                         s_State       <= `VGA1_State_Ready;
                         s_FrameBuffer <= {w_InstImm,s_FrameBuffer[55:0]};
                      end
                      default: begin
                         s_State       <= `VGA1_State_Error;
                         s_FrameBuffer <= 0;
                      end
                    endcase 
                 end 
                 else begin
                    s_State       <= `VGA1_State_Ready;
                    s_FrameBuffer <= s_FrameBuffer;
                 end 
              end 
              `VGA1_State_Error: begin
                 s_State       <= `VGA1_State_Error;
                 s_FrameBuffer <= 0;
              end
              default: begin
                 s_State       <= `VGA1_State_Error;
                 s_FrameBuffer <= 0;
              end
            endcase 
         end 
      end 
   end 
   assign scan_out = s_FrameBuffer[63];
`ifdef SIM
   always @ * begin
      if (inst_en) begin
         case (w_InstCode)
           `VGA1_NOP: begin
              $sformat(d_Input,"EN NOP");
           end
           `VGA1_LD0: begin
              $sformat(d_Input,"EN (LD0 %8B)",w_InstImm);
           end
           `VGA1_LD1: begin
              $sformat(d_Input,"EN (LD1 %8B)",w_InstImm);
           end
           `VGA1_LD2: begin
              $sformat(d_Input,"EN (LD2 %8B)",w_InstImm);
           end
           `VGA1_LD3: begin
              $sformat(d_Input,"EN (LD3 %8B)",w_InstImm);
           end
           `VGA1_LD4: begin
              $sformat(d_Input,"EN (LD4 %8B)",w_InstImm);
           end
           `VGA1_LD5: begin
              $sformat(d_Input,"EN (LD5 %8B)",w_InstImm);
           end
           `VGA1_LD6: begin
              $sformat(d_Input,"EN (LD6 %8B)",w_InstImm);
           end
           `VGA1_LD7: begin
              $sformat(d_Input,"EN (LD7 %8B)",w_InstImm);
           end
           default: begin
              $sformat(d_Input,"EN (? %8B)",w_InstImm);
           end
         endcase 
      end 
      else begin
         $sformat(d_Input,"NN");
      end 
   end 
   always @ * begin
      case (s_State)
        `VGA1_State_Reset: begin
           $sformat(d_State,"X");
        end
        `VGA1_State_Ready: begin
           $sformat(d_State,"R %8X",s_FrameBuffer);
        end
        `VGA1_State_Error: begin
           $sformat(d_State,"E");
        end
        default: begin
           $sformat(d_State,"?");
        end
      endcase 
   end 
`endif 
endmodule