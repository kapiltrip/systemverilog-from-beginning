`timescale 1ns/1ps

// Video 130: direct stimulus plus the first coverage goal--visit every input.
module tb;
  reg a, b, c, d, e, f, g, h;
  reg [2:0] sel;
  wire y;
  mux dut (a, b, c, d, e, f, g, h, sel, y);

  covergroup cover_mux;
    option.per_instance = 1;

    coverpoint a {
      bins a_low = {0};
      bins a_high = {1};
    }

    coverpoint b {
      bins b_low = {0};
      bins b_high = {1};
    }

    coverpoint c {
      bins c_low = {0};
      bins c_high = {1};
    }

    coverpoint d {
      bins d_low = {0};
      bins d_high = {1};
    }

    coverpoint e {
      bins e_low = {0};
      bins e_high = {1};
    }

    coverpoint f {
      bins f_low = {0};
      bins f_high = {1};
    }

    coverpoint g {
      bins g_low = {0};
      bins g_high = {1};
    }

    coverpoint h {
      bins h_low = {0};
      bins h_high = {1};
    }

    coverpoint sel;
    coverpoint y;

    // sel also is responsible where, we have to send the o/p to the mux
    // sel and b sel 0 b 0 sel b1 , sel can be 0 to 7 i.e 8 unique values
    cross_a_sel: cross sel, a {                             // sel , a relevant when sel is 00 and a can be both ?
      ignore_bins sel_other = binsof(sel) intersect {[1:7]};
    }

    cross_b_sel: cross sel, b {
      ignore_bins sel_other = binsof(sel) intersect {0, [2:7]};
    }

    cross_c_sel: cross sel, c {
      ignore_bins sel_other = binsof(sel) intersect {[0:1], [3:7]};
    }

    cross_d_sel: cross sel, d {
      ignore_bins sel_other = binsof(sel) intersect {[0:2], [4:7]};
    }

    cross_e_sel: cross sel, e {
      ignore_bins sel_other = binsof(sel) intersect {[0:3], [5:7]};
    }

    cross_f_sel: cross sel, f {
      ignore_bins sel_other = binsof(sel) intersect {[0:4], [6:7]};
    }

    cross_g_sel: cross sel, g {
      ignore_bins sel_other = binsof(sel) intersect {[0:5], 7};
    }

    cross_h_sel: cross sel, h {
      ignore_bins sel_other = binsof(sel) intersect {[0:6]};
    }
  endgroup

  cover_mux ci;

  initial begin
    ci = new();
    for (int i = 0; i < 50; i++) begin
      sel = $urandom();
      {a, b, c, d, e, f, g, h} = $urandom();
      ci.sample();
      #10;
    end
  end
endmodule
