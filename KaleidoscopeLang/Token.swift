//
//  Token.swift
//  KaleidoscopeLang
//
//  Created by Ben Cochran on 11/8/15.
//  Copyright © 2015 Ben Cochran. All rights reserved.
//

public enum Token {
    case Def
    case Extern
    case Identifier(String)
    case Number(Double)
    case Character(Swift.Character)
    case EndOfStatement
}

public extension Token {
    public var number: Double? {
        switch self {
        case let .Number(number): return number
        default: return nil
        }
    }
    
    public var identifier: String? {
        switch self {
        case let .Identifier(identifier): return identifier
        default: return nil
        }
    }
    
    public var character: Swift.Character? {
        switch self {
        case let .Character(character): return (character)
        default: return nil
        }
    }
}


extension Token : Equatable {}
public func == (lhs: Token, rhs: Token) -> Bool {
    switch (lhs, rhs) {
    case (.Def, .Def): return true
    case (.Extern, .Extern): return true
    case let (.Identifier(l), .Identifier(r)): return l == r
    case let (.Number(l), .Number(r)): return l == r
    case let (.Character(l), .Character(r)): return l == r
    case (.EndOfStatement, .EndOfStatement): return true
    default: return false
    }
}
