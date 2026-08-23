`timescale 1ns/1ps

// Video 136: interface-first FIFO shell; implement behavior after the plan.
module sync_fifo #(
  parameter WIDTH = 8,
  parameter DEPTH = 8
) (
  input  logic             clk,
  input  logic             reset,
  input  logic             write_enable,
  input  logic             read_enable,
  input  logic [WIDTH-1:0] data_in,
  output logic [WIDTH-1:0] data_out,
  output logic             full,
  output logic             empty
);
  assign data_out = '0;
  assign full = 1'b0;
  assign empty = 1'b1;
  // TODO: add memory, pointers, count, and sequential read/write behavior.
endmodule
