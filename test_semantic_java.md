# Java Semantic Evaluator Tests

This file demonstrates the intelligent semantic analysis capabilities of the Java language support.

## Complete Programs (Direct Execution)

### Full Java Program
```java
public class CompleteProgram {
    public static void main(String[] args) {
        System.out.println("This is a complete program!");
        System.out.println("Java version: " + System.getProperty("java.version"));
    }
}
```

### Program with Imports
```java
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class DateTimeProgram {
    public static void main(String[] args) {
        LocalDateTime now = LocalDateTime.now();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
        System.out.println("Current time: " + now.format(formatter));
    }
}
```

## Statements (Template Wrapping)

### Simple Statements
```java
int x = 10;
int y = 20;
int sum = x + y;
System.out.println("Sum: " + sum);
```

### Variable Declarations
```java
String name = "World";
int age = 25;
double height = 1.75;
boolean isStudent = true;
System.out.println("Name: " + name + ", Age: " + age);
```

## Expressions (Print Wrapping)

### Simple Expressions
```java
2 + 3 * 4
```

### String Expressions
```java
"Hello" + " " + "World"
```

### Mathematical Expressions
```java
Math.sqrt(16) + Math.pow(2, 3)
```

## Class Definitions (Class + Main Wrapping)

### Simple Class
```java
public class Person {
    private String name;
    private int age;
    
    public Person(String name, int age) {
        this.name = name;
        this.age = age;
    }
    
    public void introduce() {
        System.out.println("Hi, I'm " + name + " and I'm " + age + " years old.");
    }
}
```

### Class with Static Methods
```java
public class MathUtils {
    public static int add(int a, int b) {
        return a + b;
    }
    
    public static double multiply(double x, double y) {
        return x * y;
    }
    
    public static boolean isEven(int n) {
        return n % 2 == 0;
    }
}
```

## Collections and Data Structures

### ArrayList Operations
```java
import java.util.ArrayList;
import java.util.Arrays;

ArrayList<String> fruits = new ArrayList<>(Arrays.asList("Apple", "Banana", "Orange"));
fruits.add("Mango");
System.out.println("Fruits: " + fruits);
System.out.println("Size: " + fruits.size());
```

### HashMap Usage
```java
import java.util.HashMap;

HashMap<String, Integer> scores = new HashMap<>();
scores.put("Alice", 95);
scores.put("Bob", 87);
scores.put("Charlie", 92);

for (String name : scores.keySet()) {
    System.out.println(name + ": " + scores.get(name));
}
```

## Exception Handling

### Try-Catch Block
```java
try {
    int result = 10 / 0;
    System.out.println("Result: " + result);
} catch (ArithmeticException e) {
    System.out.println("Error: " + e.getMessage());
} finally {
    System.out.println("Finally block executed");
}
```

## Control Structures

### If-Else Chain
```java
int score = 85;
if (score >= 90) {
    System.out.println("Grade: A");
} else if (score >= 80) {
    System.out.println("Grade: B");
} else if (score >= 70) {
    System.out.println("Grade: C");
} else {
    System.out.println("Grade: F");
}
```

### For Loop with Array
```java
int[] numbers = {1, 2, 3, 4, 5};
int sum = 0;
for (int num : numbers) {
    sum += num;
}
System.out.println("Sum: " + sum);
```

## Advanced Features

### Lambda Expressions
```java
import java.util.Arrays;
import java.util.List;

List<String> names = Arrays.asList("Alice", "Bob", "Charlie", "David");
names.forEach(name -> System.out.println("Hello, " + name + "!"));
```

### Stream Operations
```java
import java.util.Arrays;
import java.util.List;

List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
int sum = numbers.stream()
    .filter(n -> n % 2 == 0)
    .mapToInt(Integer::intValue)
    .sum();
System.out.println("Sum of even numbers: " + sum);
```

## Edge Cases

### Empty Code Block
```java

```

### Single Expression
```java
42
```

### Import Only
```java
import java.util.*;
```

### Comment Only
```java
// This is just a comment
/* Multi-line comment */
```

## Testing Instructions

1. Open this file in Neovim
2. Source your Shifty configuration
3. Place your cursor in any Java code block
4. Run `:ShiftyRun` or press `<leader>sr`
5. Observe how the semantic evaluator:
   - Detects the code type
   - Chooses the appropriate execution strategy
   - Provides warnings and optimization suggestions
   - Handles different code patterns intelligently

## Expected Semantic Analysis

### Complete Programs
- ✅ Code type: complete_program
- ✅ Strategy: direct
- ✅ No wrapping needed

### Statements
- ✅ Code type: statements
- ✅ Strategy: template
- ✅ Wrapped in main method

### Expressions
- ✅ Code type: expressions
- ✅ Strategy: template
- ✅ Wrapped with System.out.println

### Class Definitions
- ✅ Code type: class_definition
- ✅ Strategy: template
- ✅ Wrapped with main method to test class

### Warnings and Optimizations
- ✅ Detects missing imports
- ✅ Suggests StringBuilder for string concatenation
- ✅ Recommends enhanced for loops
- ✅ Identifies potential issues 