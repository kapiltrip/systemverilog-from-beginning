`timescale 1ns/1ps

// Video 083: pass constant range limits by value with input arguments.
module tb;
  logic [3:0] a, b;

  covergroup ranged_cg(
    ref logic [3:0] value,
    input string instance_name,
    input int low_max,
    input int mid_max,
    input int high_max
  );
    option.per_instance = 1;
    option.name = instance_name;
    cp_value: coverpoint value {
      bins low  = {[0:low_max]};
      bins mid  = {[low_max + 1:mid_max]};
      bins high = {[mid_max + 1:high_max]};
    }
  endgroup

  ranged_cg cg_a, cg_b;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);

    cg_a = new(a, "variable A ranges", 3, 10, 15);
    cg_b = new(b, "variable B ranges", 3, 10, 15);

    repeat (24) begin
      a = $urandom;
      b = $urandom;
      cg_a.sample();
      cg_b.sample();
      #10;
    end
    // TODO: add another per-instance name/constant and compare the bins.
  end
endmodule
