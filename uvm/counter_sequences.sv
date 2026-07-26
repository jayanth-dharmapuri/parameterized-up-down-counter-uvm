class counter_base_sequence extends uvm_sequence #(counter_seq_item);

  `uvm_object_utils(counter_base_sequence)

  function new(string name = "counter_base_sequence");
    super.new(name);
  endfunction

endclass


class counter_reset_sequence extends counter_base_sequence;

  `uvm_object_utils(counter_reset_sequence)

  function new(string name = "counter_reset_sequence");
    super.new(name);
  endfunction

  virtual task body();

    req = counter_seq_item::type_id::create("req");

    start_item(req);
    req.rst_n     = 1'b0;
    req.enable    = 1'b0;
    req.load      = 1'b0;
    req.up_down   = 1'b0;
    req.load_data = '0;
    finish_item(req);

    repeat (2) begin
      start_item(req);
      req.rst_n     = 1'b0;
      req.enable    = 1'b0;
      req.load      = 1'b0;
      req.up_down   = 1'b0;
      req.load_data = '0;
      finish_item(req);
    end

    start_item(req);
    req.rst_n     = 1'b1;
    req.enable    = 1'b0;
    req.load      = 1'b0;
    req.up_down   = 1'b0;
    req.load_data = '0;
    finish_item(req);

  endtask

endclass


class counter_load_sequence extends counter_base_sequence;

  `uvm_object_utils(counter_load_sequence)

  function new(string name = "counter_load_sequence");
    super.new(name);
  endfunction

  virtual task body();

    req = counter_seq_item::type_id::create("req");

    start_item(req);
    req.rst_n     = 1'b1;
    req.enable    = 1'b0;
    req.load      = 1'b1;
    req.up_down   = 1'b0;
    req.load_data = 'h5;
    finish_item(req);

    start_item(req);
    req.rst_n     = 1'b1;
    req.enable    = 1'b0;
    req.load      = 1'b0;
    req.up_down   = 1'b0;
    req.load_data = '0;
    finish_item(req);

  endtask

endclass


class counter_up_sequence extends counter_base_sequence;

  `uvm_object_utils(counter_up_sequence)

  function new(string name = "counter_up_sequence");
    super.new(name);
  endfunction

  virtual task body();

    req = counter_seq_item::type_id::create("req");

    repeat (10) begin
      start_item(req);
      req.rst_n     = 1'b1;
      req.enable    = 1'b1;
      req.load      = 1'b0;
      req.up_down   = 1'b1;
      req.load_data = '0;
      finish_item(req);
    end

  endtask

endclass


class counter_down_sequence extends counter_base_sequence;

  `uvm_object_utils(counter_down_sequence)

  function new(string name = "counter_down_sequence");
    super.new(name);
  endfunction

  virtual task body();

    req = counter_seq_item::type_id::create("req");

    repeat (10) begin
      start_item(req);
      req.rst_n     = 1'b1;
      req.enable    = 1'b1;
      req.load      = 1'b0;
      req.up_down   = 1'b0;
      req.load_data = '0;
      finish_item(req);
    end

  endtask

endclass


class counter_hold_sequence extends counter_base_sequence;

  `uvm_object_utils(counter_hold_sequence)

  function new(string name = "counter_hold_sequence");
    super.new(name);
  endfunction

  virtual task body();

    req = counter_seq_item::type_id::create("req");

    repeat (5) begin
      start_item(req);
      req.rst_n     = 1'b1;
      req.enable    = 1'b0;
      req.load      = 1'b0;
      req.up_down   = 1'b1;
      req.load_data = '0;
      finish_item(req);
    end

  endtask

endclass


class counter_random_sequence extends counter_base_sequence;

  `uvm_object_utils(counter_random_sequence)

  function new(string name = "counter_random_sequence");
    super.new(name);
  endfunction

  virtual task body();

    repeat (50) begin

      req = counter_seq_item::type_id::create("req");

      start_item(req);

      assert(req.randomize() with {
        rst_n dist {1 := 95, 0 := 5};
        load dist {1 := 20, 0 := 80};
        enable dist {1 := 70, 0 := 30};
      })
      else
        `uvm_fatal(get_type_name(), "Transaction randomization failed")

      finish_item(req);

    end

  endtask

endclass