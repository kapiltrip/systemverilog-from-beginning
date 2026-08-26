`timescale 1ns/1ps

// Video 136: interface-first FIFO shell; implement behavior after the plan.
module sync_fifo #(
  parameter integer dw = 8,
  parameter integer aw = 8
) (
  input wire clk, rst, wr_en, rd_en,
  input wire [dw-1:0] din,
  output reg [dw-1:0] dout,
  output wire full, empty
);
  localparam integer depth = (1 << aw);
  reg [dw-1:0] mem [0:depth-1];
  reg [aw-1:0] raddr; // reg or wire to be decided
  reg [aw-1:0] waddr; // basically pointers i call them address
  reg [aw:0] count;
  wire canRead = !empty && rd_en;
  wire canWrite = !full && wr_en;

  assign empty = (count == 0);
  assign full = (count == depth);

  always @(posedge clk) begin
    if (rst) begin
      count <= {(aw+1){1'b0}};
      dout <= {dw{1'b0}};
      raddr <= {aw{1'b0}};
      waddr <= {aw{1'b0}};
    end else begin
      if (canRead) begin
        dout <= mem[raddr];
        raddr <= raddr + 1;
      end

      if (canWrite) begin
        mem[waddr] <= din;
        waddr <= waddr + 1;
      end

      case ({canRead, canWrite})
        2'b01: count <= count + 1'b1;
        2'b10: count <= count - 1'b1;
        default: count <= count;
      endcase
    end
  end
endmodule
