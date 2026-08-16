// Code your testbench here
// or browse Examples
// Constructors accept positional or explicitly named arguments.
`timescale 1ns/1ps

class first;
  int data1;
  bit [7:0] data2;
  shortint data3;

  function new(
    input int data1 = 0,
    input bit [7:0] data2 = 8'd0,
    input shortint data3 = 0
  );
    this.data1 = data1;
    this.data2 = data2;
    this.data3 = data3;
  endfunction

  task display;
    $display("[%0t] data1=%0d, data2=%0d, data3=%0d", $time, data1, data2, data3);
  endtask
endclass

module tb;
  first f1;
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

    f1 = new(.data2(5), .data3(5), .data1(11));
    f1.display();
    check_value("named data1", f1.data1, 11);
    check_value("named data2", f1.data2, 5);
    check_value("named data3", f1.data3, 5);

    f1 = new(14, 6, 43);
    f1.display();
    check_value("positional data1", f1.data1, 14);
    check_value("positional data2", f1.data2, 6);
    check_value("positional data3", f1.data3, 43);

    if (error_count == 0) begin
      $display("PASS: named and positional constructor arguments passed");
    end
    else begin
      $display("FAIL: %0d check(s) failed", error_count);
      $fatal(1, "Part 13 self-check failed");
    end

    $finish;
  end
endmodule
