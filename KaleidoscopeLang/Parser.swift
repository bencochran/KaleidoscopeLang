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

internal typealias ValueExpressionParser = Parser<[Token], ValueExpression>.Function
internal typealias TopLevelExpressionParser = Parser<[Token], TopLevelExpression>.Function
internal typealias ExpressionParser = Parser<[Token], Expression>.Function

// MARK: Token unwrappers

private let identifier: Parser<[Token], String>.Function = attempt { $0.identifier }
private let double: Parser<[Token], Double>.Function = attempt { $0.number }

// MARK: Value expressions

private let valueExpression: ValueExpressionParser = fix { valueExpression in
    /// variable ::= Identifier
    let variable: ValueExpressionParser = VariableExpression.init <^> identifier
    
    /// number ::= Number
    let number: ValueExpressionParser = NumberExpression.init <^> double
    
    /// parenExpression ::= "(" valueExpression ")"
    let parenExpression = %(.Character("(")) *> valueExpression <* %(.Character(")"))
    
    /// callargs ::= "(" valueExpression* ")"
    let callargs = %(.Character("(")) *> many(valueExpression) <* %(.Character(")"))
    
    /// call ::= Identifier callargs
    let call: ValueExpressionParser = CallExpression.init <^> ( lift(pair) <*> identifier <*> callargs )
    
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
    let repackedInfix = map(id, ArraySlice.init) <^> ( lift(pair) <*> primary <*> many(infixRight) )
    let infix: ValueExpressionParser = collapsePackedInfix <^> repackedInfix
    
    /// valueExpression
    ///     ::= infix
    ///     ::= primary
    return infix <|> primary
}

// MARK: Top-level expressions

/// prototypeArgs ::= "(" Identifier* ")"
private let prototypeArgs = %(.Character("(")) *> many(identifier) <* %(.Character(")"))

/// prototype ::= Identifier prototypeArgs
private let prototype = PrototypeExpression.init <^> ( lift(pair) <*> identifier <*> prototypeArgs )

/// definition ::= "def" prototype expression
private let definition: TopLevelExpressionParser = FunctionExpression.init <^> ( %(Token.Def) *> lift(pair) <*> prototype <*> valueExpression )

/// external ::= "extern" prototype
private let external: TopLevelExpressionParser = id <^> ( %(Token.Extern) *> prototype )

/// top
///     ::= definition
///     ::= external
private let top = definition <|> external

/// topLevelExpression ::= top EndOfStatement
internal let topLevelExpression = top <* %(.EndOfStatement)

/// expression
///     ::= topLevelExpression
///     ::= valueExpression
internal let expression = topLevelExpression <|> valueExpression


// MARK: Public

/// Parse a series of tokens into a value expression
public func parseValueExpression(tokens: [Token]) -> Either<Error, ValueExpression> {
    return parse(valueExpression, input: tokens).mapLeft(Error.treeError(tokens))
}
/// Lex and parse a string into a value expression
public func parseValueExpression(string: String) -> Either<Error, ValueExpression> {
    return lex(string) >>- parseValueExpression
}

/// Parse a series of tokens into a top-level expression
public func parseTopLevelExpression(tokens: [Token]) -> Either<Error, TopLevelExpression> {
    return parse(topLevelExpression, input: tokens).mapLeft(Error.treeError(tokens))
}

/// Lex and parse a string into a top-level expression
public func parseTopLevelExpression(string: String) -> Either<Error, TopLevelExpression> {
    return lex(string) >>- parseTopLevelExpression
}

/// Parse a series of tokens into a value or top-level expression
public func parse(tokens: [Token]) -> Either<Error, Expression> {
    return parse(expression, input: tokens).mapLeft(Error.treeError(tokens)).map(collapseExpression)
}

/// Lex and parse a string into a value or top-level expression
public func parse(string: String) -> Either<Error, Expression> {
    return lex(string) >>- parse
}

// MARK: Private

private func collapseExpression(expression: Either<TopLevelExpression, ValueExpression>) -> Expression {
    return expression.either(ifLeft: id, ifRight: id)
}

// MARK: Infix Helpers

private func collapsePackedInfix(binop: (ValueExpression, ArraySlice<(Token, ValueExpression)>)) -> ValueExpression {
    // Recursion base
    guard let rightHalf = binop.1.first else { return binop.0 }
    
    let code = rightHalf.0.character!
    let rest = (rightHalf.1, binop.1.dropFirst())
    let left = binop.0
    return BinaryOperatorExpression(code: code, left: left, right: collapsePackedInfix(rest))
}
