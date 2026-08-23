`timescale 1ns/1ps

// Video 137: synchronous FIFO implementation starter.
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
  localparam PTR_W = $clog2(DEPTH);
  logic [WIDTH-1:0] memory [0:DEPTH-1];
  logic [PTR_W-1:0] write_pointer, read_pointer;
  logic [PTR_W:0] count;
  logic do_write, do_read;

  assign full = (count == DEPTH);
  assign empty = (count == 0);
  assign do_write = write_enable && !full;
  assign do_read = read_enable && !empty;

  always_ff @(posedge clk) begin
    if (reset) begin
      write_pointer <= '0;
      read_pointer <= '0;
      count <= '0;
      data_out <= '0;
    end else begin
      if (do_write) begin
        memory[write_pointer] <= data_in;
        write_pointer <= write_pointer + 1'b1;
      end
      if (do_read) begin
        data_out <= memory[read_pointer];
        read_pointer <= read_pointer + 1'b1;
      end
      case ({do_write, do_read})
        2'b10: count <= count + 1'b1;
        2'b01: count <= count - 1'b1;
        default: count <= count;
      endcase
    end
  end
endmodule
