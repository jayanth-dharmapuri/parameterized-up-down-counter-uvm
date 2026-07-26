module counter_assertions #(
  parameter int unsigned WIDTH = 8
) (
  input logic                 clk,
  input logic                 rst_n,
  input logic                 enable,
  input logic                 load,
  input logic                 up_down,
  input logic [WIDTH-1:0]     load_data,
  input logic [WIDTH-1:0]     count
);

  localparam logic [WIDTH-1:0] MAX_COUNT = {WIDTH{1'b1}};

  // Reset must clear the counter
  property p_reset;
    @(posedge clk)
    !rst_n |-> (count == '0);
  endproperty

  // Load has priority over enable and direction
  property p_load;
    @(posedge clk) disable iff (!rst_n)
    load |=> (count == $past(load_data));
  endproperty

  // Counter increments when enabled in up mode
  property p_count_up;
    @(posedge clk) disable iff (!rst_n)
    (!load && enable && up_down) |=> (count == ($past(count) + 1'b1));
  endproperty

  // Counter decrements when enabled in down mode
  property p_count_down;
    @(posedge clk) disable iff (!rst_n)
    (!load && enable && !up_down) |=> (count == ($past(count) - 1'b1));
  endproperty

  // Counter must hold its previous value when disabled
  property p_hold;
    @(posedge clk) disable iff (!rst_n)
    (!load && !enable) |=> (count == $past(count));
  endproperty

  // Maximum count must naturally roll over to zero
  property p_up_rollover;
    @(posedge clk) disable iff (!rst_n)
    (!load && enable && up_down && count == MAX_COUNT) |=> (count == '0);
  endproperty

  // Zero must naturally roll over to maximum count
  property p_down_rollover;
    @(posedge clk) disable iff (!rst_n)
    (!load && enable && !up_down && count == '0) |=> (count == MAX_COUNT);
  endproperty

  a_reset: assert property (p_reset)
    else $error("COUNTER_SVA: Reset failed. Expected count = 0, actual count = 0x%0h", count);

  a_load: assert property (p_load)
    else $error("COUNTER_SVA: Load operation failed");

  a_count_up: assert property (p_count_up)
    else $error("COUNTER_SVA: Count-up operation failed");

  a_count_down: assert property (p_count_down)
    else $error("COUNTER_SVA: Count-down operation failed");

  a_hold: assert property (p_hold)
    else $error("COUNTER_SVA: Hold operation failed");

  a_up_rollover: assert property (p_up_rollover)
    else $error("COUNTER_SVA: Up-count rollover failed");

  a_down_rollover: assert property (p_down_rollover)
    else $error("COUNTER_SVA: Down-count rollover failed");

  // Assertion coverage
  c_reset:         cover property (@(posedge clk) !rst_n);
  c_load:          cover property (@(posedge clk) rst_n && load);
  c_count_up:      cover property (@(posedge clk) rst_n && !load && enable && up_down);
  c_count_down:    cover property (@(posedge clk) rst_n && !load && enable && !up_down);
  c_hold:          cover property (@(posedge clk) rst_n && !load && !enable);
  c_up_rollover:   cover property (@(posedge clk) rst_n && !load && enable && up_down && count == MAX_COUNT);
  c_down_rollover: cover property (@(posedge clk) rst_n && !load && enable && !up_down && count == '0);

endmodule