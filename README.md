# ANSIMarkdown

A Swift library for streaming markdown formatted text with ANSI color codes.

## Features

- 🎨 **Rich ANSI formatting** - Headers, emphasis, code blocks, quotes, thematic
  breaks, links, and images
- 🚀 **Streaming support** - Process markdown incrementally as it arrives
- 🔧 **Flexible output** - Write to stdout or capture formatted strings
- 🧪 **Comprehensive testing** - Extensive unit test coverage
- 📦 **Zero dependencies** - Pure Swift implementation

## Installation

### Swift Package Manager

Add ANSIMarkdown to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/subpop/swift-ansi-markdown.git", from: "0.1.0")
]
```

Then add it to your target dependencies:

```swift
.target(
    name: "YourTarget",
    dependencies: ["ANSIMarkdown"]
)
```

### Xcode

1. In Xcode, go to **File** → **Add Package Dependencies**
2. Enter the repository URL: `https://github.com/subpop/swift-ansi-markdown.git`
3. Click **Add Package**

## Quick Start

```swift
import ANSIMarkdown

let formatter = ANSIMarkdownFormatter()
// Add some markdown to be formatted.
formatter.add("# Hello **World**!\n\nThis is *italic* and `code`.\n\n---\n\nMore content below.")
// Format and print.
formatter.format()
```

Output:
```
# Hello World!

This is italic and code.

──────────────────────────────────────────────────

More content below.
```
*(with beautiful ANSI colors and formatting)*

## Usage

### Basic Formatting

```swift
import ANSIMarkdown

// Create a formatter (outputs to stdout by default)
let formatter = ANSIMarkdownFormatter()

// Add markdown content
formatter.add("""
# Main Title
## Subtitle

This is **bold** and *italic* text.

Here's some `inline code` and a block quote:

> This is a block quote
> with multiple lines.

---

Check out [this link](http://www.swift.org).
""")

// Format and output
formatter.format()
```

### Streaming/Incremental Processing

Designed for processing markdown content as it arrives (e.g., from network
streams, user input, or file reading):

```swift
let formatter = ANSIMarkdownFormatter()

// Process content in chunks
let chunks = [
    "# Streaming",
    " Markdown",
    "\n\nThis content is being",
    " processed **incrementally**"
]

for chunk in chunks {
    formatter.add(chunk)
    formatter.format() // Formats available complete tokens
}
```

### Capturing Output

Instead of printing to stdout, capture formatted output as a string:

```swift
let output = StringOutput()
let formatter = ANSIMarkdownFormatter(output: output)

formatter.add("# Captured Output\nThis is **bold** text.")
formatter.format()

let formattedString = formatter.getOutput() // Returns the ANSI-formatted string
print("Length: \(formattedString?.count ?? 0) characters")
```

### Custom Output Streams

Implement the `TextOutputStream` protocol for custom output handling:

```swift
struct FileOutput: TextOutputStream {
    let fileHandle: FileHandle
    
    mutating func write(_ string: String) {
        fileHandle.write(Data(string.utf8))
    }
}

let fileOutput = FileOutput(fileHandle: someFileHandle)
let formatter = ANSIMarkdownFormatter(output: fileOutput)
```

### Reset and Reuse

```swift
let formatter = ANSIMarkdownFormatter()

// First document
formatter.add("# Document 1")
formatter.format()

// Reset for new document
formatter.reset()
formatter.add("# Document 2")
formatter.format()
```

## Supported Markdown Elements

| Element | Syntax | ANSI Formatting |
|---------|--------|-----------------|
| **Headers** | `# H1`, `## H2`, etc. | Bold + bright colors (red, yellow, green, cyan, blue, magenta) |
| **Bold** | `**text**` | Bold |
| **Italic** | `*text*` | Italic |
| **Inline Code** | `` `code` `` | Cyan + dim |
| **Code Blocks** | ``` ```code``` ``` | Bright black + dim |
| **Block Quotes** | `> quote` | Gray indicator (▎) + reset formatting |
| **Thematic Breaks** | `---`, `***`, or `___` | Gray horizontal line (─) |
| **Links** | `[text]` | Blue + underline |
| **Images** | `![alt]` | Magenta |

