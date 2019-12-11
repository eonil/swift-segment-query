SegmentQuery
============
Eonil, 2019.

[![Build Status](https://api.travis-ci.org/eonil/swift-segment-query.svg)](https://travis-ci.org/eonil/swift-segment-query)

Dynamically stores additive values and get arbitrary sub-range sums in O(log(n)) time.

This is an implementation of something called "segment-tree" or "interval-tree".
You insert/remove lengths of consecutive segments and query positions on it.
I'm not sure which one is correct name.



How to Use
--------------

```swift

var x = SegmentQuery<Int>()

/// Append segment lengths.
x.append(contentsOf: [111,222,333])

/// Get subrange sum.
let s = x[1..<3].sum
assert(s == 222+333)

/// Get start/end offsets of a segment 1.
let a = x[..<1].sum
let b = x[...1].sum
let c = a..<b

/// Get index of segment and in-segment-offset from an offset.
let (a,b) = x.location(at: 230)
assert(a == 1)
assert(b == 8)

``` 



Complexity
--------------
- O(log(n)) for element query/insert/update/remove and sub-sum query. 



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
- 4x faster than `BTree.List`.

Run `SegmentQueryBenchmark` to get numbers on your machine.



Implementation
-------------------
- B-Tree based with no key stored. 
- Only values are stored. 
- Values are stored only on leafs.
- Buffer sizes are optimized for ordered list behavior with dynamic automatic sum.



Missing Features
---------------------
- Balancing after remove. (Now only insertion is balanced by B-Tree insertion algorithm)
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
