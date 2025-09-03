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

@Suite("Formatter Tests") struct FormatterTests {

    @Test("Basic text formatting")
    func testBasicTextFormatting() {
        let output = StringOutput()
        let formatter = ANSIMarkdownFormatter(output: output)

        formatter.add("Hello world")
        formatter.format()

        let result = formatter.getOutput() ?? ""
        #expect(result == "Hello world")
    }

    @Test("Heading formatting")
    func testHeadingFormatting() {
        let output = StringOutput()
        let formatter = ANSIMarkdownFormatter(output: output)

        formatter.add("# Main Title")
        formatter.format()

        let result = formatter.getOutput() ?? ""
        // Should contain green formatting and level markers
        #expect(result.contains(ANSICode.green))
        #expect(result.contains("# Main Title"))
    }

    @Test("Multiple heading levels")
    func testMultipleHeadingLevels() {
        let output = StringOutput()
        let formatter = ANSIMarkdownFormatter(output: output)

        formatter.add("# Level 1\n## Level 2\n### Level 3")
        formatter.format()

        let result = formatter.getOutput() ?? ""
        // Should contain green formatting for all levels and level markers
        #expect(result.contains(ANSICode.green))
        #expect(result.contains("# Level 1"))
        #expect(result.contains("## Level 2"))
        #expect(result.contains("### Level 3"))
    }

    @Test("Emphasis formatting")
    func testEmphasisFormatting() {
        let output = StringOutput()
        let formatter = ANSIMarkdownFormatter(output: output)

        formatter.add("This is *italic* text")
        formatter.format()

        let result = formatter.getOutput() ?? ""
        #expect(result.contains(ANSICode.italic))
        #expect(result.contains(ANSICode.resetItalic))
        #expect(result.contains("italic"))
    }

    @Test("Strong emphasis formatting")
    func testStrongEmphasisFormatting() {
        let output = StringOutput()
        let formatter = ANSIMarkdownFormatter(output: output)

        formatter.add("This is **bold** text")
        formatter.format()

        let result = formatter.getOutput() ?? ""
        #expect(result.contains(ANSICode.bold))
        #expect(result.contains(ANSICode.resetBold))
        #expect(result.contains("bold"))
    }

    @Test("Code formatting")
    func testCodeFormatting() {
        let output = StringOutput()
        let formatter = ANSIMarkdownFormatter(output: output)

        formatter.add("Here is `code` text")
        formatter.format()

        let result = formatter.getOutput() ?? ""
        #expect(result.contains(ANSICode.cyan))
        #expect(result.contains(ANSICode.dim))
        #expect(result.contains(ANSICode.reset))
        #expect(result.contains("code"))
    }

    @Test("Code block formatting")
    func testCodeBlockFormatting() {
        let output = StringOutput()
        let formatter = ANSIMarkdownFormatter(output: output)

        formatter.add("```swift\nlet x = 5\n```")
        formatter.format()

        let result = formatter.getOutput() ?? ""
        // Check for bright red emdash sequences
        #expect(result.contains(ANSICode.brightRed))
        #expect(result.contains("—"))  // Emdash character
        // Check for language embedded in opening sequence
        #expect(result.contains("——swift"))  // Two emdashes followed by language
        // Check for cyan code content
        #expect(result.contains(ANSICode.cyan))
        #expect(result.contains("let x = 5"))
    }

    @Test("Block quote formatting")
    func testBlockQuoteFormatting() {
        let output = StringOutput()
        let formatter = ANSIMarkdownFormatter(output: output)

        formatter.add("> This is a quote")
        formatter.format()

        let result = formatter.getOutput() ?? ""
        #expect(result.contains("▎"))  // Block quote indicator
        #expect(result.contains("This is a quote"))
    }

    @Test("Link formatting")
    func testLinkFormatting() {
        let output = StringOutput()
        let formatter = ANSIMarkdownFormatter(output: output)

        formatter.add("[link text]")
        formatter.format()

        let result = formatter.getOutput() ?? ""
        #expect(result.contains(ANSICode.blue))
        #expect(result.contains(ANSICode.underline))
        #expect(result.contains("["))
    }

    @Test("Image formatting")
    func testImageFormatting() {
        let output = StringOutput()
        let formatter = ANSIMarkdownFormatter(output: output)

        formatter.add("![alt text]")
        formatter.format()

        let result = formatter.getOutput() ?? ""
        #expect(result.contains(ANSICode.magenta))
        #expect(result.contains("!["))
    }

