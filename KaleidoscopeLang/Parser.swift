//
//  Parser.swift
//  KaleidoscopeLang
//
//  Created by Ben Cochran on 11/8/15.
//  Copyright © 2015 Ben Cochran. All rights reserved.
//

import Madness
import Prelude
import Either

typealias ExpressionParser = Parser<[Token], Expression>.Function

// MARK: Token unwrappers

private let identifier: Parser<[Token], String>.Function = attempt { $0.identifier }
private let double: Parser<[Token], Double>.Function = attempt { $0.number }

// MARK: Grammar

private let expression: ExpressionParser = fix { expression in
    /// variable ::= Identifier
    let variable: ExpressionParser = Expression.Variable <^> identifier
    
    /// number ::= Number
    let number: ExpressionParser = Expression.Number <^> double
    
    /// parenExpression ::= "(" expression ")"
    let parenExpression = %(.Character("(")) *> expression <* %(.Character(")"))
    
    /// callargs ::= "(" expression* ")"
    let callargs = %(.Character("(")) *> many(expression) <* %(.Character(")"))
    
    /// call ::= Identifier callargs
    let call = Expression.Call <^> (lift(pair) <*> identifier <*> callargs)
    
    /// primary
    ///     ::= call
    ///     ::= variable
    ///     ::= number
    ///     ::= parenExpression
    let primary = call <|> variable <|> number <|> parenExpression
    
    /// infixOperator
    ///     ::= "+"
    ///     ::= "-"
    ///     ::= "*"
    ///     ::= "/"
    let infixOperator: Parser<[Token], Token>.Function = oneOf([
        .Character("+"),
        .Character("-"),
        .Character("*"),
        .Character("/")
    ])
    
    /// infixRight ::= infixOperator primary
    let infixRight = lift(pair) <*> infixOperator <*> primary
    
    /// infix ::= primary infixRight*
    let repackedInfix = map(id, ArraySlice.init) <^> (lift(pair) <*> primary <*> many(infixRight))
    let infix: ExpressionParser = collapsePackedInfix <^> repackedInfix
    
    /// expression
    ///     ::= infix
    ///     ::= primary
    return infix <|> primary
}

/// prototypeArgs ::= "(" Identifier* ")"
private let prototypeArgs = %(.Character("(")) *> many(identifier) <* %(.Character(")"))

/// prototype ::= Identifier prototypeArgs
private let prototype = Expression.Prototype <^> (lift(pair) <*> identifier <*> prototypeArgs)

/// definition ::= "def" prototype expression
private let definition: ExpressionParser = Expression.Function <^> (%(Token.Def) *> lift(pair) <*> prototype <*> expression)

/// external ::= "extern" prototype
private let external = %(Token.Extern) *> prototype

/// top
///     ::= definition
///     ::= external
///     ::= expression
private let top = definition <|> external <|> expression

/// topLevelExpression ::= top EndOfStatement
internal let topLevelExpression = top <* %(.EndOfStatement)

// MARK: Public

public func parse(tokens: [Token]) -> Either<Error, Expression> {
    return parse(topLevelExpression, input: tokens).mapLeft(Error.treeError(tokens))
}

public func parse(string: String) -> Either<Error, Expression> {
    return lex(string) >>- parse
}

// MARK: Infix Helpers

private extension Expression {
    static func rightAssociativeBinaryOperator(code: Character, left: Expression)(right: Expression) -> Expression {
        return .BinaryOperator(code: code, left: left, right: right)
    }
}

private func collapsePackedInfix(binop: (Expression, ArraySlice<(Token, Expression)>)) -> Expression {
    guard let rightHalf = binop.1.first else { return binop.0 }
    let code = rightHalf.0.character!
    let rest = (rightHalf.1, binop.1.dropFirst())
    let left = binop.0
    return Expression.rightAssociativeBinaryOperator(code, left: left)(right: collapsePackedInfix(rest))
}
