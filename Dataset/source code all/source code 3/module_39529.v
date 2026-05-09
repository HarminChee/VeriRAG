`default_nettype none
`timescale 1ns / 1ps
`default_nettype none
`timescale 1ns / 1ps
module adc_frontend (
  input  wire        clk,  
  input  wire        reset,
  output  wire        adc_clk,  
  input  wire        write_req,
  input  wire        read_req,
  input  wire [31:0] data_write,
  output reg  [31:0] data_read,
  input  wire [25:0] addr,
  output wire        busy,
  input  wire [7:0]  adc_fco,
  input  wire [7:0]  adc_dco,
  input  wire [7:0]  adc_dat_a,
  input  wire [7:0]  adc_dat_b,
  input  wire [7:0]  adc_dat_c,
  input  wire [7:0]  adc_dat_d
);
localparam IDLE   = 2'd0,
           READ_0 = 2'd1,
           READ_1 = 2'd2;
reg [7:0]  read_enable;
reg [7:0]  buffer_rdreq;
reg        busy_int;
reg [25:0] addr_int;
reg [1:0]  state;
wire [7:0] deser_busy;
wire [7:0] buffer_empty;
wire [9:0] buffer_data_a[7:0];
wire [9:0] buffer_data_b[7:0];
wire [9:0] buffer_data_c[7:0];
wire [9:0] buffer_data_d[7:0];
assign busy = reset | busy_int | write_req | read_req;
always @( posedge clk ) begin
  if ( reset ) begin
    read_enable <= 8'd0;
    buffer_rdreq <= 8'd0;
    data_read <= 32'd0;
    busy_int <= 0;
    state <= IDLE;
  end
  else begin
    buffer_rdreq <= 8'd0;
    data_read <= 32'd0;
    case ( state )
      IDLE: begin
        if ( read_req ) begin
          busy_int <= 1;
          state <= READ_0;
          addr_int <= addr;
        end
        else if ( write_req ) begin
          read_enable <= {8{data_write[0]}};
        end
      end
      READ_0: begin
        if ( ~buffer_empty[addr_int[4:2]] ) begin
          state <= READ_1;
          buffer_rdreq[addr_int[4:2]] <= 1;
        end
      end
      READ_1: begin
        state <= IDLE;
        busy_int <= 0;
        case ( addr_int[1:0] )
          2'b00: begin
            data_read <= {22'd1, buffer_data_a[addr_int[4:2]]};
          end
          1'b01: begin
            data_read <= {22'd1, buffer_data_b[addr_int[4:2]]};
          end
          2'b10: begin
            data_read <= {22'd1, buffer_data_c[addr_int[4:2]]};
          end
          2'b11: begin
            data_read <= {22'd1, buffer_data_d[addr_int[4:2]]};
          end
        endcase
      end
    endcase
  end
end
generate
  genvar i;
  for ( i=0; i<8; i=i+1 ) begin: my_loop
    adc_deser adc_deser_inst (
      .clk ( clk ),
      .reset ( reset ),
      .read_enable ( read_enable[i] ),
      .buffer_rdreq ( buffer_rdreq[i] ),
      .buffer_empty ( buffer_empty[i] ),
      .buffer_data_a ( buffer_data_a[i] ),
      .buffer_data_b ( buffer_data_b[i] ),
      .buffer_data_c ( buffer_data_c[i] ),
      .buffer_data_d ( buffer_data_d[i] ),
      .adc_fco ( adc_fco[i] ),
      .adc_dco ( adc_dco[i] ),
      .adc_dat_a ( adc_dat_a[i] ),
      .adc_dat_b ( adc_dat_b[i] ),
      .adc_dat_c ( adc_dat_c[i] ),
      .adc_dat_d ( adc_dat_d[i] )
    );
  end
endgenerate
adc_pll adc_pll_inst (
  .areset ( 1'b0 ),
  .inclk0 ( clk ),
  .c0 ( adc_clk ),
  .locked (  )
);
endmodule
