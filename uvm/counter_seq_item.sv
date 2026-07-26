class counter_seq_item extends uvm_sequence_item;

  // DUT input signals
  rand bit                      rst_n;
  rand bit                      enable;
  rand bit                      load;
  rand bit                      up_down;
  rand bit [`COUNTER_WIDTH-1:0] load_data;

  // DUT output signal
  logic [`COUNTER_WIDTH-1:0]    count;

  // Factory registration
  `uvm_object_utils(counter_seq_item)

  // Constructor
  function new(string name = "counter_seq_item");
    super.new(name);
  endfunction

  // Transaction printing
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