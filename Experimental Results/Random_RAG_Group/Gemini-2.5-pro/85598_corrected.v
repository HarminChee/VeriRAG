`timescale 1ns / 1ps
// timescale duplicated in original, keep one
module PdmDes(
    input clk,
    input test_i, // Added test mode input
    input en,
    output done,
    output [15:0] dout,
    output pdm_m_clk_o,
    input pdm_m_data_i
    );
parameter C_PDM_FREQ_HZ=2000000;
reg en_int=0;
reg done_int=0;
reg clk_int=0;
reg pdm_clk_rising;
reg [15:0] pdm_tmp, dout_reg; // Changed output reg name
integer cnt_bits=0;
integer cnt_clk=0;

assign done = done_int;
assign pdm_m_clk_o = clk_int;
assign dout = dout_reg; // Assign output from internal reg

always @(posedge clk)
    en_int <= en;

// Gated register pdm_tmp
always @(posedge clk)
  // Functional reset condition
  if (en==0 && !test_i) // Reset only in functional mode
    pdm_tmp <= 16'b0;
  // Update condition: gated or test mode
  else if (pdm_clk_rising || test_i)
     pdm_tmp <= {pdm_tmp[14:0],pdm_m_data_i}; // Data source in test mode needs scan_in

// Gated counter cnt_bits
always @(posedge clk)
begin
  // Functional reset condition
  if (en_int==0 && !test_i) // Reset only in functional mode
    cnt_bits <=0;
  // Update condition: gated or test mode
  else if (pdm_clk_rising || test_i)
  begin
      if (cnt_bits == 15)
          cnt_bits <=0;
      else
          cnt_bits <= cnt_bits + 1;
   end
end

// Gated logic for done_int and dout_reg
always @(posedge clk)
begin
  // Reset done_int logic: In functional mode, done_int is low unless explicitly set high below.
  // In test mode, it holds state unless updated.
  if (!test_i) begin
      // Default assignment for functional mode unless conditions below met
      done_int <= 1'b0;
  end

  // Update logic: gated or test mode
  if (pdm_clk_rising || test_i)
  begin
    if (cnt_bits==0) // Check condition
    begin
        // Update only if enabled in functional mode OR if in test mode
        if (en_int || test_i)
        begin
            done_int <= 1'b1;
            dout_reg <= pdm_tmp; // Data source in test mode needs scan_in
        end
        // else if (!test_i) { done_int <= 1'b0; } // Handled by default assignment above
     end
     // else if (!test_i) { done_int <= 1'b0; } // Handled by default assignment above
     // In test mode (test_i=1), if cnt_bits!=0, done_int and dout_reg hold state for scan chain
  end
end

// Clock generation logic (remains functionally same)
// Registers clk_int, cnt_clk, pdm_clk_rising use primary clock clk
always @(posedge clk)
begin
  if (cnt_clk == 24)
  begin
    cnt_clk <= 0;
    clk_int <= ~clk_int;
    // Generate pulse based on the state *before* the clock edge
    // Pulse pdm_clk_rising high for one cycle when clk_int is about to transition 0 -> 1 (rising edge)
    if (clk_int == 0)
        pdm_clk_rising <= 1;
    else
        pdm_clk_rising <= 0;
  end
  else
  begin
    cnt_clk <= cnt_clk + 1;
    pdm_clk_rising <= 0; // Pulse is only one cycle wide
  end
end
endmodule