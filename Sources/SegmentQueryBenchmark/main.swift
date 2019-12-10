//
//  File.swift
//
//
//  Created by Henry Hathaway on 12/8/19.
//

import Foundation
import TestUtil
import SBTL
import BTree
import SegmentQuery

let N = 1024 * 128
let rns = ReproduciblePRNG(N)

enum Op: Int { case insert, update, remove }
struct Stat {
    var time = 0 as TimeInterval
    var minElementCount = Int.max
    var maxElementCount = Int.min
}
func run<C>(_ a: inout C) -> Stat where
C:RandomAccessCollection & MutableCollection & RangeReplaceableCollection, C.Index == Int, C.Element == Int {
    var prng = rns
    var stat = Stat()
    stat.time = measure() {
        for _ in 0..<N {
            let op = Op(rawValue: prng.nextWithRotation(in: 0..<3))!
            switch op {
            case .insert:
                let x = prng.nextWithRotation()
                let i = prng.nextWithRotation(in: 0..<a.count+1)
                a.insert(x, at: i)
            case .update:
                guard a.count > 0 else { continue }
                let x = prng.nextWithRotation()
                let i = prng.nextWithRotation(in: 0..<a.count)
                a[i] = x
            case .remove:
                guard a.count > 0 else { continue }
                let i = prng.nextWithRotation(in: 0..<a.count)
                a.remove(at: i)
            }
            stat.minElementCount = min(stat.minElementCount, a.count)
            stat.maxElementCount = max(stat.maxElementCount, a.count)
        }
    }
    return stat
}









struct Session: CustomStringConvertible {
    var name: String
    var consecutiveRandomInsertionTime = 0 as TimeInterval
    var operationStat = Stat()
    var destructionTime = 0 as TimeInterval
    var description: String {
        let totalTime = consecutiveRandomInsertionTime + operationStat.time + destructionTime
        return [
            "\(name)",
            name.map({_ in "-"}).joined(),
            "- consecutive random insertion time:   \(consecutiveRandomInsertionTime)",
            "- random operation time:               \(operationStat.time)",
            "- min element count in random op.:     \(operationStat.minElementCount)",
            "- max element count in random op.:     \(operationStat.maxElementCount)",
            "- destruction time:                    \(destructionTime)",
            "------------------------------------------------------------------------",
            "- total time:                          \(totalTime)"
        ].joined(separator: "\n")
    }
}

extension RandomAccessCollection where
Self: MutableCollection & RangeReplaceableCollection & ExpressibleByArrayLiteral,
Index == Int,
Element == Int {
    static func runBenchmark(preinsertionCount:Int, name n:String = "\(Self.self)") {
        var x = Session(name: n)
        var a = Self()
        x.consecutiveRandomInsertionTime = measure {
            for _ in 0..<preinsertionCount {
                a.insert(1111, at: a.count/2)
            }
        }
        x.operationStat = run(&a)
        x.destructionTime = measure { a = [] }
        print("\(x)\n")
    }
}

extension Int: SBTLValueProtocol { public var sum:Int { self } }
let M = 1024 * 1024
//Swift.Array<Int>.runBenchmark(preinsertionCount: M)
List<Int>.runBenchmark(preinsertionCount: M)
//SBTL<Int>.runBenchmark(preinsertionCount: M)
SegmentQuery<Int>.runBenchmark(preinsertionCount: M)

Thread.sleep(forTimeInterval: 1)
exit(0)
