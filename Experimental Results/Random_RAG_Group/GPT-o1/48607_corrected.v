module jtag_cores (
    input [7:0] reg_d,
    input [2:0] reg_addr_d,
    input       jtck,
    input       jrstn,
    output      reg_update,
    output [7:0] reg_q,
    output [2:0] reg_addr_q
);

wire tdi;
wire tdo;
wire shift;
wire update;
wire reset = ~jrstn;

jtag_tap jtag_tap (
    .tck   (jtck),
    .tdi   (tdi),
    .tdo   (tdo),
    .shift (shift),
    .update(update),
    .reset (reset)
);

reg [10:0] jtag_shift;
reg [10:0] jtag_latched;

always @(posedge jtck or negedge jrstn) begin
    if(!jrstn)
        jtag_shift <= 11'b0;
    else if(shift)
        jtag_shift <= {tdi, jtag_shift[10:1]};
    else
        jtag_shift <= {reg_d, reg_addr_d};
end

assign tdo = jtag_shift[0];

always @(posedge jtck or negedge jrstn) begin
    if(!jrstn)
        jtag_latched <= 11'b0;
    else if(update)
        jtag_latched <= jtag_shift;
end

assign reg_update = update;
assign reg_q = jtag_latched[10:3];
assign reg_addr_q = jtag_latched[2:0];

endmodule