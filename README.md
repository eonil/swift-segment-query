SegmentQuery
============
Eonil, 2019.

Dynamically stores additive values and get arbitrary sub-range sums in O(log(n)) time.



How to Use
--------------

```swift

var x = SegmentQuery<Int>()
x.append(contentsOf: [111,222,333])

/// Get subrange sum.
let s = x[1..<3].sum
assert(s == 222+333)

/// Get start/end offsets of a segment 1.
let a = x[..<1].sum
let b = x[...1].sum
let c = a..<b

/// Get index of segment and offset from segment starting point.
let (a,b) = x.location(at: 230)
assert(a == 1)
assert(b == 8)

``` 



Complexity
--------------
- O(log(n)) for element query/insert/update/remove and sub-sum query. 
- Internal tree structure is automatically balanced.



Performance
-----------------
I couldn't find other segment query library written in Swift for comparison.
Instead, I performed insert/remove performance comparison
with *[well-known B-Tree library written by Lőrentey](https://github.com/attaswift/BTree)*.
This is one-by-one random `Int` number insert/remove at random location on 64-bit macOS,

With list of 128K values,
- 4x faster than `Swift.Array`.
- Very close speed to `BTree.List`.

With list of 1 million values,
- 4x faster* than `BTree.List`.
- `BTree.List` is faster if insertion is done sequentially
  as it's been optimized for appending.

Run `SegmentQueryBenchmark` to get numbers on your machine.



Implementation
-------------------
- B-Tree based with no key stored. 
- Only values are stored. 
- Values are stored only on leafs.



Name
--------
I chose `SegmentQuery` because it explains well what it does.
Trees providing this kind of query are also known as Segment Tree, Interval tree or Binary indexing Tree.
Differences of them are subtle and it seems there is no globally agreed single term.



Missing Features
---------------------
- Bulk insert/remove implementation.
- Sequential element iteration in O(n) time. Now it's O(n log n).
- Sub-sum indexing in each node. 
  We can store sub-sum for each branch/leaf node children 
  to perform binary search to get an item. 
  There is a trade-off, but I didn't try due to lack of time.




Credit & License
---------------------
Copyright(C) Eonil 2019. All rights reserved.
Using of this code is licensed under "MIT License".