    @Test("Mixed formatting")
    func testMixedFormatting() {
        let output = StringOutput()
        let formatter = ANSIMarkdownFormatter(output: output)

        formatter.add("# **Bold Heading**\n> Quote with *emphasis*")
        formatter.format()

        let result = formatter.getOutput() ?? ""
        // Should contain heading formatting
        #expect(result.contains(ANSICode.green))
        // Should contain bold formatting
        #expect(result.contains(ANSICode.bold))
        // Should contain block quote indicator
        #expect(result.contains("▎"))
        // Should contain italic formatting
        #expect(result.contains(ANSICode.italic))
    }

    @Test("Nested formatting")
    func testNestedFormatting() {
        let output = StringOutput()
        let formatter = ANSIMarkdownFormatter(output: output)

        formatter.add("**Bold with *italic* inside**")
        formatter.format()

        let result = formatter.getOutput() ?? ""
        #expect(result.contains(ANSICode.bold))
        #expect(result.contains(ANSICode.italic))
        #expect(result.contains("Bold with"))
        #expect(result.contains("italic"))
        #expect(result.contains("inside"))
    }

    @Test("Code inside other formatting")
    func testCodeInsideOtherFormatting() {
        let output = StringOutput()
        let formatter = ANSIMarkdownFormatter(output: output)

        formatter.add("**Bold `code` text**")
        formatter.format()

        let result = formatter.getOutput() ?? ""
        #expect(result.contains(ANSICode.bold))
        #expect(result.contains(ANSICode.cyan))
        #expect(result.contains("code"))
    }

    @Test("Formatting preservation across newlines")
    func testFormattingPreservationAcrossNewlines() {
        let output = StringOutput()
        let formatter = ANSIMarkdownFormatter(output: output)

        formatter.add("**Bold text\ncontinues here**")
        formatter.format()

        let result = formatter.getOutput() ?? ""
        #expect(result.contains(ANSICode.bold))
        #expect(result.contains("Bold text"))
        #expect(result.contains("continues here"))
    }

    @Test("Block quote on multiple lines")
    func testBlockQuoteMultipleLines() {
        let output = StringOutput()
        let formatter = ANSIMarkdownFormatter(output: output)

        formatter.add("> First line\n> Second line")
        formatter.format()

        let result = formatter.getOutput() ?? ""
        // Should have two block quote indicators
        let indicatorCount = result.components(separatedBy: "▎").count - 1
        #expect(indicatorCount == 2)
    }

    @Test("Incremental formatting - basic")
    func testIncrementalFormattingBasic() {
        let output = StringOutput()
        let formatter = ANSIMarkdownFormatter(output: output)

        // Add content incrementally
        formatter.add("# Head")
        formatter.format()

        let result1 = formatter.getOutput() ?? ""
        #expect(result1.contains("Head"))

        // Add more content
        formatter.add("ing\n")
        formatter.format()

        let result2 = formatter.getOutput() ?? ""
        #expect(result2.contains("Heading"))
    }

    @Test("Incremental formatting - incomplete tokens")
    func testIncrementalFormattingIncompleteTokens() {
        let output = StringOutput()
        let formatter = ANSIMarkdownFormatter(output: output)

        // Add incomplete strong emphasis
        formatter.add("*")
        formatter.format()

        // Complete it later
        formatter.add("*bold text**")
        formatter.format()

        let result = formatter.getOutput() ?? ""
        #expect(result.contains(ANSICode.bold))
        #expect(result.contains("bold text"))
    }

    @Test("Incremental formatting - code blocks")
    func testIncrementalFormattingCodeBlocks() {
        let output = StringOutput()
        let formatter = ANSIMarkdownFormatter(output: output)

        // Start code block
        formatter.add("```")
        formatter.format()

        // Add language and code
        formatter.add("swift\nlet x = 5")
        formatter.format()

        // Close code block
        formatter.add("\n```")
        formatter.format()

        let result = formatter.getOutput() ?? ""
        // Check for bright red emdash sequences
        #expect(result.contains(ANSICode.brightRed))
        #expect(result.contains("—"))  // Emdash character
        // Check for language embedded in opening sequence
        #expect(result.contains("——swift"))  // Two emdashes followed by language
        // Check for cyan code content
        #expect(result.contains(ANSICode.cyan))
        #expect(result.contains("let x = 5"))
    }

