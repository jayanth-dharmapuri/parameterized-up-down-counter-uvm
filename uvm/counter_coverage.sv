class counter_coverage extends uvm_subscriber #(counter_seq_item);
    `uvm_component_utils(counter_coverage)

    localparm logic [`COUNTER_WIDTH-1:0] MAX_COUNT = {`COUNTER_WIDTH{1'b1}};

    typedef enum bit [2:0] {
        RESET_OPERATION, 
        LOAD_OPERATION,
        HOLD_OPERATION,
        COUNT_UP_OPERATION,
        COUNT_DOWN_OPERATION
    } counter_operation_e;

    bit rst_n, enable, load, up_down;
    logic [`COUNTER_WIDTH-1:0] load_data, count;

    counter_operation_e operation;

    covergroup counter_cg;
        option.per_instance = 1;
        option.name = "counter_functional_coverage";

        reset_cp: coverpoint rst_n {
            bins reset_asserted = {0};
            bins reset_deasserted = {1};
        }

        enable_cp: coverpoint enable {
            bins disabled = {0};
            bins enabled = {1};
        }

        load_cp: coverpoint load {
            bins inactive = {0};
            bins active = {1};
        }
        

        direction_cp: coverpoint up_down iff (rst_n && !load && enable) {
            bins count_down = {0};
            bins count_up = {1};
        }

        direction_transition_cp: coverpoint up_down iff (rst_n && !load && enable) {
            bins up_to_down = {0};
            bins count_up = {1};
        }

        operation_cp: coverpoint operation (
            bins reset_operation = {RESET_OPERATION};
            bins load_operation = {LOAD_OPERATION};
            bins hold_operation = {HOLD_OPERATION};
            bins count_up_operation = {COUNT_UP_OPERATION};
            bins count_down_operation = {COUNT_DOWN_OPERATION};
        )

        load_data_cp: coverpoint load_data iff (rst_n && load) {
            bins zero_value = {`0};
            bins maximum = {MAX_COUNT};
            bins other_values = default;
        }

        count_cp: coverpoint count {
            bins zero_value   = {'0};
            bins maximum      = {MAX_COUNT};
            bins other_values = default;
        }

        up_rollover_cp: coverpoint count iff (rst_n && !load && enable && up_down) {
            bins rollover_point = {MAX_COUNT};
            bins normal_count   = default;
        }

        down_rollover_cp: coverpoint count iff (rst_n && !load && enable && !up_down) {
            bins rollover_point = {'0};
            bins normal_count   = default;
        }

        load_enable_cross: cross load_cp, enable_cp iff (rst_n) {
            bins load_priority = binsof(load_cp.active) && binsof(enable_cp.enabled);
        }

    endgroup 

    function new(string name = "counter_coverage", uvm_component parent);
        super.new(name, parent);
        counter_cg = new();
    endfunction

    virtual function void write(counter_seq_item tr);

        if (tr == null)
          `uvm_fatal(get_type_name(), "Received a null transaction")

        rst_n     = tr.rst_n;
        enable    = tr.enable;
        load      = tr.load;
        up_down   = tr.up_down;
        load_data = tr.load_data;
        count     = tr.count;

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

        `uvm_info(get_type_name(), $sformatf("Functional Coverage = %0.2f%%", counter_cg.get_inst_coverage()), UVM_HIGH)
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);

        `uvm_info(get_type_name(), $sformatf("FINAL FUNCTIONAL COVERGAE = %0.2f%%", counter_cg.get_inst_coverage()), UVM_NONE)
    endfunction 
endclass