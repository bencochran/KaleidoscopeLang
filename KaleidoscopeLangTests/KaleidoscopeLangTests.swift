//
//  KaleidoscopeLangTests.swift
//  KaleidoscopeLangTests
//
//  Created by Ben Cochran on 11/8/15.
//  Copyright © 2015 Ben Cochran. All rights reserved.
//

import XCTest
@testable import KaleidoscopeLang

class LexerTests: XCTestCase {
    func testIdentifier() {
        assertMatched(identifierToken, "a".characters)
        assertMatched(identifierToken, "some".characters)
        assertMatched(identifierToken, "_some".characters)
        assertMatched(identifierToken, "__some_".characters)
        assertMatched(identifierToken, "__some".characters)
        assertUnmatched(identifierToken, "2name".characters)
        assertUnmatched(identifierToken, "2".characters)
    }
    
    func testSimpleExpressions() {
        assertStringToTokens("a+b", [.Identifier("a"), .Character("+"), .Identifier("b")])
        
        assertStringToTokens(
            "def add(a b) a + b",
            [
                .Def, .Identifier("add"),
                .Character("("), .Identifier("a"), .Identifier("b"), .Character(")"),
                .Identifier("a"), .Character("+"), .Identifier("b")
            ]
        )
        
        assertStringToTokens(
            "extern atan2(a b)",
            [
                .Extern, .Identifier("atan2"),
                .Character("("), .Identifier("a"), .Identifier("b"), .Character(")")
            ]
        )
    }
    
    func testMultilineExpressions() {
        assertStringToTokens(
            "def add(a b)\n\ta + b",
            [
                .Def, .Identifier("add"),
                .Character("("), .Identifier("a"), .Identifier("b"), .Character(")"),
                .Identifier("a"), .Character("+"), .Identifier("b")
            ]
        )
    }
    
    func testWhitespaceAtStart() {
        assertStringToTokens(
            "\textern atan2(y x);",
            [
                .Extern, .Identifier("atan2"),
                .Character("("), .Identifier("y"), .Identifier("x"), .Character(")"),
                .EndOfStatement
            ]
        )
    }
}

class ParserTests: XCTestCase {
    func testParser() {
        assertTokensToTopLevelExpression(
            [.Extern, .Identifier("sin"), .Character("("), .Identifier("angle"), .Character(")"), .EndOfStatement],
            PrototypeExpression(name: "sin", args: ["angle"])
        )
    }
}

class CombinedTests: XCTestCase {
    func testExtern() {
        assertStringToTopLevelExpression(
            "extern sin(angle);",
            PrototypeExpression(name: "sin", args: ["angle"])
        )
    }
    
    func testBinaryOperator() {
        assertStringToValueExpression(
            "a + b",
            BinaryOperatorExpression(
                code: "+",
                left: VariableExpression("a"),
                right: VariableExpression("b")
            )
        )
    }
    
    func testComplexBinaryOperator() {
        assertStringToValueExpression(
            "a + sin(b) - c",
            BinaryOperatorExpression(
                code: "+",
                left: VariableExpression("a"),
                right: BinaryOperatorExpression(
                    code: "-",
                    left: CallExpression(
                        callee: "sin",
                        args: [ VariableExpression("b") ]
                    ),
                    right: VariableExpression("c")
                )
            )
        )
    }
    
    func testDefinition() {
        assertStringToTopLevelExpression(
            "def add(a b) a + b;",
            FunctionExpression(
                prototype: PrototypeExpression(
                    name: "add",
                    args: [ "a", "b" ]
                ),
                body: BinaryOperatorExpression(
                    code: "+",
                    left: VariableExpression("a"),
                    right: VariableExpression("b")
                )
            )
        )
    }
    
    func testComments() {
        assertStringToTokens(
            "a + b; # this is addition\n",
            [.Identifier("a"), .Character("+"), .Identifier("b"), .EndOfStatement]
        )
        
        assertStringToTokens("# this is only a comment\n", [])
    }
    
    func testTopLevelNumbers() {
        assertStringToValueExpression("0", NumberExpression(0))
        assertStringToValueExpression("00.00", NumberExpression(0))
        assertStringToValueExpression("10.0", NumberExpression(10))
        assertStringToValueExpression("10.01", NumberExpression(10.01))
    }
}