    @Test("Reset functionality")
    func testResetFunctionality() {
        let output = StringOutput()
        let formatter = ANSIMarkdownFormatter(output: output)

        formatter.add("**bold text**")
        formatter.format()

        let result1 = formatter.getOutput() ?? ""
        #expect(result1.contains(ANSICode.bold))

        // Reset and format again with new output
        formatter.reset()
        let newOutput = StringOutput()
        formatter.setOutput(newOutput)
        formatter.add("*italic text*")
        formatter.format()

        let result2 = formatter.getOutput() ?? ""
        // Should only contain the new content
        #expect(result2.contains(ANSICode.italic))
        #expect(!result2.contains("bold text"))
    }

    @Test("Clear processed content")
    func testClearProcessedContent() {
        let output = StringOutput()
        let formatter = ANSIMarkdownFormatter(output: output)

        formatter.add("First part ")
        formatter.format()

        formatter.clearProcessed()

        formatter.add("second part")
        formatter.format()

        let result = formatter.getOutput() ?? ""
        #expect(result.contains("First part"))
        #expect(result.contains("second part"))
    }

    @Test("Special characters in text")
    func testSpecialCharactersInText() {
        let output = StringOutput()
        let formatter = ANSIMarkdownFormatter(output: output)

        formatter.add("Text with & special < > characters")
        formatter.format()

        let result = formatter.getOutput() ?? ""
        #expect(result.contains("&"))
        #expect(result.contains("<"))
        #expect(result.contains(">"))
    }

    @Test("Empty content")
    func testEmptyContent() {
        let output = StringOutput()
        let formatter = ANSIMarkdownFormatter(output: output)

        formatter.format()

        let result = formatter.getOutput() ?? ""
        #expect(result.isEmpty)
    }

    @Test("Whitespace preservation")
    func testWhitespacePreservation() {
        let output = StringOutput()
        let formatter = ANSIMarkdownFormatter(output: output)

        formatter.add("Text  with   multiple    spaces")
        formatter.format()

        let result = formatter.getOutput() ?? ""
        #expect(result.contains("  "))
        #expect(result.contains("   "))
        #expect(result.contains("    "))
    }

    @Test("Standard output integration")
    func testStandardOutputIntegration() {
        let formatter = ANSIMarkdownFormatter()  // Uses StandardOutput by default

        // This test mainly verifies that the formatter can be created with StandardOutput
        // without crashing. We can't easily test the actual output to stdout in unit tests.
        formatter.add("Test content")
        formatter.format()

        // If we get here without crashing, the test passes
        #expect(formatter.getOutput() == nil)  // StandardOutput returns nil for getOutput()
    }

    @Test("Thematic break formatting")
    func testThematicBreakFormatting() {
        let output = StringOutput()
        let formatter = ANSIMarkdownFormatter(output: output)

        formatter.add("---")
        formatter.format()

        let result = formatter.getOutput() ?? ""
        #expect(result.contains(ANSICode.brightBlack))
        #expect(result.contains(ANSICode.dim))
        #expect(result.contains("─"))  // Unicode horizontal line character
        #expect(result.contains(ANSICode.reset))
    }

    @Test("Thematic break with different characters")
    func testThematicBreakWithDifferentCharacters() {
        let output = StringOutput()
        let formatter = ANSIMarkdownFormatter(output: output)

        formatter.add("***\n___")
        formatter.format()

        let result = formatter.getOutput() ?? ""
        // Should contain two thematic breaks (both rendered the same way)
        let horizontalLineCount = result.components(separatedBy: "─").count - 1
        #expect(horizontalLineCount >= 100)  // Two 50-character lines
    }

    @Test("Thematic break in context")
    func testThematicBreakInContext() {
        let output = StringOutput()
        let formatter = ANSIMarkdownFormatter(output: output)

        formatter.add("# Section 1\nContent here\n\n---\n\n# Section 2")
        formatter.format()

        let result = formatter.getOutput() ?? ""
        #expect(result.contains(ANSICode.green))  // Heading
        #expect(result.contains("Section 1"))
        #expect(result.contains("Content here"))
        #expect(result.contains("─"))  // Thematic break
        #expect(result.contains("Section 2"))
    }

    @Test("Thematic break with leading spaces")
    func testThematicBreakWithLeadingSpaces() {
        let output = StringOutput()
        let formatter = ANSIMarkdownFormatter(output: output)

        formatter.add("  ---")
        formatter.format()

        let result = formatter.getOutput() ?? ""
        #expect(result.contains("─"))  // Should still render as thematic break
        #expect(result.contains(ANSICode.brightBlack))
    }

