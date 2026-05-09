`timescale 1ps / 1ps
`timescale 1ps / 1ps
module axi_stream_ingress_demo #(
  parameter ADDR_WIDTH          = 32,
  parameter DATA_WIDTH          = 32,
  parameter STROBE_WIDTH        = (DATA_WIDTH / 8)
)(
  input                               clk,
  input                               rst,
  input                               i_tvalid,
  output  reg                         o_tready,
  input       [DATA_WIDTH - 1: 0]     i_tdata,
  input       [STROBE_WIDTH - 1:0]    i_tstrb,
  input       [STROBE_WIDTH - 1:0]    i_tkeep,
  input                               i_tlast,
  input       [3:0]                   i_tuser,
  input       [3:0]                   i_tid,
  input       [31:0]                  i_tdest
);
localparam      IDLE                = 4'h0;
localparam      RECEIVE_WRITE_DATA  = 4'h1;
localparam      ADDR_CONTROL        = 0;
localparam      ADDR_STATUS         = 1;
reg           [3:0]                  state;
reg           [ADDR_WIDTH - 1: 0]    address;
reg           [DATA_WIDTH - 1: 0]    control;
reg           [DATA_WIDTH - 1: 0]    status;
always @ (posedge clk) begin
  if (rst) begin
    o_tready            <=  0;
    control             <=  0;
    status              <=  0;
    state               <= IDLE;
  end
  else begin
    case (state)
      IDLE: begin
        o_tready        <= 1;
        if (i_tvalid) begin
          state         <=  RECEIVE_WRITE_DATA;
          $display("Dest: %h", i_tdest);
          $display("User: %h", i_tuser);
          $display("ID:   %h", i_tid);
          $display("Data: 0x%08X", i_tdata);
        end
      end
      RECEIVE_WRITE_DATA: begin
        if (!i_tvalid) begin
          state         <=  IDLE;
          o_tready      <=  0;
        end
        else begin
          $display ("Data: 0x%08X", i_tdata);
        end
      end
      default: begin
        $display("Shouldn't have gotten here!");
      end
    endcase
    if (i_tlast) begin
      $display("Last Signal Strobed");
    end
  end
end
endmodule
