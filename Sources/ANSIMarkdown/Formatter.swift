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

import Foundation

/// ANSI color and styling codes
public struct ANSICode {
    // Text colors
    public static let black = "\u{001B}[30m"
    public static let red = "\u{001B}[31m"
    public static let green = "\u{001B}[32m"
    public static let yellow = "\u{001B}[33m"
    public static let blue = "\u{001B}[34m"
    public static let magenta = "\u{001B}[35m"
    public static let cyan = "\u{001B}[36m"
    public static let white = "\u{001B}[37m"

    // Bright colors
    public static let brightBlack = "\u{001B}[90m"
    public static let brightRed = "\u{001B}[91m"
    public static let brightGreen = "\u{001B}[92m"
    public static let brightYellow = "\u{001B}[93m"
    public static let brightBlue = "\u{001B}[94m"
    public static let brightMagenta = "\u{001B}[95m"
    public static let brightCyan = "\u{001B}[96m"
    public static let brightWhite = "\u{001B}[97m"

    // Text styles
    public static let reset = "\u{001B}[0m"
    public static let bold = "\u{001B}[1m"
    public static let dim = "\u{001B}[2m"
    public static let italic = "\u{001B}[3m"
    public static let underline = "\u{001B}[4m"
    public static let blink = "\u{001B}[5m"
    public static let reverse = "\u{001B}[7m"
    public static let strikethrough = "\u{001B}[9m"

    // Reset specific styles
    public static let resetBold = "\u{001B}[22m"
    public static let resetDim = "\u{001B}[22m"
    public static let resetItalic = "\u{001B}[23m"
    public static let resetUnderline = "\u{001B}[24m"
    public static let resetBlink = "\u{001B}[25m"
    public static let resetReverse = "\u{001B}[27m"
    public static let resetStrikethrough = "\u{001B}[29m"
}

/// Protocol for objects that can receive formatted output
public protocol TextOutputStream {
    mutating func write(_ string: String)
}

/// Standard output implementation
public struct StandardOutput: TextOutputStream {
    public init() {}

    public mutating func write(_ string: String) {
        print(string, terminator: "")
    }
}

/// String buffer implementation for testing
public struct StringOutput: TextOutputStream {
    public private(set) var content = ""

    public init() {}

    public mutating func write(_ string: String) {
        content += string
    }
}

/// Formatting state to track current markdown context
private struct FormattingState {
    var inEmphasis = false
    var inStrongEmphasis = false
    var inCode = false
    var inCodeBlock = false
    var inBlockQuote = false
    var headingLevel = 0
    var atLineStart = true

    mutating func reset() {
        inEmphasis = false
        inStrongEmphasis = false
        inCode = false
        inCodeBlock = false
        inBlockQuote = false
        headingLevel = 0
        atLineStart = true
    }
}

/// Markdown formatter that converts lexer tokens to ANSI-formatted output
public class ANSIMarkdownFormatter {
    private let lexer = Lexer()
    private var state = FormattingState()
    private var output: any TextOutputStream

    public init(output: any TextOutputStream = StandardOutput()) {
        self.output = output
    }

    /// Add markdown text to be formatted
    public func add(_ text: String) {
        lexer.add(text)
    }

    /// Process all available tokens and write formatted output
    public func format() {
        while lexer.hasMoreTokens() {
            let token = lexer.next()
            if token.type == .eof {
                break
            }
            processToken(token)
        }
    }

    /// Process a single token and update formatting state
    private func processToken(_ token: Token) {
        switch token.type {
        case .heading:
            handleHeading(token)

        case .emphasis:
            handleEmphasis(token)

        case .strongEmphasis:
            handleStrongEmphasis(token)

        case .code:
            handleCode(token)

        case .codeBlock:
            handleCodeBlock(token)

        case .blockQuote:
            handleBlockQuote(token)

        case .link:
            handleLink(token)

        case .image:
            handleImage(token)

        case .text:
            handleText(token)

        case .whitespace:
            handleWhitespace(token)

        case .newline:
            handleNewline(token)

        case .eof:
            break
        }
    }

    private func handleHeading(_ token: Token) {
        if state.atLineStart {
            state.headingLevel += 1
            // Don't output the # character itself, we'll handle it when we see text
        } else {
            // If not at line start, treat as regular text
            writeText(token.value)
        }
    }

    private func handleEmphasis(_ token: Token) {
        if state.inCode || state.inCodeBlock {
            writeText(token.value)
            return
        }

        state.inEmphasis.toggle()
        if state.inEmphasis {
            output.write(ANSICode.italic)
        } else {
            output.write(ANSICode.resetItalic)
        }
    }

