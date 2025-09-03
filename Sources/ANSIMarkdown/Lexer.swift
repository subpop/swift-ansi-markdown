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
    case codeBlockLanguage = "```lang"
    case thematicBreak = "---"
    case linkOpenBracket = "["
    case linkCloseBracket = "]"
    case linkOpenParen = "("
    case linkCloseParen = ")"
    case linkText = "linkText"
    case linkURL = "linkURL"
    case imageOpenBracket = "!["
    case imageCloseBracket = "img]"
    case imageOpenParen = "img("
    case imageCloseParen = "img)"
    case imageAltText = "imageAltText"
    case imageURL = "imageURL"
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
    private var inCodeBlock: Bool = false
    private var expectingCodeBlockLanguage: Bool = false
    private var linkParsingState: LinkParsingState = .none

    private enum LinkParsingState {
        case none
        case expectingLinkText
        case expectingLinkCloseBracket
        case expectingLinkOpenParen
        case expectingLinkURL
        case expectingLinkCloseParen
        case expectingImageAltText
        case expectingImageCloseBracket
        case expectingImageOpenParen
        case expectingImageURL
        case expectingImageCloseParen
    }

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

        // Check for code blocks (```) - can be at line start or with leading whitespace
        if remainingText.hasPrefix("```") {
            // For opening code blocks, require line start (standard markdown)
            // For closing code blocks, allow them anywhere on the line
            let shouldRecognize = atLineStart || inCodeBlock

            if shouldRecognize {
                atLineStart = false
                inCodeBlock.toggle()

                // If we're entering a code block, expect a language token next
                if inCodeBlock {
                    expectingCodeBlockLanguage = true
                }

                let token = Token(type: .codeBlock, value: "```", position: position)
                advancePosition(by: 3)
                return token
            }
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
            linkParsingState = .expectingImageAltText
            let token = Token(type: .imageOpenBracket, value: "![", position: position)
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
        if inCodeBlock {
            switch char {
            case "\n":
                // If we were expecting a language but hit a newline, there's no language
                if expectingCodeBlockLanguage {
                    expectingCodeBlockLanguage = false
                }
                // Reset link parsing state on newlines - links/images don't span lines
                linkParsingState = .none
                atLineStart = true
                return Token(type: .newline, value: String(char), position: tokenStart)
            case " ", "\t":
                // Handle whitespace inside code blocks properly
                return Token(type: .whitespace, value: String(char), position: tokenStart)
            default:
                return parseTextToken(startingWith: char, at: tokenStart)
            }
        }
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
            linkParsingState = .expectingLinkText
            return Token(type: .linkOpenBracket, value: String(char), position: tokenStart)
        case "]":
            atLineStart = false
            return handleCloseBracket(at: tokenStart)
        case "\n":
            // If we were expecting a language but hit a newline, there's no language
            if expectingCodeBlockLanguage {
                expectingCodeBlockLanguage = false
            }
            // Reset link parsing state on newlines - links/images don't span lines
            linkParsingState = .none
            atLineStart = true
            return Token(type: .newline, value: String(char), position: tokenStart)
        case " ", "\t":
            // If we're expecting a language and hit whitespace, skip it (don't reset expectation yet)
            // Only stay at line start if we're already there and this is whitespace
            return Token(type: .whitespace, value: String(char), position: tokenStart)
        default:
            atLineStart = false
            return parseTextToken(startingWith: char, at: tokenStart)
        }
    }

    private func handleCloseBracket(at tokenStart: Int) -> Token {
        switch linkParsingState {
        case .expectingLinkCloseBracket:
            linkParsingState = .expectingLinkOpenParen
            return Token(type: .linkCloseBracket, value: "]", position: tokenStart)
        case .expectingImageCloseBracket:
            linkParsingState = .expectingImageOpenParen
            return Token(type: .imageCloseBracket, value: "]", position: tokenStart)
        default:
            // Reset state if we encounter unexpected bracket
            linkParsingState = .none
            return Token(type: .text, value: "]", position: tokenStart)
        }
    }

    private func handleOpenParen(at tokenStart: Int) -> Token {
        switch linkParsingState {
        case .expectingLinkOpenParen:
            linkParsingState = .expectingLinkURL
            return Token(type: .linkOpenParen, value: "(", position: tokenStart)
        case .expectingImageOpenParen:
            linkParsingState = .expectingImageURL
            return Token(type: .imageOpenParen, value: "(", position: tokenStart)
        default:
            return Token(type: .text, value: "(", position: tokenStart)
        }
    }

    private func handleCloseParen(at tokenStart: Int) -> Token {
        switch linkParsingState {
        case .expectingLinkCloseParen:
            linkParsingState = .none
            return Token(type: .linkCloseParen, value: ")", position: tokenStart)
        case .expectingImageCloseParen:
            linkParsingState = .none
            return Token(type: .imageCloseParen, value: ")", position: tokenStart)
        default:
            return Token(type: .text, value: ")", position: tokenStart)
        }
    }

    private func parseTextToken(startingWith firstChar: Character, at tokenStart: Int) -> Token {
        var textValue = String(firstChar)
        advancePosition()  // Move past the first character

        // Collect consecutive text characters
        while currentIndex < buffer.endIndex {
            let char = buffer[currentIndex]

            // Stop at markdown special characters or whitespace
            // Also stop at brackets and parentheses when in link parsing state
            if isMarkdownSpecialChar(char) || char.isWhitespace
                || (linkParsingState != .none && (char == "]" || char == "(" || char == ")"))
            {
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

        // If we're expecting a code block language, emit it as a language token
        if expectingCodeBlockLanguage {
            expectingCodeBlockLanguage = false
            return Token(type: .codeBlockLanguage, value: textValue, position: tokenStart)
        }

        // Handle parentheses when in appropriate link parsing states
        if linkParsingState != .none {
            if textValue == "(" {
                return handleOpenParen(at: tokenStart)
            } else if textValue == ")" {
                return handleCloseParen(at: tokenStart)
            }
            // If text starts with ( or ) but has more content, we need to split it
            if textValue.hasPrefix("(") && textValue.count > 1 {
                // Put back the extra characters and just handle the opening paren
                let extraChars = String(textValue.dropFirst())
                // We need to rewind the buffer to put back the extra characters
                for _ in 0..<extraChars.count {
                    if position > 0 {
                        position -= 1
                        currentIndex = buffer.index(before: currentIndex)
                    }
                }
                return handleOpenParen(at: tokenStart)
            } else if textValue.hasSuffix(")") && textValue.count > 1 {
                // Similar logic for closing paren
                let beforeParen = String(textValue.dropLast())
                // Rewind to put back the closing paren
                if position > 0 {
                    position -= 1
                    currentIndex = buffer.index(before: currentIndex)
                }
                // Return the text before the paren, and the paren will be handled next
                return Token(type: .text, value: beforeParen, position: tokenStart)
            }
        }

        // Check if we're parsing link/image content
        switch linkParsingState {
        case .expectingLinkText:
            linkParsingState = .expectingLinkCloseBracket
            return Token(type: .linkText, value: textValue, position: tokenStart)
        case .expectingLinkCloseBracket:
            // Continue parsing link text after whitespace
            return Token(type: .linkText, value: textValue, position: tokenStart)
        case .expectingImageAltText:
            linkParsingState = .expectingImageCloseBracket
            return Token(type: .imageAltText, value: textValue, position: tokenStart)
        case .expectingImageCloseBracket:
            // Continue parsing image alt text after whitespace
            return Token(type: .imageAltText, value: textValue, position: tokenStart)
        case .expectingLinkURL:
            linkParsingState = .expectingLinkCloseParen
            return Token(type: .linkURL, value: textValue, position: tokenStart)
        case .expectingLinkCloseParen:
            // Continue parsing link URL after whitespace
            return Token(type: .linkURL, value: textValue, position: tokenStart)
        case .expectingImageURL:
            linkParsingState = .expectingImageCloseParen
            return Token(type: .imageURL, value: textValue, position: tokenStart)
        case .expectingImageCloseParen:
            // Continue parsing image URL after whitespace
            return Token(type: .imageURL, value: textValue, position: tokenStart)
        default:
            return Token(type: .text, value: textValue, position: tokenStart)
        }
    }

    private func isMarkdownSpecialChar(_ char: Character) -> Bool {
        return [">", "#", "*", "`", "[", "]", "!"].contains(char)
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
        inCodeBlock = false
        expectingCodeBlockLanguage = false
        linkParsingState = .none
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
        inCodeBlock = false
        expectingCodeBlockLanguage = false
        linkParsingState = .none
    }
}
