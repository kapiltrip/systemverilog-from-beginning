// Code your design here
// mealy fsm
module fsm(
  input wire x,clk ,rst,
  output reg y
);
  typedef enum bit {
    s0= 1'b0,
    s1=1'b1
  } state_t;
  state_t state, next_state;

  always_ff @(posedge clk or posedge rst) begin
    if(rst)
      state <= s0;
    else
      state <= next_state;
  end

  always_comb begin
    next_state = s0;
    y=1'b0;
    case (state)
      s0: begin
        if(x)begin
          next_state = s1;
          y=1'b1;
        end else begin
          next_state = s0;
        end
      end
      s1: begin
        if(x)begin
          y=1'b1;
          next_state = s0;
        end else begin
          next_state = s1;
        end
      end
      default: next_state = s0;
    endcase
  end
endmodule
