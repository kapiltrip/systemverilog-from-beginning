// Focused, deterministic checks for Parts 04-21 of the revision notes.
// This is intentionally one standalone testbench: no DUT or package is required.

// Give compilation-unit class declarations the same scale as the module. XSim
// requires every design unit in the elaborated design to have a time scale.
timeunit 1ns;
timeprecision 1ps;

class nested_value;
  int value;

  function new(input int value = 0);
    this.value = value;
  endfunction
endclass

class copy_probe;
  static int constructor_calls = 0;
  int scalar;
  nested_value nested;

  function new(input int scalar = 0, input int nested_value_arg = 0);
    constructor_calls++;
    this.scalar = scalar;
    this.nested = new(nested_value_arg);
  endfunction

  // A user-written deep copy: allocate both the outer and nested objects.
  function copy_probe copy();
    copy = new(this.scalar, this.nested.value);
  endfunction
endclass

class constructor_output_probe;
  int stored;

  // Constructor formals follow ordinary function argument-direction rules.
  function new(input int value, output int side_result);
    this.stored = value;
    side_result = value * 2;
  endfunction
endclass

class handle_box;
  int value;

  function new(input int value = 0);
    this.value = value;
  endfunction
endclass

class dispatch_base;
  virtual function int virtual_id();
    return 2;
  endfunction

  function int nonvirtual_id();
    return 20;
  endfunction
endclass

class dispatch_child extends dispatch_base;
  function int virtual_id();
    return 3;
  endfunction

  function int nonvirtual_id();
    return 30;
  endfunction
endclass

