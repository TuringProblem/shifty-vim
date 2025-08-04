# Java Language Support Tests

This file contains various Java code examples to test the Shifty Java language support.

## Basic Java Examples

### Simple Print Statement
```java
System.out.println("Hello from Java!");
```

### Java Version Info
```java
System.out.println("Java version: " + System.getProperty("java.version"));
System.out.println("Java home: " + System.getProperty("java.home"));
```

### Variables and Data Types
```java
int number = 42;
String message = "The answer is: ";
double pi = 3.14159;
boolean isTrue = true;

System.out.println(message + number);
System.out.println("Pi: " + pi);
System.out.println("Boolean: " + isTrue);
```

## Control Structures

### If-Else Statement
```java
int age = 25;
if (age >= 18) {
    System.out.println("You are an adult");
} else {
    System.out.println("You are a minor");
}
```

### For Loop
```java
for (int i = 1; i <= 5; i++) {
    System.out.println("Count: " + i);
}
```

### While Loop
```java
int count = 0;
while (count < 3) {
    System.out.println("While loop iteration: " + count);
    count++;
}
```

## Arrays and Collections

### Array Operations
```java
int[] numbers = {1, 2, 3, 4, 5};
for (int num : numbers) {
    System.out.println("Number: " + num);
}
```

### String Array
```java
String[] fruits = {"Apple", "Banana", "Orange"};
for (String fruit : fruits) {
    System.out.println("Fruit: " + fruit);
}
```

## Methods and Functions

### Simple Method
```java
public static int add(int a, int b) {
    return a + b;
}

int result = add(5, 3);
System.out.println("5 + 3 = " + result);
```

### Method with String
```java
public static String greet(String name) {
    return "Hello, " + name + "!";
}

String greeting = greet("World");
System.out.println(greeting);
```

## Classes and Objects

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

Person person = new Person("Alice", 30);
person.introduce();
```

### Static Methods
```java
public class MathUtils {
    public static double square(double x) {
        return x * x;
    }
    
    public static double cube(double x) {
        return x * x * x;
    }
}

System.out.println("Square of 5: " + MathUtils.square(5));
System.out.println("Cube of 3: " + MathUtils.cube(3));
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

## Date and Time

### Current Date and Time
```java
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

LocalDateTime now = LocalDateTime.now();
DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
String formatted = now.format(formatter);
System.out.println("Current time: " + formatted);
```

## File Operations

### File Information
```java
import java.io.File;

File currentDir = new File(".");
System.out.println("Current directory: " + currentDir.getAbsolutePath());
System.out.println("Directory exists: " + currentDir.exists());
System.out.println("Is directory: " + currentDir.isDirectory());
```

## Collections Framework

### ArrayList
```java
import java.util.ArrayList;
import java.util.Arrays;

ArrayList<String> colors = new ArrayList<>(Arrays.asList("Red", "Green", "Blue"));
colors.add("Yellow");
System.out.println("Colors: " + colors);
System.out.println("Size: " + colors.size());
```

### HashMap
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

## Advanced Examples

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

### Thread Example
```java
Thread thread = new Thread(() -> {
    for (int i = 0; i < 3; i++) {
        System.out.println("Thread: " + i);
        try {
            Thread.sleep(100);
        } catch (InterruptedException e) {
            System.out.println("Thread interrupted");
        }
    }
});

thread.start();
try {
    thread.join();
} catch (InterruptedException e) {
    System.out.println("Main thread interrupted");
}
System.out.println("Thread completed");
```

## Edge Cases

### Empty Code Block
```java

```

### Single Statement
```java
System.out.println("Single statement");
```

### Multiple Classes
```java
public class FirstClass {
    public static void main(String[] args) {
        System.out.println("First class");
    }
}

public class SecondClass {
    public static void main(String[] args) {
        System.out.println("Second class");
    }
}
```

## Testing Instructions

1. Open this file in Neovim
2. Source your Shifty configuration
3. Place your cursor in any Java code block
4. Run `:ShiftyRun` or press `<leader>sr`
5. Check that the output appears in the floating window
6. Test different Java features and syntax

## Expected Behavior

- ✅ Simple Java statements should execute
- ✅ Class definitions should work
- ✅ Method calls should function
- ✅ Exception handling should work
- ✅ Collections and arrays should work
- ✅ File operations should work (if permissions allow)
- ✅ Thread operations should work
- ✅ Import statements should be handled
- ✅ Multiple classes in one block should work
- ✅ Compilation errors should be displayed clearly 