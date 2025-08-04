# Shifty-Vim Intelligent Language Detection

## Overview

Shifty-Vim now features an advanced intelligent language detection system that automatically identifies programming languages from code snippets and executes them seamlessly. This enhancement provides a "magical" user experience where you can highlight any code and execute it immediately without manual language specification.

## 🎯 Key Features

### ✨ Intelligent Language Detection
- **Semantic Analysis**: Analyzes code syntax patterns, keywords, and language-specific constructs
- **Context Awareness**: Uses file extensions and buffer types as additional detection hints
- **Confidence Scoring**: Provides accuracy levels for detection reliability
- **Fallback Mechanisms**: Multiple detection strategies for maximum reliability

### 👻 Invisible Processing
- **Background Execution**: Creates invisible floating windows for seamless processing
- **Automatic Wrapping**: Programmatically wraps code in markdown format
- **Resource Management**: Automatic cleanup of background resources
- **Performance Optimized**: Minimal impact on existing execution speed

### 🎮 Enhanced User Experience
- **Magic Execution**: One-key automatic detection and execution
- **Visual Selection**: Execute highlighted code with intelligent detection
- **Context Extraction**: Automatically extracts functions, classes, and code blocks
- **Interactive Dialogs**: Language selection for ambiguous cases

## 🚀 Quick Start

### Basic Usage

1. **Magic Execution** (Recommended):
   ```vim
   <leader>sm  " Auto-detect and execute code at cursor
   ```

2. **Visual Selection**:
   ```vim
   v           " Enter visual mode
   [select code]
   <leader>ss  " Execute selected code with detection
   ```

3. **Language Detection**:
   ```vim
   <leader>sd  " Show language detection results
   ```

### Configuration

Add to your Neovim configuration:

```lua
require('shifty').setup({
  keymaps = {
    toggle = "<leader>st",
    run = "<leader>sr",
    smart = "<leader>se",
    selection = "<leader>ss",
    context = "<leader>sl",
    magic = "<leader>sm",      -- New: Magic execution
    detect = "<leader>sd",     -- New: Language detection
    clear = "<leader>sc",
    close = "<Esc>",
  },
  ui = {
    auto_language_detection = true,  -- Enable intelligent detection
    show_language_info = true,       -- Show detection confidence
  }
})
```

## 🔍 Supported Languages

The intelligent detection system supports 6 major programming languages with comprehensive pattern matching:

### Python
- **Keywords**: `def`, `class`, `import`, `from`, `as`, `if`, `elif`, `else`, `for`, `while`, `try`, `except`, `finally`, `with`, `lambda`, `yield`, `return`, `pass`, `break`, `continue`, `raise`, `assert`, `del`, `global`, `nonlocal`
- **Patterns**: Function definitions, class definitions, decorators, imports, variable assignments
- **Boosters**: `__init__`, `self`, `super()`, `print(`, `len(`, `range(`, `list(`, `dict(`, `set(`

### JavaScript
- **Keywords**: `function`, `var`, `let`, `const`, `if`, `else`, `for`, `while`, `try`, `catch`, `finally`, `switch`, `case`, `default`, `break`, `continue`, `return`, `throw`, `new`, `delete`, `typeof`, `instanceof`, `in`, `of`, `async`, `await`, `yield`, `class`, `extends`, `super`, `import`, `export`, `default`
- **Patterns**: Function declarations, arrow functions, class definitions, imports/exports
- **Boosters**: `console.log(`, `document.`, `window.`, `JSON.`, `Array.`, `Object.`, `Promise.`, `fetch(`, `setTimeout(`, `setInterval(`

