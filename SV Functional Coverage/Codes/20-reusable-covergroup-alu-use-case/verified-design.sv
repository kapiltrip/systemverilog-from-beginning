`timescale 1ns/1ps

module alu_verified (
  input  logic [3:0] a,
  input  logic [3:0] b,
  input  logic [2:0] opcode,
  output logic [4:0] y
);
  always_comb begin
    case (opcode)
      3'b000: y = {1'b0, a} + {1'b0, b};
      3'b001: y = {1'b0, a} - {1'b0, b};
      3'b010: y = {1'b0, a} + 5'd1;
      3'b011: y = {1'b0, b} + 5'd1;
      3'b100: y = {1'b0, a & b};
      3'b101: y = {1'b0, a | b};
      3'b110: y = {1'b0, a ^ b};
      3'b111: y = {1'b0, ~a};
      default: y = '0;
    endcase
  end
endmodule
