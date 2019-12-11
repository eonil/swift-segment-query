import XCTest
@testable import SegmentQuery

final class SegmentQueryTests: XCTestCase {
    func test1() {
        var x = SegmentQuery<Int>()
        x.insert(111, at: 0)
        x.insert(222, at: 1)
        x.insert(333, at: 2)
        XCTAssertEqual(x[0], 111)
        XCTAssertEqual(x[1], 222)
        XCTAssertEqual(x[2], 333)
    }
    func test2() {
        var x = SegmentQuery<Int>()
        x.insert(111, at: 0)
        x.insert(222, at: 1)
        x.insert(333, at: 2)
        let a = x.location(at: 666)
        XCTAssertEqual(a.index, 2)
        XCTAssertEqual(a.suboffset, 333)
    }
    func test3() {
        let x = SegmentQuery<Int>()
        let a = x.location(at: 0)
        XCTAssertEqual(a.index, 0)
        XCTAssertEqual(a.suboffset, 0)
    }
    func test4() {
        var x = SegmentQuery<Int>()
        x.append(4)
        x.append(3)
        XCTAssertEqual(x[...].sum, 7)
    }
    func test5() {
        var x = SegmentQuery<Int>()
        x.append(0)
        XCTAssertEqual(x[...].sum, 0)
        x[0] = 4
        XCTAssertEqual(x[...].sum, 4)
        x.append(3)
        XCTAssertEqual(x[...].sum, 7)
    }
}
