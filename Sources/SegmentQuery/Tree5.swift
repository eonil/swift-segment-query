////
////  File.swift
////  
////
////  Created by Henry Hathaway on 12/9/19.
////
//
//import Foundation
//
//struct Tree5<T:AdditiveArithmetic> {
//    var root = Node5<T>()
//    func get(at offset:Int) -> T {
//        return root.get(at: offset)
//    }
//    mutating func insert(_ x:T, at offset:Int) {
//        switch root.insert(x, at: offset) {
//        case .none: break
//        case let .replaceUpNode(a, b):
//            root = Node5(
//                count: a.count + b.count,
//                sum: a.sum + b.sum,
//                nodes: [a,b],
//                elems: [])
//        }
//    }
//    mutating func remove(at offset:Int) -> T {
//        switch root.remove(at: offset) {
//        case let .removed(x):
//            return x
//        case let .removedAndShouldRemoveUpNode(x):
//            root = Node5()
//            return x
//        }
//    }
//}
///// Accessing `enum` contents are very slow.
//struct Node5<T:AdditiveArithmetic> {
//    /// Total value count in this subtree.
//    var count = 0
//    var sum = T.zero
//    /// Empty on leaf node.
//    var nodes = [Node5]()
//    /// Empty on branch node.
//    var elems = [T]()
//
//    var isBranch: Bool { nodes.count > 0 }
//    var isLeaf: Bool { nodes.count == 0 }
//    var isEmpty: Bool { count == 0 }
//    var isFull: Bool { isLeaf ? elems.count == Node5.maxElemCountInLeafNode() : nodes.count == Node5.maxNodeCountInBranchNode() }
//    
//    func countNode(branches: inout Int, leafs: inout Int) {
//        if isBranch {
//            branches += 1
//            for n in nodes {
//                n.countNode(branches: &branches, leafs: &leafs)
//            }
//        }
//        else {
//            leafs += 1
//        }
//    }
//    func countMinDepth() -> Int {
//        if isBranch {
//            return nodes.map({$0.countMinDepth()}).min()! + 1
//        }
//        else {
//            return 1
//        }
//    }
//    func countMaxDepth() -> Int {
//        if isBranch {
//            return nodes.map({$0.countMaxDepth()}).max()! + 1
//        }
//        else {
//            return 1
//        }
//    }
//    func get(at offset:Int) -> T {
//        if isBranch {
//            let (i,suboffset) = Node5.project(offset, into: nodes, totalElemCount: count)
//            return nodes[i].get(at: suboffset)
//        }
//        else {
//            return elems[offset]
//        }
//    }
//    mutating func set(_ x:T, at offset:Int) {
//        if isBranch {
//            let (i,suboffset) = Node5.project(offset, into: nodes, totalElemCount: count)
//            nodes[i].set(x, at: suboffset)
//        }
//        else {
//            elems[offset] = x
//        }
//    }
//    
//    enum InsertResult {
//        case none
//        case replaceUpNode(Node5,Node5)
//    }
//    mutating func insert(_ x:T, at offset:Int) -> InsertResult {
//        if isBranch {
//            let (i,suboffset) = Node5.project(offset, into: nodes, totalElemCount: count)
//            sum += x
//            count += 1
//            let r = nodes[i].insert(x, at: suboffset)
//            switch r {
//            case .none:
//                return .none
//            case let .replaceUpNode(a, b):
//                if !isFull {
//                    nodes[i] = a
//                    nodes.insert(b, at: i+1)
//                    return .none
//                }
//                else {
//                    nodes[i] = a
//                    let (c,d) = nodes.splitAtHalfWithInsertingElement(b, at: i+1)
//                    let e = Node5(
//                        count: c.lazy.map({$0.count}).reduce(.zero, +),
//                        sum: c.lazy.map({$0.sum}).reduce(.zero, +),
//                        nodes: c,
//                        elems: [])
//                    let f = Node5(
//                        count: d.lazy.map({$0.count}).reduce(.zero, +),
//                        sum: d.lazy.map({$0.sum}).reduce(.zero, +),
//                        nodes: d,
//                        elems: [])
//                    return .replaceUpNode(e, f)
//                }
//            }
//        }
//        else {
//            if isFull {
//                let (a,b) = elems.splitAtHalfWithInsertingElement(x, at: offset)
//                let e = Node5(
//                    count: a.count,
//                    sum: a.reduce(.zero, +),
//                    nodes: [],
//                    elems: a)
//                let f = Node5(
//                    count: b.count,
//                    sum: b.reduce(.zero, +),
//                    nodes: [],
//                    elems: b)
//                return .replaceUpNode(e,f)
//            }
//            else {
//                count += 1
//                sum += x
//                elems.insert(x, at: offset)
//                return .none
//            }
//        }
//    }
//    enum RemoveResult {
//        case removed(T)
//        case removedAndShouldRemoveUpNode(T)
//    }
//    mutating func remove(at offset:Int) -> RemoveResult {
//        if isBranch {
//            let (i,suboffset) = Node5.project(offset, into: nodes, totalElemCount: count)
//            switch nodes[i].remove(at: suboffset) {
//            case let .removed(x):
//                sum -= x
//                count -= 1
//                return .removed(x)
//            case let .removedAndShouldRemoveUpNode(x):
//                sum -= x
//                count -= 1
//                nodes.remove(at: i)
//                if 0 < nodes.count {
//                    return .removed(x)
//                }
//                else {
//                    return .removedAndShouldRemoveUpNode(x)
//                }
//            }
//        }
//        else {
//            let x = elems.remove(at: offset)
//            count -= 1
//            sum -= x
//            if elems.isEmpty {
//                return .removedAndShouldRemoveUpNode(x)
//            }
//            else {
//                return .removed(x)
//            }
//        }
//    }
//}
//extension Node5 {
//    static func maxNodeCountInBranchNode() -> Int {
//        return 16
////        return inCPUCacheSize / MemoryLayout<Node5>.stride
//    }
//    static func maxElemCountInLeafNode() -> Int {
//        return inCPUCacheSize / MemoryLayout<T>.stride
//    }
//}
//extension Node5 {
//    static func project(_ elementOffset:Int, into nodes:[Node5], totalElemCount:Int) -> (nodeOffset:Int, inNodeElementOffset:Int) {
//        precondition(elementOffset <= totalElemCount)
//        var a = 0
//        var b = 0
//        for i in 0..<nodes.count {
//            let nc = nodes[i].count
//            b += nc
//            if a <= elementOffset && elementOffset < b {
//                return (i, elementOffset-a)
//            }
//            a = b
//        }
//        return (nodes.count-1, nodes.last!.count)
//    }
//}
//extension Array {
//    func splitAtHalfWithInsertingElement(_ x:Element, at offset:Int) -> (Array,Array) {
//        assert(count > 0)
//        let z = inCPUCacheSize / MemoryLayout<Element>.stride
//        let i = count / 2
//        let a = self[..<i]
//        let b = self[i...]
//        var c = Array()
//        var d = Array()
//        c.reserveCapacity(z)
//        d.reserveCapacity(z)
//        if offset < i {
//            c.append(contentsOf: a[..<offset])
//            c.append(x)
//            c.append(contentsOf: a[offset...])
//            d.append(contentsOf: b)
//        }
//        else {
//            c.append(contentsOf: a)
//            d.append(contentsOf: b[..<offset])
//            d.append(x)
//            d.append(contentsOf: b[offset...])
//        }
//        return (c,d)
//    }
//}
//
////private let inCPUCacheSize = 1024 * 64
//private let inCPUCacheSize = 1024 * 16
////private let inCPUCacheSize = 1024 * 4
////private let inCPUCacheSize = 64
