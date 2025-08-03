# Test Shifty Installation

This file contains code blocks in various languages to test your Shifty installation.

## Python Test

```python
print("Hello from Python!")
print(f"Python version: {__import__('sys').version}")
```

## JavaScript Test

```javascript
console.log("Hello from JavaScript!");
console.log(`Node.js version: ${process.version}`);
```

## Lua Test

```lua
print("Hello from Lua!")
print("Lua version: " .. _VERSION)
```

## Rust Test

```rust
fn main() {
    println!("Hello from Rust!");
    println!("Rust version: {}", env!("CARGO_PKG_VERSION"));
}
```

## Instructions

1. Open this file in Neovim
2. Run `:ShiftyToggle` to open the Shifty window
3. Place your cursor in any code block above
4. Run `:ShiftyRun` to execute the code
5. You should see the output in the floating window

## Troubleshooting

If you get errors:

1. Make sure the language runtime is installed (python3, node, lua, rustc)
2. Check that the language is in your PATH
3. Run `:ShiftyInfo` to see available languages
4. Verify your configuration in your Neovim config file 