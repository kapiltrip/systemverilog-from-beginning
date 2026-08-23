`timescale 1ns/1ps

// Video 138: final FIFO plate--operation, status, data, and cross coverage.
module tb;
  logic clk = 0;
  logic reset;
  logic write_enable, read_enable;
  logic [7:0] data_in, data_out;
  logic full, empty;

  sync_fifo dut (.*);

  covergroup fifo_cg @(posedge clk);
    option.per_instance = 1;
    cp_write: coverpoint write_enable;
    cp_read: coverpoint read_enable;
    cp_full: coverpoint full;
    cp_empty: coverpoint empty;
    cp_data_in: coverpoint data_in {
      bins low = {[0:63]}; bins mid = {[64:191]}; bins high = {[192:255]};
    }
    x_operation: cross cp_write, cp_read;
    x_write_status: cross cp_write, cp_full;
    x_read_status: cross cp_read, cp_empty;
  endgroup

  fifo_cg cg;
  always #5 clk = ~clk;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
    cg = new();
    reset = 1; write_enable = 0; read_enable = 0; data_in = '0;
    repeat (2) @(posedge clk);
    reset = 0;
    repeat (80) begin
      @(negedge clk);
      {write_enable, read_enable, data_in} = $urandom;
    end
    // TODO: ignore impossible status combinations and add a scoreboard.
    #10 $finish;
  end
endmodule
