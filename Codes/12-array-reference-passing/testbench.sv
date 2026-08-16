// Code your testbench here
// or browse Examples
//Copying an array to stack is not an optimum choice
module tb ;
  bit [3:0] res[16] ;

  function automatic void init_arr( ref bit [3:0] a [16]); // 4 bit 16 elements
    for(int i=0;i<16 ; i++ )begin
      a[i] = i ;

    end
  endfunction
  initial begin
    init_arr(res);
    $display("Values the array res is having are : %0p" , res) ;
  end
endmodule
*/
