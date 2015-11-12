//
//  Lexer.swift
//  KaleidoscopeLang
//
//  Created by Ben Cochran on 11/8/15.
//  Copyright © 2015 Ben Cochran. All rights reserved.
//

import Either
import Madness
import Prelude

internal typealias TokenParser = Parser<String.CharacterView, Token>.Function
internal typealias TokenArrayParser = Parser<String.CharacterView, [Token]>.Function

// Characters
private let whitespace: CharacterParser = space <|> tab
private let lower: CharacterParser = oneOf("a"..."z")
private let upper: CharacterParser = oneOf("A"..."Z")
private let alpha: CharacterParser = lower <|> upper
private let op: CharacterParser = char("+") <|> char("-") <|> char("*") <|> char("/")
private let paren: CharacterParser =  char("(") <|> char(")")
private let hash: CharacterParser =  char("#")
private let comment: CharacterArrayParser = hash *> many(not(newline) *> any)

// Identifiers
private let identifierCharacters: CharacterArrayParser = not(digit) *> some(alpha <|> char("_") <|> digit)
private let identifierString: StringParser = String.init <^> identifierCharacters

// Tokens
internal let identifierToken: TokenParser = Token.Identifier <^> identifierString
internal let characterToken: TokenParser = Token.Character <^> ( op <|> paren )
internal let defToken: TokenParser = const(.Def) <^> %"def"
internal let externToken: TokenParser = const(.Extern) <^> %"extern"
internal let numberToken: TokenParser = Token.Number <^> Madness.number
internal let endOfStatementToken: TokenParser = const(.EndOfStatement) <^> %";"
internal let token = defToken <|> externToken <|> identifierToken <|> numberToken <|> characterToken <|> endOfStatementToken

private let tokenRun: TokenArrayParser = many(token <* many(whitespace))
private let tokenLine: TokenArrayParser = many(whitespace) *> tokenRun <* comment|?
private let tokenLines: TokenArrayParser = flatten <^> ( many(tokenLine <* newline) )

internal let tokens: TokenArrayParser = maybeConcat <^> tokenLines <*> tokenLine|?


// MARK: Public


public func lex(string: String) -> Either<Error, [Token]> {
    return parse(tokens, input: string).mapLeft(Error.TokenizeError)
}


// MARK: Private helpers

private func maybeConcat<T>(value: [T]) -> [T]? -> [T] {
    return { $0 != nil ? value + $0! : value }
}

private func flatten<T>(value: [[T]]) -> [T] {
    // value.flatten() returns a `FlattenSequence`, so use `flatMap`
    return value.flatMap({ $0 })
}

// Stolen from Madness internals
private func prepend<T>(value: T) -> [T] -> [T] {
    return { [value] + $0 }
}
