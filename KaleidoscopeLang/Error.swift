//
//  Error.swift
//  KaleidoscopeLang
//
//  Created by Ben Cochran on 11/8/15.
//  Copyright © 2015 Ben Cochran. All rights reserved.
//

import Madness

public enum Error : ErrorType {
    case TokenizeError(Madness.Error<String.CharacterView.Index>)
    case TreeError([Token], Madness.Error<Array<Token>.Index>)
}

internal extension Error {
    static func treeError(tokens: [Token])(_ error: Madness.Error<Array<Token>.Index>) -> Error {
        return .TreeError(tokens, error)
    }
}
