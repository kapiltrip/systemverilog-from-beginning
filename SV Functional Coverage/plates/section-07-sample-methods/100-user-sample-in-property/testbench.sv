`timescale 1ns/1ps

// Video 100: sample from a property's cover-action block.
module tb;
  logic clk = 0;
  logic rst_n = 0;
  logic write = 0;
  logic [4:0] address = 0;

  covergroup address_cg with function sample(input logic [4:0] observed_address);
    option.per_instance = 1;
    cp_address: coverpoint observed_address {
      bins low  = {[0:7]};
      bins mid  = {[8:20]};
      bins high = {[21:31]};
    }
  endgroup

  address_cg cg;

  property p_write_attempt;
    @(posedge clk) disable iff (!rst_n) write;
  endproperty

  // TODO: extend the property with local snapshots and readback checks.
  c_write_attempt: cover property (p_write_attempt) cg.sample(address);

  initial repeat (40) #5 clk = ~clk;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
    cg = new();

    repeat (2) @(negedge clk);
    rst_n = 1;
    repeat (12) begin
      @(negedge clk);
      write = $urandom_range(1, 0);
      address = $urandom;
    end
    @(negedge clk);
    write = 0;
  end
endmodule
