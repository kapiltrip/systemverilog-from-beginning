`timescale 1ns/1ps

// Video 124: consecutive repetition and the deliberate endpoint value.
module tb;
  logic clk = 0;
  logic state = 0;

  covergroup repetition_cg @(posedge clk);
    option.per_instance = 1;
    cp_state: coverpoint state {
      bins four_ones = (0 => 1[*4] => 0);
    }
  endgroup

  repetition_cg cg;

  task automatic drive_state(input logic next_state);
    @(negedge clk);
    state = next_state;
  endtask

  initial repeat (24) #5 clk = ~clk;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
    cg = new();
    drive_state(0);
    repeat (4) drive_state(1);
    drive_state(0); // endpoint prevents an unintended held-high tail
    repeat (3) drive_state(0);
    // TODO: vary the [*] repetition count and drive both hit and miss traces.
  end
endmodule
