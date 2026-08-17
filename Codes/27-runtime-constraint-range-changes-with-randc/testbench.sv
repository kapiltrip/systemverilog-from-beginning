// Code your testbench here
// or browse Examples
// Code your testbench here
// or browse Examples
//WEIGHTED DESTRIBUTION 

class generator ; 
  randc bit [3:0] a ,b ; 
  bit [3:0] y; 
  int min ; 
  int max; 
  function void pre_random(input int min , input int max);
    this.min= min ; 
    this.max=max; 
    
  endfunction 
  constraint pre_rand {
    a inside {[min:max]} ; 
    b inside {[min: max]}; 
    
  }
  function void post_randomize(); 
    $display("The value of a , and b post randomization is : %0d , %0d " , a,b );
  endfunction 
endclass
module tb; 
  generator g; 
  initial begin
    g=new(); 
    g.pre_random(3,8);
    $display("SPACE 1 ");
    for(int i =0; i<10 ; i++)begin
      //g.pre_random(3,12); 
      g.randomize(); 
      #10; 
      // I AM NOT CALLING POST RANDOMIZE RATHER ITS GETTING CALLED ITSELF 
      //rand and randc : will create a bucket and it have an idea of the constraint 
      // but if i changed the constraint in the run time we could see the repetition 
      //ALSO why am i calling it run time constraint changing 
    end
      $display("SPACE 2 ");
    g.pre_random(3,12);
    
      for(int i =0; i<10 ; i++)begin
        //g.pre_random(3,8); 
        g.randomize(); 
        #10; 
      end
    end
endmodule 
