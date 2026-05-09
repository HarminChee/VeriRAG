`timescale 1ns / 1ps
`timescale 1ns / 1ps
module csr_block (
  clk,
  reset,
  csr_writedata,
  csr_write,
  csr_byteenable,
  csr_readdata,
  csr_read,
  csr_address,
  csr_irq,
  done_strobe,
  busy,
  descriptor_buffer_empty,
  descriptor_buffer_full,
  stop_state,
  stopped_on_error,
  stopped_on_early_termination,
  reset_stalled,
  stop,
  sw_reset,
  stop_on_error,
  stop_on_early_termination,
  stop_descriptors,
  sequence_number,
  descriptor_watermark,
  response_watermark,
  response_buffer_empty,
  response_buffer_full,
  transfer_complete_IRQ_mask,
  error_IRQ_mask,
  early_termination_IRQ_mask,
  error,
  early_termination
);
  parameter ADDRESS_WIDTH = 3;
  localparam CONTROL_REGISTER_ADDRESS = 3'b001;
  input clk;
  input reset;
  input [31:0] csr_writedata;
  input csr_write;
  input [3:0] csr_byteenable;
  output wire [31:0] csr_readdata;
  input csr_read;
  input [ADDRESS_WIDTH-1:0] csr_address;
  output wire csr_irq;
  input done_strobe;
  input busy;
  input descriptor_buffer_empty;
  input descriptor_buffer_full;
  input stop_state;      
  input reset_stalled;   
  output wire stop;
  output reg stopped_on_error;
  output reg stopped_on_early_termination;
  output reg sw_reset;
  output wire stop_on_error;
  output wire stop_on_early_termination;
  output wire stop_descriptors;
  input [31:0] sequence_number;
  input [31:0] descriptor_watermark;
  input [15:0] response_watermark;
  input response_buffer_empty;
  input response_buffer_full;
  input transfer_complete_IRQ_mask;
  input [7:0] error_IRQ_mask;
  input early_termination_IRQ_mask;
  input [7:0] error;
  input early_termination;
  wire [31:0] status;
  reg [31:0] control;
  reg [31:0] readdata;
  reg [31:0] readdata_d1;
  reg irq;  
  wire set_irq;
  wire clear_irq;
  reg [15:0] irq_count; 
  wire clear_irq_count;
  wire incr_irq_count;
  wire set_stopped_on_error;
  wire set_stopped_on_early_termination;
  wire set_stop;
  wire clear_stop;
  wire global_interrupt_enable;
  wire sw_reset_strobe;  
  wire set_sw_reset;
  wire clear_sw_reset;
  always @ (posedge clk or posedge reset)
  begin
    if (reset)
    begin
      readdata_d1 <= 0;
    end
    else if (csr_read == 1)
    begin
      readdata_d1 <= readdata;
    end
  end
  always @ (posedge clk or posedge reset)
  begin
    if (reset)
    begin
      control[31:1] <= 0;
    end
    else
    begin
      if (sw_reset_strobe == 1)  
      begin
        control[31:1] <= 0;
      end
      else
      begin
        if ((csr_address == CONTROL_REGISTER_ADDRESS) & (csr_write == 1) & (csr_byteenable[0] == 1))
        begin
          control[7:1] <= csr_writedata[7:1];  
        end
        if ((csr_address == CONTROL_REGISTER_ADDRESS) & (csr_write == 1) & (csr_byteenable[1] == 1))
        begin
          control[15:8] <= csr_writedata[15:8];
        end
        if ((csr_address == CONTROL_REGISTER_ADDRESS) & (csr_write == 1) & (csr_byteenable[2] == 1))
        begin
          control[23:16] <= csr_writedata[23:16];
        end
        if ((csr_address == CONTROL_REGISTER_ADDRESS) & (csr_write == 1) & (csr_byteenable[3] == 1))
        begin
          control[31:24] <= csr_writedata[31:24];
        end
      end
    end
  end
  always @ (posedge clk or posedge reset)
  begin
    if (reset)
    begin
      control[0] <= 0;
    end
    else
    begin
      if (sw_reset_strobe == 1)
      begin
        control[0] <= 0;
      end
      else
      begin
        case ({set_stop, clear_stop})
          2'b00: control[0] <= control[0];
          2'b01: control[0] <= 1'b0;
          2'b10: control[0] <= 1'b1;
          2'b11: control[0] <= 1'b1;  
        endcase
      end
    end
  end
  always @ (posedge clk or posedge reset)
  begin
    if (reset)
    begin
      sw_reset <= 0;
    end
    else
    begin
      if (set_sw_reset == 1)
      begin
        sw_reset <= 1;
      end
      else if (clear_sw_reset == 1)
      begin
        sw_reset <= 0;
      end
    end
  end
  always @ (posedge clk or posedge reset)
  begin
    if (reset)
    begin
      stopped_on_error <= 0;
    end
    else
    begin
      case ({set_stopped_on_error, clear_stop})
        2'b00: stopped_on_error <= stopped_on_error;
        2'b01: stopped_on_error <= 1'b0;
        2'b10: stopped_on_error <= 1'b1;
        2'b11: stopped_on_error <= 1'b0;
      endcase
    end
  end
  always @ (posedge clk or posedge reset)
  begin
    if (reset)
    begin
      stopped_on_early_termination <= 0;
    end
    else
    begin
      case ({set_stopped_on_early_termination, clear_stop})
        2'b00: stopped_on_early_termination <= stopped_on_early_termination;
        2'b01: stopped_on_early_termination <= 1'b0;
        2'b10: stopped_on_early_termination <= 1'b1;
        2'b11: stopped_on_early_termination <= 1'b0;
      endcase
    end
  end
  always @ (posedge clk or posedge reset)
  begin
    if (reset)
    begin
      irq <= 0;
    end
    else
    begin
      if (sw_reset_strobe == 1)
      begin
        irq <= 0;
      end
      else
      begin
        case ({clear_irq, set_irq})
          2'b00: irq <= irq;
          2'b01: irq <= 1'b1;
          2'b10: irq <= 1'b0;
          2'b11: irq <= 1'b1;  
        endcase
      end
    end
  end
  always @ (posedge clk or posedge reset)
  begin
    if (reset)
    begin
        irq_count <= {16{1'b0}};
    end
    else
    begin
        if (sw_reset_strobe == 1)
        begin
            irq_count <= {16{1'b0}};
        end
        else
        begin
            case ({clear_irq_count, incr_irq_count})
                2'b00: irq_count <= irq_count;
                2'b01: irq_count <= irq_count + 1;
                2'b10: irq_count <= {16{1'b0}};
                2'b11: irq_count <= {{15{1'b0}}, 1'b1};
            endcase
        end
    end
  end
  generate
    if (ADDRESS_WIDTH == 3)
    begin  
      always @ (csr_address or status or control or descriptor_watermark or response_watermark or sequence_number)
      begin
        case (csr_address)
          3'b000: readdata = status;
          3'b001: readdata = control;
          3'b010: readdata = descriptor_watermark;
          3'b011: readdata = response_watermark;
          default: readdata = sequence_number;  
        endcase  
      end
    end
    else
    begin
      always @ (csr_address or status or control or descriptor_watermark or response_watermark)
      begin
        case (csr_address)
          3'b000: readdata = status;
          3'b001: readdata = control;
          3'b010: readdata = descriptor_watermark;
          default: readdata = response_watermark;  
        endcase  
      end
    end
  endgenerate
  assign clear_irq = (csr_address == 0) & (csr_write == 1) & (csr_byteenable[1] == 1) & (csr_writedata[9] == 1);  
  assign set_irq = (global_interrupt_enable == 1) & (done_strobe == 1) &       
                   ((transfer_complete_IRQ_mask == 1) |                        
                    ((error & error_IRQ_mask) != 0) |                          
                    ((early_termination & early_termination_IRQ_mask) == 1));  
  assign csr_irq = irq;
  assign incr_irq_count = set_irq; 
  assign clear_irq_count = (csr_address == 0) & (csr_write == 1) & (csr_byteenable[2] == 1) & (csr_writedata[16] == 1); 
  assign clear_stop = (csr_address == CONTROL_REGISTER_ADDRESS) & (csr_write == 1) & (csr_byteenable[0] == 1) & (csr_writedata[0] == 0);
  assign set_stopped_on_error = (done_strobe == 1) & (stop_on_error == 1) & (error != 0);  
  assign set_stopped_on_early_termination = (done_strobe == 1) & (stop_on_early_termination == 1) & (early_termination == 1);  
  assign set_stop = ((csr_address == CONTROL_REGISTER_ADDRESS) & (csr_write == 1) & (csr_byteenable[0] == 1) & (csr_writedata[0] == 1)) |  
                    (set_stopped_on_error == 1) |  
                    (set_stopped_on_early_termination == 1) ;  
  assign stop = control[0];
  assign set_sw_reset = (csr_address == CONTROL_REGISTER_ADDRESS) & (csr_write == 1) & (csr_byteenable[0] == 1) & (csr_writedata[1] == 1);
  assign clear_sw_reset = (sw_reset == 1) & (reset_stalled == 0);
  assign sw_reset_strobe = control[1];
  assign stop_on_error = control[2];
  assign stop_on_early_termination = control[3];
  assign global_interrupt_enable = control[4];
  assign stop_descriptors = control[5];
  assign csr_readdata = readdata_d1;
  assign status = {irq_count, {6{1'b0}}, irq, stopped_on_early_termination, stopped_on_error, sw_reset, stop_state, response_buffer_full, response_buffer_empty, descriptor_buffer_full, descriptor_buffer_empty, busy};  
endmodule
