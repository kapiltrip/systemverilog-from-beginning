// Code your testbench here
// or browse Examples
// overlapping implication -> evaluate of consequent in the same clock tick as antecedant becomes true  a  |-> b 
// non overlapping implication -> evaluation of consequent in the next clock tick as antecedant becomes true  a |=>

// t t non vacuos success will be our target 
// t f failure 
// f (x) vacuous success 
// non overlapping implication in the next clock tick we are checking for the concequent 
module tb; 
  reg clk=0 ; 
  reg req = 0; 
  reg ack =0 ; 
  task req_stimuli();
    #10; 
    req=1; 
    #10;
    req=0; 
    #10; 
    req=1; 
    #10;
    req=0;     
    #10; 
    req=1; 
    #10;
    req=0;     
  endtask 
  task ack_stimuli(); 
    #10 ;
    ack=1; 
    #10 ; 
    ack=0;
        #10 ;
    ack=1; 
    #10 ; 
    ack=0;
        #10 ;
    ack=1; 
    #10 ; 
    ack=0;
  endtask 
  initial begin
    fork
      req_stimuli();
      ack_stimuli();
    join
  end
  always #5 clk = ~clk ; 
  a1 : assert property (@(posedge clk) req |-> ack ) $info("Overlapping success at %0t" , $time) ; else $error("Overlapping failure at %0t" , $time);
    a2 : assert property (@(posedge clk) req |=> ack ) $info("NON Overlapping success at %0t" , $time) ; else $error("non Overlapping failure at %0t" , $time);
  
    initial begin
      $dumpfile("dump.vcd");
      $dumpvars; 
      $assertvacuousoff(0); // to filter vacuous success
    end
    initial begin
      repeat (15) @(posedge clk); 
      $finish();
    end
endmodule
