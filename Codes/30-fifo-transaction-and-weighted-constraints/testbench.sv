// Code your testbench here
// or browse Examples
//Transaction class  will hold all the input and output together in a single class
class Transaction ;
  bit clk;  // it should not be random rather, rst can be random value sometimes

  bit rst;
  rand bit wr_en,rd_en;
  rand bit [7:0] wr_data;
  bit [7:0] rd_data;

  bit empty;
  bit full;

  constraint control_wr_en{
    wr_en dist {0:=30 ; 1:= 70 ; }
  }
  constraint control_rd_en{
    rd_en dist {0 := 30 ; 1:= 70 ; }
  }
  constraint write_read{
    wr_en != rd_en ;  // why i didnt used implication here, or if else

  }

endclass
