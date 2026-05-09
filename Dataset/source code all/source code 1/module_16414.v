module acl_stall_free_sink 
#(
    parameter integer DATA_WIDTH = 32,         
    parameter integer PIPELINE_DEPTH = 32,
    parameter integer SHARINGII = 1,
    parameter integer SCHEDULEII = 1,
    parameter integer ALWAYS_THROTTLE = 0
)
(
    input  logic clock,
    input  logic resetn,
    input  logic [DATA_WIDTH-1:0] data_in,  
    output logic [DATA_WIDTH-1:0] data_out,
    input  logic input_accepted,
    input  logic valid_in,
    output logic valid_out,
    input  logic stall_in,
    output logic stall_entry,
    output logic [SHARINGII-1:0] IIphases,
    input logic inc_pipelined_thread,
    input logic dec_pipelined_thread
);
    reg shift_reg;
    reg [DATA_WIDTH-1:0] reg_data_in;
    localparam FIFO_DEPTH_LOG2 = CLogB2(PIPELINE_DEPTH);
    localparam FIFO_DEPTH = 1 << FIFO_DEPTH_LOG2;
    reg [FIFO_DEPTH_LOG2:0] counter;
    reg [SHARINGII-1:0] IIshreg;
    wire output_accepted;
    wire staging_reg_stall;
    wire fifo_valid;
    wire [DATA_WIDTH-1:0] fifo_data;
    wire throttle_pipelined_iterations;  
    assign stall_entry = counter[FIFO_DEPTH_LOG2] | (!IIshreg[0]) | throttle_pipelined_iterations;
    assign output_accepted = fifo_valid & ~staging_reg_stall;
    assign IIphases = IIshreg;
    generate 
    if (SHARINGII == 1) begin
       assign IIshreg = 1;
    end else begin
        always @(posedge clock or negedge resetn)
        begin
           if (!resetn)
           begin
              IIshreg <= {{(SHARINGII - 1){1'b0}},1'b1};
           end 
           else
           begin
              IIshreg <= {IIshreg,IIshreg[SHARINGII-1]};
           end
        end
    end
    endgenerate
    reg[$clog2(SCHEDULEII):0] IIschedcount;
    reg[$clog2(SCHEDULEII):0] threads_count;
    always @(posedge clock or negedge resetn)
    begin
       if (!resetn) begin
          IIschedcount <= 0;
          threads_count <= 0;
       end else begin
          if (IIshreg[0]) begin
             IIschedcount <= ((ALWAYS_THROTTLE == 0 ) && input_accepted && dec_pipelined_thread ) ? IIschedcount : (IIschedcount == (SCHEDULEII - 1) ? 0 : (IIschedcount + 1));
          end
          if (input_accepted) begin
             threads_count <= (ALWAYS_THROTTLE) ? ( inc_pipelined_thread ? 2'b01 : threads_count ) : ( threads_count + inc_pipelined_thread - dec_pipelined_thread );
          end
       end
    end 
    assign throttle_pipelined_iterations = (IIschedcount >= (threads_count > 0 ? threads_count : 1));
    always @(posedge clock or negedge resetn)
    begin
       if (!resetn)
       begin
          shift_reg <= 1'b0;
          counter <= {(FIFO_DEPTH_LOG2+1){1'b0}};
          reg_data_in <= 'x;
       end
       else
       begin
          shift_reg <= valid_in;
          counter <= counter + input_accepted - output_accepted;
          reg_data_in <= data_in;
       end
    end 
    acl_fifo #(
      .DATA_WIDTH(DATA_WIDTH),
      .DEPTH(FIFO_DEPTH)
    )
    fifo (
      .clock(clock),
      .resetn(resetn),
      .data_in(reg_data_in),
      .data_out(fifo_data),
      .valid_in(shift_reg),
      .valid_out(fifo_valid),
      .stall_in(staging_reg_stall)
    );
    acl_staging_reg #(
      .WIDTH(DATA_WIDTH)
    ) staging_reg (
      .clk(clock), 
      .reset(~resetn), 
      .i_data(fifo_data), 
      .i_valid(fifo_valid), 
      .o_stall(staging_reg_stall), 
      .o_data(data_out), 
      .o_valid(valid_out), 
      .i_stall(stall_in)
    );
    function integer CLogB2;
       input [31:0] Depth;
       integer i;
       begin
           i = Depth;        
           for(CLogB2 = 0; i > 0; CLogB2 = CLogB2 + 1)
              i = i >> 1;
       end
    endfunction
endmodule
