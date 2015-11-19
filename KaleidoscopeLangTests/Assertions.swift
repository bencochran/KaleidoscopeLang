//
//  Assertions.swift
//  KaleidoscopeLang
//
//  Created by Ben Cochran on 11/11/15.
//  Copyright © 2015 Ben Cochran. All rights reserved.
//

import XCTest
import Madness
import Either
@testable import KaleidoscopeLang

func assert<T>(left: T?, _ match: (T, T) -> Bool, _ right: T?, message: String = "", file: String = __FILE__, line: UInt = __LINE__) {
    switch (left, right) {
    case (.None, .None):
        break;
    case let (.Some(l), .Some(r)) where match(l, r):
        break;
    case let (.Some(l), .Some(r)):
        XCTFail("\(String(reflecting: l)) did not match \(String(reflecting: r)). " + message, file: file, line: line)
    case let (.Some(l), .None):
        XCTFail("\(String(reflecting: l)) did not match nil. " + message, file: file, line: line)
    case let (.None, .Some(r)):
        XCTFail("nil did not match \(String(reflecting: r)). " + message, file: file, line: line)
    }
}

func assertMatched<C: CollectionType, T>(parser: Parser<C,T>.Function, _ input: C, message: String = "", file: String = __FILE__, line: UInt = __LINE__) {
    switch parse(parser, input: input) {
    case .Left(_):
        XCTFail("should have matched \(input). " + message, file: file, line: line)
    case .Right(_):
        break;
    }
}


func assertUnmatched<C: CollectionType, T>(parser: Parser<C,T>.Function, _ input: C, message: String = "", file: String = __FILE__, line: UInt = __LINE__) {
    switch parse(parser, input: input) {
    case .Left(_):
        break
    case .Right(_):
        XCTFail("should not have matched \(input). " + message, file: file, line: line)
    }
}

func assertStringToTokens(string: String, _ tokens: [Token], message: String = "", file: String = __FILE__, line: UInt = __LINE__) {
    let parsed = lex(string)
    assert(parsed.right, ==, tokens, message: message, file: file, line: line)
}

func assertTokensToTopLevelExpression(tokens: [Token], _ expression: TopLevelExpression, message: String = "", file: String = __FILE__, line: UInt = __LINE__) {
    let parsed = parseTopLevelExpression(tokens)
    assert(parsed.right, ==, expression, message: message, file: file, line: line)
}

func assertTokensToValueExpression(tokens: [Token], _ expression: ValueExpression, message: String = "", file: String = __FILE__, line: UInt = __LINE__) {
    let parsed = parseValueExpression(tokens)
    assert(parsed.right, ==, expression, message: message, file: file, line: line)
}

func assertStringToTopLevelExpression(string: String, _ expression: TopLevelExpression, message: String = "", file: String = __FILE__, line: UInt = __LINE__) {
    let parsed = parseTopLevelExpression(string)
    assert(parsed.right, ==, expression, message: message, file: file, line: line)
}

func assertStringToValueExpression(string: String, _ expression: ValueExpression, message: String = "", file: String = __FILE__, line: UInt = __LINE__) {
    let parsed = parseValueExpression(string)
    assert(parsed.right, ==, expression, message: message, file: file, line: line)
}

func == (left: Expression, right: Expression) -> Bool {
    return left.equals(right)
}
