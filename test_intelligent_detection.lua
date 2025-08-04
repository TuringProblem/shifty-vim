-- Test script for Shifty-Vim Intelligent Language Detection
-- Run this in Neovim to test the new features

local detector = require('shifty.detector')
local parser = require('shifty.parser')
local utils = require('shifty.utils')

-- Test cases for language detection
local test_cases = {
    {
        name = "Python Function",
        code = [[
def greet(name):
    print(f"Hello, {name}!")
    return f"Greeted {name}"

result = greet("World")
print(result)
]],
        expected = "python"
    },
    {
        name = "JavaScript Function",
        code = [[
function calculateSum(a, b) {
    return a + b;
}

const result = calculateSum(5, 3);
console.log(`Sum: ${result}`);
]],
        expected = "javascript"
    },
    {
        name = "Java Class",
        code = [[
public class Calculator {
    public static int add(int a, int b) {
        return a + b;
    }
    
    public static void main(String[] args) {
        int result = add(10, 20);
        System.out.println("Result: " + result);
    }
}
]],
        expected = "java"
    },
    {
        name = "C Function",
        code = [[
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
]],
        expected = "c"
    },
    {
        name = "Rust Function",
        code = [[
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
]],
        expected = "rust"
    },
    {
        name = "Lua Function",
        code = [[
function factorial(n)
    if n <= 1 then
        return 1
    else
        return n * factorial(n - 1)
    end
end

local result = factorial(5)
print("Factorial of 5 is " .. result)
]],
        expected = "lua"
    }
}

-- Run tests
print("🧪 Testing Shifty-Vim Intelligent Language Detection")
print("=" .. string.rep("=", 50))
print()

local passed = 0
local total = #test_cases

for i, test_case in ipairs(test_cases) do
    print(string.format("Test %d: %s", i, test_case.name))
    
    -- Test language detection
    local result = detector.detect_language(test_case.code)
    
    if result then
        local success = result.language == test_case.expected
        local status = success and "✅ PASS" or "❌ FAIL"
        
        print(string.format("  Expected: %s", test_case.expected))
        print(string.format("  Detected: %s (%.1f%% confidence)", result.language, result.confidence))
        print(string.format("  Status: %s", status))
        
        if result.alternatives and #result.alternatives > 0 then
            print("  Alternatives:")
            for _, alt in ipairs(result.alternatives) do
                print(string.format("    • %s (%.1f%%)", alt.language, alt.confidence))
            end
        end
        
        if success then
            passed = passed + 1
        end
    else
        print("  ❌ FAIL: Detection failed")
    end
    
    print()
end

-- Summary
print("📊 Test Summary")
print("=" .. string.rep("=", 50))
print(string.format("Passed: %d/%d (%.1f%%)", passed, total, (passed/total)*100))

if passed == total then
    print("🎉 All tests passed! Intelligent detection is working correctly.")
else
    print("⚠️  Some tests failed. Check the detection patterns.")
end

print()
print("🔍 Testing Context Extraction")
print("=" .. string.rep("=", 50))

-- Test context extraction
local context_test = {
    name = "Python with Context",
    code = [[
import json

def process_data(data):
    result = {
        "processed": True,
        "data": data
    }
    return json.dumps(result)

# Test the function
test_data = {"name": "test"}
output = process_data(test_data)
print(output)
]]
}

print("Testing context extraction with Python code...")
local context = {
    file_extension = ".py",
    buffer_filetype = "python"
}

local detection_result = detector.detect_language(context_test.code, context)
if detection_result then
    print(string.format("✅ Context-aware detection: %s (%.1f%% confidence)", 
         detection_result.language, detection_result.confidence))
    print(string.format("   Context used: %s", detection_result.analysis.context_used and "Yes" or "No"))
else
    print("❌ Context extraction failed")
end

print()
print("👻 Testing Invisible Window System")
print("=" .. string.rep("=", 50))

-- Test invisible window system
local invisible_ui = require('shifty.invisible_ui')

-- Initialize the system
invisible_ui.init()

-- Create a test invisible window
local test_win = invisible_ui.create_invisible_window({
    purpose = "test_processing",
    width = 1,
    height = 1
})

if test_win then
    print("✅ Invisible window created successfully")
    
    -- Get statistics
    local stats = invisible_ui.get_invisible_window_stats()
    print(string.format("   Active windows: %d", stats.total_windows))
    
    -- Clean up
    invisible_ui.close_invisible_window(test_win)
    print("✅ Invisible window cleaned up")
else
    print("❌ Failed to create invisible window")
end

print()
print("🎯 Testing Supported Languages")
print("=" .. string.rep("=", 50))

local supported = detector.get_supported_languages()
print(string.format("Supported languages (%d):", #supported))
for _, lang in ipairs(supported) do
    print(string.format("  • %s", lang))
end

print()
print("✨ Intelligent Language Detection Test Complete!")
print("=" .. string.rep("=", 50))
print()
print("To test the full functionality:")
print("1. Open the demo file: examples/intelligent_detection_demo.md")
print("2. Try the magic execution: <leader>sm")
print("3. Test visual selection: v + <leader>ss")
print("4. Check language detection: <leader>sd")
print()
print("Happy coding! 🚀") 