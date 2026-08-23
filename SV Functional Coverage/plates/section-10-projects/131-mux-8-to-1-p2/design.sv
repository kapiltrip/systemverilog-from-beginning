`timescale 1ns/1ps

module mux8to1 (
  input  logic [7:0] data,
  input  logic [2:0] select,
  output logic       y
);
  always_comb y = data[select];
endmodule
