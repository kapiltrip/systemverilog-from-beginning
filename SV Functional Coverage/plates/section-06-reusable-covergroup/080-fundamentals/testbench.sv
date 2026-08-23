`timescale 1ns/1ps

// Video 080: reusable/generic covergroup fundamentals.
module tb;
  logic [3:0] a, b;

  covergroup reusable_cg(ref logic [3:0] value);
    option.per_instance = 1;
    cp_value: coverpoint value;
    // TODO: replace the automatic bins with the lesson-specific ranges.
  endgroup

  reusable_cg cg_a, cg_b;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);

    cg_a = new(a);
    cg_b = new(b);

    repeat (16) begin
      a = $urandom_range(15, 0);
      b = $urandom_range(15, 0);
      cg_a.sample();
      cg_b.sample();
      #10;
    end
  end
endmodule
