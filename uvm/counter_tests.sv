class counter_base_test extends uvm_test;

  `uvm_component_utils(counter_base_test)

  counter_env env;

  function new(string name = "counter_base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    env = counter_env::type_id::create("env", this);
  endfunction

  task apply_reset();
    counter_reset_sequence reset_seq;

    reset_seq = counter_reset_sequence::type_id::create("reset_seq");
    reset_seq.start(env.agent.sequencer);
  endtask

endclass


class counter_reset_test extends counter_base_test;

  `uvm_component_utils(counter_reset_test)

  function new(string name = "counter_reset_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    apply_reset();

    phase.drop_objection(this);
  endtask

endclass


class counter_load_test extends counter_base_test;

  `uvm_component_utils(counter_load_test)

  function new(string name = "counter_load_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    counter_load_sequence load_seq;

    phase.raise_objection(this);

    apply_reset();

    load_seq = counter_load_sequence::type_id::create("load_seq");
    load_seq.start(env.agent.sequencer);

    phase.drop_objection(this);
  endtask

endclass


class counter_up_test extends counter_base_test;

  `uvm_component_utils(counter_up_test)

  function new(string name = "counter_up_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    counter_up_sequence up_seq;

    phase.raise_objection(this);

    apply_reset();

    up_seq = counter_up_sequence::type_id::create("up_seq");
    up_seq.start(env.agent.sequencer);

    phase.drop_objection(this);
  endtask

endclass


class counter_down_test extends counter_base_test;

  `uvm_component_utils(counter_down_test)

  function new(string name = "counter_down_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    counter_load_sequence load_seq;
    counter_down_sequence down_seq;

    phase.raise_objection(this);

    apply_reset();

    load_seq = counter_load_sequence::type_id::create("load_seq");
    down_seq = counter_down_sequence::type_id::create("down_seq");

    load_seq.start(env.agent.sequencer);
    down_seq.start(env.agent.sequencer);

    phase.drop_objection(this);
  endtask

endclass


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

    load_seq = counter_load_sequence::type_id::create("load_seq");
    hold_seq = counter_hold_sequence::type_id::create("hold_seq");

    load_seq.start(env.agent.sequencer);
    hold_seq.start(env.agent.sequencer);

    phase.drop_objection(this);
  endtask

endclass


class counter_random_test extends counter_base_test;

  `uvm_component_utils(counter_random_test)

  function new(string name = "counter_random_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    counter_random_sequence random_seq;

    phase.raise_objection(this);

    apply_reset();

    random_seq = counter_random_sequence::type_id::create("random_seq");
    random_seq.start(env.agent.sequencer);

    phase.drop_objection(this);
  endtask

endclass


class counter_full_test extends counter_base_test;

  `uvm_component_utils(counter_full_test)

  function new(string name = "counter_full_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    counter_load_sequence   load_seq;
    counter_up_sequence     up_seq;
    counter_hold_sequence   hold_seq;
    counter_down_sequence   down_seq;
    counter_random_sequence random_seq;

    phase.raise_objection(this);

    load_seq   = counter_load_sequence::type_id::create("load_seq");
    up_seq     = counter_up_sequence::type_id::create("up_seq");
    hold_seq   = counter_hold_sequence::type_id::create("hold_seq");
    down_seq   = counter_down_sequence::type_id::create("down_seq");
    random_seq = counter_random_sequence::type_id::create("random_seq");

    apply_reset();

    load_seq.start(env.agent.sequencer);
    up_seq.start(env.agent.sequencer);
    hold_seq.start(env.agent.sequencer);
    down_seq.start(env.agent.sequencer);
    random_seq.start(env.agent.sequencer);

    phase.drop_objection(this);
  endtask

endclass