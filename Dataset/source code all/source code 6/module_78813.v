`define SALU_SOPP_FORMAT 8'h01
`define SALU_SOP1_FORMAT 8'h02
`define SALU_SOPC_FORMAT 8'h04
`define SALU_SOP2_FORMAT 8'h08
`define SALU_SOPK_FORMAT 8'h10
`define SALU_SOPP_FORMAT 8'h01
`define SALU_SOP1_FORMAT 8'h02
`define SALU_SOPC_FORMAT 8'h04
`define SALU_SOP2_FORMAT 8'h08
`define SALU_SOPK_FORMAT 8'h10
module scalar_alu(
    s1,
    s2,
    exec,
    control,
    b64_op,
    out,
    scc_val
);
input[63:0] s1, s2, exec;
input[31:0] control;
input b64_op;
output[63:0] out;
output scc_val;
reg scc_val;
reg infogen;
reg [31:0] partial_sum, out_low, out_hi;
wire [31:0] s1_low, s2_low;
assign s1_low = s1[31:0];
assign s2_low = s2[31:0];
assign out = b64_op ? {out_hi, out_low} : {32'bx, out_low};
always@(s1 or s2 or control)
begin
    casex(control[31:24])
        {`SALU_SOPP_FORMAT} : begin
            infogen     = 1'bx;
            partial_sum = 32'bx;
            out_hi = 32'bx;
            casex(control[23:0])
                24'h000002 : begin out_low = s1_low + s2_low*4 + 4; end
                24'h000004 : begin out_low = s1_low + s2_low*4 + 4; end
                24'h000005 : begin out_low = s1_low + s2_low*4 + 4; end
                24'h000006 : begin out_low = s1_low + s2_low*4 + 4; end
                24'h000008 : begin out_low = s1_low + s2_low*4 + 4; end
                default : begin out_low = 32'bx; end
            endcase
        end
        {`SALU_SOP1_FORMAT} : begin
            infogen     = 1'bx;
            partial_sum = 32'bx;
            casex(control[23:0])
                24'h000003 : begin
                               out_low = s1_low;
                               out_hi = 32'bx;
                             end
                24'h000004 : begin {out_hi, out_low} = s1; end
                24'h000007 : begin
                               out_low = ~s1_low;
                               out_hi = 32'bx;
                             end
                24'h000024 : begin {out_hi, out_low} = s1 & exec; end
                default : begin
                               out_low = 32'bx;
                               out_hi = 32'bx;
                          end
            endcase
        end
        {`SALU_SOP2_FORMAT} : begin
            casex(control[23:0])
                24'h000000 : begin
                    {infogen, out_low} = s1_low + s2_low;
                    partial_sum = 32'bx;
                    out_hi = 32'bx;
                end
                24'h000001 : begin
                    {infogen, out_low} = s1_low - s2_low;
                    partial_sum = 32'bx;
                    out_hi = 32'bx;
                end
                24'h000002 : begin
                    {infogen, out_low} = s1_low + s2_low;
                    partial_sum = s1_low[30:0] + s2_low[30:0];
                    out_hi = 32'bx;
                end
                24'h000003 : begin
                    {infogen, out_low} = s1_low - s2_low;
                    partial_sum = s1_low[30:0] + (~(s2_low[30:0])) + 31'b1;
                    out_hi = 32'bx;
                end
                24'h000007 : begin
                    out_low     = (s1_low < s2_low) ? s1_low : s2_low;
                    infogen     = s1_low < s2_low;
                    partial_sum = 32'bx;
                    out_hi = 32'bx;
                end
                24'h000009 : begin
                    out_low     = (s1_low > s2_low) ? s1_low : s2_low;
                    infogen     = s1_low > s2_low;
                    partial_sum = 32'bx;
                    out_hi = 32'bx;
                end
                24'h00000e : begin
                    out_low     = s1_low & s2_low;
                    infogen     = 1'bx;
                    partial_sum = 32'bx;
                    out_hi = 32'bx;
                end
                24'h00000f : begin
                    {out_hi, out_low} = s1 & s2;
                    infogen           = 1'bx;
                    partial_sum       = 32'bx;
                end
                24'h000010 : begin
                    out_low     = s1_low | s2_low;
                    infogen     = 1'bx;
                    partial_sum = 32'bx;
                    out_hi = 32'bx;
                end
                24'h000015 : begin
                    {out_hi, out_low} = s1 & ~s2;
                    infogen           = 1'bx;
                    partial_sum       = 32'bx;
                end
                24'h00001e : begin
                    out_low     = s1_low << s2_low[4:0];
                    infogen     = 1'bx;
                    partial_sum = 32'bx;
                    out_hi = 32'bx;
                end
                24'h000020 : begin
                    out_low     = s1_low >> s2_low[4:0];
                    infogen     = 1'bx;
                    partial_sum = 32'bx;
                    out_hi = 32'bx;
                end
                24'h000022 : begin
                    out_low     = s1_low >>> s2_low[4:0];
                    infogen     = 1'bx;
                    partial_sum = 32'bx;
                    out_hi = 32'bx;
                end
                24'h000026 : begin
                    out_low     = s1_low * s2_low;
                    infogen     = 1'bx;
                    partial_sum = 32'bx;
                    out_hi = 32'bx;
                end
                default : begin
                    out_low     = 32'bx;
                    infogen     = 1'bx;
                    partial_sum = 32'bx;
                    out_hi = 32'bx;
                end
            endcase
        end
        {`SALU_SOPC_FORMAT} : begin
            out_low     = 32'bx;
            partial_sum = 32'bx;
            casex(control[23:0])
                24'h000000 : begin infogen = s1_low == s2_low;
                                   out_hi = 32'bx;
                             end
                24'h000005 : begin
                    if (s1_low[31] == 1'b1 & s2_low[31] == 1'b1)
                      begin
                        infogen = s1_low >= s2_low;
                        out_hi = 32'bx;
                      end
                    else if (s1_low[31] == 1'b1)
                      begin
                        infogen = 1'b1;
                        out_hi = 32'bx;
                      end
                    else if (s2_low[31] == 1'b1)
                      begin
                        infogen = 1'b0;
                        out_hi = 32'bx;
                      end
                    else
                      begin
                        infogen = s1_low <= s2_low;
                        out_hi = 32'bx;
                      end
                end
                24'h000009 : begin infogen = s1_low >= s2_low;
                                   out_hi = 32'bx;
                             end
                24'h00000B : begin infogen = s1_low <= s2_low;
                                   out_hi = 32'bx;
                             end
                default : begin infogen = 1'bx;
                                out_hi = 32'bx;
                          end
            endcase
        end
        {`SALU_SOPK_FORMAT} : begin
            casex(control[23:0])
                24'h000000 : begin
                    out_low = s2_low;
                    infogen = 1'bx;
                    partial_sum = 32'bx;
                    out_hi = 32'bx;
                end
                24'h00000F : begin
                    {infogen, out_low} = s1_low + s2_low;
                    partial_sum = s1_low[30:0] + s2_low[30:0];
                    out_hi = 32'bx;
                end
                24'h000010 : begin
                    {infogen, out_low} = s1_low * s2_low;
                    partial_sum = 32'bx;
                    out_hi = 32'bx;
                end
                default : begin
                    out_low = 32'bx;
                    infogen = 1'bx;
                    partial_sum = 32'bx;
                    out_hi = 32'bx;
                end
            endcase
        end
        default : begin
            out_low     = 32'bx;
            infogen     = 1'bx;
            partial_sum = 32'bx;
            out_hi = 32'bx;
        end
    endcase
end
always@(control or out_low or out or infogen or partial_sum)
begin
    scc_val = 1'bx;
    casex(control[31:24])
        {`SALU_SOP1_FORMAT} : begin
            casex(control[23:0])
                24'h000007 : begin scc_val = (|out_low); end
                24'h000024 : begin scc_val = (|out); end
                default : begin scc_val = 1'bx; end
            endcase
        end
        {`SALU_SOP2_FORMAT} : begin
            casex(control[23:0])
                24'h000000 : begin scc_val = infogen; end
                24'h000001 : begin scc_val = infogen; end
                24'h000002 : begin scc_val = partial_sum[31] ^ infogen; end
                24'h000003 : begin scc_val = partial_sum[31] ^ infogen; end
                24'h000007 : begin scc_val = infogen; end
                24'h000009 : begin scc_val = infogen; end
                24'h00000E : begin scc_val = |out_low; end
                24'h00000F : begin scc_val = |out; end
                24'h000010 : begin scc_val = |out_low; end
                24'h000015 : begin scc_val = |out; end
                24'h00001E : begin scc_val = |out_low; end
                24'h000020 : begin scc_val = |out_low; end
                24'h000022 : begin scc_val = |out_low; end
                default : begin scc_val = 1'bx; end
            endcase
        end
        {`SALU_SOPC_FORMAT} : begin
            casex(control[23:0])
                24'h000000 : begin scc_val = infogen; end
                24'h000005 : begin scc_val = infogen; end
                24'h000009 : begin scc_val = infogen; end
                24'h00000B : begin scc_val = infogen; end
                default : begin scc_val = 1'bx; end
            endcase
        end
        {`SALU_SOPK_FORMAT} : begin
            casex(control[23:0])
                24'h00000F : begin scc_val = partial_sum[31] ^ infogen; end
                24'h000010 : begin scc_val = infogen; end
                default : begin scc_val = 1'bx; end
            endcase
        end
    endcase
end
endmodule
