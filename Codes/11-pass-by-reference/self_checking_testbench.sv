// Code your testbench here
// or browse Examples
// ref task arguments update the caller's variables directly.
`timescale 1ns/1ps

module tb;
  bit [1:0] c;
  bit [1:0] d;
  int error_count;

  task automatic swap(ref bit [1:0] a, b);
    bit [1:0] temp;
    temp = a;
    a = b;
    b = temp;
    $display("[%0t] inside swap: a=%0d, b=%0d", $time, a, b);
  endtask

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

  initial begin
    $timeformat(-9, 0, " ns", 8);
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
    error_count = 0;
    c = 1;
    d = 2;

    #1;
    swap(c, d);
    $display("[%0t] after swap: c=%0d, d=%0d", $time, c, d);
    check_value("c after ref swap", c, 2);
    check_value("d after ref swap", d, 1);

    if (error_count == 0) begin
      $display("PASS: ref arguments changed the caller variables");
    end
    else begin
      $display("FAIL: %0d check(s) failed", error_count);
      $fatal(1, "Part 11 self-check failed");
    end

    $finish;
  end
endmodule
