module flash_writer_corrected_ffc (
  input         p_ready,
  input         WE_CLK,       // Unused in the provided logic snippet
  input         iFLASH_RY_N,
  input         iOSC_28,      // Primary clock
  input         iERASE,
  input         iPROGRAM,
  input         iVERIFY,
  input         iOK,
  input         iFAIL,
  input         iRESET_N,     // Assumed active-low asynchronous reset
  output        oREAD_PRO_END,
  output        oVERIFY_TIME,
  output [21:0] oFLASH_ADDR,
  output reg [3:0] oFLASH_CMD,
  output        oFLASH_TR
);

  // Generate oFLASH_CMD based on control signals, clocked by primary clock
  always @(posedge iOSC_28 or negedge iRESET_N) begin
    if (!iRESET_N) begin
      oFLASH_CMD <= 4'h0; // Define reset state
    end else begin
      case ({iFAIL, iOK, 1'b0, iVERIFY, iPROGRAM, iERASE}) // Assuming iRESET_N shouldn't be in sensitivity list for command generation? Use a placeholder '0' if reset is handled async. Or remove iRESET_N from case if it's purely async reset. Let's assume it's not part of the command encoding.
        6'b000100: oFLASH_CMD <= 4'h0; // VERIFY
        6'b000001: oFLASH_CMD <= 4'h4; // ERASE
        6'b000010: oFLASH_CMD <= 4'h1; // PROGRAM
        6'b001000: oFLASH_CMD <= 4'h7; // OK (assuming this maps to a command) - Check original intent if needed
        6'b010000: oFLASH_CMD <= 4'h8; // FAIL (assuming this maps to a command) - Check original intent if needed
        // 6'b100000: oFLASH_CMD <= 4'h9; // Original had iRESET_N here, seems incorrect for command generation. Assuming this case is unused or needs redefinition.
        default: oFLASH_CMD <= oFLASH_CMD; // Keep current command if no match
      endcase
    end
  end

  // Internal counter for generating enable signals
  reg [31:0] delay;
  always @(posedge iOSC_28 or negedge iRESET_N) begin
    if (!iRESET_N) begin
      delay <= 32'b0;
    end else begin
      delay <= delay + 1;
    end
  end

  // Generate clock enables based on counter transitions (detect rising edge)
  reg delay_5_prev;
  reg delay_4_prev;

  always @(posedge iOSC_28 or negedge iRESET_N) begin
    if (!iRESET_N) begin
      delay_5_prev <= 1'b0;
      delay_4_prev <= 1'b0;
    end else begin
      delay_5_prev <= delay[5];
      delay_4_prev <= delay[4];
    end
  end

  wire prog_enable = (delay[5] == 1'b1) && (delay_5_prev == 1'b0);
  wire read_enable = (delay[4] == 1'b1) && (delay_4_prev == 1'b0);

  // Programming Address Counter and State Machine
  localparam P_END_ADDR = 22'h3fffff;
  reg [21:0] addr_prog;
  reg        end_prog;
  reg        PROGRAM_TR_r;
  reg [7:0]  ST_P; // State register for programming

  always @(posedge iOSC_28 or negedge iRESET_N) begin
    if (!iRESET_N) begin
      addr_prog    <= P_END_ADDR;
      end_prog     <= 1'b1;
      ST_P         <= 8'd9; // Reset to idle/end state
      PROGRAM_TR_r <= 1'b0;
    end else if (iPROGRAM) begin // Synchronous start/reset triggered by iPROGRAM
      addr_prog    <= 22'b0;
      end_prog     <= 1'b0;
      ST_P         <= 8'd0; // Start state
      PROGRAM_TR_r <= 1'b0;
    end else if (prog_enable) begin // Update state machine only when prog_enable is asserted
      case (ST_P)
        0: begin
          ST_P         <= ST_P + 1;
          PROGRAM_TR_r <= 1'b1; // Assert trigger
        end
        1: begin
          ST_P         <= 8'd4; // Skip states 2, 3? Check original logic intent.
          PROGRAM_TR_r <= 1'b0; // Deassert trigger
        end
        2: begin
          ST_P <= ST_P + 1;
        end
        3: begin
          ST_P <= ST_P + 1;
        end
        4: begin // Wait state?
          ST_P <= ST_P + 1;
        end
        5: begin // Wait for Flash Ready
          if (iFLASH_RY_N) ST_P <= 8'd7; // Ready, proceed to check address
        end
        6: begin // Unused state?
          ST_P <= ST_P + 1;
        end
        7: begin // Check address and increment or finish
          if (addr_prog == P_END_ADDR) begin
            ST_P <= 8'd9; // Go to end state
          end else begin
            addr_prog <= addr_prog + 1;
            ST_P      <= 8'd0; // Go back to start for next word
          end
        end
        8: begin // Unused state? Original logic could reach here from state 7 else. Merged into state 7.
          // If needed separately:
          // addr_prog <= addr_prog + 1;
          // ST_P <= 8'd0;
          ST_P <= 8'd9; // Go to end state if reached unexpectedly
        end
        9: begin // End state
          end_prog <= 1'b1;
          // ST_P remains 9
        end
        default: begin
          ST_P         <= 8'd9; // Default to end state
          PROGRAM_TR_r <= 1'b0;
        end
      endcase
    end // end if (prog_enable)
  end // end always

  // Read/Verify Address Counter
  reg [21:0] addr_read;
  reg        end_read;

  always @(posedge iOSC_28 or negedge iRESET_N) begin
    if (!iRESET_N) begin
      addr_read <= P_END_ADDR;
      end_read  <= 1'b1;
    end else if (iVERIFY) begin // Synchronous start/reset triggered by iVERIFY
      addr_read <= 22'b0;
      end_read  <= 1'b0;
    end else if (read_enable) begin // Update address only when read_enable is asserted
      if (addr_read < P_END_ADDR) begin
        addr_read <= addr_read + 1;
        end_read <= 1'b0; // Ensure end_read is low while reading
      end else if (addr_read == P_END_ADDR) begin
        end_read <= 1'b1; // Reached end
        // addr_read remains P_END_ADDR
      end
    end // end if(read_enable)
  end // end always

  // Output assignments
  assign oFLASH_ADDR = (oFLASH_CMD == 4'h1) ? addr_prog :
                       (oFLASH_CMD == 4'h0) ? addr_read :
                       22'b0; // Default address

  wire erase_tr   = iERASE; // Erase trigger active when iERASE is high
  wire porgram_tr = PROGRAM_TR_r; // Program trigger controlled by state machine
  wire verify_tr  = iVERIFY && !end_read; // Verify trigger active during verify op before end

  assign oFLASH_TR = erase_tr | porgram_tr | verify_tr;

  assign oREAD_PRO_END = end_read & end_prog; // Both operations finished
  assign oVERIFY_TIME  = iVERIFY && !end_read; // Indicates verify operation is ongoing (before end_read)

endmodule