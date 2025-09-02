//
// Copyright 2025 Link Dupont
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Testing

@testable import ANSIMarkdown

@Suite("Lexer Tests") struct LexerTests {

    @Test("Basic text tokenization")
    func testBasicTextTokenization() {
        let lexer = Lexer()
        lexer.add("hello world")

        let token1 = lexer.next()
        #expect(token1.type == .text)
        #expect(token1.value == "hello")
        #expect(token1.position == 0)

        let token2 = lexer.next()
        #expect(token2.type == .whitespace)
        #expect(token2.value == " ")
        #expect(token2.position == 5)

        let token3 = lexer.next()
        #expect(token3.type == .text)
        #expect(token3.value == "world")
        #expect(token3.position == 6)

        let eofToken = lexer.next()
        #expect(eofToken.type == .eof)
    }

    @Test("Heading tokenization")
    func testHeadingTokenization() {
        let lexer = Lexer()
        lexer.add("# Heading")

        let token1 = lexer.next()
        #expect(token1.type == .heading)
        #expect(token1.value == "#")
        #expect(token1.position == 0)

        let token2 = lexer.next()
        #expect(token2.type == .whitespace)
        #expect(token2.value == " ")

        let token3 = lexer.next()
        #expect(token3.type == .text)
        #expect(token3.value == "Heading")
    }

    @Test("Multiple headings")
    func testMultipleHeadings() {
        let lexer = Lexer()
        lexer.add("## Level 2")

        let token1 = lexer.next()
        #expect(token1.type == .heading)
        #expect(token1.value == "#")

        let token2 = lexer.next()
        #expect(token2.type == .heading)
        #expect(token2.value == "#")

        let token3 = lexer.next()
        #expect(token3.type == .whitespace)

        let token4 = lexer.next()
        #expect(token4.type == .text)
        #expect(token4.value == "Level")
    }

    @Test("Emphasis tokenization")
    func testEmphasisTokenization() {
        let lexer = Lexer()
        lexer.add("*italic* text")

        let token1 = lexer.next()
        #expect(token1.type == .emphasis)
        #expect(token1.value == "*")

        let token2 = lexer.next()
        #expect(token2.type == .text)
        #expect(token2.value == "italic")

        let token3 = lexer.next()
        #expect(token3.type == .emphasis)
        #expect(token3.value == "*")

        let token4 = lexer.next()
        #expect(token4.type == .whitespace)

        let token5 = lexer.next()
        #expect(token5.type == .text)
        #expect(token5.value == "text")
    }

    @Test("Strong emphasis tokenization")
    func testStrongEmphasisTokenization() {
        let lexer = Lexer()
        lexer.add("**bold** text")

        let token1 = lexer.next()
        #expect(token1.type == .strongEmphasis)
        #expect(token1.value == "**")
        #expect(token1.position == 0)

        let token2 = lexer.next()
        #expect(token2.type == .text)
        #expect(token2.value == "bold")

        let token3 = lexer.next()
        #expect(token3.type == .strongEmphasis)
        #expect(token3.value == "**")

        let token4 = lexer.next()
        #expect(token4.type == .whitespace)

        let token5 = lexer.next()
        #expect(token5.type == .text)
        #expect(token5.value == "text")
    }

    @Test("Block quote tokenization")
    func testBlockQuoteTokenization() {
        let lexer = Lexer()
        lexer.add("> Quote text")

        let token1 = lexer.next()
        #expect(token1.type == .blockQuote)
        #expect(token1.value == ">")

        let token2 = lexer.next()
        #expect(token2.type == .whitespace)

        let token3 = lexer.next()
        #expect(token3.type == .text)
        #expect(token3.value == "Quote")
    }

    @Test("Code tokenization")
    func testCodeTokenization() {
        let lexer = Lexer()
        lexer.add("`code` here")

        let token1 = lexer.next()
        #expect(token1.type == .code)
        #expect(token1.value == "`")

        let token2 = lexer.next()
        #expect(token2.type == .text)
        #expect(token2.value == "code")

        let token3 = lexer.next()
        #expect(token3.type == .code)
        #expect(token3.value == "`")
    }

