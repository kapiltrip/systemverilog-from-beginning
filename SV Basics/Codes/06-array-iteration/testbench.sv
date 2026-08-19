// Code your testbench here
// or browse Examples
module tb; 
  /*
  int arr[10]; 
  // why j is going from 0 to 9 cause im not specifying anything , is it because of foreach loop ? 
  
  initial begin
  foreach(arr[j])begin
    arr[j]=j; 
    $display("the value here, locally update at index %0d   is %0d " , j, arr[j]);
    
  end
  end
  */
  int arr[10]; 
  int i =0; 
  initial begin
    repeat(10)begin
      arr[i]=i ; 
      i++; 
    end
    $display("The array values are %0p" , arr); 
  end
endmodule
