module registerfile(ADDA, DATAA, ADDB, DATAB, ADDC, DATAC, clk, clr, WE);
    input [4:0]  ADDA,ADDB, ADDC;
    input [31:0] DATAC;
    input clk, clr, WE;
    output [31:0] DATAA, DATAB;
    
    reg [31:0] DATAA, DATAB;

    reg [31:0] register [31:0];
    integer i;

    //clear all the registers in the register file
    initial begin
       for (i=0; i<32; i=i+1)
          register[i] = 0;
       $readmemh("reg.dat", register);
    end
    
    //only when a positive(rising) edge occurs
    always @(posedge clk or posedge clr) 
    begin
    // clear signal will reset all register as well
    if (clr)
       for (i=0; i<32; i=i+1)
          register[i] = 0;
    else
       // only when WE is 1, we write the register file 
       if (WE == 1)
       begin
          register[ADDC] = DATAC;
          register[0] = 0;
       end
    end
    
    // we read content of A and B only when a negative edge occurs 
    always @ (negedge clk )
    begin
           DATAA = register[ADDA];
           DATAB = register[ADDB];
    end
       
endmodule

