`timescale 1ns/1ps
`define DEBUG
`define PRINT_TEST_VECTORS
`define PRINT_KEY_VECTORS
`timescale 1ns/1ps
`define DEBUG
`define PRINT_TEST_VECTORS
`define PRINT_KEY_VECTORS
module PRESENT_ENCRYPT (
        output [63:0] odat,   
        input  [63:0] idat,   
        input  [79:0] key,    
        input         load,   
        input         clk     
    );
reg  [79:0] kreg;               
reg  [63:0] dreg;               
reg  [4:0]  round;              
wire [63:0] dat1,dat2,dat3;     
wire [79:0] kdat1,kdat2;        
reg         done;
reg         first_pass;
wire        true_done;
assign dat1 = dreg ^ kreg[79:16];        
assign odat = dat1;                      
assign kdat1        = {kreg[18:0], kreg[79:19]}; 
assign kdat2[14:0 ] = kdat1[14:0 ];
assign kdat2[19:15] = kdat1[19:15] ^ round;  
assign kdat2[75:20] = kdat1[75:20];
genvar i;
generate
    for (i=0; i<64; i=i+4) begin: sbox_loop
       PRESENT_ENCRYPT_SBOX USBOX( .odat(dat2[i+3:i]), .idat(dat1[i+3:i]) );
    end
endgenerate
PRESENT_ENCRYPT_PBOX UPBOX    ( .odat(dat3), .idat(dat2) );
PRESENT_ENCRYPT_SBOX USBOXKEY ( .odat(kdat2[79:76]), .idat(kdat1[79:76]) );
always @(posedge clk)
begin
   if (load)
      dreg <= idat;
   else if (~first_pass)
      dreg <= dreg;
   else
      dreg <= dat3;
end
always @(posedge clk)
begin
   if (load)
      kreg <= key;
   else if (~first_pass)
      kreg <= kreg;    
   else
      kreg <= kdat2;
end
always @(posedge clk)
begin
   if (load)
      round <= 1;
   else if (~first_pass)
      round <= round;    
   else
      round <= round + 1;
end
always @(posedge clk) done <= (round == 30);
always @(posedge clk) begin
  if (load)       first_pass <= 1'b1;
  else if (done)  first_pass <= 1'b0;
  else            first_pass <= first_pass;
end
assign true_done = first_pass & done;
`ifdef PRINT_KEY_VECTORS
always @(posedge clk)
begin
   if (round==0)
      $display("KEYVECTOR=> key1=%x  key32=%x",key,kreg);
end
`endif
`ifdef PRINT_TEST_VECTORS
always @(posedge clk)
begin
   if (round==0)
      $display("TESTVECTOR=> ", $time, " plaintext=%x  key=%x  ciphertext=%x",idat,key,odat);
end
`endif
`ifdef DEBUG
always @(posedge clk)
begin
      $display("D=> ", $time, " %d  %x  %x  %x  %x  %x  %x",round,idat,dreg,dat1,dat2,dat3,odat);
      $display("K=> ", $time, " %d  %x  %x  %x",round,kreg,kdat1,kdat2);
end
`endif
endmodule
