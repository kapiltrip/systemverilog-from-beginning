`timescale 1ns/1ps

// Video 132: final mux plate--sample the selected input value directly.
module tb;
  logic [7:0] data;
  logic [2:0] select;
  logic       y;

  mux8to1 dut (.*);

  covergroup mux_selected_value_cg;
    option.per_instance = 1;
    cp_select: coverpoint select { bins each_input[] = {[0:7]}; }
    cp_selected_value: coverpoint data[select] { bins zero = {0}; bins one = {1}; }
    x_input_value: cross cp_select, cp_selected_value;
  endgroup

  mux_selected_value_cg cg;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
    cg = new();
    repeat (64) begin
      {select, data} = $urandom;
      cg.sample();
      #10;
    end
    // TODO: compare y with data[select] and close any coverage holes.
  end
endmodule
