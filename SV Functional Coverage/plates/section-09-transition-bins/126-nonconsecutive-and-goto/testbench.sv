`timescale 1ns/1ps

// Video 126: non-consecutive [=] versus goto [->] repetition.
module tb;
  logic clk = 0;
  logic state = 0;

  covergroup repetition_cg @(posedge clk);
    option.per_instance = 1;
    cp_state: coverpoint state {
      bins two_nonconsecutive = (0 => 1[=2] => 0);
      bins two_goto = (0 => 1[->2] => 0);
    }
  endgroup

  repetition_cg cg;

  task automatic drive_state(input logic next_state);
    @(negedge clk);
    state = next_state;
  endtask

  initial repeat (28) #5 clk = ~clk;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
    cg = new();
    drive_state(0);
    drive_state(1);
    drive_state(0);
    drive_state(0);
    drive_state(1);
    drive_state(0);
    // TODO: alter the gaps and endpoint to compare [=2] with [->2].
  end
endmodule
