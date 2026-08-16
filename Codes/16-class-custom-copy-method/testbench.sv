// Code your testbench here
// or browse Examples
class first ;
  int data = 34 ;
  bit [7:0] temp= 8'h11;

  // custom methods to copy
  function first copy();
    copy= new();
    copy.data = data;    // why am i not using this here,
    copy.temp = temp ;

  endfunction
endclass

module tb ;
  first f1;
  first f2 ;
  // to store copy of f1 to f2
  /*
  initial begin
    f1=new();
    f1.data = 45;

    f2=new f1;  // copy of the data members of f1 to f2

    $display("Data member of f2 now becomes a copy %0d " , f2.data );
    // this is not changing f1

    f2.data = 56;
    $display("Data member of f2 now becomes a copy %0d " , f2.data );
    $display("Data member of f1 now becomes a copy %0d " , f1.data );

  end
  */
  initial begin
    f1=new();
    f2=new();
    f2= f1.copy;     //automatically copies  why i havent used f1.copy()
    $display("Data : %0d and temp is %0h" , f2.data, f2.temp); // he called hex by using %0x
  end
endmodule
