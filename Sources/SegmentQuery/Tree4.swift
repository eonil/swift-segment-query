////
////  File.swift
////  
////
////  Created by Henry Hathaway on 12/9/19.
////
//
//import Foundation
//
//struct Tree4<T:AdditiveArithmetic> {
//    var root = Node4<T>()
//    func get(at offset:Int) -> T {
//        return root.get(at: offset)
//    }
//    mutating func insert(_ x:T, at offset:Int) {
//        switch root.insert(x, at: offset) {
//        case .none: break
//        case let .replaceUpNode(a, b):
//            root = .branch(Node4<T>.Branch(
//                sum: a.sum + b.sum,
//                count: a.count + b.count,
//                nodes: [a,b]))
//        }
//    }
//    mutating func remove(at offset:Int) -> T {
//        switch root.remove(at: offset) {
//        case let .removed(x):
//            return x
//        case let .removedAndShouldRemoveUpNode(x):
//            root = Node4()
//            return x
//        }
//    }
//}
//indirect enum Node4<T:AdditiveArithmetic> {
//    /// - Parameter count: Total value count in this subtree.
//    case branch(Branch)
//    struct Branch {
//        var sum: T
//        /// Total value count in this subtree.
//        var count: Int
//        var nodes: [Node4]
//    }
//    case leaf(Leaf)
//    struct Leaf {
//        var sum: T
//        var elems: [T]
//    }
//    
//    init() {
//        self = .leaf(Leaf(sum: .zero, elems: []))
//    }
//    var sum: T {
//        switch self {
//        case let .branch(m):    return m.sum
//        case let .leaf(m):      return m.sum
//        }
//    }
//    var count: Int {
//        switch self {
//        case let .branch(m):    return m.count
//        case let .leaf(m):      return m.elems.count
//        }
//    }
//    var isEmpty: Bool {
//        switch self {
//        case let .branch(m):    return m.nodes.isEmpty
//        case let .leaf(m):      return m.elems.isEmpty
//        }
//    }
//    var isFull: Bool {
//        switch self {
//        case let .branch(m):    return m.nodes.count == Node4.maxNodeCountInBranchNode()
//        case let .leaf(m):      return m.elems.count == Node4.maxElemCountInLeafNode()
//        }
//    }
//    
////    struct Stat {
////        var countBranchNodes = 0
////        var countLeafNodes = 0
////    }
////    func stat(_ x: inout Stat) {
////        
////    }
//    
//    func countNode(branches: inout Int, leafs: inout Int) {
//        switch self {
//        case let .branch(m):
//            branches += 1
//            for n in m.nodes {
//                n.countNode(branches: &branches, leafs: &leafs)
//            }
//        case .leaf(_):
//            leafs += 1
//        }
//    }
//    func countMinDepth() -> Int {
//        switch self {
//        case let .branch(m):    return m.nodes.map({$0.countMinDepth()}).min()! + 1
//        case .leaf(_):          return 1
//        }
//    }
//    func countMaxDepth() -> Int {
//        switch self {
//        case let .branch(m):    return m.nodes.map({$0.countMaxDepth()}).max()! + 1
//        case .leaf(_):          return 1
//        }
//    }
//    func get(at offset:Int) -> T {
//        switch self {
//        case let .branch(m):
//            let (i,suboffset) = Node4.project(offset, into: m.nodes, totalElemCount: m.count)
//            return m.nodes[i].get(at: suboffset)
//        case let .leaf(m):
//            return m.elems[offset]
//        }
//    }
//    mutating func set(_ x:T, at offset:Int) {
//        switch self {
//        case var .branch(m):
//            let (i,suboffset) = Node4.project(offset, into: m.nodes, totalElemCount: m.count)
//            m.nodes[i].set(x, at: suboffset)
//            self = .branch(m)
//        case var .leaf(m):
//            m.elems[offset] = x
//            self = .leaf(m)
//        }
//    }
//    
//    enum InsertResult {
//        case none
//        case replaceUpNode(Node4,Node4)
//    }
//    mutating func insert(_ x:T, at offset:Int) -> InsertResult {
//        switch self {
//        case var .branch(m):
//            let (i,suboffset) = Node4.project(offset, into: m.nodes, totalElemCount: m.count)
//            m.sum += x
//            m.count += 1
//            let r = m.nodes[i].insert(x, at: suboffset)
//            switch r {
//            case .none:
//                self = .branch(m)
//                return .none
//            case let .replaceUpNode(a, b):
//                if !isFull {
//                    m.nodes[i] = a
//                    m.nodes.insert(b, at: i+1)
//                    self = .branch(m)
//                    return .none
//                }
//                else {
//                    m.nodes[i] = a
//                    let (c,d) = m.nodes.splitAtHalfWithInsertingElement(b, at: i+1)
//                    let e = Node4.branch(Branch(
//                        sum: c.lazy.map({$0.sum}).reduce(.zero, +),
//                        count: c.lazy.map({$0.count}).reduce(.zero, +),
//                        nodes: c))
//                    let f = Node4.branch(Branch(
//                        sum: d.lazy.map({$0.sum}).reduce(.zero, +),
//                        count: d.lazy.map({$0.count}).reduce(.zero, +),
//                        nodes: d))
//                    return .replaceUpNode(e, f)
//                }
//            }
//        case var .leaf(m):
//            if isFull {
//                let (a,b) = m.elems.splitAtHalfWithInsertingElement(x, at: offset)
//                let e = Leaf(
//                    sum: a.reduce(.zero, +),
//                    elems: a)
//                let f = Leaf(
//                    sum: b.reduce(.zero, +),
//                    elems: b)
//                return .replaceUpNode(.leaf(e), .leaf(f))
//            }
//            else {
//                m.elems.insert(x, at: offset)
//                self = .leaf(Leaf(
//                    sum: m.sum + x,
//                    elems: m.elems))
//                return .none
//            }
//        }
//    }
//    enum RemoveResult {
//        case removed(T)
//        case removedAndShouldRemoveUpNode(T)
//    }
//    mutating func remove(at offset:Int) -> RemoveResult {
//        switch self {
//        case var .branch(m):
//            let (i,suboffset) = Node4.project(offset, into: m.nodes, totalElemCount: m.count)
//            switch m.nodes[i].remove(at: suboffset) {
//            case let .removed(x):
//                m.sum -= x
//                m.count -= 1
//                self = .branch(m)
//                return .removed(x)
//            case let .removedAndShouldRemoveUpNode(x):
//                m.sum -= x
//                m.count -= 1
//                m.nodes.remove(at: i)
//                if 0 < m.nodes.count {
//                    self = .branch(m)
//                    return .removed(x)
//                }
//                else {
//                    return .removedAndShouldRemoveUpNode(x)
//                }
//            }
//        case var .leaf(m):
//            let x = m.elems.remove(at: offset)
//            m.sum -= x
//            if m.elems.isEmpty {
//                return .removedAndShouldRemoveUpNode(x)
//            }
//            else {
//                self = .leaf(m)
//                return .removed(x)
//            }
//        }
//    }
//}
//extension Node4 {
//    static func maxNodeCountInBranchNode() -> Int {
//        return 16
////        return inCPUCacheSize / MemoryLayout<Node4>.stride
//    }
//    static func maxElemCountInLeafNode() -> Int {
//        return inCPUCacheSize / MemoryLayout<T>.stride
//    }
//}
//extension Node4 {
//    static func project(_ elementOffset:Int, into nodes:[Node4], totalElemCount:Int) -> (nodeOffset:Int, inNodeElementOffset:Int) {
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
////    static func project(_ elementOffset:Int, into nodes:[Node4]) -> (nodeOffset:Int, inNodeElementOffset:Int) {
////        var c = 0
////        for (i,n) in nodes.enumerated() {
////            let a = c
////            let b = c + n.count
////            if (a..<b).contains(elementOffset) {
////                return (i, elementOffset-c)
////            }
////            c = b
////        }
////        precondition(elementOffset == c)
////        return (nodes.count-1, nodes.last!.count)
////    }
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
