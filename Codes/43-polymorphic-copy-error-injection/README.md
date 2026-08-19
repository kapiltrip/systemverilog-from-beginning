# Part 43 — Polymorphic Copy for Error Injection

[← Part 42](../42-error-injection-with-inheritance/README.md) · [Learning index](../README.md) · [Part 44 →](../44-monitor-scoreboard-separate-mailboxes/README.md)

| Saved-playground field | Value |
|---|---|
| EDA Playground Name | **Untitled at capture**; repository title: `SV 43 - Polymorphic Copy for Error Injection` |
| Stable playground | [F5HU](https://edaplayground.com/x/F5HU) |
| Saved code ID | `7366062` |
| Simulator | Siemens Questa 2025.2 |
| Compile / run options | `-timescale 1ns/1ns` / `-voptargs=+acc=npr` |
| Open EPWave after run | Unchecked |
| Verified live result | **Pass:** 16 generated transactions; the driver receives `a=0, b=0` 16 times; finish at 320 ns |

Part 42 attempted to pass a derived `error` object through a base `transaction` handle, but its missing `copy()` method stopped compilation and a later base-class `new()` would have discarded the derived object. This next playground fixes both ideas: the base class declares a `virtual copy()` method, the derived class overrides it, and `generator.run()` no longer replaces `g.t`.

## Object flow

~~~text
error err
   │
   └── g.t = err              base handle, derived object
          │
          ├── t.randomize()   random values are visible in [GEN]
          │
          └── t.copy()        virtual dispatch selects error.copy()
                    │
                    ├── creates a new transaction
                    └── forces copied a=0 and b=0
                              │
                              ▼
                         mailbox → driver → interface → DUT
~~~

## Questions from the code, explained

### Why are random values generated but zeros sent to the driver?

**Question in the source**

> `// value is getting generated but the copy is sending 0 to the object handle`

The two displays are observing different objects:

1. `t.display()` runs on the derived `error` object held through `generator.t`, so it prints the randomized values.
2. `mbx.put(t.copy)` is a virtual call. Because the runtime object is an `error`, SystemVerilog dispatches to `error.copy()`.
3. That override creates a new `transaction` and explicitly assigns `copy.a = 0` and `copy.b = 0`.
4. The driver receives that independent zero-valued snapshot, not the randomized source object.

The verified run makes the distinction visible: generator pairs vary across all 16 iterations, while every driver display is `a=0, b=0`.

### What is the use of `d.aif = aif`?

**Question in the source**

> `d.aif=aif ; // what is the use of this`

The interface instance `aif` in `tb` is static HDL structure, while `driver.aif` is a virtual-interface variable inside a class object. The assignment binds that class variable to the concrete interface instance. After binding, the driver can wait on `aif.clk` and drive `aif.a` and `aif.b`. Without it, `d.aif` remains null and the driver cannot access the DUT-facing signals.

## Constraint injection versus copy-based injection

The derived constraint is commented out:

~~~systemverilog
//constraint data_c {a ==0 ; b==0; }
~~~

Therefore randomization itself is not forcing zeros. The error is injected later by the overridden copy policy. Both techniques can create error traffic, but they mean different things:

- a constraint controls the values on the randomized source object;
- the overridden `copy()` transforms the object while it crosses the generator-to-driver boundary.

This lesson deliberately demonstrates the second technique.

## Why `g.t = err` is essential

`generator.t` is declared as a `transaction` handle, but it may point to an `error` object because `error extends transaction`. The assignment preserves the derived runtime object. Since `copy()` is virtual, a call through that base handle still selects the derived override.

The constructor initially creates a base object with `t = new()`, but `g.t = err` replaces that handle before `g.run()` starts. Unlike Part 42, this run task does not execute another `t = new()` and therefore does not erase the injected derived object.

## Important limitation of this copy method

`error.copy()` returns a newly allocated base `transaction`, not a new `error`. This is sufficient for delivering the forced zero values to the current driver, but it does not preserve the dynamic type. A general polymorphic clone would allocate an `error` object and return it through the base return type, so later virtual behavior and derived members remain available.

## Design code

~~~systemverilog
// Code your design here
// Code your design here
// Code your design here
// Code your design here
module add(
  input [3:0]a,b,
  input clk,
  output reg [4:0] sum
);
  always @(posedge clk)begin
       sum <= a+b;

  end
endmodule
~~~

## Testbench code

~~~systemverilog
// Code your testbench here
// or browse Examples
//To inject error form generator class to driver and hence dut
//DEEP COPY OF A TRANSACTION
/*
1) independent object
2) capability to inject an error form gen to driver */
class transaction ;
  randc bit [3:0] a;
  randc bit [3:0] b;
  bit [4:0] sum;
  function void display();
    $display("value of a is %0d \t and value of b is %0d \t and their sum is %0d " , a,b, sum );
    endfunction
  virtual function transaction copy ();  // making a new handle of type transaction
    copy=new();                  //copying the current objects attributes to that handle
    copy.a= this.a;
    copy.b=this.b;
    copy.sum=this.sum;
  endfunction  // value is getting generated but the copy is sending 0 to the object handle
endclass
//inject the error
class error extends transaction ;
  //constraint data_c {a ==0 ; b==0; }
   function transaction copy ();  // making a new handle of type transaction
    copy=new();                  //copying the current objects attributes to that handle
    copy.a= 0;
    copy.b=0;
    copy.sum=this.sum;
   endfunction
endclass

class generator;
  transaction t;
  mailbox #(transaction) mbx;
  event genDone ;
  //CONSTRUCTOR FOR GENERATOR
  function new (mailbox #(transaction) mbx) ;
    this.mbx=mbx; //
    t=new(); //single space so randc can remember its history and we can get intended behaviour
  endfunction


  task run();
    //t=new();//single object

    for(int i =0 ; i<16;i++ )begin
      //t=new(); // we need  a deep copy INDEPENDENT SPACE OBJECT

      assert(t.randomize()) else $display("Randomization failed ");
      $display("[GEN] : DATA SENT TO DRIVER ");
      t.display();
      mbx.put(t.copy);  //im not sending the real transaction obj instead im sending the copy
      #20;
      $display("[GEN] : DATA ");
    end
     ->genDone;
    endtask
endclass


class driver;
  virtual add_interface.DRV aif;
  mailbox #(transaction) mbx;
  transaction container;
  event next ;
  function new(mailbox #(transaction) mbx);
    this.mbx=mbx;

  endfunction

   task run();
   forever begin
     mbx.get(container); // transaction type container

     @(posedge aif.clk);
     aif.a=container.a;
     aif.b=container.b;
     $display("[DRV] : INTERFACE TRIGGERED ");
     container.display();  // display the value received form the mailbox
     ->next; // event triggered next ;

    end
   endtask
endclass


module tb;
  add_interface aif();
  error err;

  driver d;
  generator g;
  event done ;

  mailbox #(transaction) mbx;
  initial begin
    aif.clk<=0;
  end
  always #10 aif.clk = ~ aif.clk ;

  add dut(
    .a(aif.a),
    .b(aif.b),
    .clk(aif.clk),
    .sum(aif.sum)
  );

  initial begin
    mbx=new();
    g=new(mbx); // TRANSACTION OJBECT will be created here, this will be removed
    d=new(mbx);
    err=new();

    g.t=err; // will send an error injecting of error

    d.aif=aif ; // what is the use of this
    done = g.genDone ;
  end
  initial begin
    fork
      g.run();
      d.run();

    join_none //non blocking
    wait(done.triggered);
    $finish();
  end
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;

  end
  /*
  initial begin
    #400;
    $finish();

  end
  */
endmodule

interface add_interface;
  logic [3:0] a ; //equivalent logic type defined in interface
  logic [3:0] b;
  logic [4:0] sum;
  logic clk ;
  modport DRV (output a,b,input sum, clk );// A AND B will have o/p direction rest all r inputs

endinterface
~~~

## What happened when it ran

The refreshed playground compiled with 0 errors. Questa reported one optimization warning because `+acc` reduces optimization. The simulation produced 16 generator displays with changing randomized values and 16 driver displays with `a=0` and `b=0`, then finished at 320 ns.

This proves that virtual dispatch and the overridden copy transformation work. It does not yet verify the DUT result because this playground still has no monitor or scoreboard; Part 44 adds those layers.

## Points to remember

- A base-class handle can refer to a derived object.
- A method must be virtual for a call through the base handle to select the derived override.
- Do not overwrite an injected derived handle with a later base-class `new()`.
- Copy-based error injection can transform data without changing the original randomized object.
- A copy that allocates the base type preserves values but not necessarily the derived runtime type.
- The virtual interface assignment `d.aif = aif` binds the class driver to the concrete interface instance.
- Passing stimulus through a driver is not the same as checking a DUT response.

## References

[IEEE 1800-2023 SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/) · [Accellera class handles and copy material](https://www.accellera.org/images/eda/sv-ec/att-0051/01-sv3.1_donation_VeraLite.pdf) · [Accellera SystemVerilog interfaces paper](https://www.accellera.org/images/eda/sv-bc/att-10226/Interfaces_Future.pdf)
