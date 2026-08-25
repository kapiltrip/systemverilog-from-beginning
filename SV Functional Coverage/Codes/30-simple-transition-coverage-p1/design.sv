module two_state_fsm(
  input  logic clk,
  input  logic reset,
  input  logic d,
  output logic d_out
);
  localparam logic s0 = 1'b0;
  localparam logic s1 = 1'b1;
  logic state, next_state;

  always_ff @(posedge clk or posedge reset) begin
    if (reset) state <= s0;
    else       state <= next_state;
  end

  always_comb begin
    next_state = state;
    d_out = 1'b0;
    case (state)
      s0: if (d) next_state = s1;
      s1: if (d) begin
        next_state = s0;
        d_out = 1'b1;
      end
      default: next_state = s0;
    endcase
  end
endmodule
