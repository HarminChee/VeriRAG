module acl_work_item_iterator #(parameter WIDTH=32) (
   input clock,
   input resetn,
   input start,         
   input issue,         
   input [WIDTH-1:0] local_size[2:0],
   input [WIDTH-1:0] global_size[2:0],
   input [WIDTH-1:0] global_id_base[2:0],
   output reg [WIDTH-1:0] local_id[2:0],
   output reg [WIDTH-1:0] global_id[2:0],
   output last_in_group
);
wire [WIDTH-1:0] global_total = global_id[0] + global_size[0] * ( global_id[1] + global_size[1] * global_id[2] );
wire [WIDTH-1:0] local_total = local_id[0] + local_size[0] * ( local_id[1] + local_size[1] * local_id[2] );
function [WIDTH-1:0] incr_lid ( input [WIDTH-1:0] old_lid, input to_incr, input last );
   if ( to_incr )
      if ( last )
         incr_lid = {WIDTH{1'b0}};
      else 
         incr_lid = old_lid + 2'b01;
   else 
      incr_lid = old_lid;
endfunction
reg [WIDTH-1:0] max_local_id[2:0];
wire last_local_id[2:0];
assign last_local_id[0] = (local_id[0] == max_local_id[0] );
assign last_local_id[1] = (local_id[1] == max_local_id[1] );
assign last_local_id[2] = (local_id[2] == max_local_id[2] );
assign last_in_group = last_local_id[0] & last_local_id[1] & last_local_id[2];
wire bump_local_id[2:0];
assign bump_local_id[0] = (max_local_id[0] != 0);
assign bump_local_id[1] = (max_local_id[1] != 0) && last_local_id[0];
assign bump_local_id[2] = (max_local_id[2] != 0) && last_local_id[0] && last_local_id[1];
always @(posedge clock or negedge resetn) begin
   if ( ~resetn ) begin
      local_id[0] <= {WIDTH{1'b0}};
      local_id[1] <= {WIDTH{1'b0}};
      local_id[2] <= {WIDTH{1'b0}};
      max_local_id[0] <= {WIDTH{1'b0}};
      max_local_id[1] <= {WIDTH{1'b0}};
      max_local_id[2] <= {WIDTH{1'b0}};		
   end else if ( start ) begin
      local_id[0] <= {WIDTH{1'b0}};
      local_id[1] <= {WIDTH{1'b0}};
      local_id[2] <= {WIDTH{1'b0}};
      max_local_id[0] <= local_size[0] - 2'b01;
      max_local_id[1] <= local_size[1] - 2'b01;
      max_local_id[2] <= local_size[2] - 2'b01;		
   end else 
   begin
      if ( issue ) begin
         local_id[0] <= incr_lid (local_id[0], bump_local_id[0], last_local_id[0]);
         local_id[1] <= incr_lid (local_id[1], bump_local_id[1], last_local_id[1]);
         local_id[2] <= incr_lid (local_id[2], bump_local_id[2], last_local_id[2]);
      end
   end
end
  reg just_seen_last_in_group;
  always @(posedge clock or negedge resetn) begin
    if ( ~resetn )
      just_seen_last_in_group <= 1'b1;
    else if ( start )
      just_seen_last_in_group <= 1'b1;
    else if (last_in_group & issue)
      just_seen_last_in_group <= 1'b1;
    else if (issue)
      just_seen_last_in_group <= 1'b0;
    else
      just_seen_last_in_group <= just_seen_last_in_group;
  end
always @(posedge clock or negedge resetn) begin
   if ( ~resetn ) begin
      global_id[0] <= {WIDTH{1'b0}};
      global_id[1] <= {WIDTH{1'b0}};
      global_id[2] <= {WIDTH{1'b0}};
   end else if ( start ) begin
      global_id[0] <= {WIDTH{1'b0}};
      global_id[1] <= {WIDTH{1'b0}};
      global_id[2] <= {WIDTH{1'b0}};
   end else 
   begin
      if ( issue ) begin
         if ( !last_in_group ) begin
            if ( just_seen_last_in_group ) begin
               global_id[0] <= global_id_base[0] + bump_local_id[0];
               global_id[1] <= global_id_base[1] + bump_local_id[1];
               global_id[2] <= global_id_base[2] + bump_local_id[2];
            end else begin
               if ( bump_local_id[0] ) global_id[0] <= (last_local_id[0] ? (global_id[0] - max_local_id[0]) : (global_id[0] + 2'b01));
               if ( bump_local_id[1] ) global_id[1] <= (last_local_id[1] ? (global_id[1] - max_local_id[1]) : (global_id[1] + 2'b01));
               if ( bump_local_id[2] ) global_id[2] <= (last_local_id[2] ? (global_id[2] - max_local_id[2]) : (global_id[2] + 2'b01));
            end
         end
      end
   end
end
endmodule
