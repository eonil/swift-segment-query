//
//  File.swift
//  
//
//  Created by Henry Hathaway on 12/10/19.
//

import Foundation

func measure(_ fx: () -> Void) -> TimeInterval {
    let start = Date()
    fx()
    let end = Date()
    let x = end.timeIntervalSince(start)
    return x
}

