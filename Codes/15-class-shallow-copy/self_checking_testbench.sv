// Code your testbench here
// or browse Examples
// Copying a class object creates a separate object with copied member values.
`timescale 1ns/1ps

class first;
  int data = 41;
endclass

module tb;
  first f1;
  first p1;
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
    error_count = 0;

    f1 = new();
    f1.data = 24;

    p1 = new f1;
    $display("[%0t] copied data: p1.data=%0d", $time, p1.data);
    check_value("copied member", p1.data, 24);

    p1.data = 123;
    $display("[%0t] after changing p1: f1.data=%0d, p1.data=%0d", $time, f1.data, p1.data);
    check_value("original after copy mutation", f1.data, 24);
    check_value("copy after mutation", p1.data, 123);

    if (error_count == 0) begin
      $display("PASS: class copy preserved independent scalar member values");
    end
    else begin
      $display("FAIL: %0d check(s) failed", error_count);
      $fatal(1, "Part 15 self-check failed");
    end

    $finish;
  end
endmodule
