//
//  File.swift
//  
//
//  Created by Henry Hathaway on 12/10/19.
//

import Foundation

Thread.current.stackSize = 4096 * 128

let N = 1024 * 128
//fuzzBasics(N)
//fuzzGetRange(N)
fuzzSubSum(N)
