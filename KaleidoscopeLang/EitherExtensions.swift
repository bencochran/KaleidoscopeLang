//
//  EitherExtensions.swift
//  KaleidoscopeLang
//
//  Created by Ben Cochran on 11/8/15.
//  Copyright © 2015 Ben Cochran. All rights reserved.
//

import Either

internal extension Either {
    /// Maps `Left` values with `transform`, and re-wraps `Right` values.
    internal func mapLeft<V>(@noescape transform: T -> V) -> Either<V, U> {
        return flatMapLeft { .left(transform($0)) }
    }
    
    /// Returns the result of applying `transform` to `Left` values, or re-wrapping `Right` values.
    internal func flatMapLeft<V>(@noescape transform: T -> Either<V, U>) -> Either<V, U> {
        return either(
            ifLeft: transform,
            ifRight: Either<V, U>.right)
    }
}
