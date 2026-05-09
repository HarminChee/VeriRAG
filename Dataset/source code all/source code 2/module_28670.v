`timescale 1ns/1ps
`timescale 1ns/1ps
module resync_data
#(
  parameter integer DATA_WIDTH=16,
  parameter integer DATA_DEPTH=4, 
  parameter         INITIAL_VALUE = 0
) (
    input                       arst,     
    input                       srst,     
    input                       wclk,     
    input                       rclk,     
    input                       we,       
    input                       re,       
    input      [DATA_WIDTH-1:0] data_in,  
    output reg [DATA_WIDTH-1:0] data_out, 
    output reg                  valid     
  );
    localparam integer DATA_2DEPTH=(1<<DATA_DEPTH)-1;
    reg  [DATA_WIDTH-1:0] ram [0:DATA_2DEPTH];
    reg  [DATA_DEPTH-1:0] raddr;
    reg  [DATA_DEPTH-1:0] waddr;
    reg             [1:0] rrst = 3;
    always @ (posedge  rclk or posedge arst) begin
        if      (arst)                         valid <= 0;
        else if (srst)                         valid <= 0;
        else if (&waddr[DATA_DEPTH-2:0] && we) valid <= 1; 
    end
    always @ (posedge  wclk or posedge arst) begin
        if      (arst) waddr <= 0;
        else if (srst) waddr <= 0;
        else if (we)   waddr <= waddr + 1;
    end
    always @ (posedge  rclk or posedge arst) begin
        if      (arst) rrst <= 3;
        else if (srst) rrst <= 3; 
        else           rrst <= rrst << 1;
        if      (arst)          raddr <= 0;
        else if (rrst[0])       raddr <= 0;
        else if (re || rrst[1]) raddr <= raddr + 1;
        if (arst)               data_out <= INITIAL_VALUE;
        else if (rrst[0])       data_out <= INITIAL_VALUE;
        else if (re || rrst[1]) data_out <= ram[raddr];
    end
    always @ (posedge  wclk) begin
          if (we) ram[waddr] <= data_in;
    end
endmodule