    @Test("Code block tokenization")
    func testCodeBlockTokenization() {
        let lexer = Lexer()
        lexer.add("```swift\ncode\n```")

        let token1 = lexer.next()
        #expect(token1.type == .codeBlock)
        #expect(token1.value == "```")

        let token2 = lexer.next()
        #expect(token2.type == .text)
        #expect(token2.value == "swift")

        let token3 = lexer.next()
        #expect(token3.type == .newline)

        let token4 = lexer.next()
        #expect(token4.type == .text)
        #expect(token4.value == "code")

        let token5 = lexer.next()
        #expect(token5.type == .newline)

        let token6 = lexer.next()
        #expect(token6.type == .codeBlock)
        #expect(token6.value == "```")
    }

    @Test("Link tokenization")
    func testLinkTokenization() {
        let lexer = Lexer()
        lexer.add("[link text]")

        let token1 = lexer.next()
        #expect(token1.type == .link)
        #expect(token1.value == "[")

        let token2 = lexer.next()
        #expect(token2.type == .text)
        #expect(token2.value == "link")

        let token3 = lexer.next()
        #expect(token3.type == .whitespace)

        let token4 = lexer.next()
        #expect(token4.type == .text)
        #expect(token4.value == "text]")
    }

    @Test("Image tokenization")
    func testImageTokenization() {
        let lexer = Lexer()
        lexer.add("![alt text]")

        let token1 = lexer.next()
        #expect(token1.type == .image)
        #expect(token1.value == "![")

        let token2 = lexer.next()
        #expect(token2.type == .text)
        #expect(token2.value == "alt")

        let token3 = lexer.next()
        #expect(token3.type == .whitespace)

        let token4 = lexer.next()
        #expect(token4.type == .text)
        #expect(token4.value == "text]")
    }

    @Test("Newline tokenization")
    func testNewlineTokenization() {
        let lexer = Lexer()
        lexer.add("line1\nline2")

        let token1 = lexer.next()
        #expect(token1.type == .text)
        #expect(token1.value == "line1")

        let token2 = lexer.next()
        #expect(token2.type == .newline)
        #expect(token2.value == "\n")

        let token3 = lexer.next()
        #expect(token3.type == .text)
        #expect(token3.value == "line2")
    }

    @Test("Incremental content addition")
    func testIncrementalContentAddition() {
        let lexer = Lexer()

        // Add content incrementally
        lexer.add("# Head")
        let token1 = lexer.next()
        #expect(token1.type == .heading)

        let token2 = lexer.next()
        #expect(token2.type == .whitespace)

        let token3 = lexer.next()
        #expect(token3.type == .text)
        #expect(token3.value == "Head")

        // Add more content
        lexer.add("ing\n")
        let token4 = lexer.next()
        #expect(token4.type == .text)
        #expect(token4.value == "ing")

        let token5 = lexer.next()
        #expect(token5.type == .newline)

        // Add even more content
        lexer.add("More text")
        let token6 = lexer.next()
        #expect(token6.type == .text)
        #expect(token6.value == "More")
    }

    @Test("Incomplete markdown elements")
    func testIncompleteMarkdownElements() {
        let lexer = Lexer()

        // Add incomplete strong emphasis
        lexer.add("*")
        let token1 = lexer.next()
        #expect(token1.type == .emphasis)
        #expect(token1.value == "*")

        // Complete it later
        lexer.add("*bold")
        let token2 = lexer.next()
        #expect(token2.type == .emphasis)
        #expect(token2.value == "*")

        let token3 = lexer.next()
        #expect(token3.type == .text)
        #expect(token3.value == "bold")
    }

