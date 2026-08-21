// Code your design here
// Code your design here 
module fsm( 
  input wire clk ,rst,  
  input wire x, 
  output reg y 
); 
  
  /*
  // 3 states  
  reg [2:0] state, next_state;  
  parameter idle= 3'b000; 
  parameter s0 = 3'b001; 
  parameter s1 = 3'b010;  
   */
  typedef enum bit [2:0] {
    idle = 3'b001, 
    s0= 3'b010, 
    s1= 3'b100 
    
  } state_a; 
  state_a state,next_state;  // similar to int a , b; 
  // present state logic  
  always @(posedge clk )begin 
    if(rst)begin 
      state<= idle;   
    end else  
      state<= next_state;  
  end 

  always @(*)begin 
    next_state = state ;  
    y=1'b0;  

    case (state) 
      idle : next_state = s0 ; 
      
      s0: next_state= (x)? s1:s0;  

      s1: begin 
        if(x)begin 
          next_state = s0;  
          y= 1'b1;  
        end else begin 
          next_state = s1;  
        end 
      end 

      default : next_state = idle ;  
    endcase 
  end 
endmodule
