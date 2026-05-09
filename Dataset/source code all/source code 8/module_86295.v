module acl_level_detect
#(
  parameter WIDTH=13,          
  parameter COUNTERWIDTH=10    
)
(
  input  logic clk,
  input  logic resetn,
  input  logic                    valid,
  input  logic [WIDTH-1:0]        value,
  output logic [COUNTERWIDTH-1:0] count[WIDTH+1]
);
  logic [WIDTH-1:0] last_value;
  logic scaledown;
  always@(posedge clk or negedge resetn)
    if (!resetn)
      last_value <= {WIDTH{1'b0}};
    else if (valid)
      last_value <= value;
    else
      last_value <= {WIDTH{1'b0}};
  genvar i;
  generate
    for (i = 0; i < WIDTH; i = i + 1)
    begin:counters
      always@(posedge clk or negedge resetn)
        if (!resetn)
          count[i] <= {COUNTERWIDTH{1'b0}};
        else if (last_value[i] && scaledown)
          count[i] <= (count[i] + 2'b1) >> 1;
        else if (last_value[i])
          count[i] <= count[i] + 2'b1;
        else if (scaledown)
          count[i] <= count[i] >> 1;
    end
  endgenerate
  always@(posedge clk or negedge resetn)
    if (!resetn)
      count[WIDTH] <= 1'b0;
    else if (scaledown && count[WIDTH]!={COUNTERWIDTH{1'b1}})
      count[WIDTH] <= count[WIDTH] + 2'b1;
  integer j;
  always@(posedge clk or negedge resetn)
    if (!resetn)
      scaledown <= 1'b0;
    else if (scaledown)
      scaledown <= 1'b0;
    else
      for (j = 0; j < WIDTH; j = j + 1)
        if (&count[j][COUNTERWIDTH-1:COUNTERWIDTH-3])
          scaledown <= 1'b1;
endmodule
