// Code your testbench here
// or browse Examples
// compare element in scoreboard , golden data + dut response compare elememnt by element and copy used here, 
// CONDITION 1 SAME DATA TYPE AND 
// CONDITION 2 SAME SIZE 
//07 
/*
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
*/ 
module tb; 
  int arr[];
  int arrfixed[30]; 

  initial begin
    arr = new[5];
    //of storing an element 
    for(int i =0 ; i<5 ; i++)begin
      arr[i] = 5 * i ; 
      
    end
    $display("the values in the array arr is %0p" , arr ) ; 
    $display("the size of array arr is %0d" , arr.size() ) ; 

    //arr.delete();   
    //why its not having default value printed xxxx cause i deleted and its a 4 state logic 
    
    $display("the values in the array arr is %0p" , arr ) ; 
    $display("the size of array arr is %0d" , arr.size() ) ; 
   // arr = new [30]; 
    arr = new [30](arr);
    $display("the values in the array arr is %0p" , arr ) ; 

    $display("the size of array arr is %0d" , arr.size() ) ; 
    //to store that in fixed size array 
    arrfixed = arr ; 
    $display("the values in the fixed size array arr is %0p" , arrfixed ) ; 

  end
  //have to use new keyword when i want to add elements 
  
endmodule
