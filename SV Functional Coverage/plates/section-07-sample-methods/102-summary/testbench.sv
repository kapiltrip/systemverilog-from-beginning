`timescale 1ns/1ps

// Video 102: compact choose-the-right-sampling-method reference.
module tb;
  logic clk = 0;
  logic [2:0] value = 0;

  covergroup event_cg @(posedge clk);
    cp: coverpoint value;
  endgroup

  covergroup manual_cg;
    cp: coverpoint value;
  endgroup

  covergroup argument_cg with function sample(input logic [2:0] snapshot);
    cp: coverpoint snapshot;
  endgroup

  event_cg event_cov;
  manual_cg manual_cov;
  argument_cg argument_cov;

  initial repeat (24) #5 clk = ~clk;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
    event_cov = new();
    manual_cov = new();
    argument_cov = new();

    repeat (8) begin
      @(negedge clk);
      value = $urandom;
      manual_cov.sample();
      argument_cov.sample(value);
    end
    // TODO: keep one style, then explain why it best matches your monitor.
  end
endmodule
