# Part 06 — Array iteration

EDA Playground: [https://edaplayground.com/x/GK3p](https://edaplayground.com/x/GK3p)

This part compares `foreach` with `repeat` while filling a fixed-size unpacked array.

## Complete testbench code

The complete source is rendered here and remains available as [`testbench.sv`](testbench.sv).

~~~systemverilog
// Code your testbench here
// or browse Examples
module tb; 
  /*
  int arr[10]; 
  // why j is going from 0 to 9 cause im not specifying anything , is it because of foreach loop ? 
  
  initial begin
  foreach(arr[j])begin
    arr[j]=j; 
    $display("the value here, locally update at index %0d   is %0d " , j, arr[j]);
    
  end
  end
  */
  int arr[10]; 
  int i =0; 
  initial begin
    repeat(10)begin
      arr[i]=i ; 
      i++; 
    end
    $display("The array values are %0p" , arr); 
  end
endmodule
~~~

## Question: Why does `j` go from 0 to 9 without an explicit limit?

Yes—`foreach` gets the legal index range from the array itself. `int arr[10]` has ten elements indexed from 0 through 9, so `foreach (arr[j])` automatically declares/uses `j` for those indices in array order. If the declared bounds were different, `foreach` would follow those bounds instead.

## `repeat` comparison

- `repeat (10)` executes its body exactly ten times but does not create or advance an index.
- The explicit `i++` is therefore required in the active example.
- `foreach` is preferable for visiting every array entry because the loop remains correct if the array bounds change.

## Detailed discussion

### How `foreach` discovers the index

`foreach (arr[j])` binds `j` to the index dimension of `arr`. Because `int arr[10]` contains ten elements indexed 0 through 9, the simulator supplies those ten legal values automatically. The loop is based on the declared array domain, not on a hidden universal rule that `j` must start at zero.

For example, if the array were declared with explicit descending bounds, the iteration would follow those legal bounds:

~~~systemverilog
int arr[9:0];
foreach (arr[j])
  $display("j = %0d", j);
~~~

This is why `foreach` is robust when an array declaration changes.

### How `repeat` differs

`repeat (10)` only means “execute this statement ten times.” It does not know that `arr` exists and does not manage `i`. The active example must initialize `i`, use `arr[i]`, and increment `i` manually. If the repeat count becomes larger than the array size, the code can attempt an out-of-bounds access; if it becomes smaller, some elements remain untouched.

| Loop | Controls termination using | Index management | Best use here |
| --- | --- | --- | --- |
| `for` | Explicit initialization, condition, update | Explicit | Numeric patterns where the loop formula matters |
| `repeat` | A fixed repetition count | Manual | Repeating an action a known number of times |
| `foreach` | The array's legal indices | Automatic | Visiting every element safely |

### Expected result

Both the commented `foreach` version and the active `repeat` version assign each element its index. When the active block finishes, `arr` contains `'{0, 1, 2, 3, 4, 5, 6, 7, 8, 9}`. The difference is not the final data; it is how safely the loop stays coupled to the array bounds.

### Points to remember

- `foreach` obtains indices from the array declaration.
- `repeat` counts executions and knows nothing about an array's size.
- A manually maintained index must be initialized, incremented, and kept in range.
- Use `foreach` for bounds-safe traversal and `repeat` for count-based stimulus.
