`timescale 1ns/1ps

// Video 121: legal toggles and illegal same-state behavior while d is high.
module tb;
  logic clk = 0, reset = 1, d = 0;
  logic d_out;

  two_state_fsm dut(.*);

  covergroup transition_high_cg @(posedge clk);
    option.per_instance = 1;
    cp_d: coverpoint d { bins high = {1}; }
    cp_state: coverpoint dut.state iff (!reset && d) {
      bins s0_to_s1 = (0 => 1);
      bins s1_to_s0 = (1 => 0);
      illegal_bins same_state = (0 => 0), (1 => 1);
    }
  endgroup

  transition_high_cg cg;

  initial repeat (30) #5 clk = ~clk;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
    cg = new();
    repeat (2) @(negedge clk);
    reset = 0;
    repeat (8) begin @(negedge clk); d = $urandom_range(1, 0); end
    repeat (4) begin @(negedge clk); d = 1; end
    @(negedge clk); d = 0;
    // TODO: add the opposite simple transition and compare hit counts.
  end
endmodule
