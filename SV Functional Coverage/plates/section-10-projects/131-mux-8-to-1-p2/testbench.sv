`timescale 1ns/1ps

// Video 131: separate input-pattern and select coverage before crossing them.
module tb;
  logic [7:0] data;
  logic [2:0] select;
  logic       y;

  mux8to1 dut (.*);

  covergroup mux_cg;
    option.per_instance = 1;
    cp_select: coverpoint select { bins each_input[] = {[0:7]}; }
    cp_data: coverpoint data {
      bins all_zero = {'0};
      bins all_one  = {'1};
      bins other    = default;
    }
    x_select_data: cross cp_select, cp_data;
  endgroup

  mux_cg cg;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
    cg = new();
    repeat (32) begin
      {select, data} = $urandom;
      cg.sample();
      #10;
    end
    // TODO: bias stimulus toward any uncovered cross combinations.
  end
endmodule
