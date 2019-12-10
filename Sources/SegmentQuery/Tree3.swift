////
////  File.swift
////  
////
////  Created by Henry Hathaway on 12/9/19.
////
//
//import Foundation
//
//struct Tree3<T:AdditiveArithmetic> {
//    var root = Node3<T>()
//    func get(at offset:Int) -> T {
//        return root.get(at: offset)
//    }
//    mutating func insert(_ x:T, at offset:Int) {
//        switch root.insert(x, at: offset) {
//        case .none: break
//        case let .replaceUpNode(a, b):
//            root = .branch(Node3<T>.Branch(
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
//            root = Node3()
//            return x
//        }
//    }
//}
//enum Node3<T:AdditiveArithmetic> {
//    /// - Parameter count: Total value count in this subtree.
//    case branch(Branch)
//    struct Branch {
//        var sum: T
//        /// Total value count in this subtree.
//        var count: Int
//        var nodes: [Node3]
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
//        case let .branch(m):    return m.count == 0
//        case let .leaf(m):      return m.elems.isEmpty
//        }
//    }
//    var isFull: Bool {
//        switch self {
//        case let .branch(m):    return m.count == Node3.maxNodeCountInBranchNode()
//        case let .leaf(m):      return m.elems.count == Node3.maxElemCountInLeafNode()
//        }
//    }
//    
//    func get(at offset:Int) -> T {
//        switch self {
//        case let .branch(m):
//            let (i,suboffset) = Node3.project(offset, into: m.nodes)
//            return m.nodes[i].get(at: suboffset)
//        case let .leaf(m):
//            return m.elems[offset]
//        }
//    }
//    mutating func set(_ x:T, at offset:Int) {
//        switch self {
//        case var .branch(m):
//            let (i,suboffset) = Node3.project(offset, into: m.nodes)
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
//        case replaceUpNode(Node3,Node3)
//    }
//    mutating func insert(_ x:T, at offset:Int) -> InsertResult {
//        switch self {
//        case var .branch(m):
//            m.sum += x
//            m.count += 1
//            let (i,suboffset) = Node3.project(offset, into: m.nodes)
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
//                    let e = Node3.branch(Branch(
//                        sum: c.lazy.map({$0.sum}).reduce(.zero, +),
//                        count: c.lazy.map({$0.count}).reduce(.zero, +),
//                        nodes: c))
//                    let f = Node3.branch(Branch(
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
//            let (i,suboffset) = Node3.project(offset, into: m.nodes)
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
//extension Node3 {
//    static func maxNodeCountInBranchNode() -> Int {
//        return inCPUCacheSize / MemoryLayout<Node3>.stride
//    }
//    static func maxElemCountInLeafNode() -> Int {
//        return inCPUCacheSize / MemoryLayout<T>.stride
//    }
//}
//extension Node3 {
//    static func project(_ elementOffset:Int, into nodes:[Node3]) -> (nodeOffset:Int, inNodeElementOffset:Int) {
//        var c = 0
//        for (i,n) in nodes.enumerated() {
//            let a = c
//            let b = c + n.count
//            if (a..<b).contains(elementOffset) {
//                return (i, elementOffset-c)
//            }
//            c = b
//        }
//        precondition(elementOffset == c)
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
//private let inCPUCacheSize = 1024 * 16
////private let inCPUCacheSize = 64