    @Test("Thematic break ensures newlines")
    func testThematicBreakEnsuresNewlines() {
        let output = StringOutput()
        let formatter = ANSIMarkdownFormatter(output: output)

        formatter.add("text---")
        formatter.format()

        let result = formatter.getOutput() ?? ""
        // Since "text---" is not a valid thematic break (not at line start),
        // it should be treated as text
        #expect(result.contains("text"))
        #expect(!result.contains("─"))  // No thematic break line
    }

    @Test("Multiple thematic breaks")
    func testMultipleThematicBreaks() {
        let output = StringOutput()
        let formatter = ANSIMarkdownFormatter(output: output)

        formatter.add("---\n\n***\n\n___")
        formatter.format()

        let result = formatter.getOutput() ?? ""
        // Should contain three thematic breaks
        let horizontalLineCount = result.components(separatedBy: "─").count - 1
        #expect(horizontalLineCount >= 150)  // Three 50-character lines
    }
}

@Suite("Raw Formatter Tests") struct RawFormatterTests {

    @Test("Basic text pass-through")
    func testBasicTextPassThrough() {
        let output = StringOutput()
        let formatter = RawMarkdownFormatter(output: output)

        formatter.add("Hello world")
        formatter.format()

        let result = formatter.getOutput() ?? ""
        #expect(result == "Hello world")
    }

    @Test("Heading pass-through")
    func testHeadingPassThrough() {
        let output = StringOutput()
        let formatter = RawMarkdownFormatter(output: output)

        formatter.add("# Main Title")
        formatter.format()

        let result = formatter.getOutput() ?? ""
        #expect(result == "# Main Title")
        // Should not contain any ANSI codes
        #expect(!result.contains(ANSICode.bold))
        #expect(!result.contains(ANSICode.brightRed))
    }

    @Test("Multiple heading levels pass-through")
    func testMultipleHeadingLevelsPassThrough() {
        let output = StringOutput()
        let formatter = RawMarkdownFormatter(output: output)

        let markdown = """
            # H1 Title
            ## H2 Title
            ### H3 Title
            """

        formatter.add(markdown)
        formatter.format()

        let result = formatter.getOutput() ?? ""
        #expect(result == markdown)
        // Should not contain any ANSI codes
        #expect(!result.contains(ANSICode.bold))
        #expect(!result.contains(ANSICode.brightRed))
        #expect(!result.contains(ANSICode.brightYellow))
    }

    @Test("Emphasis pass-through")
    func testEmphasisPassThrough() {
        let output = StringOutput()
        let formatter = RawMarkdownFormatter(output: output)

        formatter.add("This is *emphasized* text")
        formatter.format()

        let result = formatter.getOutput() ?? ""
        #expect(result == "This is *emphasized* text")
        // Should not contain any ANSI codes
        #expect(!result.contains(ANSICode.italic))
    }

    @Test("Strong emphasis pass-through")
    func testStrongEmphasisPassThrough() {
        let output = StringOutput()
        let formatter = RawMarkdownFormatter(output: output)

        formatter.add("This is **bold** text")
        formatter.format()

        let result = formatter.getOutput() ?? ""
        #expect(result == "This is **bold** text")
        // Should not contain any ANSI codes
        #expect(!result.contains(ANSICode.bold))
    }

    @Test("Code pass-through")
    func testCodePassThrough() {
        let output = StringOutput()
        let formatter = RawMarkdownFormatter(output: output)

        formatter.add("Here is `inline code`")
        formatter.format()

        let result = formatter.getOutput() ?? ""
        #expect(result == "Here is `inline code`")
        // Should not contain any ANSI codes
        #expect(!result.contains(ANSICode.cyan))
        #expect(!result.contains(ANSICode.dim))
    }

    @Test("Code block pass-through")
    func testCodeBlockPassThrough() {
        let output = StringOutput()
        let formatter = RawMarkdownFormatter(output: output)

        let markdown = """
            ```
            function test() {
                return true;
            }
            ```
            """

        formatter.add(markdown)
        formatter.format()

        let result = formatter.getOutput() ?? ""
        #expect(result == markdown)
        // Should not contain any ANSI codes
        #expect(!result.contains(ANSICode.brightBlack))
        #expect(!result.contains(ANSICode.dim))
    }