    @Test("Mixed markdown content")
    func testMixedMarkdownContent() {
        let lexer = Lexer()
        lexer.add("# **Bold Heading**\n> Quote with *emphasis*")

        // Parse heading
        let token1 = lexer.next()
        #expect(token1.type == .heading)

        let token2 = lexer.next()
        #expect(token2.type == .whitespace)

        let token3 = lexer.next()
        #expect(token3.type == .strongEmphasis)

        let token4 = lexer.next()
        #expect(token4.type == .text)
        #expect(token4.value == "Bold")

        let token5 = lexer.next()
        #expect(token5.type == .whitespace)

        let token6 = lexer.next()
        #expect(token6.type == .text)
        #expect(token6.value == "Heading")

        let token7 = lexer.next()
        #expect(token7.type == .strongEmphasis)

        let token8 = lexer.next()
        #expect(token8.type == .newline)

        // Parse block quote
        let token9 = lexer.next()
        #expect(token9.type == .blockQuote)

        let token10 = lexer.next()
        #expect(token10.type == .whitespace)

        let token11 = lexer.next()
        #expect(token11.type == .text)
        #expect(token11.value == "Quote")

        let token12 = lexer.next()
        #expect(token12.type == .whitespace)

        let token13 = lexer.next()
        #expect(token13.type == .text)
        #expect(token13.value == "with")

        let token14 = lexer.next()
        #expect(token14.type == .whitespace)

        let token15 = lexer.next()
        #expect(token15.type == .emphasis)

        let token16 = lexer.next()
        #expect(token16.type == .text)
        #expect(token16.value == "emphasis")

        let token17 = lexer.next()
        #expect(token17.type == .emphasis)
    }

    @Test("Buffer management")
    func testBufferManagement() {
        let lexer = Lexer()

        lexer.add("test")
        #expect(lexer.getBuffer() == "test")
        #expect(lexer.hasMoreTokens() == true)

        let _ = lexer.next()  // consume "test"
        #expect(lexer.hasMoreTokens() == false)

        let eofToken = lexer.next()
        #expect(eofToken.type == .eof)
    }

    @Test("Reset functionality")
    func testResetFunctionality() {
        let lexer = Lexer()
        lexer.add("hello")

        let token1 = lexer.next()
        #expect(token1.type == .text)
        #expect(token1.value == "hello")

        // Reset and parse again
        lexer.reset()
        let token2 = lexer.next()
        #expect(token2.type == .text)
        #expect(token2.value == "hello")
    }

    @Test("Clear processed content")
    func testClearProcessedContent() {
        let lexer = Lexer()
        lexer.add("hello world")

        let _ = lexer.next()  // consume "hello"
        let _ = lexer.next()  // consume " "

        lexer.clearProcessed()
        #expect(lexer.getBuffer().hasPrefix("world"))

        let token = lexer.next()
        #expect(token.type == .text)
        #expect(token.value == "world")
    }

    @Test("Edge cases - empty content")
    func testEmptyContent() {
        let lexer = Lexer()

        let token = lexer.next()
        #expect(token.type == .eof)

        lexer.add("")
        let token2 = lexer.next()
        #expect(token2.type == .eof)
    }

    @Test("Edge cases - only special characters")
    func testOnlySpecialCharacters() {
        let lexer = Lexer()
        lexer.add("***")

        let token1 = lexer.next()
        #expect(token1.type == .strongEmphasis)
        #expect(token1.value == "**")

        let token2 = lexer.next()
        #expect(token2.type == .emphasis)
        #expect(token2.value == "*")
    }

    @Test("Edge cases - tabs and multiple spaces")
    func testTabsAndMultipleSpaces() {
        let lexer = Lexer()
        lexer.add("a\tb  c")

        let token1 = lexer.next()
        #expect(token1.type == .text)
        #expect(token1.value == "a")

        let token2 = lexer.next()
        #expect(token2.type == .whitespace)
        #expect(token2.value == "\t")

        let token3 = lexer.next()
        #expect(token3.type == .text)
        #expect(token3.value == "b")

        let token4 = lexer.next()
        #expect(token4.type == .whitespace)
        #expect(token4.value == " ")

        let token5 = lexer.next()
        #expect(token5.type == .whitespace)
        #expect(token5.value == " ")

        let token6 = lexer.next()
        #expect(token6.type == .text)
        #expect(token6.value == "c")
    }
}
