// Code your testbench here
// or browse Examples
module tb;
  reg clk =0; 
  reg x=0; 
  reg rst=0; 
  wire y; 
  fsm dut(
    .clk (clk ), 
    .rst(rst),
    .x(x),
    .y(y)
  );
  always #5 clk = ~clk ; 
  initial begin
    #3;
    rst=1; 
    #30; 
    rst=0; 
    x=1; 
    #45; 
    x=0; 
    #25;
    rst=1;
    #40;
    rst=0;
    
  end
      initial begin
      $dumpfile("dump.vcd");
      $dumpvars; 
      $assertvacuousoff(0); 
      #180; 
      $finish();
    end
  // states are one hot encoded
  state_enconding : assert property (@(posedge clk) 1'b1|-> $onehot(dut.state))  $info("ALL THE STATES ARE ONE HOT ENCODED ");
    // if reset assert system stays in idle state 
    resetRelated : assert property (@(posedge clk) $rose(rst) |=> (dut.state == dut.idle)) $info("SUCCESS the state is idle when rst asserted at time %0t" , $time ); // since synchronous reset
      resetHigh: assert property (@(posedge clk) $rose(rst) |=> (dut.state == dut.idle) [*1:18] within rst[*1:18] ##1 !rst ) $info("checking for the whole duration of time i.e 180 ns and the clock period is of 10 ns hence 18 clock ticks  "); 
         // within rhs is reference sequence 
        //if reset deasserted system transit to correct state based on value of din 
    //    3)
      //so for the behaviour of din we must develop sequences 
        // behaviour for din == 1 
        sequence s1;
          (dut.next_state == dut.idle ) ##1 (dut.next_state == dut.s0); 
        endsequence 
        
        sequence s2;
          (dut.next_state == dut.s0 ) ##1 (dut.next_state == dut.s1); 
        endsequence 
        
        sequence s3;
          (dut.next_state == dut.s1 ) ##1 (dut.next_state == dut.s0); 
        endsequence 
        
        
        din_high: assert property (@(posedge clk) disable iff(rst) x |-> (s1 or s2 or s3)) $info("verified for x == 1 i.e high "); 
          
        
        sequence s4;
          (dut.next_state == dut.idle ) ##1 (dut.next_state == dut.idle); 
        endsequence 
        
        sequence s5;
          (dut.next_state == dut.s0 ) ##1 (dut.next_state == dut.s0); 
        endsequence 
        
        sequence s6;
          (dut.next_state == dut.s1 ) ##1 (dut.next_state == dut.s1); 
        endsequence    
        
          din_low: assert property (@(posedge clk) disable iff(rst) !x |-> (s4 or s5 or s6)) $info("verified for x being low ") ; 
        
        
        // I can also use property similarly 
         // all the states are covered or not 
            initial assert property (@(posedge clk) (dut.state == dut.idle) [->1] |-> ##[1:18] (dut.state == dut.s0) ##[1:18] (dut.state==dut.s1 )) ; 
              
        // idle then s0 then s1 , 
        
        
        // if we get and expected o/p if rst is deasserted 
              assert property (@(posedge clk) disable iff(rst) ((dut.next_state== dut.s0) && ($past(dut.next_state) == dut.s1)) |-> (y == 1'b1)); 
                
            

endmodule 
