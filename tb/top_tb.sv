`timescale 1ns/1ps

`include "counter_config.svh"

module top_tb;

    import uvm_pkg::*;
    import counter_pkg::*;

    localparam int unsigned WIDTH = `COUNTER_WIDTH;

    logic clk;

    counter_if #( .WIDTH(WIDTH)) counter_vif(.clk(clk));

      up_down_counter #(
    .WIDTH(WIDTH)
  ) dut (
    .clk       (clk),
    .rst_n     (counter_vif.rst_n),
    .enable    (counter_vif.enable),
    .load      (counter_vif.load),
    .up_down   (counter_vif.up_down),
    .load_data (counter_vif.load_data),
    .count     (counter_vif.count)
  );

    counter_assertions #(
  .WIDTH(WIDTH)
) counter_sva (
  .clk       (clk),
  .rst_n     (counter_vif.rst_n),
  .enable    (counter_vif.enable),
  .load      (counter_vif.load),
  .up_down   (counter_vif.up_down),
  .load_data (counter_vif.load_data),
  .count     (counter_vif.count)
);
    initial begin 
        clk = 1'b0;
        forever #5 clk = ~clk;
    end 

    initial begin 
    counter_vif.rst_n     = 1'b1;
    counter_vif.enable    = 1'b0;
    counter_vif.load      = 1'b0;
    counter_vif.up_down   = 1'b0;
    counter_vif.load_data = '0;

    uvm_config_db #(virtual counter_if #(.WIDTH(WIDTH)))::set(
      null,
      "*",
      "vif",
      counter_vif
    );

    run_test();
  end

endmodule