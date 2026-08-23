`timescale 1ns/1ps

// Video 097: pass the processed task value into a user-defined sample method.
module tb;
  logic clk = 0;
  logic write = 0;
  logic [3:0] address = 0;

  covergroup address_cg with function sample(input logic [3:0] observed_address);
    option.per_instance = 1;
    cp_address: coverpoint observed_address;
  endgroup

  address_cg cg;

  task automatic write_once;
    @(negedge clk);
    write = 1;
    address = $urandom;
    cg.sample(address);
    @(negedge clk);
    write = 0;
  endtask

  initial repeat (40) #5 clk = ~clk;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
    cg = new();
    repeat (8) write_once();
    // TODO: add read_once() and sample its task arguments independently.
  end
endmodule
