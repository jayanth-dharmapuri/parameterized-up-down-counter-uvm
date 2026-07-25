interface counter_if #(
  parameter int unsigned WIDTH = 8
) (
  input logic clk
);
  
  logic rst_n, enable, load, up_down;
  logic [WIDTH-1:0] load_data, count;
  
  clocking driver_cb @(posedge clk);
    default input #1 output #1;
    
    output rst_n, enable, load, up_down, load_down;
    input count;
  endclocking
  
  clocking monitor_cb @(posedge clk);
    default input #1 output #1;
    
    input rst_n, enable, load, up_down, load_data, count;
  endclocking
  
  modport DRIVER (clocking driver_cb, input clk);
  modport MONITOR (clocking monitor_cb, input clk);
      
  modport DUT (
    input clk, rst_n, enable, load, up_down, load_data,
    output count
   );
endinterface