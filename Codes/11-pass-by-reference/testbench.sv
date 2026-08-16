// Code your testbench here
// or browse Examples
module tb;
  task automatic swap(ref bit [1:0] a, b);
    //task automatic swap(const ref bit [1:0] a, ref bit b);
  //task automatic swap(ref bit [1:0] a, b);

    bit [1:0] temp;
    temp = a;
    a  = b;
    b = temp;
    $display ("value of a is : %0d and b is : %0d " , a,b ) ;
  endtask
  bit [1:0] c;
  bit [1:0] d;
  initial begin
    c=1;
    d=2;
    swap(c,d);
    $display ("value of c is : %0d and d is : %0d " , c,d ) ;
    //wont be reflected to the varaibles outside the task
    // WHY PASS BY VALUE IN TERMS OF SCALAR HE IS SAYING

  end
endmodule
