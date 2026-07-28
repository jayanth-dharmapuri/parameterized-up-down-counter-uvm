`timescale 1ns/1ps

`ifndef COUNTER_WIDTH
  `define COUNTER_WIDTH 4
`endif


//============================================================
// COUNTER INTERFACE
//============================================================

interface counter_if #(
  parameter int unsigned WIDTH = `COUNTER_WIDTH
) (
  input logic clk
);

  logic                 rst_n;
  logic                 enable;
  logic                 load;
  logic                 up_down;
  logic [WIDTH-1:0]     load_data;
  logic [WIDTH-1:0]     count;

  initial begin
    rst_n     = 1'b0;
    enable    = 1'b0;
    load      = 1'b0;
    up_down   = 1'b0;
    load_data = '0;
  end

  clocking driver_cb @(posedge clk);
    default input #1step output #0;

    output rst_n;
    output enable;
    output load;
    output up_down;
    output load_data;

    input count;
  endclocking

  clocking monitor_cb @(posedge clk);
    default input #1step;

    input rst_n;
    input enable;
    input load;
    input up_down;
    input load_data;
    input count;
  endclocking

endinterface


//============================================================
// UVM PACKAGE
//============================================================

package counter_pkg;

  import uvm_pkg::*;

  `include "uvm_macros.svh"

  typedef virtual counter_if #(
    .WIDTH(`COUNTER_WIDTH)
  ) counter_vif_t;


  //==========================================================
  // SEQUENCE ITEM
  //==========================================================

  class counter_seq_item extends uvm_sequence_item;

    rand bit                      rst_n;
    rand bit                      enable;
    rand bit                      load;
    rand bit                      up_down;
    rand bit [`COUNTER_WIDTH-1:0] load_data;

    logic [`COUNTER_WIDTH-1:0]    count;

    constraint c_reset_controls {
      (!rst_n) -> (enable == 0 && load == 0);
    }

    `uvm_object_utils(counter_seq_item)

    function new(string name = "counter_seq_item");
      super.new(name);
    endfunction

    virtual function void do_print(uvm_printer printer);
      super.do_print(printer);

      printer.print_field_int("rst_n",     rst_n,     $bits(rst_n),     UVM_BIN);
      printer.print_field_int("enable",    enable,    $bits(enable),    UVM_BIN);
      printer.print_field_int("load",      load,      $bits(load),      UVM_BIN);
      printer.print_field_int("up_down",   up_down,   $bits(up_down),   UVM_BIN);
      printer.print_field_int("load_data", load_data, $bits(load_data), UVM_HEX);
      printer.print_field_int("count",     count,     $bits(count),     UVM_HEX);
    endfunction

  endclass


  //==========================================================
  // SEQUENCER
  //==========================================================

  class counter_sequencer extends uvm_sequencer #(counter_seq_item);

    `uvm_component_utils(counter_sequencer)

    function new(string name = "counter_sequencer", uvm_component parent = null);
      super.new(name, parent);
    endfunction

  endclass


  //==========================================================
  // BASE SEQUENCE
  //==========================================================

  class counter_base_sequence extends uvm_sequence #(counter_seq_item);

    `uvm_object_utils(counter_base_sequence)

    function new(string name = "counter_base_sequence");
      super.new(name);
    endfunction

    task send_item(
      bit                      rst_n_value,
      bit                      enable_value,
      bit                      load_value,
      bit                      up_down_value,
      bit [`COUNTER_WIDTH-1:0] load_data_value
    );

      counter_seq_item tr;

      tr = counter_seq_item::type_id::create("tr");

      start_item(tr);

      tr.rst_n     = rst_n_value;
      tr.enable    = enable_value;
      tr.load      = load_value;
      tr.up_down   = up_down_value;
      tr.load_data = load_data_value;

      finish_item(tr);

    endtask

  endclass


  //==========================================================
  // RESET SEQUENCE
  //==========================================================

  class counter_reset_sequence extends counter_base_sequence;

    `uvm_object_utils(counter_reset_sequence)

    function new(string name = "counter_reset_sequence");
      super.new(name);
    endfunction

    virtual task body();

      repeat (2)
        send_item(1'b0, 1'b0, 1'b0, 1'b0, '0);

      send_item(1'b1, 1'b0, 1'b0, 1'b0, '0);

    endtask

  endclass


  //==========================================================
  // LOAD SEQUENCE
  //==========================================================

  class counter_load_sequence extends counter_base_sequence;

    bit [`COUNTER_WIDTH-1:0] value = 'h5;

    `uvm_object_utils(counter_load_sequence)

    function new(string name = "counter_load_sequence");
      super.new(name);
    endfunction

    virtual task body();
      send_item(1'b1, 1'b1, 1'b1, 1'b0, value);
    endtask

  endclass


  //==========================================================
  // COUNT-UP SEQUENCE
  //==========================================================

  class counter_up_sequence extends counter_base_sequence;

    int unsigned cycles = 10;

    `uvm_object_utils(counter_up_sequence)

    function new(string name = "counter_up_sequence");
      super.new(name);
    endfunction

    virtual task body();

      repeat (cycles)
        send_item(1'b1, 1'b1, 1'b0, 1'b1, '0);

    endtask

  endclass


  //==========================================================
  // COUNT-DOWN SEQUENCE
  //==========================================================

  class counter_down_sequence extends counter_base_sequence;

    int unsigned cycles = 10;

    `uvm_object_utils(counter_down_sequence)

    function new(string name = "counter_down_sequence");
      super.new(name);
    endfunction

    virtual task body();

      repeat (cycles)
        send_item(1'b1, 1'b1, 1'b0, 1'b0, '0);

    endtask

  endclass


  //==========================================================
  // HOLD SEQUENCE
  //==========================================================

  class counter_hold_sequence extends counter_base_sequence;

    int unsigned cycles = 5;

    `uvm_object_utils(counter_hold_sequence)

    function new(string name = "counter_hold_sequence");
      super.new(name);
    endfunction

    virtual task body();

      repeat (cycles)
        send_item(1'b1, 1'b0, 1'b0, 1'b0, '0);

    endtask

  endclass


  //==========================================================
  // IDLE SEQUENCE
  //==========================================================

  class counter_idle_sequence extends counter_base_sequence;

    `uvm_object_utils(counter_idle_sequence)

    function new(string name = "counter_idle_sequence");
      super.new(name);
    endfunction

    virtual task body();
      send_item(1'b1, 1'b0, 1'b0, 1'b0, '0);
    endtask

  endclass


  //==========================================================
  // RANDOM SEQUENCE
  //==========================================================

  class counter_random_sequence extends counter_base_sequence;

    int unsigned number_of_items = 50;

    `uvm_object_utils(counter_random_sequence)

    function new(string name = "counter_random_sequence");
      super.new(name);
    endfunction

    virtual task body();

      counter_seq_item tr;

      repeat (number_of_items) begin

        tr = counter_seq_item::type_id::create("tr");

        start_item(tr);

        if (!tr.randomize() with {
          rst_n   dist {1 := 98, 0 := 2};
          load    dist {1 := 20, 0 := 80};
          enable  dist {1 := 70, 0 := 30};
          up_down dist {1 := 50, 0 := 50};
        }) begin
          `uvm_fatal(get_type_name(), "Transaction randomization failed")
        end

        finish_item(tr);

      end

    endtask

  endclass


  //==========================================================
  // DRIVER
  //==========================================================

  class counter_driver extends uvm_driver #(counter_seq_item);

    `uvm_component_utils(counter_driver)

    counter_vif_t vif;

    function new(string name = "counter_driver", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      if (!uvm_config_db #(counter_vif_t)::get(this, "", "vif", vif))
        `uvm_fatal(get_type_name(), "Virtual interface was not found")
    endfunction

    task run_phase(uvm_phase phase);

      forever begin

        seq_item_port.get_next_item(req);

        @(vif.driver_cb);

        vif.driver_cb.rst_n     <= req.rst_n;
        vif.driver_cb.enable    <= req.enable;
        vif.driver_cb.load      <= req.load;
        vif.driver_cb.up_down   <= req.up_down;
        vif.driver_cb.load_data <= req.load_data;

        `uvm_info(get_type_name(),
                  $sformatf("Driven transaction:\n%s", req.sprint()),
                  UVM_HIGH)

        seq_item_port.item_done();

      end

    endtask

  endclass


  //==========================================================
  // MONITOR
  //==========================================================

  class counter_monitor extends uvm_monitor;

    `uvm_component_utils(counter_monitor)

    counter_vif_t vif;

    uvm_analysis_port #(counter_seq_item) monitor_ap;

    function new(string name = "counter_monitor", uvm_component parent = null);
      super.new(name, parent);

      monitor_ap = new("monitor_ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      if (!uvm_config_db #(counter_vif_t)::get(this, "", "vif", vif))
        `uvm_fatal(get_type_name(), "Virtual interface was not found")
    endfunction

    task run_phase(uvm_phase phase);

      counter_seq_item tr;

      forever begin

        @(vif.monitor_cb);

        tr = counter_seq_item::type_id::create("tr");

        tr.rst_n     = vif.monitor_cb.rst_n;
        tr.enable    = vif.monitor_cb.enable;
        tr.load      = vif.monitor_cb.load;
        tr.up_down   = vif.monitor_cb.up_down;
        tr.load_data = vif.monitor_cb.load_data;
        tr.count     = vif.monitor_cb.count;

        monitor_ap.write(tr);

        `uvm_info(get_type_name(),
                  $sformatf("Monitored transaction:\n%s", tr.sprint()),
                  UVM_HIGH)

      end

    endtask

  endclass


  //==========================================================
  // AGENT
  //==========================================================

  class counter_agent extends uvm_agent;

    `uvm_component_utils(counter_agent)

    counter_driver    driver;
    counter_monitor   monitor;
    counter_sequencer sequencer;

    function new(string name = "counter_agent", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      monitor = counter_monitor::type_id::create("monitor", this);

      if (get_is_active() == UVM_ACTIVE) begin
        driver    = counter_driver::type_id::create("driver", this);
        sequencer = counter_sequencer::type_id::create("sequencer", this);
      end
    endfunction

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);

      if (get_is_active() == UVM_ACTIVE)
        driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction

  endclass


  //==========================================================
  // SCOREBOARD
  //==========================================================

  class counter_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(counter_scoreboard)

    uvm_analysis_imp #(counter_seq_item, counter_scoreboard) analysis_imp;

    logic [`COUNTER_WIDTH-1:0] expected_count;

    bit          model_valid;
    int unsigned pass_count;
    int unsigned fail_count;

    function new(string name = "counter_scoreboard", uvm_component parent = null);
      super.new(name, parent);

      analysis_imp   = new("analysis_imp", this);
      expected_count = '0;
      model_valid    = 1'b0;
      pass_count     = 0;
      fail_count     = 0;
    endfunction

    function void write(counter_seq_item tr);

      if (!tr.rst_n) begin

        expected_count = '0;
        model_valid    = 1'b1;

        if (tr.count !== '0) begin
          fail_count++;

          `uvm_error(get_type_name(),
                     $sformatf("RESET FAILED: expected=0x%0h actual=0x%0h",
                               expected_count, tr.count))
        end
        else begin
          pass_count++;

          `uvm_info(get_type_name(),
                    $sformatf("RESET PASSED: count=0x%0h", tr.count),
                    UVM_LOW)
        end

      end
      else begin

        if (model_valid) begin

          if (tr.count !== expected_count) begin
            fail_count++;

            `uvm_error(get_type_name(),
                       $sformatf("COUNT MISMATCH: expected=0x%0h actual=0x%0h",
                                 expected_count, tr.count))
          end
          else begin
            pass_count++;

            `uvm_info(get_type_name(),
                      $sformatf("COUNT MATCH: expected=0x%0h actual=0x%0h",
                                expected_count, tr.count),
                      UVM_LOW)
          end

        end
        else begin
          expected_count = tr.count;
          model_valid    = 1'b1;
        end

        if (tr.load)
          expected_count = tr.load_data;
        else if (tr.enable && tr.up_down)
          expected_count = expected_count + 1'b1;
        else if (tr.enable && !tr.up_down)
          expected_count = expected_count - 1'b1;

      end

    endfunction

    function void report_phase(uvm_phase phase);
      super.report_phase(phase);

      if (fail_count == 0) begin
        `uvm_info(get_type_name(),
                  $sformatf("SCOREBOARD PASSED: PASSED=%0d FAILED=%0d",
                            pass_count, fail_count),
                  UVM_NONE)
      end
      else begin
        `uvm_error(get_type_name(),
                   $sformatf("SCOREBOARD FAILED: PASSED=%0d FAILED=%0d",
                             pass_count, fail_count))
      end
    endfunction

  endclass


  //==========================================================
  // FUNCTIONAL COVERAGE
  //==========================================================

  class counter_coverage extends uvm_subscriber #(counter_seq_item);

    `uvm_component_utils(counter_coverage)

    localparam logic [`COUNTER_WIDTH-1:0] MAX_COUNT = {`COUNTER_WIDTH{1'b1}};

    typedef enum bit [2:0] {
      RESET_OPERATION,
      LOAD_OPERATION,
      HOLD_OPERATION,
      COUNT_UP_OPERATION,
      COUNT_DOWN_OPERATION
    } counter_operation_e;

    bit                       rst_n;
    bit                       enable;
    bit                       load;
    bit                       up_down;
    logic [`COUNTER_WIDTH-1:0] load_data;
    logic [`COUNTER_WIDTH-1:0] count;

    counter_operation_e operation;

    covergroup counter_cg;

      option.per_instance = 1;
      option.name         = "counter_functional_coverage";
      option.goal         = 100;
      option.comment      = "Functional coverage for the parameterized up/down counter";

      reset_cp: coverpoint rst_n {
        bins reset_asserted   = {0};
        bins reset_deasserted = {1};
      }

      enable_cp: coverpoint enable iff (rst_n) {
        bins disabled = {0};
        bins enabled  = {1};
      }

      load_cp: coverpoint load iff (rst_n) {
        bins inactive = {0};
        bins active   = {1};
      }

      direction_cp: coverpoint up_down iff (rst_n && !load && enable) {
        bins count_down = {0};
        bins count_up   = {1};

        bins up_to_down = (1 => 0);
        bins down_to_up = (0 => 1);
      }

      operation_cp: coverpoint operation {
        bins reset_operation      = {RESET_OPERATION};
        bins load_operation       = {LOAD_OPERATION};
        bins hold_operation       = {HOLD_OPERATION};
        bins count_up_operation   = {COUNT_UP_OPERATION};
        bins count_down_operation = {COUNT_DOWN_OPERATION};
      }

      load_data_cp: coverpoint load_data iff (rst_n && load) {
        bins zero_value   = {'0};
        bins maximum      = {MAX_COUNT};
        bins other_values = default;
      }

      count_cp: coverpoint count {
        bins zero_value   = {'0};
        bins maximum      = {MAX_COUNT};
        bins other_values = default;
      }

      up_rollover_stimulus_cp: coverpoint count
        iff (operation == COUNT_UP_OPERATION) {
        bins maximum_boundary = {MAX_COUNT};
      }

      down_rollover_stimulus_cp: coverpoint count
        iff (operation == COUNT_DOWN_OPERATION) {
        bins zero_boundary = {'0};
      }

      load_enable_cross: cross load_cp, enable_cp {
        bins load_priority = binsof(load_cp.active) &&
                             binsof(enable_cp.enabled);
      }

    endgroup

    function new(string name = "counter_coverage", uvm_component parent = null);
      super.new(name, parent);

      counter_cg = new();
    endfunction

    virtual function void write(counter_seq_item t);

  if (t == null)
    `uvm_fatal(get_type_name(), "Received a null transaction")

  rst_n     = t.rst_n;
  enable    = t.enable;
  load      = t.load;
  up_down   = t.up_down;
  load_data = t.load_data;
  count     = t.count;

  if (!rst_n)
    operation = RESET_OPERATION;
  else if (load)
    operation = LOAD_OPERATION;
  else if (!enable)
    operation = HOLD_OPERATION;
  else if (up_down)
    operation = COUNT_UP_OPERATION;
  else
    operation = COUNT_DOWN_OPERATION;

  counter_cg.sample();

  `uvm_info(get_type_name(),
            $sformatf("Functional coverage = %0.2f%%",
                      counter_cg.get_inst_coverage()),
            UVM_HIGH)

endfunction
    function void report_phase(uvm_phase phase);
      super.report_phase(phase);

      `uvm_info(get_type_name(),
                $sformatf("FINAL FUNCTIONAL COVERAGE = %0.2f%%",
                          counter_cg.get_inst_coverage()),
                UVM_NONE)
    endfunction

  endclass


  //==========================================================
  // ENVIRONMENT
  //==========================================================

  class counter_env extends uvm_env;

    `uvm_component_utils(counter_env)

    counter_agent      agent;
    counter_scoreboard scoreboard;
    counter_coverage   coverage;

    function new(string name = "counter_env", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      agent      = counter_agent::type_id::create("agent", this);
      scoreboard = counter_scoreboard::type_id::create("scoreboard", this);
      coverage   = counter_coverage::type_id::create("coverage", this);
    endfunction

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);

      agent.monitor.monitor_ap.connect(scoreboard.analysis_imp);
      agent.monitor.monitor_ap.connect(coverage.analysis_export);
    endfunction

  endclass


  //==========================================================
  // BASE TEST
  //==========================================================

  class counter_base_test extends uvm_test;

    `uvm_component_utils(counter_base_test)

    counter_env   env;
    counter_vif_t vif;

    function new(string name = "counter_base_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      env = counter_env::type_id::create("env", this);

      if (!uvm_config_db #(counter_vif_t)::get(this, "", "vif", vif))
        `uvm_fatal(get_type_name(), "Virtual interface was not found")
    endfunction

    task apply_reset();

      counter_reset_sequence reset_seq;

      reset_seq = counter_reset_sequence::type_id::create("reset_seq");
      reset_seq.start(env.agent.sequencer);

    endtask

    task finish_test();

      counter_idle_sequence idle_seq;

      idle_seq = counter_idle_sequence::type_id::create("idle_seq");
      idle_seq.start(env.agent.sequencer);

      repeat (3)
        @(vif.monitor_cb);

    endtask

  endclass


  //==========================================================
  // RESET TEST
  //==========================================================

  class counter_reset_test extends counter_base_test;

    `uvm_component_utils(counter_reset_test)

    function new(string name = "counter_reset_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);

      phase.raise_objection(this);

      apply_reset();
      finish_test();

      phase.drop_objection(this);

    endtask

  endclass


  //==========================================================
  // LOAD TEST
  //==========================================================

  class counter_load_test extends counter_base_test;

    `uvm_component_utils(counter_load_test)

    function new(string name = "counter_load_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);

      counter_load_sequence load_seq;

      phase.raise_objection(this);

      apply_reset();

      load_seq       = counter_load_sequence::type_id::create("load_seq");
      load_seq.value = 'h5;
      load_seq.start(env.agent.sequencer);

      finish_test();

      phase.drop_objection(this);

    endtask

  endclass


  //==========================================================
  // COUNT-UP TEST
  //==========================================================

  class counter_up_test extends counter_base_test;

    `uvm_component_utils(counter_up_test)

    function new(string name = "counter_up_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);

      counter_up_sequence up_seq;

      phase.raise_objection(this);

      apply_reset();

      up_seq        = counter_up_sequence::type_id::create("up_seq");
      up_seq.cycles = (1 << `COUNTER_WIDTH) + 2;
      up_seq.start(env.agent.sequencer);

      finish_test();

      phase.drop_objection(this);

    endtask

  endclass


  //==========================================================
  // COUNT-DOWN TEST
  //==========================================================

  class counter_down_test extends counter_base_test;

    `uvm_component_utils(counter_down_test)

    function new(string name = "counter_down_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);

      counter_down_sequence down_seq;

      phase.raise_objection(this);

      apply_reset();

      down_seq        = counter_down_sequence::type_id::create("down_seq");
      down_seq.cycles = (1 << `COUNTER_WIDTH) + 2;
      down_seq.start(env.agent.sequencer);

      finish_test();

      phase.drop_objection(this);

    endtask

  endclass


  //==========================================================
  // HOLD TEST
  //==========================================================

  class counter_hold_test extends counter_base_test;

    `uvm_component_utils(counter_hold_test)

    function new(string name = "counter_hold_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);

      counter_load_sequence load_seq;
      counter_hold_sequence hold_seq;

      phase.raise_objection(this);

      apply_reset();

      load_seq       = counter_load_sequence::type_id::create("load_seq");
      load_seq.value = 'h5;
      load_seq.start(env.agent.sequencer);

      hold_seq        = counter_hold_sequence::type_id::create("hold_seq");
      hold_seq.cycles = 5;
      hold_seq.start(env.agent.sequencer);

      finish_test();

      phase.drop_objection(this);

    endtask

  endclass


  //==========================================================
  // RANDOM TEST
  //==========================================================

  class counter_random_test extends counter_base_test;

    `uvm_component_utils(counter_random_test)

    function new(string name = "counter_random_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);

      counter_random_sequence random_seq;

      phase.raise_objection(this);

      apply_reset();

      random_seq                 = counter_random_sequence::type_id::create("random_seq");
      random_seq.number_of_items = 100;
      random_seq.start(env.agent.sequencer);

      finish_test();

      phase.drop_objection(this);

    endtask

  endclass


  //==========================================================
  // FULL TEST
  // Runs every main functional scenario once
  //==========================================================

  class counter_full_test extends counter_base_test;

    `uvm_component_utils(counter_full_test)

    function new(string name = "counter_full_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);

      counter_load_sequence   load_seq;
      counter_up_sequence     up_seq;
      counter_down_sequence   down_seq;
      counter_hold_sequence   hold_seq;
      counter_random_sequence random_seq;

      phase.raise_objection(this);

      `uvm_info("COUNTER_FULL_TEST", "TEST 1: RESET STARTED", UVM_NONE)

      apply_reset();

      `uvm_info("COUNTER_FULL_TEST", "TEST 1: RESET COMPLETED", UVM_NONE)


      `uvm_info("COUNTER_FULL_TEST", "TEST 2: LOAD STARTED", UVM_NONE)

      load_seq       = counter_load_sequence::type_id::create("load_seq");
      load_seq.value = 'h5;
      load_seq.start(env.agent.sequencer);

      `uvm_info("COUNTER_FULL_TEST", "TEST 2: LOAD COMPLETED", UVM_NONE)


      `uvm_info("COUNTER_FULL_TEST", "TEST 3: COUNT-UP STARTED", UVM_NONE)

      up_seq        = counter_up_sequence::type_id::create("up_seq");
      up_seq.cycles = (1 << `COUNTER_WIDTH) + 2;
      up_seq.start(env.agent.sequencer);

      `uvm_info("COUNTER_FULL_TEST", "TEST 3: COUNT-UP COMPLETED", UVM_NONE)


      `uvm_info("COUNTER_FULL_TEST", "TEST 4: COUNT-DOWN STARTED", UVM_NONE)

      down_seq        = counter_down_sequence::type_id::create("down_seq");
      down_seq.cycles = (1 << `COUNTER_WIDTH) + 2;
      down_seq.start(env.agent.sequencer);

      `uvm_info("COUNTER_FULL_TEST", "TEST 4: COUNT-DOWN COMPLETED", UVM_NONE)


      `uvm_info("COUNTER_FULL_TEST", "TEST 5: HOLD STARTED", UVM_NONE)

      hold_seq        = counter_hold_sequence::type_id::create("hold_seq");
      hold_seq.cycles = 5;
      hold_seq.start(env.agent.sequencer);

      `uvm_info("COUNTER_FULL_TEST", "TEST 5: HOLD COMPLETED", UVM_NONE)


      `uvm_info("COUNTER_FULL_TEST", "TEST 6: RANDOM STARTED", UVM_NONE)

      random_seq                 = counter_random_sequence::type_id::create("random_seq");
      random_seq.number_of_items = 500;
      random_seq.start(env.agent.sequencer);

      `uvm_info("COUNTER_FULL_TEST", "TEST 6: RANDOM COMPLETED", UVM_NONE)

      finish_test();

      `uvm_info("COUNTER_FULL_TEST",
                "ALL COUNTER TEST SCENARIOS COMPLETED",
                UVM_NONE)

      phase.drop_objection(this);

    endtask

  endclass

endpackage


//============================================================
// SYSTEMVERILOG ASSERTIONS
//============================================================

module counter_assertions #(
  parameter int unsigned WIDTH = `COUNTER_WIDTH
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

  property p_reset;
    @(posedge clk)
    !rst_n |-> (count == '0);
  endproperty

  property p_load;
    @(posedge clk) disable iff (!rst_n)
    load |=> (count == $past(load_data));
  endproperty

  property p_count_up;
    @(posedge clk) disable iff (!rst_n)
    (!load && enable && up_down) |=> (count == ($past(count) + 1'b1));
  endproperty

  property p_count_down;
    @(posedge clk) disable iff (!rst_n)
    (!load && enable && !up_down) |=> (count == ($past(count) - 1'b1));
  endproperty

  property p_hold;
    @(posedge clk) disable iff (!rst_n)
    (!load && !enable) |=> (count == $past(count));
  endproperty

  property p_up_rollover;
    @(posedge clk) disable iff (!rst_n)
    (!load && enable && up_down && count == MAX_COUNT) |=> (count == '0);
  endproperty

  property p_down_rollover;
    @(posedge clk) disable iff (!rst_n)
    (!load && enable && !up_down && count == '0) |=> (count == MAX_COUNT);
  endproperty

  property p_count_known;
    @(posedge clk)
    rst_n |-> !$isunknown(count);
  endproperty

  a_reset: assert property (p_reset)
    else $error("COUNTER_SVA: Reset operation failed");

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

  a_count_known: assert property (p_count_known)
    else $error("COUNTER_SVA: Count contains X or Z");

  c_reset: cover property (@(posedge clk) !rst_n);

  c_load: cover property (
    @(posedge clk) rst_n && load
  );

  c_count_up: cover property (
    @(posedge clk) rst_n && !load && enable && up_down
  );

  c_count_down: cover property (
    @(posedge clk) rst_n && !load && enable && !up_down
  );

  c_hold: cover property (
    @(posedge clk) rst_n && !load && !enable
  );

  c_up_rollover: cover property (
    @(posedge clk)
    rst_n && !load && enable && up_down && count == MAX_COUNT
  );

  c_down_rollover: cover property (
    @(posedge clk)
    rst_n && !load && enable && !up_down && count == '0
  );

endmodule


//============================================================
// TOP-LEVEL TESTBENCH
//============================================================

module top_tb;

  import uvm_pkg::*;
  import counter_pkg::*;

  localparam int unsigned WIDTH = `COUNTER_WIDTH;

  logic clk;

  counter_if #(
    .WIDTH(WIDTH)
  ) vif (
    .clk(clk)
  );

  up_down_counter #(
    .WIDTH(WIDTH)
  ) dut (
    .clk       (clk),
    .rst_n     (vif.rst_n),
    .enable    (vif.enable),
    .load      (vif.load),
    .up_down   (vif.up_down),
    .load_data (vif.load_data),
    .count     (vif.count)
  );

  counter_assertions #(
    .WIDTH(WIDTH)
  ) counter_sva (
    .clk       (clk),
    .rst_n     (vif.rst_n),
    .enable    (vif.enable),
    .load      (vif.load),
    .up_down   (vif.up_down),
    .load_data (vif.load_data),
    .count     (vif.count)
  );

  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
  end

  initial begin
    $dumpfile("parameterized_counter_uvm.vcd");
    $dumpvars(0, top_tb);
  end

  initial begin
    uvm_config_db #(counter_vif_t)::set(null, "*", "vif", vif);
    run_test("counter_full_test");
  end

endmodule

