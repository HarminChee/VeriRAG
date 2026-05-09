module acl_data_fifo 
#(
    parameter integer DATA_WIDTH = 32,          
    parameter integer DEPTH = 32,               
    parameter integer STRICT_DEPTH = 0,         
    parameter integer ALLOW_FULL_WRITE = 0,     
    parameter string IMPL = "ram",              
    parameter integer ALMOST_FULL_VALUE = 0,    
    parameter LPM_HINT = "unused",
    parameter integer BACK_LL_REG_DEPTH = 2,  
    parameter string ACL_FIFO_IMPL = "basic"    
)
(
    input logic clock,
    input logic resetn,
    input logic [DATA_WIDTH-1:0] data_in,       
    output logic [DATA_WIDTH-1:0] data_out,     
    input logic valid_in,
    output logic valid_out,
    input logic stall_in,
    output logic stall_out,
    output logic empty,
    output logic full,
    output logic almost_full
);
    generate
        if( DATA_WIDTH > 0 )
        begin
            if( IMPL == "ram" )
            begin
                acl_fifo #(
                    .DATA_WIDTH(DATA_WIDTH),
                    .DEPTH(DEPTH),
                    .ALMOST_FULL_VALUE(ALMOST_FULL_VALUE),
                    .LPM_HINT(LPM_HINT),
                    .IMPL(ACL_FIFO_IMPL)
                )
                fifo (
                    .clock(clock),
                    .resetn(resetn),
                    .data_in(data_in),
                    .data_out(data_out),
                    .valid_in(valid_in),
                    .valid_out(valid_out),
                    .stall_in(stall_in),
                    .stall_out(stall_out),
                    .empty(empty),
                    .full(full),
                    .almost_full(almost_full)
                );
            end
            else if( (IMPL == "ll_reg" || IMPL == "shift_reg") && DEPTH >= 2 && !ALLOW_FULL_WRITE )
            begin
                wire r_valid;
                wire [DATA_WIDTH-1:0] r_data;
                wire staging_reg_stall;
                localparam ALMOST_FULL_DEPTH_LOG2 = $clog2(DEPTH); 
                localparam ALMOST_FULL_DEPTH_SNAPPED_TO_POW_OF_2 = 1 << ALMOST_FULL_DEPTH_LOG2;
                localparam ALMOST_FULL_COUNTER_OFFSET = ALMOST_FULL_DEPTH_SNAPPED_TO_POW_OF_2 - ALMOST_FULL_VALUE;
                reg [ALMOST_FULL_DEPTH_LOG2:0]  almost_full_counter;
                wire    input_accepted_for_counter;
                wire    output_accepted_for_counter;
                assign  input_accepted_for_counter  = valid_in & ~stall_out;
                assign  output_accepted_for_counter = ~stall_in & valid_out;
                assign  almost_full                 = almost_full_counter[ALMOST_FULL_DEPTH_LOG2];
                always @(posedge clock or negedge resetn)
                begin
                  if (~resetn)
                  begin
                    almost_full_counter <= ALMOST_FULL_COUNTER_OFFSET;
                  end
                  else
                  begin
                    almost_full_counter <= almost_full_counter  + input_accepted_for_counter - output_accepted_for_counter; 
                  end
                end 
                acl_data_fifo #(
                    .DATA_WIDTH(DATA_WIDTH),
                    .DEPTH(DEPTH-1),
                    .ALLOW_FULL_WRITE(1),
                    .IMPL(IMPL)
                )
                fifo (
                    .clock(clock),
                    .resetn(resetn),
                    .data_in(data_in),
                    .data_out(r_data),
                    .valid_in(valid_in),
                    .valid_out(r_valid),
                    .empty(empty),
                    .stall_in(staging_reg_stall),
                    .stall_out(stall_out)
                );
                acl_staging_reg #(
                   .WIDTH(DATA_WIDTH)
                ) staging_reg (
                   .clk(clock), 
                   .reset(~resetn), 
                   .i_data(r_data), 
                   .i_valid(r_valid), 
                   .o_stall(staging_reg_stall), 
                   .o_data(data_out), 
                   .o_valid(valid_out), 
                   .i_stall(stall_in)
                );
            end
            else if( IMPL == "shift_reg" && DEPTH <= 1)
            begin
                reg [DEPTH-1:0] r_valid_NO_SHIFT_REG;
                reg [DATA_WIDTH-1:0] r_data_NO_SHIFT_REG;
                assign empty = 1'b0;
                always @(posedge clock or negedge resetn) begin
                    if (!resetn) begin
                        r_valid_NO_SHIFT_REG <= 1'b0;
                    end else begin 
                        if (!stall_in) begin
                            r_valid_NO_SHIFT_REG <= valid_in;
                        end
                    end
                end    
                always @(posedge clock) begin
                        if (!stall_in) begin
                            r_data_NO_SHIFT_REG <= data_in;
                        end
                end
                assign stall_out = stall_in; 
                assign valid_out = r_valid_NO_SHIFT_REG;
                assign data_out = r_data_NO_SHIFT_REG;
            end
            else if( IMPL == "shift_reg" )
            begin
                reg [DEPTH-1:0] r_valid;
                reg [DATA_WIDTH-1:0] r_data[0:DEPTH-1];
                assign empty = 1'b0;
                always @(posedge clock or negedge resetn) begin
                    if (!resetn) begin
                        r_valid <= {(DEPTH){1'b0}};
                    end else begin
                        if (!stall_in) begin
                            r_valid[0] <= valid_in;
                            for (int i = 1; i < DEPTH; i++) begin
                                    r_valid[i] <= r_valid[i - 1];
                            end
                        end
                    end
                end    
                always @(posedge clock) begin
                     if (!stall_in) begin
                         r_data[0]  <= data_in;
                         for (int i = 1; i < DEPTH; i++) begin
                                 r_data[i]  <= r_data[i - 1];
                         end
                     end
                end
                assign stall_out = stall_in; 
                assign valid_out = r_valid[DEPTH-1];
                assign data_out = r_data[DEPTH-1];
            end
            else if( IMPL == "ll_reg" )
            begin
                logic write, read;
                assign write = valid_in & ~stall_out;
                assign read = ~stall_in & ~empty;
                acl_ll_fifo #(
                    .WIDTH(DATA_WIDTH),
                    .DEPTH(DEPTH),
                    .ALMOST_FULL_VALUE(ALMOST_FULL_VALUE)
                )
                fifo (
                    .clk(clock),
                    .reset(~resetn),
                    .data_in(data_in),
                    .write(write),
                    .data_out(data_out),
                    .read(read),
                    .empty(empty),
                    .full(full),
                    .almost_full(almost_full)
                );
                assign valid_out = ~empty;
                assign stall_out = ALLOW_FULL_WRITE ? (full & stall_in) : full;
            end
            else if( IMPL == "ll_ram" )
            begin
                acl_ll_ram_fifo #(
                    .DATA_WIDTH(DATA_WIDTH),
                    .DEPTH(DEPTH)
                )
                fifo (
                    .clock(clock),
                    .resetn(resetn),
                    .data_in(data_in),
                    .data_out(data_out),
                    .valid_in(valid_in),
                    .valid_out(valid_out),
                    .stall_in(stall_in),
                    .stall_out(stall_out),
                    .empty(empty),
                    .full(full)
                );
            end
            else if( IMPL == "passthrough" )
            begin
                assign valid_out = valid_in; 
                assign stall_out = stall_in;
                assign data_out = data_in;
            end
            else if( IMPL == "ram_plus_reg" )
            begin
                wire [DATA_WIDTH-1:0] rdata2;
                wire v2;
                wire s2;
                acl_fifo #(
                    .DATA_WIDTH(DATA_WIDTH),
                    .DEPTH(DEPTH),
                    .ALMOST_FULL_VALUE(ALMOST_FULL_VALUE),
                    .LPM_HINT(LPM_HINT),
                    .IMPL(ACL_FIFO_IMPL)
                )
                fifo_inner (
                    .clock(clock),
                    .resetn(resetn),
                    .data_in(data_in),
                    .data_out(rdata2),
                    .valid_in(valid_in),
                    .valid_out(v2),
                    .stall_in(s2),
                    .empty(empty),
                    .stall_out(stall_out),
                    .almost_full(almost_full)
                );
                acl_data_fifo #(
                    .DATA_WIDTH(DATA_WIDTH),
                    .DEPTH(2),
                    .IMPL("ll_reg")
                )
                fifo_outer (
                    .clock(clock),
                    .resetn(resetn),
                    .data_in(rdata2),
                    .data_out(data_out),
                    .valid_in(v2),
                    .valid_out(valid_out),
                    .stall_in(stall_in),
                    .stall_out(s2)
                );
            end
            else if( IMPL == "sandwich" )
            begin
                wire [DATA_WIDTH-1:0] rdata1;
                wire [DATA_WIDTH-1:0] rdata2;
                wire v1, v2;
                wire s1, s2;
                acl_data_fifo #(
                    .DATA_WIDTH(DATA_WIDTH),
                    .DEPTH(2),
                    .IMPL("ll_reg")
                )
                fifo_outer1 (
                    .clock(clock),
                    .resetn(resetn),
                    .data_in(data_in),
                    .data_out(rdata1),
                    .valid_in(valid_in),
                    .valid_out(v1),
                    .stall_in(s1),
                    .stall_out(stall_out)
                );
                acl_fifo #(
                    .DATA_WIDTH(DATA_WIDTH),
                    .DEPTH(DEPTH),
                    .ALMOST_FULL_VALUE(ALMOST_FULL_VALUE),
                    .LPM_HINT(LPM_HINT),
                    .IMPL(ACL_FIFO_IMPL)
                )
                fifo_inner (
                    .clock(clock),
                    .resetn(resetn),
                    .data_in(rdata1),
                    .data_out(rdata2),
                    .valid_in(v1),
                    .valid_out(v2),
                    .stall_in(s2),
                    .stall_out(s1),
                    .empty(empty),
                    .almost_full(almost_full)
                );
                acl_data_fifo #(
                    .DATA_WIDTH(DATA_WIDTH),
                    .DEPTH(BACK_LL_REG_DEPTH),
                    .IMPL("ll_reg")
                )
                fifo_outer2 (
                    .clock(clock),
                    .resetn(resetn),
                    .data_in(rdata2),
                    .data_out(data_out),
                    .valid_in(v2),
                    .valid_out(valid_out),
                    .stall_in(stall_in),
                    .stall_out(s2)
                );
            end
            else if( IMPL == "zl_reg" || IMPL == "zl_ram" )
            begin
                logic [DATA_WIDTH-1:0] fifo_data_in, fifo_data_out;
                logic fifo_valid_in, fifo_valid_out;
                logic fifo_stall_in, fifo_stall_out;
                acl_data_fifo #(
                    .DATA_WIDTH(DATA_WIDTH),
                    .DEPTH(DEPTH),
                    .ALLOW_FULL_WRITE(ALLOW_FULL_WRITE),
                    .IMPL(IMPL == "zl_reg" ? "ll_reg" : "ll_ram"),
                    .ALMOST_FULL_VALUE(ALMOST_FULL_VALUE)
                )
                fifo (
                    .clock(clock),
                    .resetn(resetn),
                    .data_in(fifo_data_in),
                    .data_out(fifo_data_out),
                    .valid_in(fifo_valid_in),
                    .valid_out(fifo_valid_out),
                    .stall_in(fifo_stall_in),
                    .stall_out(fifo_stall_out),
                    .empty(empty),
                    .full(full),
                    .almost_full(almost_full)
                );
		wire staging_reg_stall;
                assign fifo_data_in = data_in;
                assign fifo_valid_in = valid_in & (staging_reg_stall | fifo_valid_out);
                assign fifo_stall_in = staging_reg_stall;
                assign stall_out = fifo_stall_out;
                acl_staging_reg #(
                   .WIDTH(DATA_WIDTH)
                ) staging_reg (
                   .clk(clock), 
                   .reset(~resetn), 
                   .i_data(fifo_valid_out ? fifo_data_out : data_in), 
                   .i_valid(fifo_valid_out | valid_in), 
                   .o_stall(staging_reg_stall), 
                   .o_data(data_out), 
                   .o_valid(valid_out), 
                   .i_stall(stall_in)
                );
            end
         end
         else 
         begin
            if( IMPL == "ram" || IMPL == "ram_plus_reg" || IMPL == "ll_reg" || IMPL == "ll_ram" || IMPL == "ll_counter" )
            begin
                acl_valid_fifo_counter #(
                    .DEPTH(DEPTH),
                    .STRICT_DEPTH(STRICT_DEPTH),
                    .ALLOW_FULL_WRITE(ALLOW_FULL_WRITE)
                )
                counter (
                    .clock(clock),
                    .resetn(resetn),
                    .valid_in(valid_in),
                    .valid_out(valid_out),
                    .stall_in(stall_in),
                    .stall_out(stall_out),
                    .empty(empty),
                    .full(full)
                );
             end
             else if( IMPL == "zl_reg" || IMPL == "zl_ram" || IMPL == "zl_counter" )
             begin
                logic fifo_valid_in, fifo_valid_out;
                logic fifo_stall_in, fifo_stall_out;
                acl_data_fifo #(
                    .DATA_WIDTH(DATA_WIDTH),
                    .DEPTH(DEPTH),
                    .STRICT_DEPTH(STRICT_DEPTH),
                    .ALLOW_FULL_WRITE(ALLOW_FULL_WRITE),
                    .IMPL("ll_counter")
                )
                fifo (
                    .clock(clock),
                    .resetn(resetn),
                    .valid_in(fifo_valid_in),
                    .valid_out(fifo_valid_out),
                    .stall_in(fifo_stall_in),
                    .stall_out(fifo_stall_out),
                    .empty(empty),
                    .full(full)
                );
                assign fifo_valid_in = valid_in & (stall_in | fifo_valid_out);
                assign fifo_stall_in = stall_in;
                assign stall_out = fifo_stall_out;
                assign valid_out = fifo_valid_out | valid_in;
             end
         end
    endgenerate
endmodule
