import Foundation
import SegmentQuery
import SegmentQueryTestUtil

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
        for num in 0..<n {
            let i = prng.nextWithRotation(in: 0..<a.count)
            let sum1a = a[..<i].reduce(0, +)
            let sum1b = a[i...].reduce(0, +)
            let sum2a = b[0..<i].sum
            let sum2b = b[i...].sum
            precondition(sum1a == sum2a)
            precondition(sum1b == sum2b)
            if num % 1024 == 0 {
                print("subsum: #\(num)")
            }
        }
        for num in 0..<n {
            let a_sum = a.reduce(0,+)
            let b_sum = b[0...].sum
            precondition(a_sum == b_sum)
            let p = prng.nextWithRotation(in: 0..<a_sum)
            let (i,j) = b.location(at: p)
            let s = a[0..<i].reduce(0, +) + j
            precondition(p == s)
            if num % 1024 == 0 {
                print("location at point in sum: #\(num)")
            }
        }
    }
}

