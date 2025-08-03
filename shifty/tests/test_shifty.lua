-- Test file for Shifty plugin
-- This file contains Lua code blocks that can be tested with the Shifty plugin

```lua
-- Test code block 1
print("Hello from Shifty!")
local x = 10
local y = 20
print("Sum:", x + y)
```

```lua
-- Test code block 2
local function fibonacci(n)
  if n <= 1 then
    return n
  end
  return fibonacci(n-1) + fibonacci(n-2)
end

print("Fibonacci(10):", fibonacci(10))
```

```lua
-- Test code block 3 (with error)
print("This should work")
undefined_function() -- This will cause an error
print("This won't be reached")
``` 
