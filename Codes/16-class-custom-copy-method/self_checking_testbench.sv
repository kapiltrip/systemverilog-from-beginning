// Code your testbench here
// or browse Examples
// A class method can make an explicit value copy of selected members.
`timescale 1ns/1ps

class first;
  int data = 34;
  bit [7:0] temp = 8'h11;

  function void copy_from(input first source);
    data = source.data;
    temp = source.temp;
  endfunction
endclass

module tb;
  first f1;
  first f2;
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

  task automatic check_byte(
    input string label,
    input bit [7:0] actual,
    input bit [7:0] expected
  );
    if (actual !== expected) begin
      error_count++;
      $error("FAIL: %s expected %0h, got %0h", label, expected, actual);
    end
  endtask

  initial begin
    $timeformat(-9, 0, " ns", 8);
    error_count = 0;

    f1 = new();
    f1.data = 45;
    f1.temp = 8'h11;
    f2 = new();
    f2.copy_from(f1);
    $display("[%0t] copied data=%0d, temp=%0h", $time, f2.data, f2.temp);
    check_value("copied data", f2.data, 45);
    check_byte("copied temp", f2.temp, 8'h11);

    f2.data = 56;
    f2.temp = 8'h22;
    $display("[%0t] after changing copy: f1.data=%0d, f2.data=%0d", $time, f1.data, f2.data);
    check_value("original data after copy mutation", f1.data, 45);
    check_byte("original temp after copy mutation", f1.temp, 8'h11);
    check_value("copy data after mutation", f2.data, 56);
    check_byte("copy temp after mutation", f2.temp, 8'h22);

    if (error_count == 0) begin
      $display("PASS: custom class copy method made an independent member copy");
    end
    else begin
      $display("FAIL: %0d check(s) failed", error_count);
      $fatal(1, "Part 16 self-check failed");
    end

    $finish;
  end
endmodule
