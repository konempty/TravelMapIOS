//
//  AtomicInteger.swift
//  TravelMap
//
//  Created by 김한빈 on 2021/10/23.
//

import Foundation

public class AtomicInteger {

    private let lock = DispatchSemaphore(value: 1)
    private var value: Int64 = 0

    init(_ val: Int64) {
        value = val
    }

    // You need to lock on the value when reading it too since
    // there are no volatile variables in Swift as of today.
    public func get() -> Int64 {

        lock.wait()
        defer {
            lock.signal()
        }
        return value
    }


    public func incrementAndGet() -> Int64 {

        lock.wait()
        defer {
            lock.signal()
        }
        value += 1
        return value
    }


}
