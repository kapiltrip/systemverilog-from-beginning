// Code your testbench here
// or browse Examples
module tb;
  reg clk =0;
  always #5 clk = ~clk ; 
  property p1;
    time starttime =0; 
    time currtime=0; 
    time count =0; 
    (1'b1 , starttime = $realtime ) ##1 (1'b1, currtime =$realtime, count = (currtime - starttime) , $display("The time period in nsec is %0t" , count)); 
    //HOW IS IT WORKING , TELL ME THAT AS WELL . 
  endproperty 
  assert property (@(posedge clk ) p1 ) $info("Success at time %0t" , $time); 
    
    initial begin
      $dumpfile("dump.vcd");
      $dumpvars; 
      $assertvacuousoff(0); 
      #100; 
      $finish();
    end
    
endmodule
    
    /*
    boolean operator 
    both a and b must be high 
    (a && b )
    either fo one a or b could be high || 
    one of the signal is high while other must be low 
    both must be low 
    implication operator : antecedant |-> or |=> consequent 
      delay : ##[] fixed or range , fixed range , ##2 a , 
      if a assert a must remain high for 2 clock ticks 
        $rose(a) |-> ##2 a ##1 !a ; // it will not guranteee that a is high for 2 clock ticks 
        $rose(a) |-> [*2]a ##1 !a ; 
    
        $rose(a) |=> (a && $past(a))
        if a assert b should assert after 4 clock ticks 
          $rose(a) |-> ##4 $rose(b); 
        a followed by b followed by c 
        a ##1 b ##1 c 
       repetition :
      matching operator : 
      
    boolean operator 
    unbounded deiay 
    if a assert b must assert at same clock tick 
      $rose(a) |-> ##[0:$] b ;                             //b can be high in the samme clock tick
    if a assert b deassert in the next clock tick or somewhere during simulation 
      $rose(a) |=> ##[0:$] $fall(b) 
      $rose(a) |-> s_eventually !b ; 
    b must become high anytime later during simulation 
    s_eventually b ; 
    rst should become low within 4 to 5 clock ticks 
    ##[4:5] !rst 
    ack should be granted / given to new req within 0 to 1 clock tick 
    $rose(req) |-> ##[0:1] ack;
    repetition operator 
    // consecutive and non consecutive and goto operator 
    rd assert then it must be high for 2 clock tick s
      $rose(rd) |-> rd[*2]; 
    // 3 write s consecutive 
    wr[*3] |=> rd[*2]; 
    if rst deassert ce must remain high 
      $fell(rst) |-> ce[*1:$]; 
    difference b/w goto and non consecutive repetition operator 
    */
