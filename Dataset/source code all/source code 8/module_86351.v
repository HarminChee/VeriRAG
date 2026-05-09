module acl_profile_counter
(
  clock,
  resetn,
  enable,
  shift,
  incr_cntl,
  shift_in,
  incr_val,
  data_out,
  shift_out
);
parameter COUNTER_WIDTH=64;
parameter INCREMENT_WIDTH=32;
input clock;
input resetn;
input enable;
input shift;
input incr_cntl;
input shift_in;
input [INCREMENT_WIDTH-1:0] incr_val;
output [31:0] data_out;
output shift_out;
reg [COUNTER_WIDTH-1:0] counter;
always@(posedge clock or negedge resetn)
begin
  if( !resetn )
    counter <= { COUNTER_WIDTH{1'b0} };
  else if(shift) 
    counter <= { counter[COUNTER_WIDTH-2:0], shift_in };
  else if(enable && incr_cntl) 
    counter <= counter + incr_val;
end
assign data_out = counter;
assign shift_out = counter[COUNTER_WIDTH-1:COUNTER_WIDTH-1];
endmodule
module acl_profiler
(
  clock,
  resetn,
  enable,
  profile_shift, 
  incr_cntl,
  incr_val,
  daisy_out
);
parameter COUNTER_WIDTH=64;
parameter INCREMENT_WIDTH=32;
parameter NUM_COUNTERS=4;
parameter TOTAL_INCREMENT_WIDTH=INCREMENT_WIDTH * NUM_COUNTERS;
input clock;
input resetn;
input enable;
input profile_shift;
input [NUM_COUNTERS-1:0] incr_cntl;
input [TOTAL_INCREMENT_WIDTH-1:0] incr_val;
output daisy_out;
wire [NUM_COUNTERS-2:0] shift_wire;
wire [31:0] data_out [0:NUM_COUNTERS-1];
genvar n;
generate
   for(n=0; n<NUM_COUNTERS; n++)
   begin : counter_n
   if(n == 0)
      acl_profile_counter #(
         .COUNTER_WIDTH( COUNTER_WIDTH ),
         .INCREMENT_WIDTH( INCREMENT_WIDTH )
      ) counter (
         .clock( clock ),
         .resetn( resetn ),
         .enable( enable ),
         .shift( profile_shift ),
         .incr_cntl( incr_cntl[n] ),
         .shift_in( shift_wire[n] ),
         .incr_val( incr_val[ ((n+1)*INCREMENT_WIDTH-1) : (n*INCREMENT_WIDTH) ] ),
         .data_out( data_out[ n ] ),
         .shift_out( daisy_out )
      );
   else if(n == NUM_COUNTERS-1)
      acl_profile_counter #(
         .COUNTER_WIDTH( COUNTER_WIDTH ),
         .INCREMENT_WIDTH( INCREMENT_WIDTH )
      ) counter (
         .clock( clock ),
         .resetn( resetn ),
         .enable( enable ),
         .shift( profile_shift ),
         .incr_cntl( incr_cntl[n] ),
         .shift_in( 1'b0 ),
         .incr_val( incr_val[ ((n+1)*INCREMENT_WIDTH-1) : (n*INCREMENT_WIDTH) ] ),
         .data_out( data_out[ n ] ),
         .shift_out( shift_wire[n-1] )
      );
   else
      acl_profile_counter #(
         .COUNTER_WIDTH( COUNTER_WIDTH ),
         .INCREMENT_WIDTH( INCREMENT_WIDTH )
      ) counter (
         .clock( clock ),
         .resetn( resetn ),
         .enable( enable ),
         .shift( profile_shift ),
         .incr_cntl( incr_cntl[n] ),
         .shift_in( shift_wire[n] ),
         .incr_val( incr_val[ ((n+1)*INCREMENT_WIDTH-1) : (n*INCREMENT_WIDTH) ] ),
         .data_out( data_out[ n ] ),
         .shift_out( shift_wire[n-1] )
      );
   end
endgenerate
endmodule
module acl_profile_counter
(
  clock,
  resetn,
  enable,
  shift,
  incr_cntl,
  shift_in,
  incr_val,
  data_out,
  shift_out
);
parameter COUNTER_WIDTH=64;
parameter INCREMENT_WIDTH=32;
input clock;
input resetn;
input enable;
input shift;
input incr_cntl;
input shift_in;
input [INCREMENT_WIDTH-1:0] incr_val;
output [31:0] data_out;
output shift_out;
reg [COUNTER_WIDTH-1:0] counter;
always@(posedge clock or negedge resetn)
begin
  if( !resetn )
    counter <= { COUNTER_WIDTH{1'b0} };
  else if(shift) 
    counter <= { counter[COUNTER_WIDTH-2:0], shift_in };
  else if(enable && incr_cntl) 
    counter <= counter + incr_val;
end
assign data_out = counter;
assign shift_out = counter[COUNTER_WIDTH-1:COUNTER_WIDTH-1];
endmodule
