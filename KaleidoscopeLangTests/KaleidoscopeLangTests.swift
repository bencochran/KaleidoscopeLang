//
//  KaleidoscopeLangTests.swift
//  KaleidoscopeLangTests
//
//  Created by Ben Cochran on 11/8/15.
//  Copyright © 2015 Ben Cochran. All rights reserved.
//

import XCTest
@testable import KaleidoscopeLang

class KaleidoscopeLangTests: XCTestCase {
    func testTokenizer() {
        assertStringToTokens("a+b", [.Identifier("a"), .Character("+"), .Identifier("b")])

        assertStringToTokens("def add(a b) a + b", [.Def, .Identifier("add"), .Character("("), .Identifier("a"), .Identifier("b"), .Character(")"), .Identifier("a"), .Character("+"), .Identifier("b")])


        assertStringToTokens("def add(a b)\n\ta + b", [.Def, .Identifier("add"), .Character("("), .Identifier("a"), .Identifier("b"), .Character(")"), .Identifier("a"), .Character("+"), .Identifier("b")])

        assertStringToTokens("extern atan2(a b)", [.Extern, .Identifier("atan2"), .Character("("), .Identifier("a"), .Identifier("b"), .Character(")")])


        assertStringToTokens("\textern atan2(y x);", [.Extern, .Identifier("atan2"), .Character("("), .Identifier("y"), .Identifier("x"), .Character(")"), .EndOfStatement])
    }
    
    func testParser() {
        assertTokensToExpression(
            [.Extern, .Identifier("sin"), .Character("("), .Identifier("angle"), .Character(")"), .EndOfStatement],
            .Prototype(name: "sin", args: ["angle"])
        )
    }
    
    func testCombination() {
        assertStringToExpression(
            "extern sin(angle);",
            .Prototype(name: "sin", args: ["angle"])
        )
        
        assertStringToExpression(
            "a + b;",
            .BinaryOperator(
                code: "+",
                left: .Variable("a"),
                right: .Variable("b")
            )
        )

        assertStringToExpression(
            "a + sin(b) - c;",
            .BinaryOperator(
                code: "+",
                left: .Variable("a"),
                right: .BinaryOperator(
                    code: "-",
                    left: .Call(
                        callee: "sin",
                        args: [ .Variable("b") ]
                    ),
                    right: .Variable("c")
                )
            )
        )
        
        assertStringToExpression(
            "def add(a b) a + b;",
            .Function(
                prototype: .Prototype(
                    name: "add",
                    args: [ "a", "b" ]
                ),
                body: .BinaryOperator(
                    code: "+",
                    left: .Variable("a"),
                    right: .Variable("b")
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
    
    
    func testNumbers() {
        assertStringToExpression("0;", .Number(0))
        assertStringToExpression("00.00;", .Number(0))
        assertStringToExpression("10.0;", .Number(10))
        assertStringToExpression("10.01;", .Number(10.01))
    }
}
