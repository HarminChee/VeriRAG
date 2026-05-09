module regfile
(
  rn_data, rm_data, rs_data, pc_out, cpsr_out,
  rn_num, rm_num, rs_num, rd_num, rd_data, rd_we,
  pc_in, pc_we, cpsr_in, cpsr_we,
  clk, rst_b, halted
);
  parameter text_start  = 32'h00400000; 
  input       [3:0]  rn_num, rm_num, rs_num, rd_num;
  input       [31:0] rd_data, pc_in, cpsr_in;
  input              rd_we, pc_we, cpsr_we, clk, rst_b, halted;
  output wire [31:0] rn_data, rm_data, rs_data, pc_out, cpsr_out;
  reg         [31:0] mem[0:15];
  reg         [31:0] cpsr;
  integer            i;
  always @(posedge clk or negedge rst_b) begin
    if (!rst_b) begin
      for (i = 0; i < 15; i = i+1)
        mem[i] <= 32'b0;
      mem[15] <= text_start;
      cpsr <= 32'b0;
    end else begin
      if (rd_we && (rd_num != 4'd15))
        mem[rd_num] <= rd_data;
      if (pc_we)
        mem[4'd15] <= pc_in;
      if (cpsr_we)
        cpsr <= cpsr_in;
    end
  end
  assign rn_data = mem[rn_num];
  assign rm_data = mem[rm_num];
  assign rs_data = mem[rs_num];
  assign pc_out = mem[4'd15];
  assign cpsr_out = cpsr;
  integer fd;
  always @(halted) begin
    if (rst_b && halted) begin
      fd = $fopen("regdump.txt");
      $display("--- 18-447 Register file dump ---");
      $display("=== Simulation Cycle %d ===", $time);
      $fdisplay(fd, "--- 18-447 Register file dump ---");
      $fdisplay(fd, "=== Simulation Cycle %d ===", $time);
      for(i = 0; i < 16; i = i+1) begin
        $display("R%d\t= 0x%8x\t( %0d )", i, mem[i], mem[i]);
        $fdisplay(fd, "R%d\t= 0x%8h\t( %0d )", i, mem[i], mem[i]);
      end
      $display("CPSR\t= 0x%8x\t( %0d )", cpsr, cpsr);
      $fdisplay(fd, "CPSR\t= 0x%8h\t( %0d )", cpsr, cpsr);
      $display("--- End register file dump ---");
      $fdisplay(fd, "--- End register file dump ---");
      $fclose(fd);
    end
  end
endmodule
