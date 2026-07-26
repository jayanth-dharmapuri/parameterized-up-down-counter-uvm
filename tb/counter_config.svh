`ifndef COUNTER_CONFIG_SVH
`define COUNTER_CONFIG_SVH

  // Can be overridden during compilation:
  // +define+COUNTER_WIDTH=4

  `ifndef COUNTER_WIDTH
    `define COUNTER_WIDTH 8
  `endif

`endif
