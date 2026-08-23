/*
// bin filtering
coverpoint a {
  bina used_a[]= a with (item % 2 ==0  ) ;
  // 0,2,4,6,8 , 10  ....

}
coverpoint a {
  illegal_bins unused_a = {2,3} ;
}
coverpoint a{
  wildcard bins low = {2'b0?} ; // lsb bit is dont care for us cover the value of a as 00 / 01

}
*/

module tb;
  reg [3:0] a;   // 0 to 15
  integer i =0 ;
  int b ;
  reg [5:0] btemp ;
  covergroup c;

    option.per_instance =1 ;
    coverpoint a {

	bins track_0 = {0};
	//bins even_a  = {2, 4, 6, 8, 10, 12, 14};
    //bins odd_a   = {1, 3, 5, 7, 9, 11, 13, 15};
      bins odd_a[] = a with ((item>0) && (item %2 !=0 ));
      bins even_a[] = a with ((item>0) && (item %2 ==0 ));
      bins mul3_a[] = a with ((item>0) && (item %3 == 0 ));
      bins range0to7even = {[0:7]} with ((item %2 == 0) && (item>0 )) ;

    } // item is a special keyword each item we r tracking how we refer to item
    coverpoint b {
      bins zero = {0};
      bins bdividedBy5[] = {[1:100]} with ((item %5==0)) ; // its an array i forgot to mention []

    }
  endgroup
  c ci ;
  initial begin
    ci = new();
    for(i=0; i<10 ;i++)begin
      a = $random();
      btemp = $urandom();  // its 32 bit unsigned
      b = btemp; // and int is 32 bit
      $display("Value of a is %0d and b is %0d" , a , b ) ;
      ci.sample();
      #10 ;
    end
  end
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
    //#100;
    //$finish();
  end
endmodule
