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

public struct Token {
    public let type: TokenType
    public let value: String
    public let position: Int

    public init(type: TokenType, value: String, position: Int) {
        self.type = type
        self.value = value
        self.position = position
    }
}

public enum TokenType: String, CaseIterable {
    case blockQuote = ">"
    case heading = "#"
    case emphasis = "*"
    case strongEmphasis = "**"
    case code = "`"
    case codeBlock = "```"
    case thematicBreak = "---"
    case link = "["
    case image = "!["
    case text = ""
    case newline = "\n"
    case whitespace = " "
    case eof = "EOF"
}

public class Lexer {
    private var buffer: String = ""
    private var position: Int = 0
    private var currentIndex: String.Index
    private var atLineStart: Bool = true

    public init() {
        self.currentIndex = buffer.startIndex
    }

    public func add(_ text: String) {
        buffer += text
        // Update currentIndex if it's at the end
        if currentIndex == buffer.endIndex {
            currentIndex = buffer.index(buffer.startIndex, offsetBy: position)
        }
    }

    public func next() -> Token {
        // Skip any processed characters
        while position < buffer.count && currentIndex < buffer.endIndex {
            let char = buffer[currentIndex]
            let tokenStart = position

            // Check for multi-character tokens first
            if let multiCharToken = tryParseMultiCharToken() {
                return multiCharToken
            }

            // Check for single character tokens
            let token = parseSingleCharToken(char: char, at: tokenStart)
            advancePosition()
            return token
        }

        // Return EOF token when no more characters
        return Token(type: .eof, value: "", position: position)
    }

    private func tryParseMultiCharToken() -> Token? {
        let remainingText = String(buffer[currentIndex...])

        // Check for thematic breaks (---, ***, ___) at line start
        if let thematicBreakToken = tryParseThematicBreak(remainingText) {
            return thematicBreakToken
        }

        // Check for code blocks (```)
        if remainingText.hasPrefix("```") {
            atLineStart = false
            let token = Token(type: .codeBlock, value: "```", position: position)
            advancePosition(by: 3)
            return token
        }

        // Check for strong emphasis (**)
        if remainingText.hasPrefix("**") {
            atLineStart = false
            let token = Token(type: .strongEmphasis, value: "**", position: position)
            advancePosition(by: 2)
            return token
        }

        // Check for images (![)
        if remainingText.hasPrefix("![") {
            atLineStart = false
            let token = Token(type: .image, value: "![", position: position)
            advancePosition(by: 2)
            return token
        }

        return nil
    }

    private func tryParseThematicBreak(_ remainingText: String) -> Token? {
        // Thematic breaks can only occur at the start of a line
        guard atLineStart else { return nil }

        // Check for at least 3 consecutive characters of the same type
        let thematicChars: [Character] = ["-", "*", "_"]

        for char in thematicChars {
            var count = 0
            var index = remainingText.startIndex

            // Skip leading whitespace (up to 3 spaces allowed before thematic break)
            var leadingSpaces = 0
            while index < remainingText.endIndex && remainingText[index] == " " && leadingSpaces < 3
            {
                index = remainingText.index(after: index)
                leadingSpaces += 1
            }

            // Count consecutive thematic break characters
            while index < remainingText.endIndex && remainingText[index] == char {
                count += 1
                index = remainingText.index(after: index)
            }

            // Must have at least 3 characters
            guard count >= 3 else { continue }

            // Skip any trailing whitespace
            while index < remainingText.endIndex && remainingText[index] == " " {
                index = remainingText.index(after: index)
            }

            // Must end with newline or end of buffer
            if index == remainingText.endIndex || remainingText[index] == "\n" {
                let thematicBreakValue = String(repeating: char, count: count)
                let token = Token(
                    type: .thematicBreak, value: thematicBreakValue, position: position)
                advancePosition(by: leadingSpaces + count)
                atLineStart = false  // We've consumed the thematic break
                return token
            }
        }

        return nil
    }

    private func parseSingleCharToken(char: Character, at tokenStart: Int) -> Token {
        switch char {
        case ">":
            atLineStart = false
            return Token(type: .blockQuote, value: String(char), position: tokenStart)
        case "#":
            atLineStart = false
            return Token(type: .heading, value: String(char), position: tokenStart)
        case "*":
            atLineStart = false
            return Token(type: .emphasis, value: String(char), position: tokenStart)
        case "`":
            atLineStart = false
            return Token(type: .code, value: String(char), position: tokenStart)
        case "[":
            atLineStart = false
            return Token(type: .link, value: String(char), position: tokenStart)
        case "\n":
            atLineStart = true
            return Token(type: .newline, value: String(char), position: tokenStart)
        case " ", "\t":
            // Only stay at line start if we're already there and this is whitespace
            return Token(type: .whitespace, value: String(char), position: tokenStart)
        default:
            atLineStart = false
            return parseTextToken(startingWith: char, at: tokenStart)
        }
    }

    private func parseTextToken(startingWith firstChar: Character, at tokenStart: Int) -> Token {
        var textValue = String(firstChar)
        advancePosition()  // Move past the first character

        // Collect consecutive text characters
        while currentIndex < buffer.endIndex {
            let char = buffer[currentIndex]

            // Stop at markdown special characters or whitespace
            if isMarkdownSpecialChar(char) || char.isWhitespace {
                break
            }

            textValue.append(char)
            advancePosition()
        }

        // Move back one position since we'll advance again in the main loop
        if position > 0 {
            position -= 1
            currentIndex = buffer.index(before: currentIndex)
        }

        return Token(type: .text, value: textValue, position: tokenStart)
    }

    private func isMarkdownSpecialChar(_ char: Character) -> Bool {
        return [">", "#", "*", "`", "[", "!"].contains(char)
    }

    private func advancePosition(by count: Int = 1) {
        for _ in 0..<count {
            if currentIndex < buffer.endIndex {
                currentIndex = buffer.index(after: currentIndex)
                position += 1
            }
        }
    }

    public func hasMoreTokens() -> Bool {
        return position < buffer.count
    }

    public func reset() {
        position = 0
        currentIndex = buffer.startIndex
        atLineStart = true
    }

    public func getBuffer() -> String {
        return buffer
    }

    public func clearProcessed() {
        // Remove processed characters from buffer
        if position > 0 && position <= buffer.count {
            let newStartIndex = buffer.index(buffer.startIndex, offsetBy: position)
            buffer = String(buffer[newStartIndex...])
            position = 0
            currentIndex = buffer.startIndex
            // Keep atLineStart state as it depends on what was processed
        }
    }

    public func clearBuffer() {
        buffer = ""
        position = 0
        currentIndex = buffer.startIndex
        atLineStart = true
    }
}
