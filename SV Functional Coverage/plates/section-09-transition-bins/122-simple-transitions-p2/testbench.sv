`timescale 1ns/1ps

// Video 122: legal holds and illegal state changes while d is low.
module tb;
  logic clk = 0, reset = 1, d = 0;
  logic d_out;

  two_state_fsm dut(.*);

  covergroup transition_low_cg @(posedge clk);
    option.per_instance = 1;
    cp_d: coverpoint d { bins low = {0}; }
    cp_state: coverpoint dut.state iff (!reset && !d) {
      bins hold_s0 = (0 => 0);
      bins hold_s1 = (1 => 1);
      illegal_bins changed_state = (0 => 1), (1 => 0);
    }
  endgroup

  transition_low_cg cg;

  initial repeat (34) #5 clk = ~clk;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
    cg = new();
    repeat (2) @(negedge clk);
    reset = 0;
    @(negedge clk); d = 0;
    repeat (8) @(negedge clk);
    // TODO: deliberately pulse d high, then observe the illegal transition
    // diagnostic when sampling resumes with d low.
  end
endmodule
