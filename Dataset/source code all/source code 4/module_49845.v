module modexp(
              input wire           clk,
              input wire           reset_n,
              input wire           cs,
              input wire           we,
              input wire  [11 : 0] address,
              input wire  [31 : 0] write_data,
              output wire [31 : 0] read_data
             );
  localparam GENERAL_PREFIX        = 4'h0;
  localparam ADDR_NAME0            = 8'h00;
  localparam ADDR_NAME1            = 8'h01;
  localparam ADDR_VERSION          = 8'h02;
  localparam ADDR_CTRL             = 8'h08;
  localparam CTRL_INIT_BIT         = 0;
  localparam CTRL_NEXT_BIT         = 1;
  localparam ADDR_STATUS           = 8'h09;
  localparam STATUS_READY_BIT      = 0;
  localparam ADDR_CYCLES_HIGH      = 8'h10;
  localparam ADDR_CYCLES_LOW       = 8'h11;
  localparam ADDR_MODULUS_LENGTH   = 8'h20;
  localparam ADDR_EXPONENT_LENGTH  = 8'h21;
  localparam ADDR_MODULUS_PTR_RST  = 8'h30;
  localparam ADDR_MODULUS_DATA     = 8'h31;
  localparam ADDR_EXPONENT_PTR_RST = 8'h40;
  localparam ADDR_EXPONENT_DATA    = 8'h41;
  localparam ADDR_MESSAGE_PTR_RST  = 8'h50;
  localparam ADDR_MESSAGE_DATA     = 8'h51;
  localparam ADDR_RESULT_PTR_RST   = 8'h60;
  localparam ADDR_RESULT_DATA      = 8'h61;
  localparam DEFAULT_MODLENGTH     = 8'h80; 
  localparam DEFAULT_EXPLENGTH     = 8'h80;
  localparam CORE_NAME0            = 32'h6d6f6465; 
  localparam CORE_NAME1            = 32'h78702020; 
  localparam CORE_VERSION          = 32'h302e3532; 
  reg [07 : 0] exponent_length_reg;
  reg [07 : 0] exponent_length_new;
  reg          exponent_length_we;
  reg [07 : 0] modulus_length_reg;
  reg [07 : 0] modulus_length_new;
  reg          modulus_length_we;
  reg          start_reg;
  reg          start_new;
  reg           exponent_mem_api_rst;
  reg           exponent_mem_api_cs;
  reg           exponent_mem_api_wr;
  wire [31 : 0] exponent_mem_api_read_data;
  reg           modulus_mem_api_rst;
  reg           modulus_mem_api_cs;
  reg           modulus_mem_api_wr;
  wire [31 : 0] modulus_mem_api_read_data;
  reg           message_mem_api_rst;
  reg           message_mem_api_cs;
  reg           message_mem_api_wr;
  wire [31 : 0] message_mem_api_read_data;
  reg           result_mem_api_rst;
  reg           result_mem_api_cs;
  wire [31 : 0] result_mem_api_read_data;
  wire          ready;
  wire [63 : 0] cycles;
  reg [31 : 0]  tmp_read_data;
  assign read_data = tmp_read_data;
  modexp_core core_inst(
                        .clk(clk),
                        .reset_n(reset_n),
                        .start(start_reg),
                        .ready(ready),
                        .exponent_length(exponent_length_reg),
                        .modulus_length(modulus_length_reg),
                        .cycles(cycles),
                        .exponent_mem_api_cs(exponent_mem_api_cs),
                        .exponent_mem_api_wr(exponent_mem_api_wr),
                        .exponent_mem_api_rst(exponent_mem_api_rst),
                        .exponent_mem_api_write_data(write_data),
                        .exponent_mem_api_read_data(exponent_mem_api_read_data),
                        .modulus_mem_api_cs(modulus_mem_api_cs),
                        .modulus_mem_api_wr(modulus_mem_api_wr),
                        .modulus_mem_api_rst(modulus_mem_api_rst),
                        .modulus_mem_api_write_data(write_data),
                        .modulus_mem_api_read_data(modulus_mem_api_read_data),
                        .message_mem_api_cs(message_mem_api_cs),
                        .message_mem_api_wr(message_mem_api_wr),
                        .message_mem_api_rst(message_mem_api_rst),
                        .message_mem_api_write_data(write_data),
                        .message_mem_api_read_data(message_mem_api_read_data),
                        .result_mem_api_cs(result_mem_api_cs),
                        .result_mem_api_rst(result_mem_api_rst),
                        .result_mem_api_read_data(result_mem_api_read_data)
                       );
  always @ (posedge clk or negedge reset_n)
    begin
      if (!reset_n)
        begin
          start_reg           <= 1'b0;
          exponent_length_reg <= DEFAULT_EXPLENGTH;
          modulus_length_reg  <= DEFAULT_MODLENGTH;
        end
      else
        begin
          start_reg <= start_new;
          if (exponent_length_we)
            begin
              exponent_length_reg <= write_data[7 : 0];
            end
          if (modulus_length_we)
            begin
              modulus_length_reg <= write_data[7 : 0];
            end
        end
    end 
  always @*
    begin : api
      modulus_length_we    = 1'b0;
      exponent_length_we   = 1'b0;
      start_new            = 1'b0;
      modulus_mem_api_rst  = 1'b0;
      modulus_mem_api_cs   = 1'b0;
      modulus_mem_api_wr   = 1'b0;
      exponent_mem_api_rst = 1'b0;
      exponent_mem_api_cs  = 1'b0;
      exponent_mem_api_wr  = 1'b0;
      message_mem_api_rst  = 1'b0;
      message_mem_api_cs   = 1'b0;
      message_mem_api_wr   = 1'b0;
      result_mem_api_rst   = 1'b0;
      result_mem_api_cs    = 1'b0;
      tmp_read_data        = 32'h00000000;
      if (cs)
        begin
          case (address[11 : 8])
            GENERAL_PREFIX:
              begin
                if (we)
                  begin
                    case (address[7 : 0])
                      ADDR_CTRL:
                        begin
                          start_new = write_data[0];
                        end
                      ADDR_MODULUS_LENGTH:
                        begin
                          modulus_length_we = 1'b1;
                        end
                      ADDR_EXPONENT_LENGTH:
                        begin
                          exponent_length_we = 1'b1;
                        end
                      ADDR_MODULUS_PTR_RST:
                        begin
                          modulus_mem_api_rst = 1'b1;
                        end
                      ADDR_MODULUS_DATA:
                        begin
                          modulus_mem_api_cs = 1'b1;
                          modulus_mem_api_wr = 1'b1;
                        end
                      ADDR_EXPONENT_PTR_RST:
                        begin
                          exponent_mem_api_rst = 1'b1;
                        end
                      ADDR_EXPONENT_DATA:
                        begin
                          exponent_mem_api_cs = 1'b1;
                          exponent_mem_api_wr = 1'b1;
                        end
                      ADDR_MESSAGE_PTR_RST:
                        begin
                          message_mem_api_rst = 1'b1;
                        end
                      ADDR_MESSAGE_DATA:
                        begin
                          message_mem_api_cs = 1'b1;
                          message_mem_api_wr = 1'b1;
                        end
                      ADDR_RESULT_PTR_RST:
                        begin
                          result_mem_api_rst = 1'b1;
                        end
                      default:
                        begin
                        end
                    endcase 
                  end
                else
                  begin
                    case (address[7 : 0])
                      ADDR_NAME0:
                        tmp_read_data = CORE_NAME0;
                      ADDR_NAME1:
                        tmp_read_data = CORE_NAME1;
                      ADDR_VERSION:
                        tmp_read_data = CORE_VERSION;
                      ADDR_CTRL:
                        tmp_read_data = {31'h00000000, start_reg};
                      ADDR_STATUS:
                        tmp_read_data = {31'h00000000, ready};
                      ADDR_CYCLES_HIGH:
                        tmp_read_data = cycles[63 : 32];
                      ADDR_CYCLES_LOW:
                        tmp_read_data = cycles[31 : 0];
                      ADDR_MODULUS_LENGTH:
                        tmp_read_data = {24'h000000, modulus_length_reg};
                      ADDR_EXPONENT_LENGTH:
                        tmp_read_data = {24'h000000, exponent_length_reg};
                      ADDR_MODULUS_DATA:
                        begin
                          modulus_mem_api_cs = 1'b1;
                          tmp_read_data      = modulus_mem_api_read_data;
                        end
                      ADDR_EXPONENT_DATA:
                        begin
                          exponent_mem_api_cs = 1'b1;
                          tmp_read_data       = exponent_mem_api_read_data;
                        end
                      ADDR_MESSAGE_DATA:
                        begin
                          message_mem_api_cs = 1'b1;
                          tmp_read_data      = message_mem_api_read_data;
                        end
                      ADDR_RESULT_DATA:
                        begin
                          result_mem_api_cs = 1'b1;
                          tmp_read_data     = result_mem_api_read_data;
                        end
                      default:
                        begin
                        end
                    endcase 
                  end
              end
            default:
              begin
              end
          endcase 
        end 
    end 
endmodule 
