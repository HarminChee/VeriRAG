module flash_writer(
    input           p_ready,        // Unused in this snippet
    input           WE_CLK,         // Unused in this snippet
    input           iFLASH_RY_N,
    input           iOSC_28,
    input           iERASE,
    input           iPROGRAM,
    input           iVERIFY,
    input           iOK,
    input           iFAIL,
    input           iRESET_N,
    output          oREAD_PRO_END,
    output          oVERIFY_TIME,
    output [21:0]   oFLASH_ADDR,
    output reg [3:0] oFLASH_CMD,
    output          oFLASH_TR
);

    // Combinational logic for oFLASH_CMD based on inputs
    always @* begin
        case ({iFAIL, iOK, iVERIFY, iPROGRAM, iERASE}) // Removed iRESET_N from case selector as it's usually handled asynchronously
            5'b00100: oFLASH_CMD = 4'h0; // VERIFY
            5'b00001: oFLASH_CMD = 4'h4; // ERASE
            5'b00010: oFLASH_CMD = 4'h1; // PROGRAM
            5'b01000: oFLASH_CMD = 4'h8; // OK (assuming this maps to a command)
            5'b10000: oFLASH_CMD = 4'h9; // FAIL (assuming this maps to a command)
            default:  oFLASH_CMD = 4'hx; // Default case to avoid latches
        endcase
        // Note: The original mapping 6'b001000: oFLASH_CMD = 4'h7; was removed as iRESET_N is handled separately.
        // You might need to adjust the command mapping based on your actual requirements.
    end

    reg [31:0] delay;
    always @(posedge iOSC_28 or negedge iRESET_N) begin
        if (!iRESET_N) begin
            delay <= 32'b0;
        end else begin
            delay <= delay + 1;
        end
    end

    wire ck_prog = delay[5];
    wire ck_read = delay[4];

    localparam [21:0] end_address = 22'h3fffff;

    reg [21:0] addr_prog;
    reg end_prog;
    reg PROGRAM_TR_r;
    reg [7:0] ST_P; // State register for programming

    // Programming state machine and address counter
    always @(posedge ck_prog or negedge iRESET_N) begin
        if (!iRESET_N) begin
            addr_prog    <= end_address; // Start at end or 0? Reset usually clears address
            end_prog     <= 1'b1;
            ST_P         <= 8'd9; // Idle/End state
            PROGRAM_TR_r <= 1'b0;
        end else if (iPROGRAM && ST_P == 8'd9) begin // Start programming sequence only if idle and iPROGRAM is asserted
            addr_prog    <= 22'b0;
            end_prog     <= 1'b0;
            ST_P         <= 8'd0; // Start state
            PROGRAM_TR_r <= 1'b0;
        end else if (!end_prog) begin // Only proceed if programming is active
            case (ST_P)
                8'd0: begin
                    ST_P         <= ST_P + 1;
                    PROGRAM_TR_r <= 1'b1; // Assert trigger
                end
                8'd1: begin
                    ST_P         <= 8'd4; // Wait state? Jump ahead
                    PROGRAM_TR_r <= 1'b0; // Deassert trigger
                end
                8'd2: begin // Unused state in original logic?
                    ST_P <= ST_P + 1;
                end
                8'd3: begin // Unused state in original logic?
                    ST_P <= ST_P + 1;
                end
                8'd4: begin // Wait state?
                    ST_P <= ST_P + 1;
                end
                8'd5: begin // Wait for Flash Ready
                    if (iFLASH_RY_N) begin // Assuming active low ready, wait until high (ready)
                        ST_P <= 8'd7;
                    end else begin
                        ST_P <= 8'd5; // Stay in wait state
                    end
                end
                8'd6: begin // Unused state in original logic?
                    ST_P <= ST_P + 1;
                end
                8'd7: begin // Check if done programming
                    if (addr_prog == end_address) begin
                        ST_P <= 8'd9; // Go to end state
                    end else begin
                        addr_prog <= addr_prog + 1;
                        ST_P      <= 8'd0; // Go back to start next program cycle
                    end
                end
                8'd8: begin // Unused state in original logic? Seems like an alternate path to increment address
                    addr_prog <= addr_prog + 1;
                    ST_P      <= 8'd0;
                end
                8'd9: begin // End/Idle state
                    end_prog <= 1'b1;
                    PROGRAM_TR_r <= 1'b0; // Ensure trigger is low
                end
                default: ST_P <= 8'd9; // Go to idle on unknown state
            endcase
        end
    end

    reg [21:0] addr_read;
    reg end_read;

    // Read/Verify address counter
    always @(posedge ck_read or negedge iRESET_N) begin
        if (!iRESET_N) begin
            addr_read <= end_address; // Reset usually clears address
            end_read  <= 1'b1;
        end else if (iVERIFY && end_read) begin // Start verify sequence only if idle and iVERIFY is asserted
            addr_read <= 22'b0;
            end_read  <= 1'b0;
        end else if (!end_read) begin // Only proceed if verifying is active
            if (addr_read < end_address) begin
                addr_read <= addr_read + 1;
                end_read <= 1'b0; // Keep reading
            end else if (addr_read == end_address) begin
                 // addr_read is already end_address, stay here until next VERIFY or RESET
                end_read <= 1'b1; // Mark read as ended
            end
        end
    end

    // Address Mux based on current command
    assign oFLASH_ADDR = (oFLASH_CMD == 4'h1) ? addr_prog : // Program command
                         (oFLASH_CMD == 4'h0) ? addr_read : // Verify/Read command
                         22'b0; // Default address for other commands

    // Trigger generation
    wire erase_tr   = (oFLASH_CMD == 4'h4); // Trigger during erase command
    wire program_tr = PROGRAM_TR_r;         // Trigger controlled by program state machine
    wire verify_tr  = (oFLASH_CMD == 4'h0) && !end_read; // Trigger during verify command cycle (active while reading)

    assign oFLASH_TR = erase_tr | program_tr | verify_tr;

    // Status outputs
    assign oREAD_PRO_END = end_read & end_prog; // Indicates both processes finished
    assign oVERIFY_TIME  = !end_read;           // High during verify address sweep

endmodule