    private func handleStrongEmphasis(_ token: Token) {
        if state.inCode || state.inCodeBlock {
            writeText(token.value)
            return
        }

        state.inStrongEmphasis.toggle()
        if state.inStrongEmphasis {
            output.write(ANSICode.bold)
        } else {
            output.write(ANSICode.resetBold)
        }
    }

    private func handleCode(_ token: Token) {
        if state.inCodeBlock {
            writeText(token.value)
            return
        }

        state.inCode.toggle()
        if state.inCode {
            output.write(ANSICode.cyan)
            output.write(ANSICode.dim)
        } else {
            output.write(ANSICode.reset)
            // Restore any active formatting
            restoreActiveFormatting()
        }
    }

    private func handleCodeBlock(_ token: Token) {
        state.inCodeBlock.toggle()
        if state.inCodeBlock {
            if !state.atLineStart {
                output.write("\n")
            }
            output.write(ANSICode.brightBlack)
            output.write(ANSICode.dim)
        } else {
            output.write(ANSICode.reset)
            output.write("\n")
            // Restore any active formatting
            restoreActiveFormatting()
        }
        state.atLineStart = !state.inCodeBlock
    }

    private func handleBlockQuote(_ token: Token) {
        if state.atLineStart {
            state.inBlockQuote = true
            output.write(ANSICode.brightBlack)
            output.write("▎ ")  // Use a nice block quote indicator
            output.write(ANSICode.reset)
            restoreActiveFormatting()
        } else {
            writeText(token.value)
        }
    }

    private func handleLink(_ token: Token) {
        if state.inCode || state.inCodeBlock {
            writeText(token.value)
        } else {
            output.write(ANSICode.blue)
            output.write(ANSICode.underline)
            writeText(token.value)
        }
    }

    private func handleImage(_ token: Token) {
        if state.inCode || state.inCodeBlock {
            writeText(token.value)
        } else {
            output.write(ANSICode.magenta)
            writeText(token.value)
        }
    }

    private func handleText(_ token: Token) {
        // Apply heading formatting if we're in a heading
        if state.headingLevel > 0 && state.atLineStart {
            applyHeadingFormatting(level: state.headingLevel)
            state.headingLevel = 0  // Reset after applying
        }

        writeText(token.value)
        state.atLineStart = false
    }

    private func handleWhitespace(_ token: Token) {
        writeText(token.value)
    }

    private func handleNewline(_ token: Token) {
        // Reset line-specific states
        if state.inBlockQuote {
            output.write(ANSICode.reset)
            state.inBlockQuote = false
            restoreActiveFormatting()
        }

        writeText(token.value)
        state.atLineStart = true
        state.headingLevel = 0
    }

    private func applyHeadingFormatting(level: Int) {
        switch level {
        case 1:
            output.write(ANSICode.bold)
            output.write(ANSICode.brightRed)
        case 2:
            output.write(ANSICode.bold)
            output.write(ANSICode.brightYellow)
        case 3:
            output.write(ANSICode.bold)
            output.write(ANSICode.brightGreen)
        case 4:
            output.write(ANSICode.bold)
            output.write(ANSICode.brightCyan)
        case 5:
            output.write(ANSICode.bold)
            output.write(ANSICode.brightBlue)
        default:
            output.write(ANSICode.bold)
            output.write(ANSICode.brightMagenta)
        }
    }

    private func restoreActiveFormatting() {
        if state.inStrongEmphasis {
            output.write(ANSICode.bold)
        }
        if state.inEmphasis {
            output.write(ANSICode.italic)
        }
    }

    private func writeText(_ text: String) {
        output.write(text)
    }

    /// Reset the formatter state and clear the lexer buffer
    public func reset() {
        state.reset()
        lexer.clearBuffer()
        // Clear the output buffer if it's a StringOutput
        if output as? StringOutput != nil {
            output = StringOutput()
        }
    }

    /// Get the current output content (only works with StringOutput)
    public func getOutput() -> String? {
        if let stringOutput = output as? StringOutput {
            return stringOutput.content
        }
        return nil
    }

    /// Update the output stream (useful for reset functionality)
    public func setOutput(_ newOutput: any TextOutputStream) {
        output = newOutput
    }

    /// Clear processed content from the lexer buffer
    public func clearProcessed() {
        lexer.clearProcessed()
    }
}
