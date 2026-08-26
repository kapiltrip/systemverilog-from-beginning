# Project 02 — Counter P1 and Functional Coverage

[Functional Coverage home](../../README.md) · [Projects index](../README.md) · [Section 10 plates](../../PLATES.md)

| Playground field | Value |
|---|---|
| EDA Playground name | `FC S10 V142 - Counter P1(1)` |
| Stable playground | [h54t](https://edaplayground.com/x/h54t) |
| Course position | Section 10, Video 142 — Counter P1 |
| Simulator | Siemens QuestaSim-64 2025.2 |
| Compile / run options | `-timescale 1ns/1ns` / `-voptargs=+acc=npr` / custom `run.do` |
| Open EPWave after run | On in the saved playground settings |
| Captured source | `design.sv` (30 lines), `testbench.sv` (194 lines), `run.do` (5 nonblank lines; trailing blank retained in the captured pane) |

This archive contains the single used V142 Counter P1 playground representing
the Counter project. The source panes were captured from the saved `h54t` page
and copied with horizontal whitespace normalized; comments and executable
statements are retained. The unused Counter P2/P3 plates are not duplicated
here, and the project remains outside `SV Functional Coverage/Codes`.

## Live verification

The saved page was run in its own Questa configuration without changing the source panes. The result pane ended with `Done` and reported:

| Stage | Errors | Warnings |
|---|---:|---:|
| qrun | 0 | 0 |
| vlog | 0 | 0 |
| vopt | 0 | 1 |
| vsim | 0 | 0 |
| Total | 0 | 1 |

The sole warning is Questa's optimization warning that `+acc` disables some optimizations. The simulation reached `$finish` at `testbench.sv(192)` at `3995 ns`. The log contained 200 generator messages, 200 driver handshakes, and 400 monitor messages.

`run.do` does contain `coverage report -cvg -details;`, and the covergroup is sampled by the monitor. However, this exact EDA result pane did not emit a coverage table, percentage, or bin summary. This README therefore records no invented coverage score: the run proves clean compilation/elaboration and completion, not numeric coverage closure.

## Exact browser design

```systemverilog
`timescale 1ns/1ps

// Video 142: loadable 4-bit up-counter DUT.
module counter (
  input wire clk, rst , up , load ,
  input wire [7:0] loadIn ,
  input wire [7:0] x ,
  output reg [7:0] y
);
  always @(posedge clk)begin
    if(rst)
      y<= 8'd0 ;
    else begin
      if(load) begin
        y<= loadIn ;
      end
      else if(up )
        y<= y+1 ;
      else
        y<= y-1 ;

    end

  end
endmodule
interface counter_if();
  logic clk , rst , up , load ;
  logic [7:0] loadIn ;
  logic [7:0] y ;
endinterface
```

Local source: [design.sv](design.sv).

## Exact browser testbench and coverage model

```systemverilog
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
```

Local source: [testbench.sv](testbench.sv).

## Exact Questa report script

```tcl
# Shared Questa run script for every Sections 6-10 boilerplate.
# Each saved EDA Playground copy contains this same script.
run -all;
coverage report -cvg -details;
quit -f;
```

Local source: [run.do](run.do).

## Discussion

### Why is the saved counter actually 8-bit up/down rather than 4-bit up-only?

`counter` is an 8-bit, active-high synchronous-reset counter with priority `reset > load > up > decrement`. On a rising edge, reset loads zero; otherwise `load` loads `loadIn`; otherwise `up == 1` increments; otherwise the 8-bit value decrements. Arithmetic naturally wraps modulo 256. Although the video comment calls it a “loadable 4-bit up-counter,” every data port and `y` are `[7:0]`, and `up == 0` selects decrement, so the implementation is an 8-bit loadable up/down counter. The input `x` is tied to `8'd0` in the testbench and is not read by the RTL.

### Is `-> done` the trigger for `@(done)`?

Yes. `@(done)` blocks the generator until the named event is triggered. After
the driver removes the transaction from the mailbox and reaches a positive
clock edge, `-> done` triggers that event and releases the generator. This is a
one-item-at-a-time synchronization handshake; the event does not store data
and a trigger can be missed if no process is waiting at that instant.

### Answers to every inline code comment/question

| Source marker | Answer |
|---|---|
| `// Video 142: loadable 4-bit up-counter DUT.` | This is the lesson label, not an accurate width/behavior summary. The captured RTL is 8-bit and decrements when `up` is low; the code itself was preserved. |
| `class transaction ; // a variable for input and o/p` | `transaction` is a class type used as a packet of stimulus and sampled output fields. It is an object, not a hardware signal; the comment is shorthand for that input/output bundle. |
| `bit [7:0] y ; // the o/p` | `y` is the monitor's sampled output snapshot. It is overwritten from the virtual interface before each sample; the scoreboard currently does not check it. |
| `void'(t.randomize()); // fixed: explicit void cast` | `randomize()` returns a success bit. The explicit `void'(...)` cast intentionally discards that return value, which removes the unused-result warning; because there are no constraints, `loadIn` is simply randomized over its 8-bit domain. A checker would normally test the return value. |
| `@(done);  // -> done . i.g its trigger ?` | Yes: this is an event handshake. The generator waits for `done`, and the driver executes `-> done` after it has consumed the transaction and waited for a clock edge. It throttles generation to one mailbox item per driver handshake. An event is synchronization, not a transaction queue. |
| `cp_loadIn: coverpoint ... // fixed: named for cross` | Naming the coverpoint lets the cross refer to it through `binsof(cp_loadIn)` and makes the coverage report readable. |
| `bins rst_low = {0}; // fixed: replaced ] with }` | Covergroup bin values use braces. `{0}` is the valid one-value bin; a closing square bracket would be a syntax error. |
| `cp_load: coverpoint ... // fixed: comma to dot; named for cross` | The declaration uses a colon after the coverpoint name (`cp_load:`), and the name is then legal in the cross. The corrected form is syntactically and semantically appropriate. |
| `cross_ld_loadin: cross cp_load, cp_loadIn { // fixed: cross named coverpoints` | The cross combines the named `load` and `loadIn` coverpoints. It asks which data ranges occur when each load state is sampled. |
| `ignore_bins unused_when_load_low = binsof(cp_load) intersect {0}; // fixed: use named load coverpoint` | This intentionally removes every cross tuple with `load == 0`; `loadIn` is meaningful to the DUT only for a load cycle. It does not claim that load-low behavior is covered. |
| `endgroup // fixed: close covergroup` | This terminates the `c` covergroup declaration. The monitor's constructor then creates its per-instance covergroup object. |
| `function new(mailbox mbx); // fixed: moved below covergroup declaration` | The constructor assigns the mailbox and calls `c = new()`. Placing it after the declaration makes the covergroup member available to construct; it is still a normal class constructor. |
| `counter dut (...); // fixed: connect vif with correct widths` | The connected `clk`, controls, `loadIn`, and `y` all match the interface widths. `x` is not in `counter_if`, so the testbench ties the unused DUT input to `8'd0`; compilation confirms the connections are legal, not that `x` has functional meaning. |
| `# Shared Questa run script...` / `# Each saved EDA Playground copy...` | These comments document that the script is intentionally shared. `run -all` runs until the testbench calls `$finish`; `coverage report -cvg -details` requests covergroup details; `quit -f` exits the batch simulator. The captured result accepted the script and completed. |

### Functional and coverage review

- Reset is synchronous because it is tested inside `always @(posedge clk)`. It has highest priority, followed by load, increment, and decrement.
- `load` and `up` are not initialized before the `#60` delays in the three testbench processes. They therefore begin as `X`; at a clock edge coincident with reset release or the first control assignment, the result can depend on event ordering. Explicit initialization and edge-aligned driving would remove that ambiguity.
- The monitor samples fields and calls `c.sample()` before waiting for its next positive edge. At a positive edge it can observe `y` before the DUT's nonblocking assignment updates it. That is a scheduling/race limitation of the captured testbench, not a compile failure.
- `cp_loadIn`, reset, load, and `y` are covered. `up` has a transaction field but no coverpoint, and there are no crosses for reset/up, load/up, or output behavior. The `loadIn` cross deliberately ignores load-low samples.
- The generator randomizes only `loadIn`. The driver drives only `vif.loadIn`; the separate initial blocks drive reset, load, and up. The transaction's `load`, `rst`, and `up` fields are therefore observation fields in practice, not generated controls.
- The generator reuses one transaction object, but waits for the driver's `done` event before the next randomization, so the simple one-item-at-a-time handshake avoids overwriting the item before the driver gets it. A pipelined environment would need a fresh object or clone per mailbox entry.
- The monitor also reuses one transaction object for every mailbox entry. That is harmless for the current no-op scoreboard, but it would alias all queued observations in a real checker; a monitor should allocate or copy a new object per sample.
- The scoreboard receives transactions but has an empty body and never compares expected versus observed `y`. `temp` is unused. There are no assertions. Consequently, a clean run does not prove count sequencing, reset behavior at every edge, wraparound, or load priority.
- The environment uses `join_any`, so it returns when the finite generator finishes while driver/monitor/scoreboard threads continue until the later `$finish`. The perpetual clock is also terminated only by `$finish`; the observed stop at `3995 ns` is intentional testbench control.
- The coverpoint ranges `[0:84]`, `[85:169]`, and `[170:255]` partition the full 8-bit domain without gaps or overlaps. They are valid bins, but the saved result did not print hit counts or a percentage.

### Does the verified run prove counter correctness?

It proves that the captured source elaborates under Questa 2025.2, the `tb` top-level can run to `$finish`, and the event/mailbox processes make progress for 200 generated items. It does not prove the RTL's functional correctness or a numeric functional-coverage goal because the captured testbench has no active scoreboard/assertions and the result pane exposed no coverage summary.

## Capture fingerprints

These are SHA-256 fingerprints after normalizing CRLF to LF, replacing non-breaking indentation with spaces, removing trailing horizontal whitespace, and trimming the final newline:

| Pane | SHA-256 |
|---|---|
| `design.sv` | `93f6ac50147c0cbc18b5465bcf8cfa9cef281bf4b4527b60842223d8321f1c1c` |
| `testbench.sv` | `5b750ad3c4c24bef2bd2b572bbe4dac67c3b1ae06dcdd2664e51eaa3835ff4fe` |
| `run.do` | `e4bd4c475fc347bea28d17c7f268c6c0187d14ea1c7499aaae3f9e8cb732ac19` |

These fingerprints let the archived files be compared back to the captured `h54t` panes without changing the playground or any Section 10 index.
