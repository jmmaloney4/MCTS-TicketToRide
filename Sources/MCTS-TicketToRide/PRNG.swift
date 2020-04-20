//
//  PRNG.swift
//  ArgumentParser
//
//  Created by Jack Maloney on 4/20/20.
//

import Foundation
import Squall
import Concurrency

typealias RNG = Gust

private var RNG_OFFSET: AtomicInt = AtomicInt(initialValue: 0)

func makeRNG() -> RNG {
    return newGust(RNG_OFFSET.incrementAndGet())
    //return PRNG(RNG_OFFSET.incrementAndGet())
}

private let A: UInt32 = 15342; // any number in (0, RAND_MAX)
private let C: UInt32 = 45194; // any number in [0, RAND_MAX)

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
