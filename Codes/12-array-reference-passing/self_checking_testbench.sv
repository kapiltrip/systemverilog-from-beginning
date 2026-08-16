// Code your testbench here
// or browse Examples
// A fixed unpacked array can be initialized through a ref formal argument.
`timescale 1ns/1ps

module tb;
  bit [3:0] res[16];
  int error_count;

  function automatic void init_arr(ref bit [3:0] a[16]);
    for (int i = 0; i < 16; i++) begin
      a[i] = i;
    end
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

  initial begin
    $timeformat(-9, 0, " ns", 8);
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
    error_count = 0;

    init_arr(res);
    $display("[%0t] res after init_arr(ref): %0p", $time, res);
    for (int i = 0; i < $size(res); i++) begin
      check_value("array element after ref initialization", res[i], i);
    end

    if (error_count == 0) begin
      $display("PASS: ref function initialized all array elements");
    end
    else begin
      $display("FAIL: %0d check(s) failed", error_count);
      $fatal(1, "Part 12 self-check failed");
    end

    $finish;
  end
endmodule
