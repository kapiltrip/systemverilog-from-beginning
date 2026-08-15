# Part 06 — Array iteration

EDA Playground: [https://edaplayground.com/x/GK3p](https://edaplayground.com/x/GK3p)

This part compares `foreach` with `repeat` while filling a fixed-size unpacked array.

## Question: Why does `j` go from 0 to 9 without an explicit limit?

Yes—`foreach` gets the legal index range from the array itself. `int arr[10]` has ten elements indexed from 0 through 9, so `foreach (arr[j])` automatically declares/uses `j` for those indices in array order. If the declared bounds were different, `foreach` would follow those bounds instead.

## `repeat` comparison

- `repeat (10)` executes its body exactly ten times but does not create or advance an index.
- The explicit `i++` is therefore required in the active example.
- `foreach` is preferable for visiting every array entry because the loop remains correct if the array bounds change.

