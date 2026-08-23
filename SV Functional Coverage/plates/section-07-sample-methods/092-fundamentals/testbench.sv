`timescale 1ns/1ps

// Video 092: side-by-side starters for all three sampling methods.
module tb;
  logic clk = 0;
  logic [1:0] value = 0;

  covergroup event_cg @(posedge clk);
    cp_value: coverpoint value;
  endgroup

  covergroup manual_cg;
    cp_value: coverpoint value;
  endgroup

  covergroup argument_cg with function sample(input logic [1:0] observed);
    cp_value: coverpoint observed;
  endgroup

  event_cg cg_event;
  manual_cg cg_manual;
  argument_cg cg_argument;

  initial repeat (30) #5 clk = ~clk;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
    cg_event = new();
    cg_manual = new();
    cg_argument = new();

    repeat (12) begin
      @(negedge clk);
      value = $urandom;
      cg_manual.sample();
      cg_argument.sample(value);
    end
    // TODO: add one experiment for each of the three sampling styles.
  end
endmodule
