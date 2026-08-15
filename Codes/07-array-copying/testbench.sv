// Code your testbench here
// or browse Examples
// compare element in scoreboard , golden data + dut response compare elememnt by element and copy used here, 
// CONDITION 1 SAME DATA TYPE AND 
// CONDITION 2 SAME SIZE 
module tb ;
  int arr1[5];
  int arr2[5];
  int status ; 
  
  initial begin
    for(int i =0; i<5 ; i++)begin
      arr1[i]= 5*i ; 
      
    end
    $display("the content of arr1 is %0p" , arr1); 

    arr2= arr1; 
    $display("the content of arr2 is %0p" , arr2); 
    arr2[2] = 11; 
    $display("the content of arr2 is now  %0p" , arr2); 
    
  end
  initial begin
    status = (arr1 !=  arr2 ); 
    $display("The following arrays are : having status as %0d" , status ); // should return true 
    
  end
endmodule
