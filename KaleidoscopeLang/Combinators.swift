//
//  Combinators.swift
//  KaleidoscopeLang
//
//  Created by Ben Cochran on 11/11/15.
//  Copyright © 2015 Ben Cochran. All rights reserved.
//

import Madness
import Either

internal func oneOf<I: IntervalType where I.Bound == Character>(interval: I) -> CharacterParser {
    return satisfy { interval.contains($0) }
}

internal func attempt<C: CollectionType, T> (f: C.Generator.Element -> T?) -> Parser<C, T>.Function {
    return { input, sourcePos in
        let index = sourcePos.index
        if index != input.endIndex {
            let parsed = input[index]
            
            if let result = f(parsed) {
                return .Right((result, updateIndex(sourcePos, sourcePos.index.advancedBy(1))))
            } else {
                return .Left(Madness.Error.leaf("Failed to parse \(String(parsed)) with `let` at index", sourcePos))
            }
            
        } else {
            return .Left(Madness.Error.leaf("Failed to parse at end of input", sourcePos))
        }
    }
}