### Java
- **Keywords**: `public`, `private`, `protected`, `static`, `final`, `abstract`, `class`, `interface`, `extends`, `implements`, `import`, `package`, `new`, `if`, `else`, `for`, `while`, `do`, `switch`, `case`, `default`, `break`, `continue`, `return`, `throw`, `throws`, `try`, `catch`, `finally`, `synchronized`, `volatile`, `transient`, `native`, `strictfp`, `enum`, `assert`, `super`, `this`
- **Patterns**: Method definitions, class definitions, imports, variable declarations
- **Boosters**: `System.out.println(`, `System.out.print(`, `Scanner`, `ArrayList`, `HashMap`, `String`, `Integer`, `Double`, `Boolean`, `main(`, `public static void`

### C
- **Keywords**: `auto`, `break`, `case`, `char`, `const`, `continue`, `default`, `do`, `double`, `else`, `enum`, `extern`, `float`, `for`, `goto`, `if`, `int`, `long`, `register`, `return`, `short`, `signed`, `sizeof`, `static`, `struct`, `switch`, `typedef`, `union`, `unsigned`, `void`, `volatile`, `while`
- **Patterns**: Function definitions, include statements, variable declarations, struct definitions
- **Boosters**: `printf(`, `scanf(`, `malloc(`, `free(`, `strcpy(`, `strcmp(`, `strlen(`, `main(`, `stdio.h`, `stdlib.h`, `string.h`

### Rust
- **Keywords**: `as`, `break`, `const`, `continue`, `crate`, `else`, `enum`, `extern`, `false`, `fn`, `for`, `if`, `impl`, `in`, `let`, `loop`, `match`, `mod`, `move`, `mut`, `pub`, `ref`, `return`, `self`, `Self`, `static`, `struct`, `super`, `trait`, `true`, `type`, `unsafe`, `use`, `where`, `while`, `async`, `await`, `dyn`
- **Patterns**: Function definitions, struct definitions, enum definitions, imports
- **Boosters**: `println!(`, `print!(`, `vec![`, `String::from(`, `to_string(`, `main(`, `Result`, `Option`, `Some(`, `None`, `Ok(`, `Err(`

### Lua
- **Keywords**: `and`, `break`, `do`, `else`, `elseif`, `end`, `false`, `for`, `function`, `if`, `in`, `local`, `nil`, `not`, `or`, `repeat`, `return`, `then`, `true`, `until`, `while`
- **Patterns**: Function definitions, variable declarations, control structures
- **Boosters**: `print(`, `io.write(`, `table.insert(`, `table.remove(`, `string.format(`, `pairs(`, `ipairs(`, `tonumber(`, `tostring(`

## 🎯 Detection Confidence Levels

The system provides confidence levels to help users understand detection accuracy:

- **Definitive (90%+)**: Very high confidence, automatic execution
- **High (75-89%)**: High confidence, automatic execution
- **Medium (60-74%)**: Medium confidence, automatic execution
- **Low (40-59%)**: Low confidence, shows selection dialog
- **Very Low (<40%)**: Very low confidence, prompts for manual selection

## 🔧 Advanced Features

### Context Extraction

The system can intelligently extract code context:

- **Function Context**: Automatically detects and extracts complete functions
- **Class Context**: Identifies and extracts class definitions
- **Block Context**: Extracts control flow blocks (if, for, while, etc.)
- **Line Context**: Falls back to single line execution

### Invisible Window System

- **Background Processing**: Creates off-screen windows for processing
- **Automatic Cleanup**: Manages window lifecycle automatically
- **Resource Tracking**: Monitors and reports on background resources
- **Performance Monitoring**: Tracks processing statistics

### Error Handling

- **Graceful Fallbacks**: Multiple detection strategies
- **User Feedback**: Clear error messages and suggestions
- **Recovery Mechanisms**: Automatic retry with different strategies
- **Debug Information**: Detailed logging for troubleshooting

## 📊 Performance Considerations

### Detection Speed
- **Lightweight Analysis**: Pattern matching without full parsing
- **Caching**: Results cached for recently analyzed patterns
- **Optimized Algorithms**: Efficient string matching and scoring

