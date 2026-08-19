// Code your testbench here
// or browse Examples
/*
boolean operation  series of operations 
sequence linear or non linear , relationship known , or non linear relationship not known delay , repetition matching 
property select, implication 
  assertion => assert assume cover 
 */
//signal -> boolean   exp -> sequence-> property-> assert 
// clocking block
// disable concurrent assertion 
// 
module tb;
  reg clk=0; 
  reg temp=0;
  reg a =0; 
  reg rst = 0; 
  reg en=1; 
  
  initial begin
    temp=1 ; 
    @(posedge clk);
    temp=0;
    
  end
  initial begin
    rst=1; 
    #7; 
    rst=0; 
    #5;
    rst = 1; 
    
  end
  always #5 clk = ~clk ; 
  //always #5 clk = ~clk ; 
  clocking c1 @(posedge clk);
  endclocking 
  
  default clocking c2 @(negedge clk);
  endclocking 
  
  always #40 a = ~a ;
  a1 : assert property (@(c1) disable iff(!en) (a == 1'b1)) $info("a1 success at %0t" , $time) ; else $error("A1 fail at %0t" , $time);
       initial a2 : assert property (@(posedge clk) (a == 1'b1)) $info("a1 success at %0t" , $time) ; else $error("A1 fail at %0t" , $time);
       check_posedge : assert property (@(posedge clk) en |-> rst ) $info("posedge success at %0t" , $time) ; else $error("posedge fail at %0t" , $time);
       check_negedge : assert property (@(negedge clk) en |-> rst ) $info("negedge success at %0t" , $time) ; else $error("negedge fail at %0t" , $time);
       check_edge : assert property (@(edge clk) en |-> rst ) $info("edge success at %0t" , $time) ; else $error("edge fail at %0t" , $time);
     initial begin
       repeat (30) @(posedge clk );
       $finish();
     end
         
         
    // valid clock edges posedge negedge edge 
    
endmodule
