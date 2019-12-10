//
//  File.swift
//  
//
//  Created by Henry Hathaway on 12/10/19.
//

import Foundation
import TestUtil
@testable import SegmentQuery

func fuzzSubSum(_ n:Int) {
    var prng = ReproduciblePRNG(n)
    
    do {
        var a = Array<Int>()
        var b = SegmentQuery<Int>()
        a.append(contentsOf: [111,222,333])
        b.append(contentsOf: [111,222,333])
        let x = a.reduce(0, +)
        let y = b.reduce(0, +)
        precondition(x == 666)
        precondition(y == 666)
        precondition(b[0..<1].sum == 111)
        precondition(b[0..<2].sum == 333)
        precondition(b[0..<3].sum == 666)
    }
    do {
        var a = Array<Int>()
        var b = SegmentQuery<Int>()
        for _ in 0..<n {
            let x = prng.nextWithRotation()
            a.append(x)
            b.append(x)
        }
//        for num in 0..<1024 {
//            let i = prng.nextWithRotation(in: 0..<a.count)
//            let sum1a = a[..<i].reduce(0, +)
//            let sum1b = a[i...].reduce(0, +)
//            let sum2a = b.impl.root.getRange(0..<i).collect().reduce(0, +)
//            let sum2b = b.impl.root.getRange(i..<b.count).collect().reduce(0, +)
//            let sum3a = b.subsumOfSegments(in: 0..<i)
//            let sum3b = b.subsumOfSegments(in: i..<b.count)
//            precondition(sum1a == sum2a)
//            precondition(sum2a == sum3a)
//            precondition(sum1b == sum2b)
//            precondition(sum2b == sum3b)
//            print(num)
//        }
        for num in 0..<16 {
            let a_sum = a.reduce(0,+)
            let b_sum = b[0...].sum
            precondition(a_sum == b_sum)
            let p = prng.nextWithRotation(in: 0..<a_sum)
            let (i,j) = b.location(at: p)
            let s = a[0..<i].reduce(0, +) + j
            precondition(p == s)
            print(num)
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
