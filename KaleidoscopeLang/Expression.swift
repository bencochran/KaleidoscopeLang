//
//  Expression.swift
//  KaleidoscopeLang
//
//  Created by Ben Cochran on 11/8/15.
//  Copyright © 2015 Ben Cochran. All rights reserved.
//

// MARK: Types

public protocol Expression {
    // The ol’ non-self-requirement protocol dance
    func equals(other: Expression) -> Bool
}
public protocol ValueExpression : Expression { }
public protocol TopLevelExpression : Expression { }

extension Expression where Self : Equatable {
    public func equals(other: Expression) -> Bool {
        if let other = other as? Self { return self == other }
        return false
    }
}
public func == <E: Expression> (left: E, right: E) -> Bool {
    return left.equals(right)
}

// MARK: Number

public struct NumberExpression : ValueExpression, Equatable {
    public let value: Double
    public init(_ value: Double) {
        self.value = value
    }
}
public func == (left: NumberExpression, right: NumberExpression) -> Bool {
    return left.value == right.value
}

// MARK: Variable

public struct VariableExpression : ValueExpression, Equatable {
    public let name: String
    public init(_ name: String) {
        self.name = name
    }
}
public func == (left: VariableExpression, right: VariableExpression) -> Bool {
    return left.name == right.name
}

// MARK: BinaryOperator

public struct BinaryOperatorExpression : ValueExpression, Equatable {
    public let code: Character
    public let left: ValueExpression
    public let right: ValueExpression
    public init(code: Character, left: ValueExpression, right: ValueExpression) {
        self.code = code
        self.left = left
        self.right = right
    }
}
public func == (left: BinaryOperatorExpression, right: BinaryOperatorExpression) -> Bool {
    return left.code == right.code
        && left.left.equals(right.left)
        && left.right.equals(right.right)
}

// MARK: Call

public struct CallExpression : ValueExpression, Equatable {
    public let callee: String
    public let args: [ValueExpression]
    public init(callee: String, args: [ValueExpression]) {
        self.callee = callee
        self.args = args
    }
}
public func == (left: CallExpression, right: CallExpression) -> Bool {
    return left.callee == right.callee
        && zip(left.args, right.args).map({ $0.equals($1) }).reduce(true, combine: { $0 && $1 })
}

// MARK: Prototype

public struct PrototypeExpression : TopLevelExpression, Equatable {
    public let name: String
    public let args: [String]
    public init(name: String, args: [String]) {
        self.name = name
        self.args = args
    }
}
public func == (left: PrototypeExpression, right: PrototypeExpression) -> Bool {
    return left.name == right.name
        && left.args == right.args
}

// MARK: Function

public struct FunctionExpression : TopLevelExpression, Equatable {
    public let prototype: PrototypeExpression
    public let body: ValueExpression
    public init(prototype: PrototypeExpression, body: ValueExpression) {
        self.prototype = prototype
        self.body = body
    }
}
public func == (left: FunctionExpression, right: FunctionExpression) -> Bool {
    return left.prototype == right.prototype
        && left.body.equals(right.body)
}
