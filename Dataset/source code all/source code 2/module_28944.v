module Cpu
  (clk, reset, start, ack, instruc, btn, sw,
   pc, done, ld, ssd0, ssd1, ssd2, ssd3);
  localparam INSTRUC_SIZE = 32, ARG_SIZE = 8, DATA_SIZE = 8;
  input clk, reset, start, ack;
  input [(INSTRUC_SIZE - 1) : 0] instruc;
  input [3:0] btn;
  input [7:0] sw;
  output [(ARG_SIZE - 1) : 0] pc; 
  output done;
  output reg [7:0] ld;
  output reg [3:0] ssd0;
  output reg [3:0] ssd1;
  output reg [3:0] ssd2;
  output reg [3:0] ssd3;
  wire [(DATA_SIZE - 1) : 0] rdData;
  wire rdEn; 
  wire wrEn; 
  wire [(ARG_SIZE - 1) : 0] addr; 
  wire [(DATA_SIZE - 1) : 0] wrData; 
  wire [(DATA_SIZE - 1) : 0] rdDataMem;
  reg [(ARG_SIZE - 1) : 0] addrPrev; 
  assign rdData = ((addrPrev == 8'he0) ? sw[7:0] :
                   (addrPrev == 8'he1) ? btn[0] :
                   (addrPrev == 8'he2) ? btn[1] :
                   (addrPrev == 8'he3) ? btn[2] :
                   (addrPrev == 8'he4) ? btn[3] :
                   rdDataMem);
  Operate operate(.clk(clk), .reset(reset), .start(start), .ack(ack), .instruc(instruc), .rdData(rdData),
                  .rdEn(rdEn), .wrEn(wrEn), .addr(addr), .wrData(wrData), .pc(pc), .done(done));
  DataMemory dataMemory(.Clk(clk), .rdEn(rdEn), .wrEn(wrEn), .addr(addr), .wrData(wrData),
                        .Data(rdDataMem));
  always @(posedge clk, posedge reset)
  begin
    if (reset)
    begin
      ld <= 8'b0;
      ssd0 <= 4'h0;
      ssd1 <= 4'h0;
      ssd2 <= 4'h0;
      ssd3 <= 4'h0;
    end
    else
    begin
      addrPrev <= addr;
      if (wrEn)
      begin
        case (addr)
          8'hf0: ld[0] <= wrData[0];
          8'hf1: ld[1] <= wrData[0];
          8'hf2: ld[2] <= wrData[0];
          8'hf3: ld[3] <= wrData[0];
          8'hf4: ld[4] <= wrData[0];
          8'hf5: ld[5] <= wrData[0];
          8'hf6: ld[6] <= wrData[0];
          8'hf7: ld[7] <= wrData[0];
          8'hfa: ssd0 <= wrData[3:0];
          8'hfb: ssd1 <= wrData[3:0];
          8'hfc: ssd2 <= wrData[3:0];
          8'hfd: ssd3 <= wrData[3:0];
        endcase
      end
    end
  end
endmodule
