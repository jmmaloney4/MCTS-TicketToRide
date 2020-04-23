//
//  PRNG.swift
//  ArgumentParser
//
//  Created by Jack Maloney on 4/20/20.
//

import Foundation
import Squall
import PSWyhash

typealias RNG = WyRandomGenerator

private var RNG_OFFSET: AtomicInt = AtomicInt(0)

func makeRNG() -> RNG {
    // return Gust(offset: UInt32(RNG_OFFSET.incrementAndGet()))
    // return SystemRandomNumberGenerator()
    // return PRNG(RNG_OFFSET.incrementAndGet())
    // return WyRand(seed: UInt64(RNG_OFFSET.incrementAndGet()) + UInt64(Date().timeIntervalSince1970.rounded()))
    return WyRandomGenerator(seed: UInt64(RNG_OFFSET.incrementAndGet()) + UInt64(Date().timeIntervalSince1970.rounded()))
}

private let P: UInt64 = 514229;
private let Q: UInt64 = 31397;
var M: UInt64 = P * Q;

func gcd(_ A: UInt64, B: UInt64) -> UInt64 {
    var a = A
    var b = B
    while(a != b) {
        if(a > b) {
            a = a - b;
        } else {
            b = b - a;
        }
    }
    return a;
}

struct PRNG: RandomNumberGenerator {
    var prev: UInt64
    init(_ offset: Int) {
        var seed = UInt64((Date().timeIntervalSinceReferenceDate)) + UInt64(offset)
        while gcd(seed, B: M) != 1 {
            seed = seed.addingReportingOverflow(UInt64(UInt16.max - 1)).partialValue
        }
        self.prev = seed
    }
    
    public mutating func next() -> UInt64 {
        var x = self.prev
        x = x.multipliedReportingOverflow(by: x).partialValue
        x = x.remainderReportingOverflow(dividingBy: M).partialValue
        self.prev = x
        print(self.prev)
        return self.prev
    }
    
    public mutating func next<T>() -> T where T : FixedWidthInteger, T : UnsignedInteger {
        return T(self.next())
    }
    
    public mutating func next<T>(upperBound: T) -> T where T : FixedWidthInteger, T : UnsignedInteger {
        return T(self.next()).remainderReportingOverflow(dividingBy: upperBound).partialValue
    }
}
