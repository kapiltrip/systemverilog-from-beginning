// Code your testbench here
// or browse Examples
// Functions return a value without consuming simulation time; tasks can wait.
`timescale 1ns/1ps

module tb;
  bit [2:0] c;
  bit [2:0] d;
  bit [3:0] e;
  bit [4:0] function_result;
  bit clk;
  int cycle_count;
  int error_count;

  function automatic bit [4:0] add_function(
    input bit [3:0] a,
    input bit [3:0] b
  );
    return a + b;
  endfunction

  task automatic check_value(
    input string label,
    input int actual,
    input int expected
  );
    if (actual !== expected) begin
      error_count++;
      $error("FAIL: %s expected %0d, got %0d", label, expected, actual);
    end
  endtask

  task automatic add;
    e = {1'b0, c} + {1'b0, d};
    $display("[%0t] task add: %0d + %0d = %0d", $time, c, d, e);
  endtask

  task automatic stimuli_clk(input int next_c, input int next_d);
    @(posedge clk);
    c = next_c;
    d = next_d;
    add();
    cycle_count++;
    check_value("task result", e, next_c + next_d);
  endtask

  always #5 clk = ~clk;

  initial begin
    $timeformat(-9, 0, " ns", 8);
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
    clk = 1'b0;
    c = 3'b0;
    d = 3'b0;
    e = 4'b0;
    cycle_count = 0;
    error_count = 0;

    function_result = add_function(4'd4, 4'd13);
    $display("[%0t] function add: 4 + 13 = %0d", $time, function_result);
    check_value("function result", function_result, 17);

    stimuli_clk(1, 2);
    stimuli_clk(2, 4);
    stimuli_clk(3, 5);
    stimuli_clk(4, 7);
    stimuli_clk(5, 7);
    check_value("completed task cycles", cycle_count, 5);

    if (error_count == 0) begin
      $display("PASS: function return values and timed task calls passed");
    end
    else begin
      $display("FAIL: %0d check(s) failed", error_count);
      $fatal(1, "Part 10 self-check failed");
    end

    $finish;
  end
endmodule
