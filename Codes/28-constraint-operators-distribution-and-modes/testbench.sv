// Code your testbench here
// or browse Examples
//types of operator 
// 1) -> implication operator 
// 2) -> equivalence <-> working with control signal , and  if else 
// turning on and off the constraints 

class generator ; 
  randc bit [3:0] a; 
  rand bit ce;
  rand bit rst; 
  rand bit wr; //write 
  rand bit readen ; // readenable 
  rand bit [3:0] raddr , waddr ; 
  
  constraint control_rst{
    rst dist {0:= 80 , 1:= 20} ;  // what if i do 40 for 1 in rst 
    
  }
  constraint control_ce{
    ce dist {1:= 80 , 0 := 20 }; 
  }
  constraint control_rst_ce{
    // implication 
    (rst ==0 ) -> (ce == 1 ) ; 
  }
  constraint wr_readenable{
    //equivalence operator 
    (wr==1) <-> (readen==0); 
  }
  //constraint on wr and readen // both 50 50 distribution 
  constraint wr_const{
    wr dist {0 := 50 , 1:= 50} ; 
  }
  constraint readen_const {
    readen dist {0 := 50 , 1:= 50 }; 
  }
  constraint write_read{
    if(wr==1){
      waddr inside {[11:15]};
      raddr ==0; 
      
    }else {
      waddr ==0; // we have to do == not =  
      raddr inside {[11:15]}; // inside th ehigher valued range 
      
    }
  }
endclass
module tb; 
  generator g ; 
  initial begin
    g=new(); 
    g.write_read.constraint_mode(0) ; // 1-> constraint on 0 - > constraint off 
    $display("The condition of the constraint is %0d" , g.write_read.constraint_mode());
    for(int i =0 ; i<10 ; i++)begin
      assert(g.randomize()) else $display("Randomization failed ") ; 
      $display("The values for rst is %0b ,and ce is %0b  " , g.rst, g.ce); 
      $display("The values for write is %0b ,and readEnable  is %0b  " , g.wr, g.readen); 
      $display("The values for raddr is %0d ,and waddr  is %0d  " , g.raddr, g.waddr); 
      
    end
  end
endmodule
