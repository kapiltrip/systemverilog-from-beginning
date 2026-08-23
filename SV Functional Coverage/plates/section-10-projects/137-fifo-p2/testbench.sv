`timescale 1ns/1ps

// Video 137: reusable write/read tasks for the FIFO implementation.
module tb;
  logic clk = 0;
  logic reset;
  logic write_enable, read_enable;
  logic [7:0] data_in, data_out;
  logic full, empty;

  sync_fifo dut (.*);
  always #5 clk = ~clk;

  task automatic write_word(input logic [7:0] value);
    @(negedge clk);
    write_enable = 1; read_enable = 0; data_in = value;
    @(negedge clk);
    write_enable = 0;
  endtask

  task automatic read_word();
    @(negedge clk);
    read_enable = 1; write_enable = 0;
    @(negedge clk);
    read_enable = 0;
  endtask

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
    reset = 1; write_enable = 0; read_enable = 0; data_in = '0;
    repeat (2) @(posedge clk);
    reset = 0;
    repeat (4) write_word($urandom);
    repeat (4) read_word();
    // TODO: add a reference queue and automatic data checks.
    #10 $finish;
  end
endmodule
