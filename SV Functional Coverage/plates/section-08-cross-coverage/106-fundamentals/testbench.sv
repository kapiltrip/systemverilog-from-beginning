`timescale 1ns/1ps

// Video 106: independent coverage can be 100% while combinations are missing.
module tb;
  logic write;
  logic [1:0] address;
  logic [3:0] din, dout;

  covergroup memory_cg;
    option.per_instance = 1;
    cp_write:   coverpoint write;
    cp_address: coverpoint address;
    cp_din:     coverpoint din;
    cp_dout:    coverpoint dout;
    x_write_address: cross cp_write, cp_address;
    // TODO: add the operation/data crosses required by the verification plan.
  endgroup

  memory_cg cg;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
    cg = new();

    repeat (24) begin
      {write, address, din, dout} = $urandom;
      cg.sample();
      #10;
    end
  end
endmodule
