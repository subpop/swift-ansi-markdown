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

import ANSIMarkdown
import Foundation

/// Example demonstrating the MarkdownStream formatter usage
public class Example {

    /// Demonstrate basic formatter usage with different markdown elements
    public static func demonstrateBasicFormatting() {
        let formatter = ANSIMarkdownFormatter()

        print("=== MarkdownStream Formatter Demo ===\n")

        // Example 1: Headers
        print("1. Headers:")
        formatter.add("# Main Title\n## Subtitle\n### Section\n")
        formatter.format()
        print()

        // Example 2: Emphasis
        formatter.reset()
        print("2. Text Emphasis:")
        formatter.add("This is *italic* text and this is **bold** text.\n")
        formatter.format()
        print()

        // Example 3: Code
        formatter.reset()
        print("3. Code:")
        formatter.add("Here is `inline code` and below is a code block:\n")
        formatter.add("```swift\nlet message = \"Hello, World!\"\nprint(message)\n```\n")
        formatter.format()
        print()

        // Example 4: Block quotes
        formatter.reset()
        print("4. Block Quote:")
        formatter.add("> This is a block quote\n> with multiple lines\n")
        formatter.format()
        print()

        // Example 5: Thematic breaks
        formatter.reset()
        print("5. Thematic Breaks:")
        formatter.add(
            "First section\n\n---\n\nSecond section\n\n***\n\nThird section\n\n___\n\nFinal section\n"
        )
        formatter.format()
        print()

        // Example 6: Mixed formatting
        formatter.reset()
        print("6. Mixed Formatting:")
        formatter.add("# **Bold Heading**\n")
        formatter.add("> Quote with *emphasis* and `code`\n")
        formatter.add("Regular text with [links] and ![images].\n")
        formatter.format()
        print()
    }

    /// Demonstrate incremental formatting (streaming)
    public static func demonstrateIncrementalFormatting() {
        let formatter = ANSIMarkdownFormatter()

        print("=== Incremental Formatting Demo ===\n")

        // Simulate receiving markdown content in chunks
        let chunks = [
            "# Streaming",
            " Markdown",
            "\n\nThis content is being",
            " processed **incrementally**",
            " as it arrives.\n\n",
            "> Each chunk is",
            " formatted as",
            " soon as possible.\n\n",
            "```swift\n",
            "let streaming = true\n",
            "```",
        ]

        for (index, chunk) in chunks.enumerated() {
            let chunkDisplay = chunk.replacingOccurrences(of: "\n", with: "\\n")
            print("Processing chunk " + String(index + 1) + ": \"" + chunkDisplay + "\"")
            formatter.add(chunk)
            formatter.format()

            // Small delay to simulate real streaming
            Thread.sleep(forTimeInterval: 0.2)
        }

        print("\n=== Streaming Complete ===\n")
    }

    /// Demonstrate using StringOutput for capturing formatted content
    public static func demonstrateStringOutput() -> String {
        let output = StringOutput()
        let formatter = ANSIMarkdownFormatter(output: output)

        formatter.add("# Captured Output\n")
        formatter.add("This content is **captured** in a *string* rather than printed to stdout.\n")
        formatter.add("> Perfect for testing or processing formatted content.\n")
        formatter.format()

        return formatter.getOutput() ?? ""
    }

    /// Demonstrate the raw formatter that outputs unformatted markdown
    public static func demonstrateRawFormatter() {
        let rawFormatter = RawMarkdownFormatter()
        let ansiFormatter = ANSIMarkdownFormatter()

        print("=== Raw Formatter Demo ===\n")

        let sampleMarkdown = """
            # Raw Markdown Example

            This is a demonstration of the **raw formatter** vs the *ANSI formatter*.

            ## Features

            The raw formatter:
            - Preserves original markdown syntax
            - No ANSI color codes
            - Perfect for `plain text` output

            > This is a block quote that remains unformatted

            ```swift
            func example() {
                print("Code blocks stay as markdown")
            }
            ```

            [Links](https://example.com) and ![images](image.png) are preserved.

            ---

            This is useful for:
            1. **Documentation generation**
            2. *Text processing pipelines*
            3. `Markdown validation`
            """

        print("ANSI Formatted Output:")
        print("─────────────────────")
        ansiFormatter.add(sampleMarkdown)
        ansiFormatter.format()
        print()

        print("\nRaw Markdown Output:")
        print("────────────────────")
        rawFormatter.add(sampleMarkdown)
        rawFormatter.format()
        print()
    }

    /// Compare raw and ANSI formatters side by side
    public static func compareFormatters() -> (raw: String, ansi: String) {
        let rawOutput = StringOutput()
        let ansiOutput = StringOutput()

        let rawFormatter = RawMarkdownFormatter(output: rawOutput)
        let ansiFormatter = ANSIMarkdownFormatter(output: ansiOutput)

        let markdown = "# Title\nThis is **bold** and *italic* text with `code`."

        rawFormatter.add(markdown)
        rawFormatter.format()

        ansiFormatter.add(markdown)
        ansiFormatter.format()

        return (
            raw: rawFormatter.getOutput() ?? "",
            ansi: ansiFormatter.getOutput() ?? ""
        )
    }
}

// Uncomment the lines below to run the examples when this file is executed directly
// (Note: This won't work in a library context, but shows how to use the formatter)

/*
if CommandLine.argc > 0 && CommandLine.arguments[0].contains("Example") {
    Example.demonstrateBasicFormatting()
    Example.demonstrateIncrementalFormatting()

    print("=== String Output Demo ===")
    let capturedOutput = Example.demonstrateStringOutput()
    print("Captured content:")
    print(capturedOutput)
}
*/
