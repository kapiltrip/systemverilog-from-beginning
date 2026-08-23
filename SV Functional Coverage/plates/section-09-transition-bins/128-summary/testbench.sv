`timescale 1ns/1ps

// Video 128: compact syntax reference for all transition-repetition forms.
module tb;
  logic clk = 0;
  logic state = 0;

  covergroup transition_summary_cg @(posedge clk);
    option.per_instance = 1;
    cp_state: coverpoint state {
      bins consecutive = (0 => 1[*2] => 0);
      bins nonconsecutive = (0 => 1[=2] => 0);
      bins goto_endpoint = (0 => 1[->2] => 0);
    }
  endgroup

  transition_summary_cg cg;

  task automatic drive_state(input logic next_state);
    @(negedge clk);
    state = next_state;
  endtask

  initial repeat (32) #5 clk = ~clk;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
    cg = new();
    drive_state(0); drive_state(1); drive_state(1); drive_state(0);
    drive_state(1); drive_state(0); drive_state(1); drive_state(0);
    repeat (3) drive_state(0);
    // TODO: label a trace that distinguishes [*], [=], and [->] behavior.
  end
endmodule