module revision_checks;
  timeunit 1ns;
  timeprecision 1ps;

  int checks = 0;

  // No initializer: these declarations exercise language-defined defaults.
  bit two_state_default;
  logic four_state_default;
  int empty_dynamic[];

  // Both forms are legal aggregate initializers for an unpacked dynamic array.
  bit concat_dynamic[] = {1, 0, 1, 1};
  bit pattern_dynamic[] = '{1, 0, 1, 1};

  task automatic check(input bit condition, input string label);
    assert (condition)
      checks++;
    else
      $fatal(1, "CHECK FAILED: %s", label);
  endtask

  function automatic void add_with_output(
    input int left,
    input int right,
    output int sum
  );
    sum = left + right;
  endfunction

  function automatic int modify_input_copy(input int value);
    value += 5;
    return value;
  endfunction

  task automatic swap(ref int left, ref int right);
    int temporary;
    temporary = left;
    left = right;
    right = temporary;
  endtask

  function automatic void mutate_object_through_input(input handle_box box_copy);
    box_copy.value = 77;
    // This changes only the local copy of the handle, not the caller's handle.
    box_copy = null;
  endfunction

  initial begin : run_checks
    bit [7:0] unsigned_bits;
    byte signed_byte;
    time sampled_time;
    realtime sampled_realtime;
    string integral_time_text;
    string real_time_text;
    int old_dynamic[];
    int fixed_source[0:2];
    int fixed_copy[0:2];
    int queue_values[$];
    int popped_front;
    int popped_back;
    int output_sum;
    int caller_value;
    int modified_result;
    int swap_left;
    int swap_right;
    int constructor_side_result;
    handle_box box;
    constructor_output_probe constructor_probe;
    copy_probe original;
    copy_probe shallow;
    copy_probe deep;
    dispatch_base base_handle;
    dispatch_child child_handle;

    $display("TRACE begin focused SystemVerilog revision checks");

    // Integral type signedness and default values.
    unsigned_bits = '1;
    signed_byte = '1;
    check(unsigned_bits == 8'd255, "bit vector is unsigned by default");
    check(signed_byte == -1, "byte is signed by default");
    check(two_state_default === 1'b0, "uninitialized 2-state bit defaults to 0");
    check(four_state_default === 1'bx, "uninitialized 4-state logic defaults to X");
    $display("TRACE types bit[7:0]=%0d byte=%0d defaults(bit,logic)=%b,%b",
             unsigned_bits, signed_byte, two_state_default, four_state_default);

    // Fractional delay: $time rounds to the local 1 ns unit; $realtime preserves
    // the 1 ps-quantized fractional value.  Explicit formatting avoids relying
    // on the implementation's default %t unit and width.
    $timeformat(-9, 3, " ns", 0);
    #1.234;
    sampled_time = $time;
    sampled_realtime = $realtime;
    integral_time_text = $sformatf("%0t", sampled_time);
    real_time_text = $sformatf("%0t", sampled_realtime);
    check(sampled_time == 64'd1, "$time is rounded to an integer in this 1 ns timeunit");
    check((sampled_realtime > 1.233999) && (sampled_realtime < 1.234001),
          "$realtime retains the fractional 1.234 ns sample");
    check(integral_time_text == "1.000 ns", "explicit %t format for sampled time");
    check(real_time_text == "1.234 ns", "explicit %t format for sampled realtime");
    $display("TRACE time $time=%s $realtime=%s", integral_time_text, real_time_text);

    // Dynamic arrays, fixed-array value assignment, and queue operations.
    check(concat_dynamic.size() == 4, "unpacked array concatenation sizes dynamic array");
    check(pattern_dynamic.size() == 4, "assignment pattern sizes dynamic array");
    check((concat_dynamic[0] == 1) && (concat_dynamic[1] == 0) &&
          (concat_dynamic[2] == 1) && (concat_dynamic[3] == 1),
          "unpacked array concatenation values");
    check((pattern_dynamic[0] == 1) && (pattern_dynamic[1] == 0) &&
          (pattern_dynamic[2] == 1) && (pattern_dynamic[3] == 1),
          "assignment pattern values");
    check(empty_dynamic.size() == 0, "uninitialized dynamic array has size zero");

    old_dynamic = '{11, 22, 33};
    old_dynamic = new[5](old_dynamic);
    check((old_dynamic.size() == 5) && (old_dynamic[0] == 11) &&
          (old_dynamic[1] == 22) && (old_dynamic[2] == 33) &&
          (old_dynamic[3] == 0) && (old_dynamic[4] == 0),
          "new[N](old) preserves old elements and default-fills the extension");

    fixed_source = '{10, 20, 30};
    fixed_copy = fixed_source;
    fixed_copy[0] = 99;
    check((fixed_source[0] == 10) && (fixed_copy[0] == 99),
          "fixed unpacked array assignment copies values");

    queue_values = {1, 3, 4};
    queue_values.push_front(7);
    queue_values.push_back(9);
    queue_values.insert(2, 8);
    check((queue_values.size() == 6) && (queue_values[0] == 7) &&
          (queue_values[1] == 1) && (queue_values[2] == 8) &&
          (queue_values[3] == 3) && (queue_values[4] == 4) &&
          (queue_values[5] == 9), "queue insert(index,item) inserts without replacing");
    popped_front = queue_values.pop_front();
    popped_back = queue_values.pop_back();
    check((popped_front == 7) && (popped_back == 9),
          "queue pop methods return the removed values");
    check((queue_values.size() == 4) && (queue_values[0] == 1) &&
          (queue_values[1] == 8) && (queue_values[2] == 3) &&
          (queue_values[3] == 4), "queue pop methods remove the end elements");
    $display("TRACE arrays concat=%p resized=%p queue=%p", concat_dynamic,
             old_dynamic, queue_values);

    // Subroutine argument directions and class-handle input semantics.
    add_with_output(7, 5, output_sum);
    check(output_sum == 12, "function output argument copies a result to the caller");
    caller_value = 10;
    modified_result = modify_input_copy(caller_value);
    check((caller_value == 10) && (modified_result == 15),
          "input formal is locally writable but does not copy back");
    swap_left = 4;
    swap_right = 9;
    swap(swap_left, swap_right);
    check((swap_left == 9) && (swap_right == 4),
          "automatic ref task updates the caller variables");

    box = new(5);
    mutate_object_through_input(box);
    check((box != null) && (box.value == 77),
          "input handle copy still refers to and can mutate the caller's object");

    constructor_side_result = -1;
    constructor_probe = new(13, constructor_side_result);
    check((constructor_probe.stored == 13) && (constructor_side_result == 26),
          "constructor output formal uses ordinary function copy-out semantics");
    $display("TRACE arguments sum=%0d input(actual,result)=%0d,%0d swap=%0d,%0d ctor_out=%0d",
             output_sum, caller_value, modified_result, swap_left, swap_right,
             constructor_side_result);

    // Built-in shallow copy versus a user-written deep copy.
    copy_probe::constructor_calls = 0;
    original = new(10, 20);
    check(copy_probe::constructor_calls == 1, "ordinary new invokes the constructor");
    shallow = new original;
    check(copy_probe::constructor_calls == 1,
          "shallow new source does not invoke the constructor");
    shallow.scalar = 99;
    check((original.scalar == 10) && (shallow.scalar == 99),
          "shallow copy duplicates outer scalar storage");
    shallow.nested.value = 88;
    check(original.nested.value == 88,
          "shallow copy shares the nested object handle");

    // Parentheses are intentionally omitted: a no-argument class method call
    // may be written as original.copy.
    deep = original.copy;
    check(copy_probe::constructor_calls == 2,
          "custom deep copy invoked its allocation constructor");
    check((deep != original) && (deep.nested != original.nested),
          "custom deep copy allocates independent outer and nested objects");
    deep.scalar = 123;
    deep.nested.value = 456;
    check((original.scalar == 10) && (original.nested.value == 88),
          "custom deep-copy mutations do not affect the source");
    $display("TRACE copies source=%0d/%0d shallow=%0d/%0d deep=%0d/%0d ctor_calls=%0d",
             original.scalar, original.nested.value,
             shallow.scalar, shallow.nested.value,
             deep.scalar, deep.nested.value, copy_probe::constructor_calls);

    // A base handle can refer to a child object. Virtual calls use the dynamic
    // object type; nonvirtual calls use the base handle's declared type.
    child_handle = new;
    base_handle = child_handle;
    check(base_handle.virtual_id() == 3,
          "virtual call through base handle dispatches to child override");
    check(base_handle.nonvirtual_id() == 20,
          "nonvirtual call through base handle uses base implementation");
    $display("TRACE dispatch virtual=%0d nonvirtual=%0d",
             base_handle.virtual_id(), base_handle.nonvirtual_id());

    $display("PASS: %0d deterministic checks completed", checks);
    $finish;
  end
endmodule
