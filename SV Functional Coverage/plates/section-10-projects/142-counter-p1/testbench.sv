`timescale 1ns/1ps

// Video 142: direct counter testbench and first-pass coverage plan.
module tb;
  logic clk = 0;
  logic reset, enable, load;
  logic [3:0] load_value, count;

  counter dut (.*);

  covergroup counter_plan_cg @(posedge clk);
    option.per_instance = 1;
    cp_reset: coverpoint reset;
    cp_enable: coverpoint enable;
    cp_load: coverpoint load;
    cp_count: coverpoint count { bins each_value[] = {[0:15]}; }
  endgroup

  counter_plan_cg cg;
  always #5 clk = ~clk;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
    cg = new();
    reset = 1; enable = 0; load = 0; load_value = '0;
    repeat (2) @(posedge clk);
    reset = 0; enable = 1;
    repeat (20) @(posedge clk);
    // TODO: add directed load cases, wraparound checks, and crosses.
    $finish;
  end
endmodule
