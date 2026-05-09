module PCIeGen2x8If128_gt_top #
(
   // ... existing code ...
)
(
   // ... existing code ...
);

// ... existing code ...

  wire dft_clock_locked;
  input wire test_mode_i;
  assign dft_clock_locked = test_mode_i ? sys_clk : clock_locked;

// ... existing code ...

  PCIeGen2x8If128_pipe_wrapper #
  (
    // ... existing code ...
  ) pipe_wrapper_i (
    .PIPE_CLK                        ( test_mode_i ? sys_clk : pipe_clk_int ),
    .PIPE_RESET_N                    ( sys_rst_n ),
    .PIPE_PCLK                       ( pipe_clk_int ),
    // ... existing code ...
  );

// ... existing code ...

endmodule