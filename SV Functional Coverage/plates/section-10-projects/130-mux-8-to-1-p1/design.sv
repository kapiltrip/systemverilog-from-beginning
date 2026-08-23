`timescale 1ns/1ps

// Video 130: begin with a small, readable 8:1 mux DUT.
module mux8to1 (
  input  logic [7:0] data,
  input  logic [2:0] select,
  output logic       y
);
  always_comb y = data[select];
endmodule
