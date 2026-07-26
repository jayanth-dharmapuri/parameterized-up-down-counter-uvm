class counter_monitor extends uvm_monitor;
    `uvm_component_utils(counter_monitor)

    virtual counter_if #(.WIDTH(`COUNTER_WIDTH)) vif;

    uvm_analysis_port #(counter_seq_item) monitor_ap;

    function new(string name = "counter_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction 

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        monitor_ap = new("monitor_ap", this);

        if( !uvm_config_db #(virtual counter_if #(.WIDTH(`COUNTER_WIDTH)))::get(this, "", "vif",vif) )
            `uvm_fatal(get_type_name(), "Virtual interface was not found")
    endfunction

    task run_phase(uvm_phase phase);

        counter_seq_item tr;

        forever begin 
            @(vif.monitor_cb);

            tr = counter_seq_item::type_id::create("tr");

            tr.rst_n = vif.monitor_cb.rst_n;
            tr.enable = vif.monitor_cb.enable;
            tr.load = vif.monitor_cb.load;
            tr.up_down = vif.monitor_cb.up_down;
            tr.load_data = vif.monitor_cb.load_data;
            tr.count = vif.monitor_cb.count;

            monitor_ap.write(tr);

            `uvm_info(get_type_name(), $sformatf("Monitored Transaction:\n%s", tr.sprint()), UVM_HIGH)
        end 
    endtask
endclass