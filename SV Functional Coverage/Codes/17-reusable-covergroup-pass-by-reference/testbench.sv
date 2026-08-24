`timescale 1ns/1ps

// Video 081: pass live variables by reference into one reusable covergroup.
module tb;
  logic [3:0] a, b;

  covergroup variable_cg(ref logic [3:0] value, input string instance_name);
    option.per_instance = 1;
    option.name = instance_name;
    cp_value: coverpoint value;
  endgroup

  variable_cg cg_a, cg_b;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);

    cg_a = new(a, "variable A");
    cg_b = new(b, "variable B");

    repeat (50) begin
      a = $urandom;
      b = $urandom;
      cg_a.sample();
      cg_b.sample();
      #10;
    end
    // TODO: reuse the same covergroup type for another live signal.
  end
endmodule
