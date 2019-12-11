//
//  File.swift
//  
//
//  Created by Henry Hathaway on 12/9/19.
//

import Foundation

struct Tree1<T:AdditiveArithmetic> {
    var root = Node1<T>([])
    func get(at offset:Int) -> T {
        return root.get(at: offset)
    }
    mutating func insert(_ x:T, at offset:Int) {
        switch root.insert(x, at: offset) {
        case .none: break
        case let .replaceUpNode(a, b):
            root = Node1(
                count: a.count + b.count,
                sum: a.sum + b.sum,
                nodes: [a,b])
        }
    }
    mutating func remove(at offset:Int) -> T {
        switch root.remove(at: offset) {
        case let .removed(x):
            return x
        case let .removedAndShouldRemoveUpNode(x):
            root = Node1(sum: .zero, elems: [])
            return x
        }
    }
}
/// Accessing `enum` contents are very slow.
struct Node1<T:AdditiveArithmetic> {
    /// Total value count in this subtree.
    var count = 0
    var sum = T.zero
    /// Empty on leaf node.
    private var nodes: [Node1]

    /// Empty on branch node.
    private var elems: [T]
    
    init() {
        nodes = []
        elems = []
    }
    init<C>(_ xs:C) where C:RandomAccessCollection, C.Element == T {
        count = xs.count
        let maxElemCount = Node1.maxElemCountInLeafNode()
        if count <= maxElemCount {
            sum = xs.reduce(.zero, +)
            nodes = []
            elems = Array(xs)
        }
        else {
            sum = .zero
            nodes = []
            let nc1 = (count+maxElemCount) / maxElemCount
            let nc2 = min(Node1.maxNodeCountInBranchNode(), nc1)
            let nc = count / nc2
            var c = count
            var i = xs.startIndex
            while c > 0 {
                let cc = min(c,nc)
                let j = xs.index(i, offsetBy: cc, limitedBy: xs.endIndex) ?? xs.endIndex
                let xxs = xs[i..<j]
                let n = Node1(xxs)
                sum += n.sum
                nodes.append(n)
                c -= cc
                i = j
            }
            elems = []
        }
    }
    /// Unchecked internal subnode init.
    fileprivate init(count c:Int, sum s:T, nodes ns:[Node1]) {
        count = c
        sum = s
        nodes = ns
        elems = []
    }
    /// Unchecked internal subnode init.
    fileprivate init(sum s:T, elems xs:[T]) {
        count = xs.count
        sum = s
        nodes = []
        elems = xs
    }

    var isBranch: Bool { nodes.count > 0 }
    var isLeaf: Bool { nodes.count == 0 }
    var isEmpty: Bool { count == 0 }
    var isFull: Bool { isLeaf ? elems.count == Node1.maxElemCountInLeafNode() : nodes.count == Node1.maxNodeCountInBranchNode() }
    
    func countNode(branches: inout Int, leafs: inout Int) {
        if isBranch {
            branches += 1
            for n in nodes {
                n.countNode(branches: &branches, leafs: &leafs)
            }
        }
        else {
            leafs += 1
        }
    }
    func countMinDepth() -> Int {
        if isBranch {
            return nodes.map({$0.countMinDepth()}).min()! + 1
        }
        else {
            return 1
        }
    }
    func countMaxDepth() -> Int {
        if isBranch {
            return nodes.map({$0.countMaxDepth()}).max()! + 1
        }
        else {
            return 1
        }
    }
    func get(at offset:Int) -> T {
        precondition(0 <= offset)
        precondition(offset < count)
        if isBranch {
            let (i,suboffset) = Node1.project(offset, into: nodes, totalElemCount: count)
            return nodes[i].get(at: suboffset)
        }
        else {
            return elems[offset]
        }
    }
    /// Sets a new value `x` at `offset` and returns old value at the `offset`.
    @discardableResult
    mutating func set(_ x:T, at offset:Int) -> T {
        precondition(0 <= offset)
        precondition(offset < count)
        if isBranch {
            let (i,suboffset) = Node1.project(offset, into: nodes, totalElemCount: count)
            let z = nodes[i].set(x, at: suboffset)
            sum -= z
            sum += x
            return z
        }
        else {
            let z = elems[offset]
            elems[offset] = x
            sum -= z
            sum += x
            return z
        }
    }
    
    func getRangeFrom(_ i:Int) -> Node1 { getRange(i..<count) }
    func getRangeTo(_ i:Int) -> Node1 { getRange(0..<i) }
    /// Replaces values in range with values in node.
    func getRange(_ offsetRange:Range<Int>) -> Node1 {
        if offsetRange == 0..<count { return self }
        else {
            if isBranch {
                let (i,ii) = Node1.project(offsetRange.lowerBound, into: nodes, totalElemCount: count)
                let (j,jj) = Node1.project(offsetRange.upperBound, into: nodes, totalElemCount: count)
                if i == j {
                    return nodes[i].getRange(ii..<jj)
                }
                else {
                    let a = nodes[i].getRangeFrom(ii)
                    let b = nodes[i...j].dropFirst().dropLast() /// Includes node at `j`.
                    let c = nodes[j].getRangeTo(jj)
                    var ns = [Node1]()
                    ns.append(a)
                    ns.append(contentsOf: b)
                    ns.append(c)
                    assert(ns.map({$0.count}).reduce(0, +) == offsetRange.count)
                    let n = Node1(
                        count: offsetRange.count,
                        sum: a.sum + b.lazy.map({$0.sum}).reduce(.zero, +) + c.sum,
                        nodes: ns)
                    return n
                }
            }
            else {
                let xs = Array(elems[offsetRange])
                return Node1(sum: xs.reduce(.zero, +), elems: xs)
            }
        }
    }
    
