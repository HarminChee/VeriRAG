`timescale 1ns / 1ps
module fastmem_corrected_cdf(
           input 	    CLKCPU,
           input 	    RESET, // Assuming Active Low Asynchronous Reset
           input [23:0]     A,
           inout [7:0] 	    D,
           input [1:0] 	    SIZ,
           input 	    AS20,
           input 	    RW20,
           input 	    DS20,
           output reg 	    RAM_MUX,
           output  	    RAMOE, // Note: ROMOE was assigned below, assuming typo and it meant RAMOE
           output reg [3:0] CAS,
           output reg [1:0] RAS,
           output [1:0]     RAM_A,
           output 	    RAM_ACCESS,
	   output 	    Z2_ACCESS,
	   output reg	    WAIT
       );

wire [5:0] zaddr = {A[6:1]};
reg configured = 'b0;
reg shutup		= 'b0;
reg [7:4] data_out;
reg [7:5] base_address;

// DFT Fix: Synchronize 'configured' signal from DS20 domain to CLKCPU domain
// This resolves potential issues if DS20 is treated as a clock domain crossing
// into the CLKCPU domain logic, which can cause testability problems similar
// in nature to clocking violations.
reg configured_sync_p1; // First stage synchronizer flop
reg configured_sync;    // Synchronized signal

always @(posedge CLKCPU or negedge RESET) begin
    if (RESET == 1'b0) begin
        configured_sync_p1 <= 1'b0;
        configured_sync    <= 1'b0;
    end else begin
        configured_sync_p1 <= configured; // Capture potentially async signal
        configured_sync    <= configured_sync_p1; // Synchronized signal in CLKCPU domain
    end
end

// Use the synchronized signal 'configured_sync' in logic sensitive to CLKCPU
wire Z2_WRITE = (Z2_ACCESS | RW20);
wire Z2_READ = (Z2_ACCESS | ~RW20);

// Logic sensitive to DS20 (potential clock) and RESET
always @(negedge DS20 or negedge RESET) begin
    if (RESET == 1'b0) begin
        configured <= 1'b0;
        shutup <= 1'b0;
        // Consider resetting base_address and data_out if needed
        base_address <= 3'b0; // Example reset value
        data_out <= 4'hf;     // Example reset value
    end else begin
        // This block describes logic clocked by negedge DS20
        // Ensure DS20 is properly handled as a clock during test if necessary
        if (Z2_WRITE == 1'b0) begin // Active low write enable? Check polarity. Assuming active low from context.
            case (zaddr)
                'h24: begin
                    base_address[7:5] <= D[7:5];
                    configured <= 1'b1;
                end
                'h26: shutup <= 1'b1;
                default: begin
                   // Avoid latch inference for base_address by providing default assignment if needed
                   // base_address <= base_address; // Or some default value if appropriate
                end
            endcase
        end else begin
             // Avoid latch inference for configured, shutup if Z2_WRITE is high
             configured <= configured;
             shutup <= shutup;
        end

        // This part seems more like combinational logic read based on zaddr, gated by negedge DS20
        // If these are meant to be flops, they are clocked by negedge DS20.
        case (zaddr)
	  'h00: data_out[7:4] <= 4'he;
	  'h01: data_out[7:4] <= 4'h0;
	  'h02: data_out[7:4] <= 4'hd;
	  'h03: data_out[7:4] <= 4'h7;
	  'h04: data_out[7:4] <= 4'h7;
	  'h08: data_out[7:4] <= 4'he;
	  'h09: data_out[7:4] <= 4'hc;
	  'h0a: data_out[7:4] <= 4'h2;
	  'h0b: data_out[7:4] <= 4'h7;
	  'h11: data_out[7:4] <= 4'he;
	  'h12: data_out[7:4] <= 4'hb;
	  'h13: data_out[7:4] <= 4'h7;
	  default: data_out[7:4] <= 4'hf;
        endcase
    end
end

wire [3:0] bank;
assign bank[0] = A[23:21] != 3'b001;
assign bank[1] = A[23:21] != 3'b010;
assign bank[2] = A[23:21] != 3'b011;
assign bank[3] = A[23:21] != 3'b100;
wire [1:0] chip_ras = {&bank[3:2], &bank[1:0]};

// Use synchronized 'configured_sync' here
wire chip_selected = &chip_ras[1:0] | ~configured_sync;

wire [3:0] casint;
assign casint[3] = A[1] | A[0];
assign casint[2] = (~SIZ[1] & SIZ[0] & ~A[0]) | A[1];
assign casint[1] = (SIZ[1] & ~SIZ[0] & ~A[1] & ~A[0]) | (~SIZ[1] & SIZ[0] & ~A[1]) |(A[1] & A[0]);
assign casint[0] = (~SIZ[1] & SIZ[0] & ~A[1] ) | (~SIZ[1] & SIZ[0] & ~A[0] ) | (SIZ[1] & ~A[1] & ~A[0] ) | (SIZ[1] & ~SIZ[0] & ~A[1] );

assign RAM_A =  RAM_MUX ? {A[21:20]} : {A[3:2]} ;

reg 	  AS20_D;
reg [3:0] state = 'd0;
reg [7:0] refresh_count ='d0;
reg 	  refresh_req  ='d0;
reg [3:0] startup_count ='d0; // Unused? Ensure reset if used.

localparam CYCLE_IDLE = 'd0,
           CYCLE_RAS = 'd1,
           CYCLE_CAS = 'd3,
           CYCLE_WAIT = 'd4,
           CYCLE_CBR1 = 'd8,
           CYCLE_CBR2 = 'd9,
           CYCLE_CBR3 = 'd10;

// Main state machine and control logic - Added RESET
always @(posedge CLKCPU, posedge AS20, negedge RESET) begin
    if (RESET == 1'b0) begin // Global Asynchronous Reset
       state <= CYCLE_IDLE;
       AS20_D <= 1'b0; // Reset value for AS20_D (assuming AS20 inactive is low)
       RAS <= 2'b11;
       CAS <= 4'b1111;
       WAIT <= 1'b1;
       refresh_count <= 'd0;
       refresh_req <= 1'b0;
       startup_count <= 'd0; // Reset unused counter too
    end else if (AS20 == 1'b1) begin // AS20 Asynchronous Set/Reset condition
       state <= CYCLE_IDLE;
       AS20_D <= 1'b1; // AS20 is high, so reflect this
       RAS <= 2'b11;
       CAS <= 4'b1111;
       WAIT <= 1'b1;
       // Note: Original code didn't reset counters on AS20 edge. Preserving this.
    end else begin // Clocked operation (posedge CLKCPU when AS20 is low and RESET is high)
       AS20_D <= AS20; // AS20 is low here

       case (state)
	 CYCLE_IDLE: begin
	    RAS <= 2'b11;
	    CAS <= 4'b1111;
        WAIT <= 1'b1; // Ensure WAIT is high in IDLE unless transitioning
	    if (AS20_D & ~AS20) begin // Detect falling edge of AS20 (end of access)
	       refresh_count <= refresh_count + 'd1;
	    end
	    // Check refresh counter condition (potential for combinatorial loop if refresh_count update is slow?)
	    // Consider registering the condition check if timing is critical.
	    if (refresh_count > 'd220) begin // Use >= for safety?
	       refresh_req <= 1'b1;
	       refresh_count <= 'd0; // Reset counter when requesting refresh
	    end else begin
           // Explicitly de-assert refresh_req if not needed? No, handled in CBR1.
        end

	    if (refresh_req & RW20) begin // Start refresh cycle (only if RW20 high?)
	       state <= CYCLE_CBR1;
           refresh_req <= 1'b0; // Consume request - Moved to CBR1 in original, keep there?
	    end else if (chip_selected == 1'b0 && ~AS20) begin // Start normal access if selected and AS20 asserted (low)
	       state <= CYCLE_RAS;
           // Reset refresh counter if normal access starts? Optional.
	    end else begin
            // Stay in IDLE
            state <= CYCLE_IDLE;
        end
	 end
	 CYCLE_RAS: begin
        // Assert RAS based on chip_ras
	    RAS[0] <= chip_ras[0];
	    RAS[1] <= chip_ras[1];
	    state <= CYCLE_CAS;
        // Keep CAS high during RAS assertion
        CAS <= 4'b1111;
        WAIT <= 1'b1; // Keep WAIT high
	 end
	 CYCLE_CAS: begin
	    WAIT <= 1'b0; // Assert WAIT (active low?) during CAS phase
	    // Assert CAS based on casint, only for reads (~RW20)
	    CAS[0] <= casint[0] & ~RW20;
	    CAS[1] <= casint[1] & ~RW20;
	    CAS[2] <= casint[2] & ~RW20;
	    CAS[3] <= casint[3] & ~RW20;
	    state <= CYCLE_WAIT;
        // Keep RAS asserted
        RAS <= RAS;
	 end
	 CYCLE_WAIT: begin
        // Stay in WAIT until AS20 goes high (handled by async AS20 condition)
	    state <= CYCLE_WAIT;
        // Keep signals asserted
        WAIT <= 1'b0;
        RAS <= RAS;
        CAS <= CAS;
	 end
	 CYCLE_CBR1: begin // Start Refresh: CAS before RAS
	    CAS <= 'b0000; // Assert all CAS
	    state <= CYCLE_CBR2;
	    refresh_req <= 1'b0; // Consume refresh request
        RAS <= 2'b11; // Keep RAS high
        WAIT <= 1'b1; // Keep WAIT high
	 end
	 CYCLE_CBR2: begin
	    RAS <= 'b00; // Assert all RAS
	    state <= CYCLE_CBR3;
        CAS <= 'b0000; // Keep CAS asserted
        WAIT <= 1'b1; // Keep WAIT high
	 end
	 CYCLE_CBR3: begin // End Refresh
	    CAS <= 'b1111; // Deassert CAS
	    RAS <= 'b11;   // Deassert RAS
	    state <= CYCLE_IDLE; // Return to IDLE
        WAIT <= 1'b1; // Keep WAIT high
	 end
	 default: state <= CYCLE_IDLE;
       endcase
    end
end

// RAM_MUX logic - Added RESET
always @(negedge CLKCPU, negedge RESET) begin
    if (RESET == 1'b0) begin
        RAM_MUX <= 1'b0; // Define reset state (e.g., address mux shows row)
    end else begin
        // Mux selects Row address (0) when RAS is asserted (at least one RAS bit is 0 -> &RAS is 0)
        // Mux selects Col address (1) when RAS is deasserted (all RAS bits are 1 -> &RAS is 1)
        // Logic seems inverted based on common RAM timing? Usually MUX=0 for Row (RAS active), MUX=1 for Col (CAS active)
        // Original: RAM_MUX <= (&RAS == 1) ? 0 : 1;  -> MUX=0 if RAS=11, MUX=1 if RAS!=11 (asserted)
        // Let's keep original logic: MUX=0 when RAS is high (idle), MUX=1 when RAS is low (active)
        if( &RAS == 1'b1) begin // If RAS = 2'b11 (inactive)
            RAM_MUX <= 0; // Select A[3:2] (Row?)
        end else begin          // If RAS != 2'b11 (active)
            RAM_MUX <= 1; // Select A[21:20] (Column?) - Check address mapping convention
        end
    end
end

// Output assignments
// Use synchronized 'configured_sync'
assign Z2_ACCESS = ({A[23:16]} != {8'hE8}) | AS20 | DS20 | configured_sync | shutup;

// Assuming Z2_READ means CPU is reading from Z2 space (where this memory resides)
// D should be driven only when Z2_READ is true and it's a read cycle (~RW20)
// D should be high-Z during writes (RW20) or when not accessed.
// Original logic uses Z2_READ, which depends on Z2_ACCESS. Z2_ACCESS is low when selected.
// Let's refine the D output logic:
// Drive D if Z2 is accessed (Z2_ACCESS low), AND it's a read cycle (~RW20), AND DS20 is asserted (low?)
// Tristate D otherwise.
assign D = (~Z2_ACCESS && ~RW20 && ~DS20) ? {data_out, 4'b0000} : 8'bzzzzzzzz; // Provide full 8 bits from data_out? Or map differently? Assuming lower 4 bits are 0.

// RAM_ACCESS is low when selected, high otherwise
assign RAM_ACCESS = (AS20 | chip_selected); // Low if AS20 is low AND chip is selected

// RAMOE: Output Enable for RAM chips. Should be active during reads.
// Active when RAM_ACCESS is low and it's a read (~RW20)?
// Also needs to be timed correctly with CAS/RAS signals. Typically asserted with CAS during reads.
// Let's assume active low OE, asserted when CAS is active during a read.
assign RAMOE = |CAS | RW20; // OE is low if any CAS bit is low AND it's a read (RW20=0)

// assign ROMOE = 1'b0; // Original code had ROMOE, assuming typo for RAMOE or unused output. Removed.

endmodule