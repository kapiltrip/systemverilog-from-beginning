`timescale 1ns/1ps
// to cover all the ranges during reading as well , ok

// Video 100: call user-defined sample() from a property sequence match item.
module tb;
  reg rd = 0, wr = 0;
  reg clk = 0;
  reg [4:0] addr;
  reg [7:0] din;
  reg [7:0] dout;

  initial repeat (50) #5 clk = ~clk;
  covergroup c with function sample (reg [4:0] addrIn);  // is sample user defined ?
    option.per_instance = 1;
    coverpoint addrIn{
      bins lower = {[0:7]};
      bins mid = {[15:20]};
      bins high = {[27:31]};
    }
  endgroup
  c ci;
  initial begin
    ci = new();
    @(posedge clk);  // write
    addr = 3;
    wr = 1;
    rd = 0;
    din = 12;
    @(posedge clk);
    wr = 0;
    rd = 1;
    addr = 3;
    dout = 12;
    @(posedge clk); //
    addr = 17;
    wr = 1;
    rd = 0;
    din = 21;
    @(posedge clk);
    wr = 0;
    rd = 1;
    addr = 17;
    dout = 21;
    @(posedge clk); //28
    addr = 28;
    wr = 1;
    rd = 0;
    din = 67;
    @(posedge clk);
    wr = 0;
    rd = 1;
    dout = 67;
    addr = 28;

  end


  property p1;
    bit [4:0] addrs;
    bit [7:0] dvariable;
    @(posedge clk) (wr |-> (wr, addrs = addr, dvariable = din, ci.sample(addrs)) ##[1:50] rd [*1:50] ##0 (addrs == addr) ##0 (dout == dvariable));
    // what is this wr
  endproperty
    a1: assert property (p1) $info("success at %0t", $time);

    initial begin
      $dumpfile("dump.vcd");
      $dumpvars;
      $assertvacuousoff(0);
      //#500;
      //$finish ();

    end





endmodule
