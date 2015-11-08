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

// Stolen from Madness internals
private func prepend<T>(value: T) -> [T] -> [T] {
    return { [value] + $0 }
}

private let newline = %"\n"
private let whitespace = %" " <|> %"\t"
private let lower = %("a"..."z")
private let upper = %("A"..."Z")
private let digit = %("0"..."9")
private let alpha = lower <|> upper
private let digits = { $0.joinWithSeparator("") } <^> digit+
private let op = %"+" <|> %"-" <|> %"*" <|> %"/"
private let paren =  %"(" <|> %")"

private let def: TokenParser = const(.Def) <^> %"def"
private let extern: TokenParser = const(.Extern) <^> %"extern"
private let identifierStart = alpha <|> %"_"
private let identifierFinish = identifierStart <|> digit
private let identifierCharacters = prepend <^> identifierStart <*> identifierFinish*
private let identifierString = { $0.joinWithSeparator("") } <^> identifierCharacters
private let identifier: TokenParser = Token.Identifier <^> identifierString
private let character: TokenParser = Token.Character <^> (Character.init <^> (op <|> paren))

private let number: TokenParser = Token.Number <^> ({ Double($0)! } <^> digits)
private let token = def <|> extern <|> identifier <|> number <|> character
internal let tokens: TokenArrayParser = (token <* whitespace*)* <* newline|?

// MARK: Public

public func tokenizeTopLevelExpression(string: String) -> Either<Error, [Token]> {
    return parse(tokens, input: string).mapLeft(Error.TokenizeError)
}
