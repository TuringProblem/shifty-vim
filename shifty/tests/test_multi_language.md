# 🚀 Shifty Multi-Language REPL Test

This markdown file demonstrates the revolutionary multi-language REPL capabilities of Shifty.

## 🔧 Lua Example

```lua
print("Hello from Lua!")
local x = 10
local y = 20
print("x + y = " .. (x + y))

-- Test Neovim integration
local colors = vim.api.nvim_get_color_map()
print("Available colors: " .. #vim.tbl_keys(colors))
```

## 🐍 Python Example

```python
print("Hello from Python!")
import math
print(f"π = {math.pi}")
```

```python
# Test list comprehension
numbers = [1, 2, 3, 4, 5]
squares = [x**2 for x in numbers]
print(f"Squares: {squares}")

# Test f-strings
name = "Shifty"
version = "2.0"
print(f"Welcome to {name} v{version}!")
```

## ⚡ JavaScript Example

```javascript
console.log("Hello from JavaScript!");

// Test ES6 features
const arr = [1, 2, 3, 4, 5];
const doubled = arr.map((x) => x * 2);
console.log("Doubled array:", doubled);
```

```javascript
// Test template literals
const language = "JavaScript";
const version = "ES2022";
console.log(`Running ${language} with ${version} features!`);
```

```javascript
// Test (bad) destructuring
const person = {
  name: "Developer",
  role: "Code Explorer",
  badExample: "not accounted for.",
};
const { name, role } = person;
console.log(`${name} is a ${role} {${badExample}}`);
```

```javascript
// Test destructuring
const person = {
  name: "Developer",
  role: "Code Explorer",
  goodExample: "accounted for.",
};
const { name, role, goodExample } = person;
console.log(`${name} is a ${role} {${goodExample}}`);
```

## 🎯 Mixed Language Example

You can mix and match languages in the same document!

```lua
-- Lua can call Python or JavaScript results
print("Lua is orchestrating the show!")
```

```python
# Python can process data
data = [1, 2, 3, 4, 5]
result = sum(data)
print(f"Python calculated: {result}")
```

```javascript
// JavaScript can handle async operations
const promise = new Promise((resolve) => {
  setTimeout(() => resolve("Async operation complete!"), 100);
});

promise.then((result) => console.log(result));
```

## 🏆 Performance Test

Let's test the performance of each language:

```lua
local start = os.clock()
local sum = 0
for i = 1, 1000000 do
  sum = sum + i
end
local elapsed = os.clock() - start
print(string.format("Lua: Sum of 1M numbers = %d (%.3f seconds)", sum, elapsed))
```

```python
import time
start = time.time()
sum_val = sum(range(1, 1000001))
elapsed = time.time() - start
print(f"Python: Sum of 1M numbers = {sum_val} ({elapsed:.3f} seconds)")
```

```javascript
const start = Date.now();
let sum = 0;
for (let i = 1; i <= 1000000; i++) {
  sum += i;
}
const elapsed = (Date.now() - start) / 1000;
console.log(
  `JavaScript: Sum of 1M numbers = ${sum} (${elapsed.toFixed(3)} seconds)`,
);
```

## 🎉 Conclusion

Shifty transforms your markdown files into living, breathing development environments where you can:

- ✅ Execute code in multiple languages
- ✅ Mix languages seamlessly
- ✅ Get real-time feedback
- ✅ Test and iterate quickly
- ✅ Document and code in one place

This is the future of development! 🚀
