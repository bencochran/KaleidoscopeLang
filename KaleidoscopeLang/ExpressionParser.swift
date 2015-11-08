//
//  ExpressionParser.swift
//  KaleidoscopeLang
//
//  Created by Ben Cochran on 11/8/15.
//  Copyright © 2015 Ben Cochran. All rights reserved.
//

import Madness
import Prelude
import Either

typealias ExpressionParser = Parser<[Token], Expression>.Function

// MARK: Token Types

private let isNumber: Token -> Bool = { $0.number != nil }
private let isIdentifier: Token -> Bool = { $0.identifier != nil }
private let isOperator: Token -> Bool = { $0.character != nil }

// MARK: Grammar

/// variable ::= Identifier
private let variable: ExpressionParser = { Expression.Variable($0.identifier!) } <^> satisfy(isIdentifier)

private let expression: ExpressionParser = fix { expression in
    /// number ::= Number
    let number: ExpressionParser = { Expression.Number($0.number!) } <^> satisfy(isNumber)
    
    /// parenExpression ::= "(" expression ")"
    let parenExpression = %(.Character("(")) *> expression <* %(.Character(")"))
    
    /// callargs ::= "(" expression* ")"
    let callargs = %(.Character("(")) *> expression* <* %(.Character(")"))
    
    /// call ::= variable callargs
    let call = { Expression.Call(callee: $0.variable!, args: $1) } <^> (lift(pair) <*> variable <*> callargs)
    
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
        Token.Character("+"),
        Token.Character("-"),
        Token.Character("*"),
        Token.Character("/")
    ])
    
    /// infixRight ::= infixOperator primary
    let infixRight = lift(pair) <*> infixOperator <*> primary
    
    /// infix ::= primary infixRight*
    let repackedInfix = map(id, { ArraySlice($0) }) <^> (lift(pair) <*> primary <*> infixRight*)
    let infix: ExpressionParser = collapsePackedInfix <^> repackedInfix
    
    /// expression
    ///     ::= infix
    ///     ::= primary
    return infix <|> primary
}

private func foldPrototype(name: Expression, args: [Expression]) -> Expression {
    return Expression.Prototype(name: name.variable!, args: args.map({$0.variable!}))
}

/// prototypeArgs ::= "(" variable* ")"
private let prototypeArgs = %(.Character("(")) *> variable* <* %(.Character(")"))

/// prototype ::= variable prototypeArgs
private let prototype = foldPrototype <^> (lift(pair) <*> variable <*> prototypeArgs)

/// definition ::= "def" prototype expression
private let definition: ExpressionParser = Expression.Function <^> (%(Token.Def) *> lift(pair) <*> prototype <*> expression)

/// external ::= "extern" prototype
private let external = %(Token.Extern) *> prototype

/// top
///     ::= definition
///     ::= external
///     ::= expression
///     ::= ";"
private let top = definition <|> external <|> expression

internal let topLevelExpression = top

// MARK: Public

public func parseTopLevelExpression(string: String) -> Either<Error, Expression> {
    return tokenizeTopLevelExpression(string)
        .flatMap { (tokens: [Token]) -> Either<Error, Expression> in
            return parse(top, input: tokens).mapLeft(Error.treeError(tokens))
        }
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
