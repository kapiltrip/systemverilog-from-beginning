`timescale 1ns/1ps

// Video 095: manually call the pre-built sample() method after stimulus.
module tb;
  logic clk = 0;
  logic [1:0] a = 0;

  covergroup manual_cg;
    option.per_instance = 1;
    cp_a: coverpoint a;
  endgroup

  manual_cg cg;

  initial repeat (24) #5 clk = ~clk;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
    cg = new();

    repeat (8) begin
      @(negedge clk);
      a = $urandom;
      cg.sample();
    end
    // TODO: call sample() only at the transaction boundary you choose.
  end
endmodule
