# Shifty Code Block Test

This file tests various code block formats and languages supported by Shifty.

## Standard Markdown Code Blocks

### Python Test
```python
print("Hello from Python!")
print(f"Python version: {__import__('sys').version}")
```

### JavaScript Test
```javascript
console.log("Hello from JavaScript!");
console.log(`Node.js version: ${process.version}`);
```

### Lua Test
```lua
print("Hello from Lua!")
print("Lua version: " .. _VERSION)
```

### Rust Test
```rust
fn main() {
    println!("Hello from Rust!");
    println!("Rust version: {}", env!("CARGO_PKG_VERSION"));
}
```

### Java Test
```java
System.out.println("Hello from Java!");
System.out.println("Java version: " + System.getProperty("java.version"));
```

## Alternative Code Block Formats

### With Language Aliases
```py
print("Python with 'py' alias")
```

```js
console.log("JavaScript with 'js' alias");
```

```rs
fn main() {
    println!("Rust with 'rs' alias");
}
```

```java
System.out.println("Java with 'java' alias");
```

### With No Language Specified
```
echo "This is a shell script without language specified"
```

## Fenced Code Blocks with Different Delimiters

### Triple Backticks
```python
print("Triple backticks work")
```

### Four Backticks
````python
print("Four backticks also work")
````

### Tilde Fences
~~~python
print("Tilde fences work too")
~~~

## Inline Code Blocks

This is `inline code` that should not be executed.

## Mixed Content

Here's some text, then a code block:

```python
print("Mixed content test")
```

And more text after the code block.

## Nested Code Blocks

This should not cause issues:

````markdown
```python
print("Nested code block")
```
````

## Edge Cases

### Empty Code Block
```python

```

### Single Line
```python
print("Single line")
```

### Multiple Lines
```python
print("Line 1")
print("Line 2")
print("Line 3")
```

## Language-Specific Tests

### Python with Imports
```python
import sys
import os
print(f"Python {sys.version}")
print(f"Current directory: {os.getcwd()}")
```

### JavaScript with Async
```javascript
async function test() {
    console.log("Async function test");
    return "success";
}
test().then(console.log);
```

### Lua with Tables
```lua
local t = {name = "Lua", version = _VERSION}
print(string.format("Language: %s, Version: %s", t.name, t.version))
```

### Java with Classes
```java
public class TestClass {
    public static void main(String[] args) {
        String language = "Java";
        String version = System.getProperty("java.version");
        System.out.println("Language: " + language + ", Version: " + version);
    }
}
```

## Testing Instructions

1. Open this file in Neovim
2. Run `:ShiftyToggle` to open the Shifty window
3. Place your cursor in any code block above
4. Run `:ShiftyRun` to execute the code
5. Test different languages and formats
6. Check that inline code and nested blocks are ignored
7. Verify that the output appears in the floating window

## Expected Behavior

- ✅ Code blocks with language specifiers should execute
- ✅ Language aliases (py, js, rs) should work
- ✅ Different fence styles should work
- ✅ Inline code should be ignored
- ✅ Nested code blocks should be handled properly
- ✅ Empty code blocks should be handled gracefully
- ✅ Multi-line code should execute correctly 