//
//  Expression.swift
//  KaleidoscopeLang
//
//  Created by Ben Cochran on 11/8/15.
//  Copyright © 2015 Ben Cochran. All rights reserved.
//

public indirect enum Expression {
    case Number(Double)
    case Variable(String)
    case BinaryOperator(code: Character, left: Expression, right: Expression)
    case Call(callee: String, args: [Expression])
    case Prototype(name: String, args: [String])
    case Function(prototype: Expression, body: Expression)
}

extension Expression : Equatable {}
public func == (lhs: Expression, rhs: Expression) -> Bool {
    switch (lhs, rhs) {
    case let (.Number(l1), .Number(r1)): return l1 == r1
    case let (.Variable(l1), .Variable(r1)): return l1 == r1
    case let (.BinaryOperator(l1, l2, l3), .BinaryOperator(r1, r2, r3)): return l1 == r1 && l2 == r2 && l3 == r3
    case let (.Call(l1, l2), .Call(r1, r2)): return l1 == r1 && l2 == r2
    case let (.Prototype(l1, l2), .Prototype(r1, r2)): return l1 == r1 && l2 == r2
    case let (.Function(l1, l2), .Function(r1, r2)): return l1 == r1 && l2 == r2
    default: return false
    }
}

internal extension Expression {
    internal var number: Double? {
        switch self {
        case let .Number(number): return number
        default: return nil
        }
    }
    
    internal var variable: String? {
        switch self {
        case let .Variable(variable): return variable
        default: return nil
        }
    }
    
    internal var binaryOperator: (code: Character, left: Expression, right: Expression)? {
        switch self {
        case let .BinaryOperator(code, left, right): return (code, left, right)
        default: return nil
        }
    }
    
    internal var call: (callee: String, args: [Expression])? {
        switch self {
        case let .Call(callee, args): return (callee, args)
        default: return nil
        }
    }
    
    internal var prototype: (name: String, args: [String])? {
        switch self {
        case let .Prototype(name, args): return (name, args)
        default: return nil
        }
    }
    
    internal var function: (prototype: Expression, body: Expression)? {
        switch self {
        case let .Function(prototype, body): return (prototype, body)
        default: return nil
        }
    }
}

