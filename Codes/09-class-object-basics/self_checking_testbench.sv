// Code your testbench here
// or browse Examples
// A class handle must point to an object before its members are accessed.
`timescale 1ns/1ps

class first;
  reg [2:0] data;
  reg [1:0] data2;
endclass

module tb;
  first f;
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

    f = new();
    #1;
    $display("[%0t] new object defaults: data=%0d, data2=%0d", $time, f.data, f.data2);
    if (!$isunknown(f.data)) begin
      error_count++;
      $error("FAIL: four-state class members should start as unknown");
    end
    if (!$isunknown(f.data2)) begin
      error_count++;
      $error("FAIL: data2 should start as unknown");
    end

    f.data = 3'b010;
    f.data2 = 2'b10;
    #1;
    $display("[%0t] after member assignments: data=%0d, data2=%0d", $time, f.data, f.data2);
    check_value("data after assignment", f.data, 2);
    check_value("data2 after assignment", f.data2, 2);

    f = null;
    if (f == null) begin
      $display("[%0t] handle is null; member access is intentionally skipped", $time);
    end
    else begin
      error_count++;
      $error("FAIL: f should be null after deallocation");
    end

    if (error_count == 0) begin
      $display("PASS: class construction, member access, and null handling passed");
    end
    else begin
      $display("FAIL: %0d check(s) failed", error_count);
      $fatal(1, "Part 09 self-check failed");
    end

    $finish;
  end
endmodule
