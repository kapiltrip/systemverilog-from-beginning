// Code your testbench here
// or browse Examples
//:= equal weight to all the values inside the range 
//:/ divide the weight equally to values between the range 
// 2 bit sel 00 01 10 11 
//
class first ; 
  rand bit wr; 
  rand bit rd;
  rand bit [1:0] var1 ; 
  rand bit [1:0] var2 ; 
  constraint datavar{
    var1 dist {0 := 30 , [1:3] := 90};  // very less probability for 0 
    var2 dist {0 :/ 30 , [1:3] :/ 90}; 
  }
  constraint control{
    wr dist {0 := 30 , 1:= 70 }; // whould get more 1 
    rd dist {0 :/30 , 1:/ 70 } ; 
    
  }
  
endclass
module tb; 
  first f; 
  initial begin
    f=new(); 
    for(int i =0 ; i<30 ; i++ )begin
      f.randomize(); 
      //$display("The value of wr is : %0d and rd is %0d " , f.wr, f.rd );
      $display("The value of var1 is : %0d and var2 is %0d " , f.var1, f.var2 );
    end
  end
 
endmodule 
