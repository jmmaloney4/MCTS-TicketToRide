//
//  Concurrency.swift
//  ArgumentParser
//
//  Created by Jack Maloney on 4/21/20.
//

import Foundation
import Dispatch

func synchronized<T>(_ lock: AnyObject, _ body: () throws -> T) rethrows -> T {
    objc_sync_enter(lock)
    defer { objc_sync_exit(lock) }
    return try body()
}

struct Atomic<T> {
    private var _value: T
    private var _lock: DispatchSemaphore
    
    init(_ initialValue: T) {
        _value = initialValue
        _lock = DispatchSemaphore(value: 0)
        defer {_lock.signal() }
    }
    
    var value: T {
        get {
            _lock.wait()
            defer { _lock.signal() }
            return self._value
        }
    }
    
    @discardableResult
    mutating func getAndSet(_ newValue: T) -> T {
        _lock.wait()
        defer { _lock.signal() }
        let rv = self._value
        self._value = newValue
        return rv
    }
}

extension Atomic where T == Int {
    init() {
        self.init(0)
    }
    
    mutating func incrementAndGet() -> Int {
        _lock.wait()
        defer { _lock.signal() }
        _value += 1
        return _value
    }
    
    mutating func increment() {
        _lock.wait()
        defer { _lock.signal() }
        _value += 1
    }
    
    mutating func decrementAndGet() -> Int {
        _lock.wait()
        defer { _lock.signal() }
        _value -= 1
        return _value
    }
}

typealias AtomicInt = Atomic<Int>
typealias AtomicBool = Atomic<Bool>

//
// From: https://github.com/uber/swift-concurrency.git
//

//
//  Copyright (c) 2018. Uber Technologies
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
import Foundation

/// A concurrency utility class that allows coordination between threads. A count down latch
/// starts with an initial count. Threads can then decrement the count until it reaches zero,
/// at which point, the suspended waiting thread shall proceed. A `CountDownLatch` behaves
/// differently from a `DispatchSemaphore` once the latch is open. Unlike a semaphore where
/// subsequent waits would still block the caller thread, once a `CountDownLatch` is open, all
/// subsequent waits can directly passthrough.
public class CountDownLatch {
    
    /// The initial count of the latch.
    public let initialCount: Int
    
    /// Initializer.
    ///
    /// - parameter count: The initial count for the latch.
    public init(count: Int) {
        assert(count > 0, "CountDownLatch must have an initial count that is greater than 0.")
        initialCount = count
        conditionCount = AtomicInt(count)
    }
    
    /// Decrements the latch's count, resuming all awaiting threads if the count reaches zero.
    ///
    /// - note: If the latch is already open, invoking this method has no effects.
    public func countDown() {
        // Use `AtomicInt` to avoid contention during counting down and waiting. This allows the
        // lock to be only acquired at the time when the latch switches from closed to open.
        guard conditionCount.value > 0 else {
            return
        }
        
        let newValue = conditionCount.decrementAndGet()
        // Check for <= since multiple threads can perform decrements concurrently.
        if newValue <= 0 {
            condition.lock()
            condition.broadcast()
            condition.unlock()
        }
    }
    
    /// Causes the current thread to suspend until the latch counts down to zero.
    ///
    /// - note: If the current count is already zero, this method returns immediately without
    /// suspending the current thread.
    ///
    /// - parameter timeout: The optional timeout value in seconds. If the latch is not counted
    /// down to zero before the timeout, this method returns false. If not defined, the current
    /// thread will wait forever until the latch is counted down to zero.
    /// - returns: true if the latch is counted down to zero. false if the timeout occurred before
    /// the latch reaches zero.
    @discardableResult
    public func await(timeout: TimeInterval? = nil) -> Bool {
        // Use `AtomicInt` to avoid contention during counting down and waiting. This allows the
        // lock to be only acquired at the time when the latch switches from closed to open.
        guard conditionCount.value > 0 else {
            return true
        }
        
        let deadline: Date
        if let timeout = timeout {
            deadline = Date().addingTimeInterval(timeout)
        } else {
            deadline = Date.distantFuture
        }
        
        condition.lock()
        defer {
            condition.unlock()
        }
        // Check count again after acquiring the lock, before entering waiting. This ensures the caller
        // does not enter waiting after the last counting down occurs.
        // NSCondition must be run in a loop, since it can wake up randomly without any siganling.
        while conditionCount.value > 0 {
            let result = condition.wait(until: deadline)
            if !result || Date() > deadline {
                return false
            }
        }
        return true
    }
    
    // MARK: - Private
    private let condition = NSCondition()
    // Use `AtomicInt` to avoid contention during counting down and waiting. This allows the
    // lock to be only acquired at the time when the latch switches from closed to open.
    private var conditionCount: AtomicInt
}


