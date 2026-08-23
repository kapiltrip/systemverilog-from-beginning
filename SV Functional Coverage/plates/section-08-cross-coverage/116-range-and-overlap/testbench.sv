`timescale 1ns/1ps

// Video 116: intersect a range and observe overlap between ignore bins.
module tb;
  logic write;
  logic [2:0] d;

  covergroup range_filter_cg;
    option.per_instance = 1;
    cp_write: coverpoint write;
    cp_d: coverpoint d;
    x_write_d: cross cp_write, cp_d {
      ignore_bins unused_d = binsof(cp_d) intersect {[5:7]};
      ignore_bins unused_write = binsof(cp_write) intersect {0};
    }
  endgroup

  range_filter_cg cg;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
    cg = new();

    repeat (16) begin
      {write, d} = $urandom;
      $display("write=%0b d=%0d", write, d);
      cg.sample();
      #10;
    end
    // TODO: predict and then verify how the overlapping ignore bins combine.
  end
endmodule
