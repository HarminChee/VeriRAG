module fpga_entropy(
                    input wire           clk,
                    input wire           reset_n,
                    input wire           cs,
                    input wire           we,
                    input wire [7 : 0]   address,
                    input wire [31 : 0]  write_data,
                    output wire [31 : 0] read_data,
                    output wire          error,
                    output wire [7 : 0]  debug
                   );
  parameter ADDR_CORE_NAME0   = 8'h00;
  parameter ADDR_CORE_NAME1   = 8'h01;
  parameter ADDR_CORE_VERSION = 8'h02;
  parameter ADDR_UPDATE       = 8'h10;
  parameter ADDR_OPA          = 8'h11;
  parameter ADDR_RND_READ     = 8'h20;
  parameter CORE_NAME0   = 32'h66706761;  
  parameter CORE_NAME1   = 32'h5f656e74;  
  parameter CORE_VERSION = 32'h302e3031;  
  parameter DEFAULT_OPA = 32'haaaaaaaa;
  parameter DELAY_MAX = 32'h002625a0;
  reg [31 : 0] opa_reg;
  reg [31 : 0] opb_reg;
  reg [31 : 0] opa_new;
  reg          opa_we;
  reg          update_reg;
  reg          update_new;
  reg          update_we;
  reg [31 : 0] delay_ctr_reg;  
  reg [31 : 0] delay_ctr_new;  
  reg [7 : 0]  debug_reg;
  reg          debug_we;
  reg           tmp_error;
  reg [31 : 0]  tmp_read_data;
  wire [31 : 0] core_rnd;
  assign read_data = tmp_read_data;
  assign error     = tmp_error;
  assign debug     = debug_reg;
  fpga_entropy_core core(
                         .clk(clk),
                         .reset_n(reset_n),
                         .opa(opa_reg),
                         .opb(opb_reg),
                         .update(update_reg),
                         .rnd(core_rnd)
                        );
  always @ (posedge clk or negedge reset_n)
    begin: reg_update
      if (!reset_n)
        begin
          opa_reg    <= DEFAULT_OPA;
          opb_reg    <= ~DEFAULT_OPA;
          update_reg <= 1;
          debug_reg  <= 8'h00;
        end
      else
        begin
          delay_ctr_reg <= delay_ctr_new;
          if (opa_we)
            begin
              opa_reg <= opa_new;
              opb_reg <= ~opa_new;
            end
          if (update_we)
            begin
              update_reg <= update_new;
            end
          if (debug_we)
            begin
              debug_reg <= core_rnd[7 : 0];
            end
        end
    end 
  always @*
    begin : delay_ctr
      debug_we = 0;
      if (delay_ctr_reg == DELAY_MAX)
        begin
          delay_ctr_new = 32'h00000000;
          debug_we      = 1;
        end
      else
        begin
          delay_ctr_new = delay_ctr_reg + 1'b1;
        end
    end 
  always @*
    begin: api
      opa_new       = 32'h00000000;
      opa_we        = 0;
      update_new    = 0;
      update_we     = 0;
      tmp_read_data = 32'h00000000;
      tmp_error     = 0;
      if (cs)
        begin
          if (we)
            begin
              case (address)
                ADDR_UPDATE:
                  begin
                    update_new = write_data[0];
                    update_we  = 1;
                  end
                ADDR_OPA:
                  begin
                    opa_new = write_data;
                    opa_we  = 1;
                  end
                default:
                  begin
                    tmp_error = 1;
                  end
              endcase 
            end
          else
            begin
              case (address)
                ADDR_CORE_NAME0:
                  begin
                    tmp_read_data = CORE_NAME0;
                  end
                ADDR_CORE_NAME1:
                  begin
                    tmp_read_data = CORE_NAME1;
                  end
                ADDR_CORE_VERSION:
                  begin
                    tmp_read_data = CORE_VERSION;
                  end
                ADDR_UPDATE:
                  begin
                    tmp_read_data = update_reg;
                  end
                ADDR_OPA:
                  begin
                    tmp_read_data = opa_reg;
                  end
                ADDR_RND_READ:
                  begin
                    tmp_read_data = core_rnd;
                  end
                default:
                  begin
                    tmp_error = 1;
                  end
              endcase 
            end
        end
    end
endmodule 
