// Code your testbench here
// or browse Examples
// Class methods can encapsulate access, and one class can contain another.
`timescale 1ns/1ps

class first;
  // Class members are public by default when no access qualifier is given.
  int data = 34;

  task setter(input int data);
    this.data = data;
  endtask

  function int getter();
    return data;
  endfunction

  task display;
    $display("[%0t] first.data=%0d", $time, data);
  endtask
endclass

class second;
  first f1;

  function new();
    f1 = new();
  endfunction
endclass

module tb;
  second s;
  int error_count;

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

    s = new();
    check_value("default composed object value", s.f1.getter(), 34);
    s.f1.display();

    s.f1.setter(12);
    check_value("value after setter", s.f1.getter(), 12);
    $display("[%0t] getter returned %0d", $time, s.f1.getter());

    if (error_count == 0) begin
      $display("PASS: composed classes and setter/getter scope passed");
    end
    else begin
      $display("FAIL: %0d check(s) failed", error_count);
      $fatal(1, "Part 14 self-check failed");
    end

    $finish;
  end
endmodule