    @Test("Block quote pass-through")
    func testBlockQuotePassThrough() {
        let output = StringOutput()
        let formatter = RawMarkdownFormatter(output: output)

        formatter.add("> This is a quote")
        formatter.format()

        let result = formatter.getOutput() ?? ""
        #expect(result == "> This is a quote")
        // Should not contain any ANSI codes or special quote indicators
        #expect(!result.contains(ANSICode.brightBlack))
        #expect(!result.contains("▎"))
    }

    @Test("Link pass-through")
    func testLinkPassThrough() {
        let output = StringOutput()
        let formatter = RawMarkdownFormatter(output: output)

        formatter.add("[Link text](https://example.com)")
        formatter.format()

        let result = formatter.getOutput() ?? ""
        #expect(result == "[Link text](https://example.com)")
        // Should not contain any ANSI codes
        #expect(!result.contains(ANSICode.blue))
        #expect(!result.contains(ANSICode.underline))
    }

    @Test("Image pass-through")
    func testImagePassThrough() {
        let output = StringOutput()
        let formatter = RawMarkdownFormatter(output: output)

        formatter.add("![Alt text](image.png)")
        formatter.format()

        let result = formatter.getOutput() ?? ""
        #expect(result == "![Alt text](image.png)")
        // Should not contain any ANSI codes
        #expect(!result.contains(ANSICode.magenta))
    }

    @Test("Thematic break pass-through")
    func testThematicBreakPassThrough() {
        let output = StringOutput()
        let formatter = RawMarkdownFormatter(output: output)

        formatter.add("---")
        formatter.format()

        let result = formatter.getOutput() ?? ""
        #expect(result == "---")
        // Should not contain any ANSI codes or fancy line characters
        #expect(!result.contains(ANSICode.brightBlack))
        #expect(!result.contains("─"))
    }

    @Test("Complex markdown pass-through")
    func testComplexMarkdownPassThrough() {
        let output = StringOutput()
        let formatter = RawMarkdownFormatter(output: output)

        let markdown = """
            # Main Title

            This is a paragraph with *emphasis* and **strong** text.

            ## Code Example

            Here's some `inline code` and a block:

            ```swift
            func hello() {
                print("Hello, world!")
            }
            ```

            > This is a quote
            > with multiple lines

            [Link to example](https://example.com)

            ![Image](image.png)

            ---

            Final paragraph.
            """

        formatter.add(markdown)
        formatter.format()

        let result = formatter.getOutput() ?? ""
        #expect(result == markdown)

        // Verify no ANSI codes are present
        let ansiCodes = [
            ANSICode.bold, ANSICode.italic, ANSICode.underline,
            ANSICode.red, ANSICode.green, ANSICode.blue, ANSICode.cyan, ANSICode.magenta,
            ANSICode.brightRed, ANSICode.brightGreen, ANSICode.brightBlue,
            ANSICode.brightCyan, ANSICode.brightMagenta, ANSICode.brightYellow,
            ANSICode.brightBlack, ANSICode.dim, ANSICode.reset,
        ]

        for code in ansiCodes {
            #expect(!result.contains(code), "Result should not contain ANSI code: \(code)")
        }
    }

    @Test("Reset functionality")
    func testResetFunctionality() {
        let output = StringOutput()
        let formatter = RawMarkdownFormatter(output: output)

        formatter.add("First text")
        formatter.format()

        let firstResult = formatter.getOutput() ?? ""
        #expect(firstResult == "First text")

        formatter.reset()
        formatter.add("Second text")
        formatter.format()

        let secondResult = formatter.getOutput() ?? ""
        #expect(secondResult == "Second text")
    }

    @Test("Multiple format calls")
    func testMultipleFormatCalls() {
        let output = StringOutput()
        let formatter = RawMarkdownFormatter(output: output)

        formatter.add("First ")
        formatter.format()
        formatter.add("Second")
        formatter.format()

        let result = formatter.getOutput() ?? ""
        #expect(result == "First Second")
    }

    @Test("Empty input")
    func testEmptyInput() {
        let output = StringOutput()
        let formatter = RawMarkdownFormatter(output: output)

        formatter.add("")
        formatter.format()

        let result = formatter.getOutput() ?? ""
        #expect(result == "")
    }

    @Test("Whitespace preservation")
    func testWhitespacePreservation() {
        let output = StringOutput()
        let formatter = RawMarkdownFormatter(output: output)

        let markdown = "  Indented text  \n\n  More text  "
        formatter.add(markdown)
        formatter.format()

        let result = formatter.getOutput() ?? ""
        #expect(result == markdown)
    }
}