### Color Scheme

- **H1**: Bold + Bright Red
- **H2**: Bold + Bright Yellow  
- **H3**: Bold + Bright Green
- **H4**: Bold + Bright Cyan
- **H5**: Bold + Bright Blue
- **H6+**: Bold + Bright Magenta
- **Inline Code**: Cyan + Dim
- **Code Blocks**: Bright Black + Dim
- **Thematic Breaks**: Bright Black + Dim (horizontal line)
- **Links**: Blue + Underline
- **Images**: Magenta
- **Block Quotes**: Gray indicator with preserved inner formatting

## Architecture & Design

### Core Components

#### 1. Lexer (`Lexer.swift`)

The lexer tokenizes markdown text into discrete tokens:

```swift
public enum TokenType {
    case heading, emphasis, strongEmphasis, code, codeBlock
    case blockQuote, thematicBreak, link, image, text, whitespace, newline, eof
}
```

**Key Features:**
- **Streaming-friendly**: Processes text incrementally without requiring
  complete documents
- **Smart tokenization**: Handles multi-character tokens (`**`, `````, `![`, `---`)
  correctly
- **Position tracking**: Maintains character positions for debugging
- **Buffer management**: Efficiently manages processed vs. unprocessed content

#### 2. Formatter (`Formatter.swift`)

The formatter converts tokens to ANSI-formatted output:

```swift
public class ANSIMarkdownFormatter {
    public func add(_ text: String)  // Add content to process
    public func format()             // Process available tokens
    public func reset()              // Reset state for reuse
}
```

**Key Features:**
- **State management**: Tracks nested formatting contexts (bold inside headers,
  etc.)
- **ANSI code generation**: Produces proper escape sequences for terminal
  formatting
- **Output abstraction**: Supports different output destinations via
  `TextOutputStream`

#### 3. Output Streams

- **`StandardOutput`**: Writes directly to stdout
- **`StringOutput`**: Captures output in a string buffer for testing/processing
- **`TextOutputStream` protocol**: Allows custom output implementations

### Design Principles

#### Streaming Architecture

The library is designed for **streaming/incremental processing**:

1. **Partial token handling**: Can process incomplete markdown (e.g., receiving
   `*` before `*bold*`)
2. **Immediate formatting**: Formats complete tokens as soon as they're
   available
3. **State preservation**: Maintains formatting context across multiple `add()`
   calls
4. **Buffer efficiency**: Manages memory by clearing processed content

#### State Management

The formatter maintains rich state to handle complex markdown:

```swift
private struct FormattingState {
    var inEmphasis: Bool
    var inStrongEmphasis: Bool  
    var inCode: Bool
    var inCodeBlock: Bool
    var inBlockQuote: Bool
    var headingLevel: Int
    var atLineStart: Bool
}
```

This enables:
- **Nested formatting**: Bold text inside headers, code inside quotes
- **Context-aware processing**: Block quotes and thematic breaks only at line
  start
- **Proper reset handling**: Restoring active formatting after code blocks and
  thematic breaks

#### ANSI Code Management

Careful ANSI escape sequence handling:

- **Proper nesting**: Bold + italic + colors work together
- **Clean resets**: Specific resets (e.g., `resetBold`) preserve other formatting
- **State restoration**: After code blocks, active formatting is restored

#### Custom Formatters

The lexer is deliberately exposed as part of the public API to enable developers
to create formatters for other output types.

### Performance Characteristics

- **Fast tokenization**: Single-pass lexing with lookahead for multi-char tokens
- **Minimal allocations**: Reuses buffers and state objects
- **Streaming optimized**: No need to buffer entire documents

## Requirements

- **Swift 6.0+**
- **macOS 15.0+** (as specified in Package.swift)
- **Terminal with ANSI support** for proper color display

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Write tests for your changes
4. Ensure all tests pass (`swift test`)
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## License

This project is licensed under the Apache 2.0 License - see the
[LICENSE](LICENSE) file for details.

