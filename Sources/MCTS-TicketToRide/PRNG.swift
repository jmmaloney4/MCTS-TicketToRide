//
//  PRNG.swift
//  ArgumentParser
//
//  Created by Jack Maloney on 4/20/20.
//

import Foundation
import Squall

typealias RNG = SystemRandomNumberGenerator

private var RNG_OFFSET: AtomicInt = AtomicInt(0)

func makeRNG() -> RNG {
    // return Gust(offset: UInt32(RNG_OFFSET.incrementAndGet()))
    return SystemRandomNumberGenerator()
    // return PRNG(RNG_OFFSET.incrementAndGet())
}

private let A: UInt32 = 514229; // any number in (0, RAND_MAX)
private let C: UInt32 = 31397; // any number in [0, RAND_MAX)

class PRNG: RandomNumberGenerator {
    var prev: UInt32
    init(_ offset: Int) {
        self.prev = UInt32(offset)
    }
    
    func next<T>() -> T where T : FixedWidthInteger, T : UnsignedInteger {
        let a = prev.multipliedReportingOverflow(by: A).partialValue
        let b = a.addingReportingOverflow(C).partialValue
        let c = b.remainderReportingOverflow(dividingBy: UInt32.max).partialValue
        prev = c;
        return T(prev)
    }
}
