//
//  KaleidoscopeLangTests.swift
//  KaleidoscopeLangTests
//
//  Created by Ben Cochran on 11/8/15.
//  Copyright © 2015 Ben Cochran. All rights reserved.
//

import XCTest
import Madness
@testable import KaleidoscopeLang


// These should be better. (e.g. Don’t force-unwrap the result & pull out common
// assertion patterns). And the the coverage should be higher.

class KaleidoscopeLangTests: XCTestCase {
    func testTokenizer() {
        XCTAssert(
            tokenizeTopLevelExpression("a+b").right!
            ==
            [.Identifier("a"), .Character("+"), .Identifier("b")]
        )
        
        XCTAssert(
            tokenizeTopLevelExpression("def add(a b) a + b").right!
            ==
            [.Def, .Identifier("add"), .Character("("), .Identifier("a"), .Identifier("b"), .Character(")"), .Identifier("a"), .Character("+"), .Identifier("b")]
        )

            
        XCTAssert(
            tokenizeTopLevelExpression("extern atan2(a b)").right!
            ==
            [.Extern, .Identifier("atan2"), .Character("("), .Identifier("a"), .Identifier("b"), .Character(")")]
        )

        XCTAssert(
            tokenizeTopLevelExpression("\textern atan2(y x);").right!
            ==
            [.Extern, .Identifier("atan2"), .Character("("), .Identifier("y"), .Identifier("x"), .Character(")"), .EndOfStatement]
        )
    }
    
    func testParser() {
        let extern: [Token] = [.Extern, .Identifier("sin"), .Character("("), .Identifier("angle"), .Character(")"), .EndOfStatement]
        XCTAssert(
            parse(topLevelExpression, input: extern).right!
            ==
            .Prototype(name: "sin", args: ["angle"])
        )
    }
    
    func testCombination() {
        XCTAssert(
            parseTopLevelExpression("extern sin(angle);").right!
            ==
            .Prototype(name: "sin", args: ["angle"])
        )
        
        XCTAssert(
            parseTopLevelExpression("a + b;").right!
            ==
            .BinaryOperator(code: "+", left: .Variable("a"), right: .Variable("b"))
        )

        XCTAssert(
            parseTopLevelExpression("a + sin(b) - c;").right!
            ==
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
        
        XCTAssert(
            parseTopLevelExpression("def add(a b) a + b;").right!
            ==
            Expression.Function(
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
        XCTAssert(
            tokenizeTopLevelExpression("a + b; # this is addition\n").right!
            ==
            [.Identifier("a"), .Character("+"), .Identifier("b"), .EndOfStatement]
        )
        
        XCTAssert(
            tokenizeTopLevelExpression("# this is only a comment\n").right!
            ==
            []
        )
    }
    
    
    func testNumbers() {
        XCTAssert(
            parseTopLevelExpression("0;").right!
            ==
            .Number(0)
        )
        
        print(parseTopLevelExpression("00.00;"))
        print(parse(number, input: "00.00"))
        
        XCTAssert(
            parseTopLevelExpression("00.00;").right!
            ==
            .Number(0)
        )
        
        XCTAssert(
            parseTopLevelExpression("10.0;").right!
            ==
            .Number(10)
        )
        
        XCTAssert(
            parseTopLevelExpression("10.01;").right!
            ==
            .Number(10.01)
        )
    }
}
