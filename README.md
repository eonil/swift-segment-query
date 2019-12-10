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
For single item insert/remove at random location,

With list of 1 128K 8-byte random integer values,
- 4x faster than `Swift.Array`.
- Comparable with `BTree.List`(by Lőrentey). Quite close benchmark numbers.

With list of 1 million 8-byte random integer values,
- 4x faster* than `BTree.List`(by Lőrentey).

*`BTree.List` is faster if insertion is done sequentially.



Implementation
-------------------
- B-Tree based. But no key is stored. Only values. Values are stored only on leafs.



Name
--------
I chose `SegmentQuery` because it explains well what it does.
Trees providing this kind of query are also known as Segment Tree, Interval tree or Binary indexing Tree.
Differences of them are subtle and it seems there is no globally agreed single term.




