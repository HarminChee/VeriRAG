`timescale 1 ns/1 ps
`timescale 1 ns/1 ps
module ddr3_controller (
input                       clk,
input                       rst,
input         [27:0]        write_address,
input                       write_en, 
input         [27:0]        read_address,
input                       read_en,  
input                       if_write_strobe,
input         [31:0]        if_write_data,
output        [1:0]         if_write_ready,
input         [1:0]         if_write_activate,
output        [23:0]        if_write_fifo_size,
output                      if_starved,
input                       of_read_strobe,
output                      of_read_ready,
input                       of_read_activate,
output        [23:0]        of_read_size,
output        [31:0]        of_read_data,
output  reg                 cmd_en,       
output  reg   [2:0]         cmd_instr,    
output  reg   [5:0]         cmd_bl,       
output  reg   [27:0]        cmd_word_addr,
input                       cmd_empty,    
input                       cmd_full,     
output  reg                 wr_en,        
output  reg   [3:0]         wr_mask,      
output        [31:0]        wr_data,      
input                       wr_full,      
input                       wr_empty,     
input         [6:0]         wr_count,     
input                       wr_underrun,  
input                       wr_error,     
output                      rd_en,        
input         [31:0]        rd_data,      
input                       rd_full,      
input                       rd_empty,     
input         [6:0]         rd_count,     
input                       rd_overflow,  
input                       rd_error      
);
localparam            CMD_WRITE     = 3'b000;
localparam            CMD_READ      = 3'b001;
localparam            CMD_WRITE_PC  = 3'b010;
localparam            CMD_READ_PC   = 3'b011;
localparam            CMD_REFRESH   = 3'b100;
localparam            IDLE          = 4'h0;
localparam            WRITE_READY   = 4'h1;
localparam            WRITE_DATA    = 4'h2;
localparam            WRITE_COMMAND = 4'h3;
localparam            READ_READY    = 4'h4;
localparam            READ_COMMAND  = 4'h5;
localparam            READ_DATA     = 4'h6;
reg         [3:0]   state;
reg         [27:0]  local_address;
wire                if_fifo_idle;
reg                 if_read_strobe;
wire                if_read_ready;
reg                 if_read_activate;
wire        [23:0]  if_read_size;
wire        [31:0]  if_read_data;
wire                if_inactive;
reg         [23:0]  if_read_count;
wire                of_starved;
reg                 of_fifo_reset = 0;
wire        [1:0]   of_write_ready;
reg         [1:0]   of_write_activate;
wire        [23:0]  of_write_size;
wire                of_write_strobe;
wire                of_inactive;
reg         [23:0]  of_write_count;
reg                 read_request;
reg                 read_request_count;
reg         [31:0]  data;
ppfifo#(
  .DATA_WIDTH             (32                                        ),
  .ADDRESS_WIDTH          (6                                         )
)user_2_mem(
  .reset                  (rst                                       ),
  .write_clock            (clk                                       ),
  .write_ready            (if_write_ready                            ),
  .write_activate         (if_write_activate                         ),
  .write_fifo_size        (if_write_fifo_size                        ),
  .write_strobe           (if_write_strobe                           ),
  .write_data             (if_write_data                             ),
  .starved                (if_starved                                ),
  .read_clock             (clk                                       ),
  .read_strobe            (if_read_strobe                            ),
  .read_ready             (if_read_ready                             ),
  .read_activate          (if_read_activate                          ),
  .read_count             (if_read_size                              ),
  .read_data              (if_read_data                              ),
  .inactive               (if_inactive                               )
);
ppfifo#(
  .DATA_WIDTH             (32                                         ),
  .ADDRESS_WIDTH          (6                                          )
)mem_2_user(
  .reset                  (rst || of_fifo_reset                       ),
  .write_clock            (clk                                        ),
  .write_ready            (of_write_ready                             ),
  .write_activate         (of_write_activate                          ),
  .write_fifo_size        (of_write_size                              ),
  .write_strobe           (of_write_strobe                            ),
  .write_data             (rd_data                                    ),
  .starved                (of_starved                                 ),
  .read_clock             (clk                                        ),
  .read_strobe            (of_read_strobe                             ),
  .read_ready             (of_read_ready                              ),
  .read_activate          (of_read_activate                           ),
  .read_count             (of_read_size                               ),
  .read_data              (of_read_data                               ),
  .inactive               (of_inactive                                )
);
assign    rd_en           = (read_request & !rd_empty);
assign    of_write_strobe = rd_en;
assign    wr_data         = if_read_data;
always @ (posedge clk) begin
  if (rst) begin
    state             <=  IDLE;
    cmd_en            <=  0;
    cmd_instr         <=  0;
    cmd_bl            <=  0;
    cmd_word_addr     <=  0;
    wr_en             <=  0;  
    wr_mask           <=  0;
    read_request      <=  0;
    read_request_count<=  0;
    if_read_strobe    <=  0;
    if_read_activate  <=  0;
    if_read_count     <=  0;
    of_fifo_reset     <=  0;
    of_write_activate <=  0;
    of_write_count    <=  0;
    local_address     <=  0;
  end
  else begin
    cmd_en            <=  0;
    wr_en             <=  0;
    read_request      <=  0;
    if_read_strobe    <=  0;
    of_fifo_reset     <=  0;
    if (if_read_ready && !if_read_activate) begin
      if_read_count           <=  0;
      if_read_activate        <=  1;
    end
    if ((state == READ_READY) && (of_write_ready > 0) && (of_write_activate == 0)) begin
      of_write_count          <=  0;
      if (of_write_ready[0]) begin
        of_write_activate[0]  <=  1;
      end
      else begin
        of_write_activate[1]  <=  1;
      end
    end
    case (state)
      IDLE: begin
        if (write_en) begin
          state               <=  WRITE_READY;
          local_address       <=  write_address;
        end
        else if (read_en) begin
          state               <=  READ_READY;
          local_address       <=  read_address;
        end
      end
      WRITE_READY: begin
        if (if_read_activate) begin
          state               <=  WRITE_DATA;
        end
        else if (!write_en && if_inactive) begin  
          state               <=  IDLE;
        end
      end
      WRITE_DATA: begin
        if (if_read_count       < if_read_size) begin
          if (wr_count < 6'h3F) begin
            wr_en               <=  1;
            if_read_count       <=  if_read_count + 24'h1;
            if_read_strobe      <=  1;
          end
          else begin
            $display ("FIFO Full, attempting to write: %h", if_read_data);
          end
        end
        else begin
          state                 <=  WRITE_COMMAND;
        end
      end
      WRITE_COMMAND: begin
        if (!cmd_full) begin
          cmd_instr             <=  CMD_WRITE_PC;
          cmd_bl                <=  if_read_count - 24'h1;
          cmd_word_addr         <=  local_address;
          cmd_en                <=  1;
          if_read_activate      <=  0;
          state                 <=  WRITE_READY;
          local_address         <=  local_address + if_read_count;
        end
      end
      READ_READY: begin
        if (read_en) begin
          if (of_write_activate > 0) begin
            state               <=  READ_COMMAND;
          end
        end
        else begin
          state                 <=  IDLE;
          of_fifo_reset         <=  1;
        end
      end
      READ_COMMAND: begin
        if(!cmd_full) begin
            cmd_instr           <=  CMD_READ_PC;
            cmd_bl              <=  of_write_size - 24'h1;
            cmd_word_addr       <=  local_address;
            cmd_en              <=  1;
            local_address       <=  local_address + of_write_size;
            state               <=  READ_DATA;
        end
      end
      READ_DATA: begin
        if ((of_write_activate > 0) && (of_write_count < of_write_size)) begin
          read_request          <=  1;
          if (rd_en) begin
            of_write_count      <=  of_write_count + 24'h1;
          end
        end
        else begin
          state                 <=  READ_READY;
          if ((of_write_activate > 0) && (of_write_count > 0) && (!of_write_strobe)) begin
            of_write_activate   <=  0;
          end
        end
      end
      default: begin
        state                   <=  0;
      end
    endcase
  end
end
endmodule
