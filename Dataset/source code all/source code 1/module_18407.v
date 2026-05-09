module edc_erasure (
  input                  i_clk,
  input                  i_rst, 
  input                  i_sel, 
  input                  i_we,  
  input                  i_err, 
  input                  i_ue,  
  input [31:0]           i_addr,
  input [31:0]           i_bus_data,
  input [31:0]           i_mem_data,
  input                  i_mem_ack, 
  output reg [31:0]      o_bus_data,
  output reg [31:0]      o_mem_data,
  output reg             o_mem_sel, 
  output reg             o_mem_we,  
  output reg [7:0]       o_mem_ecc, 
  output reg             o_err,     
  output reg             o_ack      
);
parameter SIZE                  = 4;
parameter IDLE                  = 4'd0;
parameter WRITE                 = 4'd1;
parameter READ                  = 4'd2;
parameter WRITE_COMPLEMENT      = 4'd3;
parameter WRITE_COMPLEMENT_DONE = 4'd4;
parameter READ_COMPLEMENT       = 4'd5;
parameter READ_COMPLEMENT_DONE  = 4'd6;
parameter WRITE_CORRECTED       = 4'd7;
parameter WRITE_DONE            = 4'd8;
parameter READ_DONE             = 4'd9;
parameter ERROR                 = 4'd10;
reg [SIZE-1:0] current_state;
wire [SIZE-1:0] next_state;
assign next_state = fsm_function(current_state, i_sel, o_mem_sel, i_we, i_mem_ack, i_err, i_ue);
function [SIZE-1:0] fsm_function;
  input [SIZE-1:0] state;
  input i_start;
  input i_done;
  input i_we;
  input i_ack;
  input i_err;
  input i_ue;
  case(state)
    IDLE: if (i_start == 1'b1) begin
        if (i_we == 1'b1) begin
            fsm_function = WRITE;
          end else begin
            fsm_function = READ;
          end
      end else begin
        fsm_function = IDLE;    
      end
    WRITE: if (i_ack == 1'b1) begin
        fsm_function = WRITE_DONE;
      end else begin 
        fsm_function = WRITE;
      end
    READ: if (i_ack == 1'b1) begin
        if (i_ue == 1'b0) begin
          fsm_function = READ_DONE;
        end else begin
          fsm_function = WRITE_COMPLEMENT;
        end
      end else begin 
        fsm_function = READ;
      end
    WRITE_COMPLEMENT: if (i_ack == 1'b1) begin
        fsm_function = WRITE_COMPLEMENT_DONE;
      end else begin 
        fsm_function = WRITE_COMPLEMENT;
      end
    WRITE_COMPLEMENT_DONE: if (i_done == 1'b0 ) begin
        fsm_function = READ_COMPLEMENT;
      end else begin
        fsm_function = WRITE_COMPLEMENT_DONE;
      end
    READ_COMPLEMENT: if (i_ack == 1'b1) begin
        if (i_ue == 1'b1) begin
          fsm_function = ERROR;
        end else begin
          fsm_function = READ_COMPLEMENT_DONE;
        end
      end else begin 
        fsm_function = READ_COMPLEMENT;
      end
    READ_COMPLEMENT_DONE:  if (i_done == 1'b0 ) begin
        fsm_function = WRITE_CORRECTED;
      end else begin
        fsm_function = READ_COMPLEMENT_DONE;
      end
    WRITE_CORRECTED: if (i_ack == 1'b1) begin
        fsm_function = READ_DONE;
      end else begin 
        fsm_function = WRITE_CORRECTED;
      end
    WRITE_DONE:
      fsm_function = IDLE;
    READ_DONE:
      fsm_function = IDLE;
    ERROR:
        fsm_function = ERROR; 
    default:
        fsm_function = IDLE;
  endcase
endfunction
always @ (posedge i_clk)
begin : FSM_SEQ
  if(i_rst == 1'b1) begin
    current_state <= IDLE;
  end else begin
    current_state <= next_state;
  end
end
reg [31:0] word;
always @ (posedge i_clk)
begin : OUTPUT_LOGIC
  if (i_rst == 1'b1) begin
    o_bus_data <= 'b0;
    o_mem_data <= 'b0;
    o_mem_sel  <= 'b0;
    o_mem_we   <= 'b0;
    o_mem_ecc  <= 'b0;
    o_err      <= 'b0;
    o_ack      <= 'b0;
  end else begin
    case(current_state)
    IDLE: begin
        o_err  <= 'b0;
      end
    WRITE: begin      
        o_ack      <= 'b0;
        o_mem_sel  <= 1'b1;
        o_mem_we   <= 1'b1;
        o_mem_data <= i_bus_data;
      end
    READ: begin
        o_ack     <= 'b0;
        o_mem_sel <= 1'b1;
        o_mem_we  <= 1'b0;
        word      <= i_mem_data;
      end
    WRITE_COMPLEMENT: begin
        o_mem_sel  <= 1'b1;
        o_mem_we   <= 1'b1;
        o_mem_data <= ~word;
      end
    WRITE_COMPLEMENT_DONE: begin
        o_mem_sel = 1'b0;
      end
    READ_COMPLEMENT: begin
        o_mem_sel  <= 1'b1;
        o_mem_we   <= 1'b0;
        word       <= ~i_mem_data;
      end
    READ_COMPLEMENT_DONE: begin
        o_mem_sel = 1'b0;
      end
    WRITE_CORRECTED: begin
        o_mem_sel  <= 1'b1;
        o_mem_we   <= 1'b1;
        o_mem_data <= word;
      end
    WRITE_DONE: begin
        o_mem_sel = 1'b0;
      end
    READ_DONE: begin
        o_mem_sel  = 1'b0;
        o_bus_data <= word;
        o_ack      <= 1'b1;
      end
    endcase
  end
end 
endmodule
