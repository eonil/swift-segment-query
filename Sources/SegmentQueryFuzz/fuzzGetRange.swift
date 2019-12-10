//
//  File.swift
//
//
//  Created by Henry Hathaway on 12/10/19.
//

import Foundation
import TestUtil
@testable import SegmentQuery

func fuzzGetRange(_ n:Int) {
    var prng = ReproduciblePRNG(n)
    do {
        var a = Array<Int>()
        var b = SegmentQuery<Int>()
        for _ in 0..<n {
            let x = prng.nextWithRotation()
            a.append(x)
            b.append(x)
        }
        for num in 0..<1024 {
            let i = prng.nextWithRotation(in: 0..<a.count)
            let j = prng.nextWithRotation(in: i..<a.count)
            let e = a[i..<j]
            let f = b.impl.root.getRange(i..<j)
            precondition(Array(e) == f.collect())
//            precondition(f.count == e.count)
//            for i in 0..<e.count {
//                precondition(e[e.startIndex + i] == f.get(at: i))
//            }
//            if num % 16 == 0 {
                print(num)
//            }
        }
    }
}

private extension Node1 {
    func collect() -> [T] {
        var xs = [T]()
        for i in 0..<count {
            xs.append(get(at: i))
        }
        return xs
    }
}
