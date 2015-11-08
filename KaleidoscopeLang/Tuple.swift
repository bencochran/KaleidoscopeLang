//
//  Tuple.swift
//  KaleidoscopeLang
//
//  Created by Ben Cochran on 11/8/15.
//  Copyright © 2015 Ben Cochran. All rights reserved.
//

/// Curried tuple map
internal func map<A,B,T,U>(f1: A -> T, _ f2: B -> U)(_ tuple: (A, B)) -> (T, U) {
    return (
        f1(tuple.0),
        f2(tuple.1)
    )
}
