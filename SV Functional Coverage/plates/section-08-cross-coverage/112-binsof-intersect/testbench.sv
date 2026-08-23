`timescale 1ns/1ps

// Video 112: compact cross filtering with binsof(...) intersect {...}.
module tb;
  logic write;
  logic [1:0] address;

  covergroup filtered_cross_cg;
    option.per_instance = 1;
    cp_write: coverpoint write;
    cp_address: coverpoint address;
    x_read_addresses: cross cp_write, cp_address {
      ignore_bins write_operation = binsof(cp_write) intersect {1};
    }
  endgroup

  filtered_cross_cg cg;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
    cg = new();
    repeat (24) begin
      {write, address} = $urandom;
      cg.sample();
      #10;
    end
    // TODO: add another binsof/intersect filter for a selected address range.
  end
endmodule
