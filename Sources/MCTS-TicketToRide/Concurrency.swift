//
//  Concurrency.swift
//  ArgumentParser
//
//  Created by Jack Maloney on 4/21/20.
//

import Foundation
import Dispatch

func synchronized<T>(_ lock: NSLock, _ body: () throws -> T) rethrows -> T {
    lock.lock()
    defer { lock.unlock() }
    return try body()
}

struct Atomic<T> {
    private var _value: T
    private var lock: NSLock
    
    init(_ initialValue: T) {
        _value = initialValue
        lock = NSLock()
        defer { lock.unlock() }
    }
    
    var value: T {
        get {
            lock.lock()
            defer { lock.unlock() }
            return self._value
        }
    }
    
    @discardableResult
    mutating func getAndSet(_ newValue: T) -> T {
        lock.lock()
        defer { lock.unlock() }
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
        lock.lock()
        defer { lock.unlock() }
        _value += 1
        return _value
    }
    
    mutating func increment() {
        lock.lock()
        defer { lock.unlock() }
        _value += 1
    }
    
    mutating func decrementAndGet() -> Int {
        lock.lock()
        defer { lock.unlock() }
        _value -= 1
        return _value
    }
}

typealias AtomicInt = Atomic<Int>
typealias AtomicBool = Atomic<Bool>
