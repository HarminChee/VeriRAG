module ft_fifo_tester (
  input               clk,
  input               rst,
  input               i_wbs_we,
  input               i_wbs_cyc,
  input       [3:0]   i_wbs_sel,
  input       [31:0]  i_wbs_dat,
  input               i_wbs_stb,
  output  reg         o_wbs_ack,
  output  reg [31:0]  o_wbs_dat,
  input       [31:0]  i_wbs_adr,
  output  reg         o_wbs_int
);
localparam     ADDR_0  = 32'h00000000;
localparam     ADDR_1  = 32'h00000001;
localparam     ADDR_2  = 32'h00000002;
reg           [31:0]   r_test_data;
always @ (posedge clk) begin
  if (rst) begin
    o_wbs_dat   <= 32'h0;
    o_wbs_ack   <= 0;
    o_wbs_int   <= 0;
    r_test_data <= 0;
  end
  else begin
    if (o_wbs_ack && ~i_wbs_stb)begin
      o_wbs_ack <= 0;
    end
    if (i_wbs_stb && i_wbs_cyc) begin
      if (!o_wbs_ack) begin
        if (i_wbs_we) begin
          case (i_wbs_adr)
            ADDR_0: begin
              $display("ADDR: %h user wrote %h", i_wbs_adr, i_wbs_dat);
              r_test_data               <=  i_wbs_dat;
            end
            ADDR_1: begin
              $display("ADDR: %h user wrote %h", i_wbs_adr, i_wbs_dat);
            end
            ADDR_2: begin
              $display("ADDR: %h user wrote %h", i_wbs_adr, i_wbs_dat);
            end
            default: begin
            end
          endcase
        end
        else begin
          case (i_wbs_adr)
            ADDR_0: begin
              o_wbs_dat                 <=  r_test_data;
            end
            ADDR_1: begin
              $display("user read %h", ADDR_1);
              o_wbs_dat <= ADDR_1;
            end
            ADDR_2: begin
              $display("user read %h", ADDR_2);
              o_wbs_dat <= ADDR_2;
            end
            default: begin
            end
          endcase
        end
      o_wbs_ack <= 1;
    end
    end
  end
end
endmodule
