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
// Note: Duplicate defines removed for clarity
module VGA1_corrected_ffc (
    clock,
    reset,
    test_mode, // Added for DFT
    test_clk,  // Added for DFT
    inst,
    inst_en,
    vga_hsync,
    vga_vsync,
    vga_r,
    vga_g,
    vga_b
);

   input wire        clock;
   input wire        reset;
   input wire        test_mode; // Added for DFT
   input wire        test_clk;  // Added for DFT
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

   // Internal clock selection for DFT
   wire              internal_clk;
   assign internal_clk = test_mode ? test_clk : clock;


`ifdef SIM // Keep simulation-only regs separate
   reg [256*8-1:0]   d_Input;
   reg [256*8-1:0]   d_State;
`endif

   assign w_InstCode = inst[11:8];
   assign w_InstImm = inst[7:0];

   // Instantiate VGA1Interface with the potentially DFT-controlled clock
   VGA1Interface vgaint (
       .clock(internal_clk), // Use selected clock
       .reset(reset),
       .framebuffer(s_FrameBuffer),
       .vga_hsync(vga_hsync),
       .vga_vsync(vga_vsync),
       .vga_r(vga_r),
       .vga_g(vga_g),
       .vga_b(vga_b)
   );

   // Main state machine and framebuffer logic clocked by the selected clock
   always @ (posedge internal_clk) begin // Use selected clock
      if (reset) begin
         s_State       <= `VGA1_State_Reset;
         s_FrameBuffer <= 64'b0; // Explicit width
      end
      else begin
         case (s_State)
           `VGA1_State_Reset: begin
              s_State       <= `VGA1_State_Ready;
              s_FrameBuffer <= 64'b0; // Explicit width
           end
           `VGA1_State_Ready: begin
              if (inst_en) begin
                 case (w_InstCode)
                   `VGA1_NOP: begin
                      // No change required, but explicit assignment is clearer
                      // s_State       <= `VGA1_State_Ready;
                      // s_FrameBuffer <= s_FrameBuffer;
                   end
                   `VGA1_LD0: begin
                      s_State       <= `VGA1_State_Ready;
                      s_FrameBuffer <= {s_FrameBuffer[63:8], w_InstImm};
                   end
                   `VGA1_LD1: begin
                      s_State       <= `VGA1_State_Ready;
                      s_FrameBuffer <= {s_FrameBuffer[63:16], w_InstImm, s_FrameBuffer[7:0]};
                   end
                   `VGA1_LD2: begin
                      s_State       <= `VGA1_State_Ready;
                      s_FrameBuffer <= {s_FrameBuffer[63:24], w_InstImm, s_FrameBuffer[15:0]};
                   end
                   `VGA1_LD3: begin
                      s_State       <= `VGA1_State_Ready;
                      s_FrameBuffer <= {s_FrameBuffer[63:32], w_InstImm, s_FrameBuffer[23:0]};
                   end
                   `VGA1_LD4: begin
                      s_State       <= `VGA1_State_Ready;
                      s_FrameBuffer <= {s_FrameBuffer[63:40], w_InstImm, s_FrameBuffer[31:0]};
                   end
                   `VGA1_LD5: begin
                      s_State       <= `VGA1_State_Ready;
                      s_FrameBuffer <= {s_FrameBuffer[63:48], w_InstImm, s_FrameBuffer[39:0]};
                   end
                   `VGA1_LD6: begin
                      s_State       <= `VGA1_State_Ready;
                      s_FrameBuffer <= {s_FrameBuffer[63:56], w_InstImm, s_FrameBuffer[47:0]};
                   end
                   `VGA1_LD7: begin
                      s_State       <= `VGA1_State_Ready;
                      // Corrected: Load immediate into the most significant byte
                      s_FrameBuffer <= {w_InstImm, s_FrameBuffer[55:0]};
                   end
                   default: begin
                      s_State       <= `VGA1_State_Error;
                      s_FrameBuffer <= 64'b0; // Explicit width
                   end
                 endcase
              end
              // Removed redundant else block for state and framebuffer when inst_en is low,
              // as flip-flops hold their value by default unless assigned otherwise.
           end
           `VGA1_State_Error: begin
              // State remains Error, Framebuffer cleared on entry, stays 0
              // s_State       <= `VGA1_State_Error; // No need to reassign if already in this state
              // s_FrameBuffer <= 64'b0; // Already 0 from previous transition
           end
           default: begin // Handles potential X or Z states
              s_State       <= `VGA1_State_Error;
              s_FrameBuffer <= 64'b0; // Explicit width
           end
         endcase
      end
   end

`ifdef SIM
   // Simulation-only logic remains unchanged
   always @ (*) begin // Use '*' for combinational sensitivity
      if (inst_en) begin
         case (w_InstCode)
           `VGA1_NOP: begin
              $sformat(d_Input,"EN NOP");
           end
           `VGA1_LD0: begin
              $sformat(d_Input,"EN (LD0 %8b)",w_InstImm); // Use %b for binary
           end
           `VGA1_LD1: begin
              $sformat(d_Input,"EN (LD1 %8b)",w_InstImm); // Use %b for binary
           end
           `VGA1_LD2: begin
              $sformat(d_Input,"EN (LD2 %8b)",w_InstImm); // Use %b for binary
           end
           `VGA1_LD3: begin
              $sformat(d_Input,"EN (LD3 %8b)",w_InstImm); // Use %b for binary
           end
           `VGA1_LD4: begin
              $sformat(d_Input,"EN (LD4 %8b)",w_InstImm); // Use %b for binary
           end
           `VGA1_LD5: begin
              $sformat(d_Input,"EN (LD5 %8b)",w_InstImm); // Use %b for binary
           end
           `VGA1_LD6: begin
              $sformat(d_Input,"EN (LD6 %8b)",w_InstImm); // Use %b for binary
           end
           `VGA1_LD7: begin
              $sformat(d_Input,"EN (LD7 %8b)",w_InstImm); // Use %b for binary
           end
           default: begin
              $sformat(d_Input,"EN (? %8b)",w_InstImm); // Use %b for binary
           end
         endcase
      end
      else begin
         $sformat(d_Input,"NN");
      end
   end

   always @ (*) begin // Use '*' for combinational sensitivity
      case (s_State)
        `VGA1_State_Reset: begin
           $sformat(d_State,"X (Reset)"); // More descriptive
        end
        `VGA1_State_Ready: begin
           // Display full 64-bit framebuffer value
           $sformat(d_State,"R %16h",s_FrameBuffer); // Use %h for hex, 16 digits for 64 bits
        end
        `VGA1_State_Error: begin
           $sformat(d_State,"E (Error)"); // More descriptive
        end
        default: begin // Handles potential X or Z states
           $sformat(d_State,"? (Unknown)"); // More descriptive
        end
      endcase
   end
`endif // SIM

endmodule