// Code your testbench here
// or browse Examples
module temp; 
  reg a =0; 
  reg clk =0;
  reg [3:0] b;
  reg [3:0] c =4'b000x; 
  
  always #5 clk = ~clk ; 
  initial begin
    for(int i =0;i<15;i++)begin
      a=$urandom_range(0,1); 
      b=$urandom_range(0,15); 
      c=$urandom_range(0,15);
      @(posedge clk);
    end
  end
  always @(posedge clk)begin
    begin
      //complete of one hot will give me one cold or not 
      $display("Value of a is %0b changed is %0b a stabe is   %0b  at time %0t" ,a, $changed(a) , $stable(a) , $time  );
      $display("Value of b is %4b  one hot zero  b is %0d and onehot %0d at time %0t" ,b ,  $onehot0(b) , $onehot(b) , $time  );
      $display("Value of b is %4b  one cold encoded b is %0d  at time %0t" ,b , $onehot(~b) , $time  );
      $display("-------------------------------------------------------------------------------------------------------");
      $display("Value of %4b and is unknown present -> %0b  at time %0t" ,c , $isunknown(c), $time  );
      $display("-------------------------------------------------------------------------------------------------------");
      // One cold , presence of 1 zero and rest all 1 
      // count bits will return in signal having no of matching value the signal and second will be the variable to match  
      $display("count of  0 in c  i.e %4b is  %4b   at time %0t" ,c , $countbits(c, 0), $time  );
      $display("Count 1 in the number %4b is %0d at the time %0t" , c,$countones(c) , $time); 
      //$display("count of x in c i.e %4b is %0d at time %0t" ,c , $countbits(c , x), $time  );

    end
  end
    initial begin
    $dumpfile("dump.vcd"); 
    $dumpvars ; 
    #200; 
      $finish();
  end
endmodule
