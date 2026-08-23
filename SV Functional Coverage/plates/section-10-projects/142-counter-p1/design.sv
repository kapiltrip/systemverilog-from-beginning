`timescale 1ns/1ps

// Video 142: loadable 4-bit up-counter DUT.
module counter (
  input  logic       clk,
  input  logic       reset,
  input  logic       enable,
  input  logic       load,
  input  logic [3:0] load_value,
  output logic [3:0] count
);
  always_ff @(posedge clk) begin
    if (reset) count <= '0;
    else if (load) count <= load_value;
    else if (enable) count <= count + 1'b1;
  end
endmodule
