module CORDIC_elemet
#(parameter ADDRESS_WIDTH = 8,
parameter VALUE_WIDTH = 8,
parameter[ADDRESS_WIDTH - 1 : 0] e_k = 2**(ADDRESS_WIDTH - 1),
parameter ORDER = 0,
parameter MODE = 1)
  ( 
    input CLK,
    input RESET_n,
    input signed[VALUE_WIDTH : 0] x_k,
    input signed[VALUE_WIDTH : 0] y_k,
    input signed[ADDRESS_WIDTH : 0] z_k,
    output reg signed[VALUE_WIDTH : 0] x_k1,
    output reg signed[VALUE_WIDTH : 0] y_k1,
    output reg signed[ADDRESS_WIDTH : 0] z_k1
  );
wire d_k;
generate
  if (MODE == 1)
    begin
        assign d_k = z_k[ADDRESS_WIDTH];
    end
  else
    begin
        assign d_k = ~(x_k[ADDRESS_WIDTH]^y_k[ADDRESS_WIDTH]);
    end
endgenerate
always @ (posedge CLK or negedge RESET_n)
begin
    if (!RESET_n)
    begin
        z_k1 <= {(ADDRESS_WIDTH){1'b0}};
    end
    else if (d_k == 1'b0)
    begin
        z_k1 <= z_k -{1'b0, e_k};
    end
    else
    begin
        z_k1 <= z_k + {1'b0, e_k};
    end
end
always @ (posedge CLK or negedge RESET_n)
begin
    if (!RESET_n)
    begin
        x_k1 <= {(VALUE_WIDTH){1'b0}};
    end
    else if (d_k == 1'b0)
    begin
        x_k1 <= x_k - (y_k>>>ORDER);
    end
    else
    begin
        x_k1 <= x_k + (y_k>>>ORDER);
    end
end
always @ (posedge CLK or negedge RESET_n)
begin
    if (!RESET_n)
    begin
        y_k1 <= {(VALUE_WIDTH){1'b0}};
    end
    else if (d_k == 1'b0)
    begin
        y_k1 <= y_k + (x_k>>>ORDER);
    end
    else
    begin
        y_k1 <= y_k - (x_k>>>ORDER);
    end
end
endmodule
