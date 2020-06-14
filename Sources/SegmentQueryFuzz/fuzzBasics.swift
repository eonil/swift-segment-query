//
//  File.swift
//  
//
//  Created by Henry Hathaway on 12/10/19.
//

import Foundation
@testable import SegmentQuery
import SegmentQueryTestUtil

func fuzzBasics(_ n:Int) {
    do {
        var a = Array<Int>()
        var b = SegmentQuery<Int>()
        for num in 0..<12 {
            a.append(num)
            b.append(num)
            precondition(a == Array(b))
        }
        a.append(1111)
        b.append(1111)
        precondition(a == Array(b))
    }
    do {
        var a = Array<Int>()
        var b = SegmentQuery<Int>()
        for num in 0..<256 {
            a.append(num)
            b.append(num)
        }
        a.append(1111)
        b.append(1111)
        precondition(a == Array(b))
        while a.count > 253 {
            a.removeLast()
            b.removeLast()
        }
        precondition(a == Array(b))
        while a.count > 0 {
            a.removeLast()
            b.removeLast()
            precondition(a == Array(b))
        }
    }










    let N = 1024 * 128
    var prng = ReproduciblePRNG(N)
    var a = [Int]()
    var b = SegmentQuery<Int>()

    enum Op: Int { case insert, update, remove }
    struct TimeStep: CustomStringConvertible {
        var op:Op
        var offset:Int
        var from:Int?
        var to:Int?
        var description: String {
            let a = from == nil ? "_" : "\(from!)"
            let b = to == nil ? "_" : "\(to!)"
            return "\(op): [\(offset)] \(a) -> \(b)"
        }
    }
    var timeline = [TimeStep]()


    let start = Date()
    for num in 0..<N {
        let op = Op(rawValue: prng.nextWithRotation(in: 0..<3))!
        switch op {
        case .insert:
            let x = prng.nextWithRotation()
            let i = prng.nextWithRotation(in: 0..<a.count+1)
            a.insert(x, at: i)
            b.insert(x, at: i)
            timeline.append(TimeStep(op: op, offset: i, from: nil, to: x))
        case .update:
            guard a.count > 0 else { continue }
            let x = prng.nextWithRotation()
            let i = prng.nextWithRotation(in: 0..<a.count)
            let z = a[i]
            a[i] = x
            b[i] = x
            timeline.append(TimeStep(op: op, offset: i, from: z, to: x))
        case .remove:
            guard a.count > 0 else { continue }
            let i = prng.nextWithRotation(in: 0..<a.count)
            let z = a[i]
            a.remove(at: i)
            b.remove(at: i)
            timeline.append(TimeStep(op: op, offset: i, from: z, to: nil))
        }
        let c = b.count
        if num % 1024 == 0 {
            precondition(a == Array(b)) /// Integrity.
            let dd = b.impl.root.countMinDepth()..<b.impl.root.countMaxDepth()
    //        print("#\(num): \(timeline.last!), depth: \(dd), count: \(c)")
            precondition(dd.count <= 2) /// Balancing.
            print("#\(num)...depth: \(dd), count: \(c)")
            
        }
    }

    let end = Date()
    let time = end.timeIntervalSince(start)
    print("time: \(time) sec.")



    timeline = []
    a = []
    b = SegmentQuery()
    print("max node count per branch: \(Node1<Int>.maxNodeCountInBranchNode())")
    print("max elem count per leaf: \(Node1<Int>.maxElemCountInLeafNode())")
    for num in 0..<N {
        let x = prng.nextWithRotation()
        let i = prng.nextWithRotation(in: 0..<a.count+1)
        a.insert(x, at: i)
        b.insert(x, at: i)
    //    precondition(a == Array(b))
        let step = TimeStep(op: .insert, offset: i, from: nil, to: x)
        timeline.append(step)
        if num % 128 == 0 {
            precondition(a == Array(b))
            let dd = b.impl.root.countMinDepth()..<b.impl.root.countMaxDepth()
            var (e,f) = (0,0)
            b.impl.root.countNode(branches: &e, leafs: &f)
            precondition(dd.count <= 2) /// Balancing.
            let fillRate = Float64(a.count) / Float64(f * Node1<Int>.maxElemCountInLeafNode())
            print("#\(num)...depth: \(dd), count: (branch=\(e), leaf=\(f), value=\(a.count), fill=\(fillRate))")
        }
    }
    for num in 0..<N {
        let x = prng.nextWithRotation()
        let i = prng.nextWithRotation(in: 0..<a.count)
        let z = a[i]
        a[i] = x
        b[i] = x
    //    precondition(a == Array(b))
        let step = TimeStep(op: .update, offset: i, from: z, to: x)
        timeline.append(step)
        if num % 128 == 0 {
            precondition(a == Array(b))
            let dd = b.impl.root.countMinDepth()..<b.impl.root.countMaxDepth()
            var (e,f) = (0,0)
            b.impl.root.countNode(branches: &e, leafs: &f)
            precondition(dd.count <= 2) /// Balancing.
            let fillRate = Float64(a.count) / Float64(f * Node1<Int>.maxElemCountInLeafNode())
            print("#\(num)...depth: \(dd), count: (branch=\(e), leaf=\(f), value=\(a.count), fill=\(fillRate))")
        }
    }
    for num in 0..<N {
        let i = prng.nextWithRotation(in: 0..<a.count)
        let z = a[i]
        a.remove(at: i)
        b.remove(at: i)
    //    precondition(a == Array(b))
        let step = TimeStep(op: .remove, offset: i, from: z, to: nil)
        timeline.append(step)
        if num % 128 == 0 {
            precondition(a == Array(b))
            let dd = b.impl.root.countMinDepth()..<b.impl.root.countMaxDepth()
            var (e,f) = (0,0)
            b.impl.root.countNode(branches: &e, leafs: &f)
            precondition(dd.count <= 2) /// Balancing.
            let fillRate = Float64(a.count) / Float64(f * Node1<Int>.maxElemCountInLeafNode())
            print("#\(num)...depth: \(dd), count: (branch=\(e), leaf=\(f), value=\(a.count), fill=\(fillRate))")
        }
    }

}
