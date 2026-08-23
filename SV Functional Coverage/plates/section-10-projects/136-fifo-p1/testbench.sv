`timescale 1ns/1ps

// Video 136: coverage-plan skeleton before completing the FIFO DUT.
module tb;
  logic clk = 0;
  logic reset;
  logic write_enable, read_enable;
  logic [7:0] data_in, data_out;
  logic full, empty;

  sync_fifo dut (.*);

  covergroup fifo_plan_cg @(posedge clk);
    option.per_instance = 1;
    cp_reset: coverpoint reset;
    cp_write: coverpoint write_enable;
    cp_read: coverpoint read_enable;
    cp_full: coverpoint full;
    cp_empty: coverpoint empty;
    x_operation: cross cp_write, cp_read;
  endgroup

  fifo_plan_cg cg;
  always #5 clk = ~clk;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
    cg = new();
    reset = 1; write_enable = 0; read_enable = 0; data_in = '0;
    repeat (2) @(posedge clk);
    reset = 0;
    repeat (20) begin
      @(negedge clk);
      {write_enable, read_enable, data_in} = $urandom;
    end
    // TODO: refine bins, illegal operations, crosses, and stimulus targets.
    #10 $finish;
  end
endmodule
