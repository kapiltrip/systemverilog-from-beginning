// Code your testbench here
// or browse Examples
// deep copy copies dynamically created things such as class as well , and 
// in cpp it should be a user defined constructor 
// so we can have different objects copies shared and those 2 objects are independent copies 
class first ;
  int data1 =12; 
  function first copy();
    copy= new();
    copy.data1=data1 ; 
    
  endfunction 
endclass
class second;
  int data2=14;
  first f1;
  
  function new();
    f1=new();
  endfunction 
  
  function second copy();
    copy = new(); // copy becomes a handler of class second 
    
    copy.data2= data2;
    
    copy.f1 = f1.copy() ;  // why copy called without ()
    
  endfunction
endclass

module tb; 
  second s1,s2;
  
  initial begin
    s1=new(); // s1 is a different object handler and s2 is independent prove at line 43 
    s2=new();
    s1.data2= 45;
    s2 = s1.copy();
    $display("Value of data 2 is %0d " , s2.data2);
    s2.data2=555;
    $display("Value of data 2 of handler s2  is %0d " , s2.data2); // they have to be different
    $display("Value of data 2 of handler s1  is %0d " , s1.data2);
    //Till now handler are independent 
    s2.f1.data1=98;
    $display("The value of data 1 seen from handler s2 that i have written is  %0d" , s2.f1.data1);

    $display("The value of data 1 seen from handler s1 is %0d" , s1.f1.data1);
  end 
  
endmodule 









/*
## Questions You Asked in the Recent Discussion

1. **Shallow copy:** In a shallow copy, is only the handle different while the nested object it points to remains the same/shared object?

2. In this code, **what exactly am I doing?**

   ```systemverilog
   function first copy();
     copy = new();
     copy.data = data;
   endfunction
   ```

3. Why am I using a custom `copy()` function instead of simply using `function new()` and initializing the class members there?

4. What is this called?

   ```systemverilog
   function new();
     ...
   endfunction
   ```

5. Are both `function new()` and `function first copy()` **constructors**?

6. If they are not both constructors, **what exactly is the difference between a constructor and a `copy()` method?**

7. Why can't I use `new()` and `copy()` **interchangeably**?

8. What is the difference between:

   ```systemverilog
   f2 = new();
   ```

   and:

   ```systemverilog
   f2 = f1.copy();
   ```

9. Why does `new()` give me a **fresh/default object**, while `f1.copy()` gives me a **new object containing the values of `f1`**?

10. More generally, what is the relationship between:

* `function new()` → constructor **definition**
* `f1 = new()` → constructor **call / object creation**
* `function first copy()` → user-defined **copy method**
* `copy = new()` inside `copy()` → constructor call **inside the copy method**?

*/
