# Part 11 — Sampled and Vector System Functions

[← Part 10](../10-gated-past-sampled-values/README.md) · [SV Assertions index](../README.md) · [Part 12 →](../12-clocking-events-and-disable-iff/README.md)

| Playground field | Value |
|---|---|
| EDA Playground Name | `SVA 11 - Sampled and Vector System Functions` |
| Stable playground | [JE4r](https://edaplayground.com/x/JE4r) |
| Simulator | Siemens Questa 2025.2 |
| Live result | 0 errors; sampled transition and vector-query results displayed each positive edge |
| EPWave | Disabled |

## Exact browser source

~~~systemverilog
// Code your testbench here
// or browse Examples
module temp; 
  reg a =0; 
  reg clk =0;
  reg [3:0] b;
  reg [3:0] c =4'b000x; 
  
  always #5 clk = ~clk ; 
  initial begin
    for(int i =0;i<15;i++)begin
      a=$urandom_range(0,1); 
      b=$urandom_range(0,15); 
      c=$urandom_range(0,15);
      @(posedge clk);
    end
  end
  always @(posedge clk)begin
    begin
      //complete of one hot will give me one cold or not 
      $display("Value of a is %0b changed is %0b a stabe is   %0b  at time %0t" ,a, $changed(a) , $stable(a) , $time  );
      $display("Value of b is %4b  one hot zero  b is %0d and onehot %0d at time %0t" ,b ,  $onehot0(b) , $onehot(b) , $time  );
      $display("Value of b is %4b  one cold encoded b is %0d  at time %0t" ,b , $onehot(~b) , $time  );
      $display("-------------------------------------------------------------------------------------------------------");
      $display("Value of %4b and is unknown present -> %0b  at time %0t" ,c , $isunknown(c), $time  );
      $display("-------------------------------------------------------------------------------------------------------");
      // One cold , presence of 1 zero and rest all 1 
      // count bits will return in signal having no of matching value the signal and second will be the variable to match  
      $display("count of  0 in c  i.e %4b is  %4b   at time %0t" ,c , $countbits(c, 0), $time  );
      $display("Count 1 in the number %4b is %0d at the time %0t" , c,$countones(c) , $time); 
      //$display("count of x in c i.e %4b is %0d at time %0t" ,c , $countbits(c , x), $time  );

    end
  end
    initial begin
    $dumpfile("dump.vcd"); 
    $dumpvars ; 
    #200; 
      $finish();
  end
endmodule
~~~

Local source: [testbench.sv](testbench.sv). No substantive browser design source was present.

## Two different function families

This lesson combines functions that answer different kinds of questions:

| Family | Functions in the source | Meaning |
|---|---|---|
| sampled history | `$changed`, `$stable` | compare current and previous clocked samples |
| vector inspection | `$onehot`, `$onehot0`, `$isunknown`, `$countbits`, `$countones` | inspect the bits of one expression now |

The vector inspection functions do not inherently require a clock. The sampled history functions do require a sampling context; here it is inferred from `always @(posedge clk)`.

## `$changed` and `$stable`

`$changed(a)` is true if the sampled value differs from the previous sampled value. `$stable(a)` is true if it is the same. For a known scalar after valid history exists, they are logical complements.

Four-state values still matter: a change involving `X` or `Z` counts as a value change when the four-state samples differ. First-clock results use default sampled history, so do not treat them as proof of a real pre-simulation transition.

## `$onehot` versus `$onehot0`

For a vector `b`:

- `$onehot(b)` is true when **exactly one** bit is `1`;
- `$onehot0(b)` is true when **zero or one** bits are `1`.

For four bits:

| `b` | `$onehot(b)` | `$onehot0(b)` |
|---|---:|---:|
| `0000` | 0 | 1 |
| `0001` | 1 | 1 |
| `0100` | 1 | 1 |
| `0101` | 0 | 0 |
| `1111` | 0 | 0 |

`$onehot0` is not “one cold.” It means *at most one hot bit*.

## Answer: does complementing one-hot test one-cold?

The source asks: “complete [complement] of one hot will give me one cold or not.” For a fixed-width vector whose bits are all known, yes:

~~~systemverilog
$onehot(~b)
~~~

is true exactly when `b` contains one `0` and every other bit is `1`. Complementing swaps every known `0` and `1`; therefore “one hot in `~b`” is equivalent to “one cold in `b`.”

Examples for four bits:

| `b` | `~b` | `$onehot(~b)` | One-cold? |
|---|---|---:|---|
| `1110` | `0001` | 1 | yes |
| `1011` | `0100` | 1 | yes |
| `1111` | `0000` | 0 | no zero bits |
| `1001` | `0110` | 0 | two zero bits |

The qualification “all bits known” matters. If `b` contains `X` or `Z`, `~b` retains unknown information and an exact one-hot fact is not established. A defensive rule checks knownness explicitly:

~~~systemverilog
one_cold_known: assert property (@(posedge clk)
  !$isunknown(b) && $onehot(~b)
);
~~~

## `$isunknown`

`$isunknown(c)` returns true when any bit of `c` is `X` or `Z`. It is equivalent in intent to asking whether the vector contains a four-state uncertainty, not whether the vector as a whole equals the literal `'x`.

The declaration initializes `c` to `4'b000x`, but the random loop overwrites `c` before its first `@(posedge clk)` wait. Therefore the live output may never demonstrate `$isunknown(c)==1`; the initial unknown exists, but the display does not necessarily sample it.

A deterministic demonstration would delay the first overwrite:

~~~systemverilog
initial begin
  c = 4'b000x;
  @(posedge clk);       // allow one display with X
  c = 4'b0011;
end
~~~

## `$countbits` and `$countones`

`$countbits(expression, control_bit...)` returns how many bits match any listed four-state control value. Examples:

~~~systemverilog
$countbits(c, 1'b0)          // count zeros
$countbits(c, 1'b1)          // count ones
$countbits(c, 1'bx, 1'bz)    // count unknown/high-impedance bits
~~~

`$countones(c)` is the convenient count of `1` bits. For a fully known vector:

~~~systemverilog
$countones(c) == $countbits(c, 1'b1)
~~~

The commented source uses `$countbits(c, x)`. A bare `x` is parsed as an identifier, not as the X literal. Write `1'bx` or `'x`. Because the return value is a count, `%0d` is clearer than the source's `%4b`, though both can display a value.

## Stimulus-order caution

The randomizer loop and display block both resume at `posedge clk` in Active. Their relative order is not a portable stimulus contract. To make the displayed random value deterministic, generate it on `negedge clk` and inspect it on `posedge clk`.

## Revision checks

1. Why is `$onehot0(b)` different from a one-cold test?
2. Under what qualification is `$onehot(~b)` a valid one-cold test?
3. Why might this test never display the initial `X` in `c`?
4. How do you count both X and Z bits?
5. What history does `$changed` compare?

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [IEEE Std 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F24/documentation/1800-2017.pdf) — Clauses 16.9.3 and 20.9
