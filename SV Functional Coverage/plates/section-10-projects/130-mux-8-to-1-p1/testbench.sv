`timescale 1ns/1ps

// Video 130: direct stimulus plus the first coverage goal--visit every input.
module tb;
  logic [7:0] data;
  logic [2:0] select;
  logic       y;

  mux8to1 dut (.*);

  covergroup mux_plan_cg;
    option.per_instance = 1;
    cp_select: coverpoint select { bins each_input[] = {[0:7]}; }
  endgroup

  mux_plan_cg cg;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
    cg = new();
    data = 8'b1010_0101;
    foreach (data[i]) begin
      select = i;
      cg.sample();
      #10;
    end
    // TODO: add checks for y and define the remaining coverage goals.
  end
endmodule
