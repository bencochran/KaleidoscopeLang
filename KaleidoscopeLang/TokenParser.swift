//
//  TokenParser.swift
//  KaleidoscopeLang
//
//  Created by Ben Cochran on 11/8/15.
//  Copyright © 2015 Ben Cochran. All rights reserved.
//

import Either
import Madness
import Prelude

private typealias TokenParser = Parser<String.CharacterView, Token>.Function
internal typealias TokenArrayParser = Parser<String.CharacterView, [Token]>.Function

// Characters
private let whitespace: CharacterParser = space <|> tab
private let lower: CharacterParser = oneOf("a"..."z")
private let upper: CharacterParser = oneOf("A"..."Z")
private let alpha: CharacterParser = lower <|> upper
private let op: CharacterParser = char("+") <|> char("-") <|> char("*") <|> char("/")
private let paren: CharacterParser =  char("(") <|> char(")")

// Identifiers
private let identifierStart: CharacterParser = alpha <|> char("_")
private let identifierFinish: CharacterParser = identifierStart <|> digit
private let identifierCharacters: CharacterArrayParser = prepend <^> identifierStart <*> many(identifierFinish)
private let identifierString: StringParser = String.init <^> identifierCharacters

// Tokens
private let identifier: TokenParser = Token.Identifier <^> identifierString
private let character: TokenParser = Token.Character <^> (op <|> paren)
private let def: TokenParser = const(.Def) <^> %"def"
private let extern: TokenParser = const(.Extern) <^> %"extern"
private let number: TokenParser = Token.Number <^> Madness.number
private let token = def <|> extern <|> identifier <|> number <|> character

internal let tokens: TokenArrayParser = many((token <* many(whitespace))) <* newline|?


// MARK: Public


public func tokenizeTopLevelExpression(string: String) -> Either<Error, [Token]> {
    return parse(tokens, input: string).mapLeft(Error.TokenizeError)
}


// MARK: Private helpers


// Stolen from Madness internals
private func prepend<T>(value: T) -> [T] -> [T] {
    return { [value] + $0 }
}

private func oneOf<I: IntervalType where I.Bound == Character>(interval: I) -> CharacterParser {
    return satisfy { interval.contains($0) }
}
