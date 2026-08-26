`timescale 1ns/1ps

// Video 142: direct counter testbench and first-pass coverage plan.

class transaction ; // a variable for input and o/p
  rand bit [7:0] loadIn ;
  bit load ;
  bit rst ;
  bit up ;
  bit [7:0] y ; // the o/p
endclass

class generator ;
  transaction t;
  mailbox mbx;
  event done ;
  integer i ;
  function new(mailbox mbx ) ;
    this.mbx = mbx ;
  endfunction
  task run();
    t = new();
    for(int i =0 ; i< 200 ; i++)begin
      void'(t.randomize()); // fixed: explicit void cast
      mbx.put(t);
      $display("[GEN] : Data sent to driver" ) ;
      @(done);  // -> done . i.g its trigger ?

    end
  endtask
endclass

class driver;
  mailbox mbx ;
  transaction t;
  event done ;
  virtual counter_if vif;
  function new(mailbox mbx) ;
    this.mbx= mbx ;
  endfunction
  task run();
    t = new();
    forever begin
      mbx.get(t);
      vif.loadIn<= t.loadIn ;
      $display("[DRV] : Trigger Interface ");
      @(posedge vif.clk ) ;
      -> done ;

    end
  endtask
endclass
class monitor ;
  virtual counter_if vif;
  mailbox mbx;
  transaction t;
  task run();
    t= new() ;
    forever begin
      t.loadIn =vif.loadIn ;
      t.y = vif.y;
      t.rst = vif.rst ;
      t.up = vif. up ;
      t.load = vif. load;
      c.sample();
      mbx.put(t);
      $display("[MON] : DATA SENT TO SCOREBOARD ");
      @(posedge vif.clk) ;
    end
  endtask

  covergroup c ;
    option.per_instance = 1;
    cp_loadIn: coverpoint t.loadIn { // fixed: named for cross
      bins lower = {[0:84]};
      bins mid = {[85:169]};
      bins higher = {[170 : 255]};
    }
    coverpoint t.rst{
      bins rst_low = {0}; // fixed: replaced ] with }
      bins rst_high = {1};

    }
      cp_load: coverpoint t.load { // fixed: comma to dot; named for cross
        bins ld_low = {0};
        bins ld_high = {1};
      }
      coverpoint t.y {
      bins lower = {[0:84]};
      bins mid = {[85:169]};
      bins higher = {[170 : 255]};
    }
      cross_ld_loadin: cross cp_load, cp_loadIn { // fixed: cross named coverpoints
        ignore_bins unused_when_load_low = binsof(cp_load)   intersect {0} ;      // fixed: use named load coverpoint
      }

endgroup // fixed: close covergroup
    function new(mailbox mbx); // fixed: moved below covergroup declaration
    this.mbx = mbx;
    c = new();
  endfunction
endclass
class scoreboard ;
  mailbox mbx ;
  transaction t;
  bit [7:0] temp ;
  function new(mailbox mbx ) ;
    this.mbx = mbx ;
  endfunction
  task run();
    t=new() ;
    forever begin
      mbx.get(t);

    end
  endtask
endclass
class environment;
  generator gen ;
  driver drv ;
  monitor mon;
  scoreboard sco ;
  virtual counter_if vif ;
  mailbox genToDriver ;
  mailbox monToScoreboard ;
  event gddone ;
  function new(mailbox genToDriver , mailbox monToScoreboard) ;
    this.monToScoreboard= monToScoreboard ;
    this.genToDriver = genToDriver ;
    gen = new(genToDriver);
    drv = new(genToDriver) ;
    mon = new(monToScoreboard) ;
    sco = new(monToScoreboard) ;

  endfunction
  task run ();
    gen.done = gddone ;
    drv.done = gddone ;
    drv.vif = vif ;
    mon.vif = vif ;
    fork
      gen.run();
      drv.run();
      mon.run();
      sco.run();

    join_any
  endtask
endclass

module tb;
  environment env ;
  mailbox genToDriver;
  mailbox monToScoreboard ;
  counter_if vif();
  counter dut (.clk(vif.clk), .rst(vif.rst), .up(vif.up), .load(vif.load), .loadIn(vif.loadIn), .x(8'd0), .y(vif.y)); // fixed: connect vif with correct widths
  always #5 vif.clk = ~vif.clk ;
  initial begin
    vif.clk = 0 ;
    vif.rst = 1;
    #50 ;
    vif.rst =0 ;

  end
  initial begin
    #60 ;
    repeat (20) begin
      vif.load = 1 ;
      #10 ;
      vif.load = 0 ;
      #100;

    end
  end
  initial begin
    #60 ;
    repeat (20) begin
      vif.up = 1 ;
      #70 ;
      vif.up = 0 ;
      #70;

    end
  end
  initial begin
    genToDriver= new();
    monToScoreboard = new();
    env= new(genToDriver , monToScoreboard);
    env.vif = vif ;
    env.run();
    #2000 ;
    $finish();
  end
endmodule
