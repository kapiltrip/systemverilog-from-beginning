`timescale 1ns/1ps

// Video 097: pass the processed task value into a user-defined sample method.
module tb;
  reg [3:0] address;
  reg wr;
  integer i = 0;
  reg clk = 0;
  // 100 half-cycles provide exactly 50 rising edges, then run -all can finish.
  initial repeat (100) #5 clk = ~clk;
  covergroup c with function sample (reg [3:0] in);
    coverpoint in;

  endgroup
  c ci;
  task write();
    @(posedge clk);
    wr = 1;
    address = $urandom();
    ci.sample(address);
  endtask
  initial begin
    ci = new();
    for(i = 0; i < 50; i++)begin
      write();
    end
  end
endmodule
