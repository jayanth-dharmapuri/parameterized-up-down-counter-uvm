class counter_sequencer extends uvm_sequencer #(counter_seq_item);
    `uvm_component_utils(counter_sequencer)

    function new(string name = "counter_sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
endclass