    enum InsertResult {
        case none
        case replaceUpNode(Node1,Node1)
    }
    mutating func insert(_ x:T, at offset:Int) -> InsertResult {
        if isBranch {
            let (i,suboffset) = Node1.project(offset, into: nodes, totalElemCount: count)
            sum += x
            count += 1
            let r = nodes[i].insert(x, at: suboffset)
            switch r {
            case .none:
                return .none
            case let .replaceUpNode(a, b):
                if !isFull {
                    nodes[i] = a
                    nodes.insert(b, at: i+1)
                    return .none
                }
                else {
                    nodes[i] = a
                    let (c,d) = nodes.splitAtHalfWithInsertingElement(b, at: i+1)
                    let e = Node1(
                        count: c.lazy.map({$0.count}).reduce(.zero, +),
                        sum: c.lazy.map({$0.sum}).reduce(.zero, +),
                        nodes: c)
                    let f = Node1(
                        count: d.lazy.map({$0.count}).reduce(.zero, +),
                        sum: d.lazy.map({$0.sum}).reduce(.zero, +),
                        nodes: d)
                    return .replaceUpNode(e, f)
                }
            }
        }
        else {
            if isFull {
                let (a,b) = elems.splitAtHalfWithInsertingElement(x, at: offset)
                let e = Node1(
                    sum: a.reduce(.zero, +),
                    elems: a)
                let f = Node1(
                    sum: b.reduce(.zero, +),
                    elems: b)
                return .replaceUpNode(e,f)
            }
            else {
                count += 1
                sum += x
                elems.insert(x, at: offset)
                return .none
            }
        }
    }
    enum RemoveResult {
        case removed(T)
        case removedAndShouldRemoveUpNode(T)
    }
    mutating func remove(at offset:Int) -> RemoveResult {
        if isBranch {
            let (i,suboffset) = Node1.project(offset, into: nodes, totalElemCount: count)
            switch nodes[i].remove(at: suboffset) {
            case let .removed(x):
                sum -= x
                count -= 1
                return .removed(x)
            case let .removedAndShouldRemoveUpNode(x):
                sum -= x
                count -= 1
                nodes.remove(at: i)
                if 0 < nodes.count {
                    return .removed(x)
                }
                else {
                    return .removedAndShouldRemoveUpNode(x)
                }
            }
        }
        else {
            let x = elems.remove(at: offset)
            count -= 1
            sum -= x
            if elems.isEmpty {
                return .removedAndShouldRemoveUpNode(x)
            }
            else {
                return .removed(x)
            }
        }
    }
}

extension Node1 where T:Comparable {
    func findOffsetLocation(of pointInSum:T) -> (offset:Int, suboffset:T) {
        assert(pointInSum <= sum)
        if isBranch {
            var c = 0
            var s = T.zero
            for i in 0..<nodes.count {
                let n = nodes[i]
                let nc = n.count
                let ns = n.sum
                let a = s
                let b = s + ns
                if (a..<b).contains(pointInSum) {
                    let subpointInSum = pointInSum - s
                    let (v,w) = n.findOffsetLocation(of: subpointInSum)
                    return (c+v,w)
                }
                c += nc
                s = b
            }
            assert(s == pointInSum)
            if nodes.isEmpty {
                return (0,.zero)
            }
            else {
                return (nodes.count-1, nodes.last!.sum)
            }
        }
        else {
            var s = T.zero
            for i in 0..<elems.count {
                let x = elems[i]
                let a = s
                let b = s + x
                if (a..<b).contains(pointInSum) {
                    return (i, pointInSum - a)
                }
                s += x
            }
            assert(s == pointInSum)
            if elems.isEmpty {
                return (0,.zero)
            }
            else {
                return (elems.count-1, elems.last!)
            }
        }
    }
}










extension Node1 {
    static func maxNodeCountInBranchNode() -> Int {
        return 16
//        return inCPUCacheSize / MemoryLayout<Node6>.stride
    }
    static func maxElemCountInLeafNode() -> Int {
        return inCPUCacheSize / MemoryLayout<T>.stride
    }
}
extension Node1 {
    static func project(_ elementOffset:Int, into nodes:[Node1], totalElemCount:Int) -> (nodeOffset:Int, inNodeElementOffset:Int) {
        precondition(elementOffset <= totalElemCount)
        var a = 0
        var b = 0
        for i in 0..<nodes.count {
            let nc = nodes[i].count
            b += nc
            if a <= elementOffset && elementOffset < b {
                return (i, elementOffset-a)
            }
            a = b
        }
        return (nodes.count-1, nodes.last!.count)
    }
}
extension Array {
    func splitAtHalfWithInsertingElement(_ x:Element, at offset:Int) -> (Array,Array) {
        assert(count > 0)
        let z = inCPUCacheSize / MemoryLayout<Element>.stride
        let i = count / 2
        let a = self[..<i]
        let b = self[i...]
        var c = Array()
        var d = Array()
        c.reserveCapacity(z)
        d.reserveCapacity(z)
        if offset < i {
            c.append(contentsOf: a[..<offset])
            c.append(x)
            c.append(contentsOf: a[offset...])
            d.append(contentsOf: b)
        }
        else {
            c.append(contentsOf: a)
            d.append(contentsOf: b[..<offset])
            d.append(x)
            d.append(contentsOf: b[offset...])
        }
        return (c,d)
    }
}

//private let inCPUCacheSize = 1024 * 64
private let inCPUCacheSize = 1024 * 16
//private let inCPUCacheSize = 1024 * 4
//private let inCPUCacheSize = 64
