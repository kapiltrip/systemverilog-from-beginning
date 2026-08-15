// Code your testbench here
// or browse Examples
// arrays to start collecting the transactions that monitor send to scoreboards 

`timescale 1ns/1ps 
/*
module tb;
  bit arr1[8]; // array of 8 elements  // 2 state bit type 
  
  bit arr[] = {1,0,1,1}; // compiler will make the size ==4
  initial begin
    $display("size of arr1 is %0d and that of arr is %0d " , $size(arr1) , $size(arr)); 
    $display("value of first element if %0d" , arr[0]); 
    arr[1]= 1; 
    $display("value of second element if %0d" , arr[1]); 
    $display ("value of all the elements fo arr is : %0p" , arr  ); 
    // if the array is not initialize or given size i cant put any element inside 
    
  end
  //INITIALIZATION 
  
  //to initialize with unique values , or repetitive value or default value 
  
  
endmodule
*/
/*
module tb;
  int arr[5] = '{1,2,3,4,5}; 
  initial begin
    $display("all the elements of arr is %0p" , arr ); 
  end
  int arr2[5] = '{5{1'b0}}; 
  initial begin
    $display("all the elements of arr2 is %0p" , arr2 ); 
  end
  int arr3[5] = '{default : 2 }; 
  initial begin
    $display("all the elements of arr3 is %0p" , arr3 ); 
  end
  // repetition operator 
  
  int arr5[3] = '{3{3'd3}}; 
  initial begin
    $display("all the elements of arr5 is %0p" , arr5 ); 
  end
  
endmodule
*/
//REPEATING OPERATIONS 
// FOR , REPEAT AND FOR EACH LOOP 

module tb; 
  int arr [10];
  int i=0; 
  // need a procedural block 
  initial begin
    for(i =0;i<10 ; i++)begin
      arr[i]= i; 
      
    end
    $display("The values of the arr are  : %0p" , arr); 
  end
endmodule




















