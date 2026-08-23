module two_state_fsm(
  input  logic clk,
  input  logic reset,
  input  logic d,
  output logic d_out
);
  localparam logic S0 = 1'b0;
  localparam logic S1 = 1'b1;
  logic state, next_state;

  always_ff @(posedge clk or posedge reset) begin
    if (reset) state <= S0;
    else       state <= next_state;
  end

  always_comb begin
    next_state = state;
    d_out = 1'b0;
    case (state)
      S0: if (d) next_state = S1;
      S1: if (d) begin next_state = S0; d_out = 1'b1; end
      default: next_state = S0;
    endcase
  end
endmodule
