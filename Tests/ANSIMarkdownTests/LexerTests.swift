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
        #expect(token2.type == .codeBlockLanguage)
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
        #expect(token1.type == .linkOpenBracket)
        #expect(token1.value == "[")

        let token2 = lexer.next()
        #expect(token2.type == .linkText)
        #expect(token2.value == "link")

        let token3 = lexer.next()
        #expect(token3.type == .whitespace)

        let token4 = lexer.next()
        #expect(token4.type == .linkText)
        #expect(token4.value == "text")

        let token5 = lexer.next()
        #expect(token5.type == .linkCloseBracket)
        #expect(token5.value == "]")
    }

    @Test("Full link tokenization")
    func testFullLinkTokenization() {
        let lexer = Lexer()
        lexer.add("[link text](https://example.com)")

        let token1 = lexer.next()
        #expect(token1.type == .linkOpenBracket)
        #expect(token1.value == "[")

        let token2 = lexer.next()
        #expect(token2.type == .linkText)
        #expect(token2.value == "link")

        let token3 = lexer.next()
        #expect(token3.type == .whitespace)

        let token4 = lexer.next()
        #expect(token4.type == .linkText)
        #expect(token4.value == "text")

        let token5 = lexer.next()
        #expect(token5.type == .linkCloseBracket)
        #expect(token5.value == "]")

        let token6 = lexer.next()
        #expect(token6.type == .linkOpenParen)
        #expect(token6.value == "(")

        let token7 = lexer.next()
        #expect(token7.type == .linkURL)
        #expect(token7.value == "https://example.com")

        let token8 = lexer.next()
        #expect(token8.type == .linkCloseParen)
        #expect(token8.value == ")")
    }

    @Test("Image tokenization")
    func testImageTokenization() {
        let lexer = Lexer()
        lexer.add("![alt text]")

        let token1 = lexer.next()
        #expect(token1.type == .imageOpenBracket)
        #expect(token1.value == "![")

        let token2 = lexer.next()
        #expect(token2.type == .imageAltText)
        #expect(token2.value == "alt")

        let token3 = lexer.next()
        #expect(token3.type == .whitespace)

        let token4 = lexer.next()
        #expect(token4.type == .imageAltText)
        #expect(token4.value == "text")

        let token5 = lexer.next()
        #expect(token5.type == .imageCloseBracket)
        #expect(token5.value == "]")
    }

    @Test("Full image tokenization")
    func testFullImageTokenization() {
        let lexer = Lexer()
        lexer.add("![alt text](image.png)")

        let token1 = lexer.next()
        #expect(token1.type == .imageOpenBracket)
        #expect(token1.value == "![")

        let token2 = lexer.next()
        #expect(token2.type == .imageAltText)
        #expect(token2.value == "alt")

        let token3 = lexer.next()
        #expect(token3.type == .whitespace)

        let token4 = lexer.next()
        #expect(token4.type == .imageAltText)
        #expect(token4.value == "text")

        let token5 = lexer.next()
        #expect(token5.type == .imageCloseBracket)
        #expect(token5.value == "]")

        let token6 = lexer.next()
        #expect(token6.type == .imageOpenParen)
        #expect(token6.value == "(")

        let token7 = lexer.next()
        #expect(token7.type == .imageURL)
        #expect(token7.value == "image.png")

        let token8 = lexer.next()
        #expect(token8.type == .imageCloseParen)
        #expect(token8.value == ")")
    }

    @Test("Malformed link tokenization")
    func testMalformedLinkTokenization() {
        let lexer = Lexer()
        lexer.add("[incomplete link")

        let token1 = lexer.next()
        #expect(token1.type == .linkOpenBracket)
        #expect(token1.value == "[")

        let token2 = lexer.next()
        #expect(token2.type == .linkText)
        #expect(token2.value == "incomplete")

        let token3 = lexer.next()
        #expect(token3.type == .whitespace)

        let token4 = lexer.next()
        #expect(token4.type == .linkText)
        #expect(token4.value == "link")

        // Should end normally without throwing errors
        let token5 = lexer.next()
        #expect(token5.type == .eof)
    }

    @Test("Standalone brackets and parentheses")
    func testStandaloneBracketsAndParentheses() {
        let lexer = Lexer()
        lexer.add("] ( ) [")

        let token1 = lexer.next()
        #expect(token1.type == .text)
        #expect(token1.value == "]")

        let token2 = lexer.next()
        #expect(token2.type == .whitespace)

        let token3 = lexer.next()
        #expect(token3.type == .text)
        #expect(token3.value == "(")

        let token4 = lexer.next()
        #expect(token4.type == .whitespace)

        let token5 = lexer.next()
        #expect(token5.type == .text)
        #expect(token5.value == ")")

        let token6 = lexer.next()
        #expect(token6.type == .whitespace)

        let token7 = lexer.next()
        #expect(token7.type == .linkOpenBracket)
        #expect(token7.value == "[")
    }

    @Test("Mixed links and parenthesized text")
    func testMixedLinksAndParenthesizedText() {
        let lexer = Lexer()
        lexer.add("Check [link](url) and some (parenthesized text) here")

        // Check link
        let token1 = lexer.next()
        #expect(token1.type == .text)
        #expect(token1.value == "Check")

        let token2 = lexer.next()
        #expect(token2.type == .whitespace)

        // [link](url) - should be parsed as link tokens
        let token3 = lexer.next()
        #expect(token3.type == .linkOpenBracket)
        #expect(token3.value == "[")

        let token4 = lexer.next()
        #expect(token4.type == .linkText)
        #expect(token4.value == "link")

        let token5 = lexer.next()
        #expect(token5.type == .linkCloseBracket)
        #expect(token5.value == "]")

        let token6 = lexer.next()
        #expect(token6.type == .linkOpenParen)
        #expect(token6.value == "(")

        let token7 = lexer.next()
        #expect(token7.type == .linkURL)
        #expect(token7.value == "url")

        let token8 = lexer.next()
        #expect(token8.type == .linkCloseParen)
        #expect(token8.value == ")")

        let token9 = lexer.next()
        #expect(token9.type == .whitespace)

        let token10 = lexer.next()
        #expect(token10.type == .text)
        #expect(token10.value == "and")

        let token11 = lexer.next()
        #expect(token11.type == .whitespace)

        let token12 = lexer.next()
        #expect(token12.type == .text)
        #expect(token12.value == "some")

        let token13 = lexer.next()
        #expect(token13.type == .whitespace)

        // (parenthesized text) - should be parsed as regular text tokens
        let token14 = lexer.next()
        #expect(token14.type == .text)
        #expect(token14.value == "(parenthesized")

        let token15 = lexer.next()
        #expect(token15.type == .whitespace)

        let token16 = lexer.next()
        #expect(token16.type == .text)
        #expect(token16.value == "text)")

        let token17 = lexer.next()
        #expect(token17.type == .whitespace)

        let token18 = lexer.next()
        #expect(token18.type == .text)
        #expect(token18.value == "here")
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

        // *** at line start should be parsed as a thematic break
        let token1 = lexer.next()
        #expect(token1.type == .thematicBreak)
        #expect(token1.value == "***")

        let eofToken = lexer.next()
        #expect(eofToken.type == .eof)
    }

    @Test("Emphasis not at line start")
    func testEmphasisNotAtLineStart() {
        let lexer = Lexer()
        lexer.add("text ***")

        let token1 = lexer.next()
        #expect(token1.type == .text)
        #expect(token1.value == "text")

        let token2 = lexer.next()
        #expect(token2.type == .whitespace)

        let token3 = lexer.next()
        #expect(token3.type == .strongEmphasis)
        #expect(token3.value == "**")

        let token4 = lexer.next()
        #expect(token4.type == .emphasis)
        #expect(token4.value == "*")
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

    @Test("Thematic break with hyphens")
    func testThematicBreakWithHyphens() {
        let lexer = Lexer()
        lexer.add("---")

        let token = lexer.next()
        #expect(token.type == .thematicBreak)
        #expect(token.value == "---")
        #expect(token.position == 0)
    }

    @Test("Thematic break with asterisks")
    func testThematicBreakWithAsterisks() {
        let lexer = Lexer()
        lexer.add("***")

        let token = lexer.next()
        #expect(token.type == .thematicBreak)
        #expect(token.value == "***")
    }

    @Test("Thematic break with underscores")
    func testThematicBreakWithUnderscores() {
        let lexer = Lexer()
        lexer.add("___")

        let token = lexer.next()
        #expect(token.type == .thematicBreak)
        #expect(token.value == "___")
    }

    @Test("Thematic break with more than 3 characters")
    func testThematicBreakWithMoreCharacters() {
        let lexer = Lexer()
        lexer.add("-----")

        let token = lexer.next()
        #expect(token.type == .thematicBreak)
        #expect(token.value == "-----")
    }

    @Test("Thematic break with leading spaces")
    func testThematicBreakWithLeadingSpaces() {
        let lexer = Lexer()
        lexer.add("  ---")

        let token1 = lexer.next()
        #expect(token1.type == .thematicBreak)
        #expect(token1.value == "---")
    }

    @Test("Thematic break with trailing spaces")
    func testThematicBreakWithTrailingSpaces() {
        let lexer = Lexer()
        lexer.add("---  \n")

        let token1 = lexer.next()
        #expect(token1.type == .thematicBreak)
        #expect(token1.value == "---")

        let token2 = lexer.next()
        #expect(token2.type == .whitespace)
        #expect(token2.value == " ")
    }

    @Test("Not a thematic break - only 2 characters")
    func testNotThematicBreakTwoCharacters() {
        let lexer = Lexer()
        lexer.add("--")

        let token1 = lexer.next()
        #expect(token1.type == .text)
        #expect(token1.value == "--")
    }

    @Test("Not a thematic break - mixed characters")
    func testNotThematicBreakMixedCharacters() {
        let lexer = Lexer()
        lexer.add("-*-")

        let token1 = lexer.next()
        #expect(token1.type == .text)
        #expect(token1.value == "-")

        let token2 = lexer.next()
        #expect(token2.type == .emphasis)
        #expect(token2.value == "*")

        let token3 = lexer.next()
        #expect(token3.type == .text)
        #expect(token3.value == "-")
    }

    @Test("Not a thematic break - not at line start")
    func testNotThematicBreakNotAtLineStart() {
        let lexer = Lexer()
        lexer.add("text ---")

        let token1 = lexer.next()
        #expect(token1.type == .text)
        #expect(token1.value == "text")

        let token2 = lexer.next()
        #expect(token2.type == .whitespace)

        let token3 = lexer.next()
        #expect(token3.type == .text)
        #expect(token3.value == "---")
    }

    @Test("Thematic break after newline")
    func testThematicBreakAfterNewline() {
        let lexer = Lexer()
        lexer.add("text\n---")

        let token1 = lexer.next()
        #expect(token1.type == .text)
        #expect(token1.value == "text")

        let token2 = lexer.next()
        #expect(token2.type == .newline)

        let token3 = lexer.next()
        #expect(token3.type == .thematicBreak)
        #expect(token3.value == "---")
    }

    @Test("Thematic break with content after newline")
    func testThematicBreakWithContentAfterNewline() {
        let lexer = Lexer()
        lexer.add("---\nmore content")

        let token1 = lexer.next()
        #expect(token1.type == .thematicBreak)
        #expect(token1.value == "---")

        let token2 = lexer.next()
        #expect(token2.type == .newline)

        let token3 = lexer.next()
        #expect(token3.type == .text)
        #expect(token3.value == "more")
    }

    @Test("Triple backticks not at line start")
    func testTripleBackticksNotAtLineStart() {
        let lexer = Lexer()
        lexer.add("text ```")

        // The key test: ``` not at line start should be parsed as individual ` tokens
        // not as a single codeBlock token

        let token1 = lexer.next()
        #expect(token1.type == .text)
        #expect(token1.value == "text")

        let token2 = lexer.next()
        #expect(token2.type == .whitespace)
        #expect(token2.value == " ")

        // The ``` should be parsed as three individual ` tokens, not a codeBlock
        let token3 = lexer.next()
        #expect(token3.type == .code)
        #expect(token3.value == "`")

        let token4 = lexer.next()
        #expect(token4.type == .code)
        #expect(token4.value == "`")

        let token5 = lexer.next()
        #expect(token5.type == .code)
        #expect(token5.value == "`")

        let eofToken = lexer.next()
        #expect(eofToken.type == .eof)
    }

    @Test("Fenced code blocks at line start")
    func testFencedCodeBlocksAtLineStart() {
        let lexer = Lexer()
        lexer.add("```\ncode\n```")

        // ``` at line start should still be treated as code block tokens
        let token1 = lexer.next()
        #expect(token1.type == .codeBlock)
        #expect(token1.value == "```")

        let token2 = lexer.next()
        #expect(token2.type == .newline)

        let token3 = lexer.next()
        #expect(token3.type == .text)
        #expect(token3.value == "code")

        let token4 = lexer.next()
        #expect(token4.type == .newline)

        let token5 = lexer.next()
        #expect(token5.type == .codeBlock)
        #expect(token5.value == "```")

        let eofToken = lexer.next()
        #expect(eofToken.type == .eof)
    }

    @Test("Shell output with code fence - closing fence not at line start")
    func testShellOutputWithCodeFence() {
        let lexer = Lexer()
        lexer.add("[user@host dir]$ command\n```bash\necho \"Hello\"\n```\nCompleted.")

        // Skip to the opening code fence
        var token = lexer.next()  // [user@host
        while token.type != .codeBlock && token.type != .eof {
            token = lexer.next()
        }

        // Should find the opening code fence
        #expect(token.type == .codeBlock)
        #expect(token.value == "```")

        // Skip to the closing code fence
        while token.type != .eof {
            token = lexer.next()
            if token.type == .codeBlock && token.value == "```" {
                break  // Found the closing fence
            }
        }

        // The closing fence should be properly recognized even if preceded by other content
        #expect(token.type == .codeBlock)
        #expect(token.value == "```")
    }

    @Test("Code fence closing not at line start should be recognized when in code block")
    func testCodeFenceClosingNotAtLineStart() {
        let lexer = Lexer()
        lexer.add("```\ncode content\n  ```")  // Indented closing fence

        // Opening fence
        let token1 = lexer.next()
        #expect(token1.type == .codeBlock)
        #expect(token1.value == "```")

        // Newline
        let token2 = lexer.next()
        #expect(token2.type == .newline)

        // Code content
        let token3 = lexer.next()
        #expect(token3.type == .text)
        #expect(token3.value == "code")

        let token4 = lexer.next()
        #expect(token4.type == .whitespace)

        let token5 = lexer.next()
        #expect(token5.type == .text)
        #expect(token5.value == "content")

        let token6 = lexer.next()
        #expect(token6.type == .newline)

        // Whitespace before closing fence
        let token7 = lexer.next()
        #expect(token7.type == .whitespace)
        #expect(token7.value == " ")

        let token8 = lexer.next()
        #expect(token8.type == .whitespace)
        #expect(token8.value == " ")

        // Closing fence - should be recognized even with leading whitespace
        let token9 = lexer.next()
        #expect(token9.type == .codeBlock)
        #expect(token9.value == "```")

        let eofToken = lexer.next()
        #expect(eofToken.type == .eof)
    }
}