### Memory Usage
- **Minimal Footprint**: Invisible windows use minimal resources
- **Automatic Cleanup**: Background resources cleaned up automatically
- **Efficient Storage**: Optimized data structures for pattern storage

### Execution Overhead
- **Seamless Integration**: Works with existing execution pipeline
- **Minimal Latency**: Detection adds <1ms to execution time
- **Background Processing**: Non-blocking user interface

## 🛠️ Troubleshooting

### Common Issues

1. **Low Detection Confidence**:
   - Ensure code has sufficient language-specific patterns
   - Check file extension matches expected language
   - Try using visual selection for better context

2. **Incorrect Language Detection**:
   - Use `<leader>sd` to see detection alternatives
   - Manually select language from dialog if needed
   - Add more language-specific keywords to improve detection

3. **Execution Failures**:
   - Check if language runtime is installed
   - Verify code syntax is correct
   - Review error messages in Shifty output window

### Debug Information

Enable debug logging to troubleshoot issues:

```lua
-- Add to your Neovim configuration
vim.g.shifty_debug = true
```

### Performance Monitoring

Monitor system performance:

```lua
-- Check invisible window statistics
:lua print(vim.inspect(require('shifty.invisible_ui').get_invisible_window_stats()))

-- Check detection statistics
:lua print(vim.inspect(require('shifty.detector').get_supported_languages()))
```

## 🔮 Future Enhancements

### Planned Features
- **Machine Learning**: Enhanced detection using ML models
- **More Languages**: Support for additional programming languages
- **Custom Patterns**: User-defined detection patterns
- **Performance Profiling**: Advanced performance monitoring
- **Cloud Integration**: Remote execution capabilities

### Extension Points
- **Plugin API**: Interface for custom language support
- **Pattern API**: Custom pattern definition system
- **Execution API**: Custom execution strategies
- **UI API**: Custom user interface components

## 📝 Examples

### Basic Usage Examples

```lua
-- Python code detection
def hello_world():
    print("Hello, World!")
    return "success"

-- JavaScript code detection
function greet(name) {
    console.log(`Hello, ${name}!`);
    return `Greeted ${name}`;
}

-- Java code detection
public class HelloWorld {
    public static void main(String[] args) {
        System.out.println("Hello, World!");
    }
}
```

### Advanced Usage Examples

```lua
-- Complex Python with imports
import json
import datetime

def process_data(data):
    result = {
        "processed": True,
        "timestamp": datetime.datetime.now().isoformat(),
        "data": data
    }
    return json.dumps(result, indent=2)

-- JavaScript with async/await
async function fetchData(url) {
    try {
        const response = await fetch(url);
        const data = await response.json();
        return data;
    } catch (error) {
        console.error('Error:', error);
        return null;
    }
}
```

## 🤝 Contributing

### Adding New Languages

To add support for a new programming language:

1. **Define Patterns**: Add language-specific patterns to `detector.lua`
2. **Create Language Module**: Implement language execution module
3. **Add Tests**: Create comprehensive test cases
4. **Update Documentation**: Document new language support

### Pattern Definition

```lua
-- Example pattern definition
language_name = {
    keywords = {"keyword1", "keyword2", "keyword3"},
    imports = {"^%s*import%s+", "^%s*from%s+%w+%s+import"},
    functions = {"^%s*def%s+%w+%s*%(", "^%s*function%s+%w+%s*%("},
    classes = {"^%s*class%s+%w+%s*%(", "^%s*public%s+class%s+%w+"},
    variables = {"^%s*%w+%s*=", "^%s*let%s+%w+"},
    syntax = {"^%s*if%s+.*:%s*$", "^%s*for%s+.*%s+in%s+.*:%s*$"},
    confidence_boosters = {"language_specific_function(", "unique_keyword"},
    confidence_penalties = {"conflicting_keyword1", "conflicting_keyword2"}
}
```

## 📄 License

This enhancement is part of the Shifty-Vim project and follows the same licensing terms.

---

**Enjoy the magic of intelligent code execution! 🎉** 