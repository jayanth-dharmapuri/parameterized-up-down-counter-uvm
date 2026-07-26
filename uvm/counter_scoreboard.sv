class counter_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(counter_scoreboard)

  uvm_analysis_imp #(counter_seq_item, counter_scoreboard) analysis_imp;

  logic [`COUNTER_WIDTH-1:0] expected_count;

  int unsigned pass_count;
  int unsigned fail_count;

  function new(string name = "counter_scoreboard", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    analysis_imp   = new("analysis_imp", this);
    expected_count = '0;
    pass_count     = 0;
    fail_count     = 0;
  endfunction

  function void write(counter_seq_item tr);

    if (!tr.rst_n) begin
      expected_count = '0;

      if (tr.count !== '0) begin
        fail_count++;

        `uvm_error(
          get_type_name(),
          $sformatf("RESET FAILED: expected_count=0x%0h actual_count=0x%0h",
                    expected_count, tr.count)
        )
      end
      else begin
        pass_count++;

        `uvm_info(
          get_type_name(),
          $sformatf("RESET PASSED: count=0x%0h", tr.count),
          UVM_LOW
        )
      end
    end
    else begin
      compare_count(tr);
      update_reference_model(tr);
    end

  endfunction

  function void compare_count(counter_seq_item tr);

    if (tr.count !== expected_count) begin
      fail_count++;

      `uvm_error(
        get_type_name(),
        $sformatf("COUNT MISMATCH: expected_count=0x%0h actual_count=0x%0h",
                  expected_count, tr.count)
      )
    end
    else begin
      pass_count++;

      `uvm_info(
        get_type_name(),
        $sformatf("COUNT MATCH: expected_count=0x%0h actual_count=0x%0h",
                  expected_count, tr.count),
        UVM_LOW
      )
    end

  endfunction

  function void update_reference_model(counter_seq_item tr);

    if (tr.load) begin
      expected_count = tr.load_data;
    end
    else if (tr.enable) begin
      if (tr.up_down)
        expected_count = expected_count + 1'b1;
      else
        expected_count = expected_count - 1'b1;
    end

  endfunction

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);

    `uvm_info(
      get_type_name(),
      $sformatf("SCOREBOARD SUMMARY: PASSED=%0d FAILED=%0d",
                pass_count, fail_count),
      UVM_NONE
    )
  endfunction

endclass