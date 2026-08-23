`timescale 1ns/1ps

// Video 140: compact SPI-controller state machine for transition coverage.
module spi_controller (
  input  logic       clk,
  input  logic       reset,
  input  logic       start,
  output logic [1:0] state,
  output logic       busy
);
  localparam IDLE = 2'd0, LOAD = 2'd1, TRANSFER = 2'd2, DONE = 2'd3;
  logic [2:0] bit_count;

  assign busy = (state != IDLE);

  always_ff @(posedge clk) begin
    if (reset) begin
      state <= IDLE;
      bit_count <= '0;
    end else begin
      case (state)
        IDLE: if (start) state <= LOAD;
        LOAD: begin state <= TRANSFER; bit_count <= '0; end
        TRANSFER: if (bit_count == 3'd7) state <= DONE;
                  else bit_count <= bit_count + 1'b1;
        DONE: state <= IDLE;
        default: state <= IDLE;
      endcase
    end
  end
endmodule
