class counter_driver extends uvm_driver #(counter_seq_item);

  `uvm_component_utils(counter_driver)

  virtual counter_if #(.WIDTH(`COUNTER_WIDTH)) vif;

  function new(string name = "counter_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db #(virtual counter_if #(.WIDTH(`COUNTER_WIDTH)))::get(this, "", "vif", vif))
      `uvm_fatal(get_type_name(), "Virtual interface was not found")
  endfunction

  task run_phase(uvm_phase phase);

    drive_idle();

    forever begin
      seq_item_port.get_next_item(req);

      drive_transaction(req);

      `uvm_info(get_type_name(), $sformatf("Driven transaction:\n%s", req.sprint()), UVM_MEDIUM)

      seq_item_port.item_done();
    end

  endtask

  task drive_idle();

    vif.driver_cb.rst_n     <= 1'b1;
    vif.driver_cb.enable    <= 1'b0;
    vif.driver_cb.load      <= 1'b0;
    vif.driver_cb.up_down   <= 1'b0;
    vif.driver_cb.load_data <= '0;

  endtask

  task drive_transaction(counter_seq_item tr);

    @(vif.driver_cb);

    vif.driver_cb.rst_n     <= tr.rst_n;
    vif.driver_cb.enable    <= tr.enable;
    vif.driver_cb.load      <= tr.load;
    vif.driver_cb.up_down   <= tr.up_down;
    vif.driver_cb.load_data <= tr.load_data;

  endtask

endclass