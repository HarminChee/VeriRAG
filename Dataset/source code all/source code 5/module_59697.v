`timescale 1ps/1ps
`default_nettype none
`default_nettype wire
`timescale 1ps/1ps
`default_nettype none
module axi_clock_converter_v2_1_7_axic_sync_clock_converter # (
  parameter C_FAMILY     = "virtex6",
  parameter integer C_PAYLOAD_WIDTH = 32,
  parameter integer C_S_ACLK_RATIO = 1,
  parameter integer C_M_ACLK_RATIO = 1 ,
  parameter integer C_MODE = 0  
  )
 (
  input wire                    SAMPLE_CYCLE_EARLY,
  input wire                    SAMPLE_CYCLE,
  input  wire                        S_ACLK,
  input  wire                        S_ARESETN,
  input  wire [C_PAYLOAD_WIDTH-1:0] S_PAYLOAD,
  input  wire                        S_VALID,
  output wire                        S_READY,
  input  wire                        M_ACLK,
  input  wire                        M_ARESETN,
  output wire [C_PAYLOAD_WIDTH-1:0] M_PAYLOAD,
  output wire                        M_VALID,
  input  wire                        M_READY
);
localparam [1:0] ZERO = 2'b10;
localparam [1:0] ONE  = 2'b11;
localparam [1:0] TWO  = 2'b01;
localparam [1:0] INIT = 2'b00;
localparam integer P_LIGHT_WT = 0;
localparam integer P_FULLY_REG = 1;
generate
  if (C_S_ACLK_RATIO == C_M_ACLK_RATIO) begin : gen_passthru
    assign M_PAYLOAD = S_PAYLOAD;
    assign M_VALID   = S_VALID;
    assign S_READY   = M_READY;      
  end else begin : gen_sync_clock_converter
    wire s_sample_cycle;
    wire s_sample_cycle_early;
    wire m_sample_cycle;
    wire m_sample_cycle_early;
    wire slow_aclk;
    wire slow_areset;
    wire s_areset_r;
    wire m_areset_r;
    reg  s_tready_r; 
    wire s_tready_ns; 
    reg  m_tvalid_r; 
    wire m_tvalid_ns; 
    reg  [C_PAYLOAD_WIDTH-1:0] m_tpayload_r;
    reg  [C_PAYLOAD_WIDTH-1:0] m_tstorage_r;
    wire [C_PAYLOAD_WIDTH-1:0] m_tpayload_ns; 
    wire [C_PAYLOAD_WIDTH-1:0] m_tstorage_ns; 
    reg  m_tready_hold;
    wire m_tready_sample;
    wire load_tpayload;
    wire load_tstorage;
    wire load_tpayload_from_tstorage;
    reg [1:0] state;
    reg [1:0] next_state;
    reg s_aresetn_r = 1'b0; 
    always @(posedge S_ACLK) begin
      if (~S_ARESETN | ~M_ARESETN) begin
        s_aresetn_r <= 1'b0;
      end else begin
        s_aresetn_r <= S_ARESETN & M_ARESETN;
      end
    end
    assign s_areset_r = ~s_aresetn_r;
    reg m_aresetn_r = 1'b0; 
    always @(posedge M_ACLK) begin
      if (~S_ARESETN | ~M_ARESETN) begin
        m_aresetn_r <= 1'b0;
      end else begin
        m_aresetn_r <= S_ARESETN & M_ARESETN;
      end
    end
    assign m_areset_r = ~m_aresetn_r;
    if (C_S_ACLK_RATIO > C_M_ACLK_RATIO) begin : gen_slowclk_mi
      assign slow_aclk = M_ACLK;
    end else begin : gen_slowclk_si
      assign slow_aclk = S_ACLK;
    end
    assign slow_areset = (C_S_ACLK_RATIO > C_M_ACLK_RATIO) ? m_areset_r : s_areset_r;
    assign s_sample_cycle_early = (C_S_ACLK_RATIO > C_M_ACLK_RATIO) ? SAMPLE_CYCLE_EARLY : 1'b1;
    assign s_sample_cycle       = (C_S_ACLK_RATIO > C_M_ACLK_RATIO) ? SAMPLE_CYCLE : 1'b1;
    assign m_sample_cycle_early = (C_S_ACLK_RATIO > C_M_ACLK_RATIO) ? 1'b1 : SAMPLE_CYCLE_EARLY;
    assign m_sample_cycle       = (C_S_ACLK_RATIO > C_M_ACLK_RATIO) ? 1'b1 : SAMPLE_CYCLE;
    assign s_tready_ns = (C_S_ACLK_RATIO > C_M_ACLK_RATIO) ? state[1] & (state != INIT) : next_state[1];
    always @(posedge S_ACLK) begin 
      if (s_areset_r) begin
        s_tready_r <= 1'b0;
      end
      else begin
        s_tready_r <= s_sample_cycle_early ? s_tready_ns : 1'b0;
      end
    end
    assign S_READY = s_tready_r;
    assign m_tvalid_ns = next_state[0];
    always @(posedge M_ACLK) begin 
      if (m_areset_r) begin
        m_tvalid_r <= 1'b0;
      end
      else begin
        m_tvalid_r <= m_sample_cycle ? m_tvalid_ns : m_tvalid_r & ~M_READY;
      end
    end
    assign M_VALID = m_tvalid_r;
    always @(posedge M_ACLK) begin 
      if (m_areset_r) begin
        m_tready_hold <= 1'b0;
      end
      else begin
        m_tready_hold <= m_sample_cycle ? 1'b0 : m_tready_sample;
      end
    end
    assign m_tready_sample = (M_READY ) | m_tready_hold;
    assign m_tpayload_ns = ~load_tpayload ? m_tpayload_r :
                           load_tpayload_from_tstorage ? m_tstorage_r : 
                           S_PAYLOAD;
    assign m_tstorage_ns = C_MODE ? (load_tstorage ? S_PAYLOAD : m_tstorage_r) : 0;
    always @(posedge slow_aclk) begin 
      m_tpayload_r <= m_tpayload_ns;
      m_tstorage_r <= C_MODE ? m_tstorage_ns : 0;
    end
    assign M_PAYLOAD = m_tpayload_r;
    assign load_tstorage = C_MODE && (state != TWO);
    assign load_tpayload = m_tready_sample || (state == ZERO);
    assign load_tpayload_from_tstorage = C_MODE && (state == TWO) && m_tready_sample;
    always @(posedge slow_aclk) begin 
      state <= next_state;
    end
    always @* begin 
      if (slow_areset) begin 
        next_state = INIT;
      end else begin
        case (state)
          INIT: begin
            next_state = ZERO;
          end
          ZERO: begin
            if (S_VALID) begin
              next_state = C_MODE ? ONE : TWO; 
            end
            else begin
              next_state = ZERO;
            end
          end
          ONE: begin
            if (C_MODE == 0) begin
              next_state = TWO;  
            end 
            else if (m_tready_sample & ~S_VALID) begin 
              next_state = ZERO; 
            end
            else if (~m_tready_sample & S_VALID) begin
              next_state = TWO;  
            end
            else begin
              next_state = ONE;
            end
          end
          TWO: begin 
            if (m_tready_sample) begin
              next_state = C_MODE ? ONE : ZERO; 
            end
            else begin
              next_state = TWO;
            end
          end
        endcase 
      end
    end
  end 
  endgenerate
endmodule
`default_nettype wire
