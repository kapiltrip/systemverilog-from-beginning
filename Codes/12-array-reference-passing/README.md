# Part 12 — Array reference passing

EDA Playground: [https://edaplayground.com/x/ADYn](https://edaplayground.com/x/ADYn)

This part extends `ref` arguments from scalar values to a fixed unpacked array. A function receives the caller's array and initializes every element in place.

## Saved playground settings

- Simulator: Riviera Pro 2025.04
- Compile options: `-timescale 1ns/1ns`
- Run options: `+access+r`

## Corrected self-checking source

The exact captured EDA Playground source, including the orphan closing comment `*/` after `endmodule`, is preserved in [`testbench.sv`](testbench.sv). That token caused the current Edge run to fail with Riviera-Pro error `VCP2000`. The corrected verification version is rendered here and remains available as [`self_checking_testbench.sv`](self_checking_testbench.sv); it removes only that stray token and adds element-level self-checks.

~~~systemverilog
// Code your testbench here
// or browse Examples
// A fixed unpacked array can be initialized through a ref formal argument.
`timescale 1ns/1ps

module tb;
  bit [3:0] res[16];
  int error_count;

  function automatic void init_arr(ref bit [3:0] a[16]);
    for (int i = 0; i < 16; i++) begin
      a[i] = i;
    end
  endfunction

  task automatic check_value(
    input string label,
    input int actual,
    input int expected
  );
    if (actual !== expected) begin
      error_count++;
      $error("FAIL: %s expected %0d, got %0d", label, expected, actual);
    end
  endtask

  initial begin
    $timeformat(-9, 0, " ns", 8);
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
    error_count = 0;

    init_arr(res);
    $display("[%0t] res after init_arr(ref): %0p", $time, res);
    for (int i = 0; i < $size(res); i++) begin
      check_value("array element after ref initialization", res[i], i);
    end

    if (error_count == 0) begin
      $display("PASS: ref function initialized all array elements");
    end
    else begin
      $display("FAIL: %0d check(s) failed", error_count);
      $fatal(1, "Part 12 self-check failed");
    end

    $finish;
  end
endmodule
~~~

## Preserved EDA Playground source

This block is the captured EDA Playground testbench, including the orphan closing comment after `endmodule` that was present in the page. It is stored unchanged as [`testbench.sv`](testbench.sv); the self-checking code above is the separate corrected verification version.

~~~systemverilog
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
~~~

## Answers and notes

- `res[16]` is a fixed unpacked array containing sixteen four-bit elements.
- The `ref` formal `a[16]` has the same unpacked shape as `res`, so assignments to `a[i]` update `res[i]` directly.
- The function returns `void` because its purpose is the side effect on the referenced array rather than a scalar return value.
- Passing the complete array avoids copying sixteen elements onto a task/function stack for this operation.
- The final loop checks every index, which proves that the reference update reached the caller's array rather than only changing a local temporary.

## Detailed discussion

### Matching packed and unpacked dimensions

`bit [3:0] res[16]` has two layers:

- `[3:0]` is a packed four-bit element.
- `[16]` is an unpacked array dimension with indices 0 through 15.

The formal argument `ref bit [3:0] a[16]` must preserve both parts of that shape. The function can then use `a[i]` exactly as the caller uses `res[i]`.

The initialization loop assigns the index to each four-bit element, so the expected aggregate is `'{0, 1, 2, ..., 15}`.

### Why the stray `*/` mattered

The saved Edge tab showed the active module ending at `endmodule` followed by `*/`. There was no matching `/*` in the live source. Riviera-Pro therefore reported:

```text
ERROR VCP2000 "Syntax error. Unexpected token: *[O_MUL]." testbench.sv 18 2
```

That error is unrelated to `ref` semantics. Removing the unmatched comment terminator restores the intended source shown above.

### Expected result

| Time | Observation |
| ---: | --- |
| 0 ns | `init_arr(res)` writes 0 through 15 into the caller's array. |
| 0 ns | The aggregate display shows sixteen initialized elements. |
| 0 ns | All sixteen element checks pass and the testbench prints PASS. |

The local Icarus Verilog 12 installation does not support reference ports or unpacked array subroutine arguments. The saved Edge run of the uncorrected page therefore failed at parsing before it could test the intended behavior; the repository copy records and fixes that concrete source error.

### Points to remember

- A `ref` array formal shares the caller's array storage.
- Packed element width and unpacked array shape are both part of compatibility.
- A void function can be useful when the meaningful result is a referenced-object update.
- Syntax errors should be separated from simulator feature limitations when diagnosing a failed run.
