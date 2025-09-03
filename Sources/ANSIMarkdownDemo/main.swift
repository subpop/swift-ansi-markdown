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

// Run the formatter demonstrations
print("🚀 MarkdownStream Formatter Demo\n")

// Basic formatting examples
Example.demonstrateBasicFormatting()

// Incremental formatting
Example.demonstrateIncrementalFormatting()

// String output example
print("=== String Output Demo ===")
let capturedOutput = Example.demonstrateStringOutput()
print("Captured content length: \(capturedOutput.count) characters")
print("Preview: \(String(capturedOutput.prefix(100)))...")
print()

// Raw formatter demo
Example.demonstrateRawFormatter()

print("=== Formatter Comparison ===")
let comparison = Example.compareFormatters()
print("Raw output: \(comparison.raw)")
print("ANSI output: \(comparison.ansi)")
print()

// Interactive example
print("=== Interactive Example ===")
print("Enter some markdown text (or press Enter to use default):")

let input = readLine() ?? ""
let markdownText =
    input.isEmpty
    ? "# Hello **World**!\n\nThis is a *test* with `code` and:\n\n> A nice quote\n\n```swift\nlet x = 42\n```"
    : input

let formatter = ANSIMarkdownFormatter()

print("\nFormatted output:")
formatter.add(markdownText)
formatter.format()
print()

print("✨ Demo complete!")
