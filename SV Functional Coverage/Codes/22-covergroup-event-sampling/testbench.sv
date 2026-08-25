`timescale 1ns/1ps

// Video 093: the covergroup samples automatically on its declared event.
module tb;
  logic clk = 0;
  logic [1:0] a = 0;

  covergroup clocked_cg @(posedge clk); // sampling event
    option.per_instance = 1;
    cp_a: coverpoint a;
  endgroup

  clocked_cg cg;

  initial repeat (24) #5 clk = ~clk;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
    cg = new();

    // Drive on the opposite edge so a is stable at the sampling edge.
    repeat (8) begin
      @(negedge clk);
      a = $urandom;
    end
    // TODO: change the event and observe exactly when automatic sampling moves.
  end

endmodule
