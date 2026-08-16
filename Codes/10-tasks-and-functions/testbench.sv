// Code your testbench here
// or browse Examples
/*
module tb;
  function bit [4:0] add(input bit [3:0] a , b);
    return a+b;

  endfunction
  bit [4:0] result ;  // so no need to make the result initialized by 0
  bit [3:0] ain= 4'b0100;
  bit [3:0] bin =4'b1101  ;
  // i can rather pass ain, bin to the function

  function void displayAINBIN();
    $display("Inside the function display ain ");
  endfunction
    initial begin
    result = add(4'b0000 , 4'b1110 );
    $display("Value of addition is %0d" , result );
      displayAINBIN();
  end
endmodule
*/
// cannot add delay in function ,
// task
module tb();
  bit [2:0] c;
  bit [2:0] d;
  bit [3:0] e;
  bit clk=0;
  always #10 clk = ~clk;

  //task add (input bit [3:0] c , input bit [3:0] d , output bit [4:0 ]e );
  task add();
    e=c+d;
    $display("THE SUM IS : %0d ", e );
  endtask
 /* bit [3:0] a,b;
  bit [4:0] y ;
  initial begin
      a =7;
      b=4;
    add(a,b,y);
    $display("Value of y is %0d" , y);
  end
  */

  task stimuli_clk();
    @(posedge clk);
    c=$urandom(); // 32 bit unsigned value will be generated
    d=$urandom(); //
    add();
    $display("Clock generated of hte random values after waiting for posedges  are %0d" , e);
  endtask
  task addWithTiming();
    c=1;
    d=3;
    add();
    #10;
    c=2;
    d=4;
    add();
    #30;
    c=5;
    d=8;

  endtask
  initial begin
    //addWithTiming();
    for(int i =0; i<11;i++)begin
      stimuli_clk();
    end
  end
  initial begin
    #110;
    $finish();

  end
endmodule
// passby value task add (reg int x, y )"
