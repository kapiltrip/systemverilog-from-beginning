`timescale 1ns/1ps

// Video 107: construct address and data-range crosses for a memory-like DUT.
module tb;
  logic write;
  logic [1:0] address;
  logic [3:0] din, dout;

  covergroup memory_cg;
    option.per_instance = 1;
    cp_write: coverpoint write {
      bins read_mode  = {0};
      bins write_mode = {1};
    }
    cp_address: coverpoint address { bins each_address[] = {[0:3]}; }
    cp_din: coverpoint din {
      bins low = {[0:3]}; bins mid = {[4:10]}; bins high = {[11:15]};
    }
    cp_dout: coverpoint dout {
      bins low = {[0:3]}; bins mid = {[4:10]}; bins high = {[11:15]};
    }
    x_write_address: cross cp_write, cp_address;
    x_write_address_din: cross cp_write, cp_address, cp_din;
    x_write_address_dout: cross cp_write, cp_address, cp_dout;
  endgroup

  memory_cg cg;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
    cg = new();
    repeat (40) begin
      {write, address, din, dout} = $urandom;
      cg.sample();
      #10;
    end
    // TODO: inspect which Cartesian-product combinations remain uncovered.
  end
endmodule
