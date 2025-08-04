# Shifty-Vim Intelligent Language Detection Demo

This file demonstrates the new intelligent language detection features of Shifty-Vim. You can highlight any code snippet and execute it automatically without manually wrapping it in markdown code blocks.

## Python Examples

### Basic Python Code
```python
def greet(name):
    print(f"Hello, {name}!")
    return f"Greeted {name}"

result = greet("World")
print(result)
```

### Python with Imports
```python
import json
import datetime

data = {
    "name": "Shifty",
    "version": "2.0",
    "features": ["intelligent_detection", "invisible_processing"]
}

print(json.dumps(data, indent=2))
print(f"Generated at: {datetime.datetime.now()}")
```

## JavaScript Examples

### Basic JavaScript
```javascript
function calculateSum(a, b) {
    return a + b;
}

const result = calculateSum(5, 3);
console.log(`Sum: ${result}`);
```

### JavaScript with ES6 Features
```javascript
const numbers = [1, 2, 3, 4, 5];
const doubled = numbers.map(n => n * 2);
const sum = doubled.reduce((acc, n) => acc + n, 0);

console.log(`Original: ${numbers}`);
console.log(`Doubled: ${doubled}`);
console.log(`Sum: ${sum}`);
```

## Java Examples

### Basic Java
```java
public class Calculator {
    public static int add(int a, int b) {
        return a + b;
    }
    
    public static void main(String[] args) {
        int result = add(10, 20);
        System.out.println("Result: " + result);
    }
}
```

### Java with Collections
```java
import java.util.*;

public class ListDemo {
    public static void main(String[] args) {
        List<String> names = new ArrayList<>();
        names.add("Alice");
        names.add("Bob");
        names.add("Charlie");
        
        for (String name : names) {
            System.out.println("Hello, " + name + "!");
        }
    }
}
```

## C Examples

### Basic C
```c
#include <stdio.h>
#include <stdlib.h>

int factorial(int n) {
    if (n <= 1) return 1;
    return n * factorial(n - 1);
}

int main() {
    int num = 5;
    printf("Factorial of %d is %d\n", num, factorial(num));
    return 0;
}
```

### C with Arrays
```c
#include <stdio.h>

int main() {
    int numbers[] = {1, 2, 3, 4, 5};
    int sum = 0;
    
    for (int i = 0; i < 5; i++) {
        sum += numbers[i];
    }
    
    printf("Sum: %d\n", sum);
    return 0;
}
```

## Rust Examples

### Basic Rust
```rust
fn fibonacci(n: u32) -> u32 {
    match n {
        0 => 0,
        1 => 1,
        _ => fibonacci(n - 1) + fibonacci(n - 2),
    }
}

fn main() {
    let n = 10;
    println!("Fibonacci({}) = {}", n, fibonacci(n));
}
```

### Rust with Vectors
```rust
fn main() {
    let mut numbers = vec![1, 2, 3, 4, 5];
    
    // Double each number
    for num in &mut numbers {
        *num *= 2;
    }
    
    println!("Doubled numbers: {:?}", numbers);
    
    // Calculate sum
    let sum: i32 = numbers.iter().sum();
    println!("Sum: {}", sum);
}
```

## Lua Examples

### Basic Lua
```lua
function factorial(n)
    if n <= 1 then
        return 1
    else
        return n * factorial(n - 1)
    end
end

local result = factorial(5)
print("Factorial of 5 is " .. result)
```

### Lua with Tables
```lua
local fruits = {"apple", "banana", "orange", "grape"}

print("Fruits:")
for i, fruit in ipairs(fruits) do
    print(i .. ". " .. fruit)
end

local person = {
    name = "John",
    age = 30,
    city = "New York"
}

print("\nPerson:")
for key, value in pairs(person) do
    print(key .. ": " .. value)
end
```

## Testing the Intelligent Detection

### Instructions for Testing:

1. **Magic Execution**: Place your cursor on any line of code above and press `<leader>sm` to automatically detect the language and execute it.

2. **Visual Selection**: Highlight any code snippet in visual mode and press `<leader>ss` to execute the selected code.

3. **Language Detection**: Place your cursor on any code and press `<leader>sd` to see the language detection results.

4. **Smart Execution**: Press `<leader>se` to let Shifty intelligently choose the best execution method.

### Expected Behavior:

- **High Confidence (>60%)**: Code executes automatically with detected language
- **Medium Confidence (40-60%)**: Shows language selection dialog
- **Low Confidence (<40%)**: Prompts for manual language selection

### Features Demonstrated:

- ✅ **Semantic Analysis**: Detects language based on syntax patterns
- ✅ **Context Awareness**: Uses file extension and buffer type as hints
- ✅ **Invisible Processing**: Background execution without visible windows
- ✅ **Confidence Scoring**: Provides confidence levels for detection accuracy
- ✅ **Fallback Mechanisms**: Multiple detection strategies for reliability
- ✅ **User Feedback**: Clear indication of detection confidence and alternatives

### Supported Languages:

- Python (def, import, print, etc.)
- JavaScript (function, const, console.log, etc.)
- Java (public class, System.out.println, etc.)
- C (#include, printf, main, etc.)
- Rust (fn, println!, vec!, etc.)
- Lua (function, print, local, etc.)

The system analyzes keywords, import statements, function definitions, variable declarations, and language-specific constructs to determine the programming language with high accuracy. 