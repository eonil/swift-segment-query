//
//  File.swift
//  
//
//  Created by Henry Hathaway on 12/10/19.
//

import Foundation

/// A collection of segments that you can query on for sum and point locations.
public struct SegmentQuery<T:AdditiveArithmetic & Comparable> {
    var impl = Tree1<T>()
    public init() {}
    /// Gets sum of all values contained in this collection.
    /// - Complexity: O(1).
    /// - Note: All sums are precomputed as you add/remove values.
    public var sum: T { impl.root.sum }
    /// Gets offset to segment that contains `pointInSum` and in-segment offset to the point.
    /// - Complexity: O(log(n))
    public func location(at pointInSum:T) -> (index:Index, suboffset:T) {
        let (a,b) = impl.root.findOffsetLocation(of: pointInSum)
        return (a,b)
    }
}
extension SegmentQuery: RandomAccessCollection, MutableCollection, RangeReplaceableCollection {
    public typealias SubSequence = SegmentQuery
    public var startIndex: Int { 0 }
    public var endIndex: Int { impl.root.count }
    public subscript(_ i: Int) -> T {
        get { impl.root.get(at: i) }
        set(x) { impl.root.set(x, at: i) }
    }
    public subscript(_ range:Range<Int>) -> SegmentQuery {
        var x = self
        x.impl.root = x.impl.root.getRange(range)
        return x
    }
    public mutating func replaceSubrange<C,R>(_ subrange:R, with newElements:C) where C:Collection, R:RangeExpression, Element == C.Element, Index == R.Bound {
        let q = subrange.relative(to: self)
        for i in q.lazy.reversed() {
            _ = impl.remove(at: i)
        }
        for (i,x) in newElements.enumerated() {
            let k = q.lowerBound + i
            impl.insert(x, at: k)
        }
    }
}
extension SegmentQuery: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: T...) {
        append(contentsOf: elements)
    }
}
extension SegmentQuery: CustomStringConvertible {
    public var description: String {
        return Array(self).description
    }
}
