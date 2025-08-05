local M = {}

local parser = require("shifty.languages.java.parser")
local utils = require("shifty.utils")

-- Execution strategies
local EXECUTION_STRATEGIES = {
    DIRECT = "direct",           -- Complete program, run as-is
    TEMPLATE = "template",       -- Wrap in template
    INTERACTIVE = "interactive", -- REPL-style execution
    COMPILED = "compiled"        -- Compile and run
}

local ACCESS_MODIFIERS = { 
  "public", 
  "protected", 
  "private" 
}

local NON_ACCESS_MODIFIERS = { 
  "static", 
  "final", 
  "synchronized", 
  "volatile", 
  "transient", 
  "native", 
  "strictfp" 
}

local types = {
  "void",
  "boolean",
  "byte",
  "char",
  "short",
  "int",
  "long",
  "float",
  "double",
  "String",
  "Object",
  "Class",
  "Enum",
  "Annotation",
  "Map",
  "List",
  "Set",
  "Array",
  "Date",
  "Calendar",
  "UUID",
  "Pattern",
  "Number",
  "Math",
  "Random",
  "Thread",
  "Runnable",
  "ThreadLocal",
  "Atomic",
  "Collection",
  "Iterator",
  "Iterable",
  "Stream",
  "Optional",
  "Supplier",
  "Function",
  "Consumer",
  "Predicate",
  "BiConsumer",
  "BiPredicate",
}



-- Code pattern matchers
local patterns = {
    complete_program = {
        pattern = "public%s+class%s+%w+%s*{.*public%s+static%s+void%s+main%s*%(.*%)%s*{",
        strategy = EXECUTION_STRATEGIES.DIRECT
    },
    
    statements = {
        pattern = "^%s*[^%s]+.*;%s*$",
        strategy = EXECUTION_STRATEGIES.TEMPLATE
    },
    
    expressions = {
        pattern = "^%s*[^;{}]+%s*$",
        strategy = EXECUTION_STRATEGIES.TEMPLATE
    },
    
    class_definition = {
        pattern = "public%s+class%s+%w+%s*{",
        strategy = EXECUTION_STRATEGIES.TEMPLATE
    },
    
    -- Method definition patterns
    method_definition = {
        pattern = "public%s+static%s+[^%s]+%s+%w+%s*%(",
        strategy = EXECUTION_STRATEGIES.TEMPLATE
    }
}

-- Semantic analysis of Java code
function M.analyze_semantics(code)
    local analysis = {
        code_type = "unknown",
        complexity = "simple",
        dependencies = {},
        execution_strategy = EXECUTION_STRATEGIES.TEMPLATE,
        suggested_wrapper = nil,
        class_name = nil,
        imports_needed = {},
        warnings = {},
        optimizations = {}
    }
    
    -- Parse the code structure
    local structure = parser.parse_structure(code)
    
    -- Determine code type and complexity
    if structure.is_complete_program then
        analysis.code_type = "complete_program"
        analysis.execution_strategy = EXECUTION_STRATEGIES.DIRECT
        analysis.complexity = "complete"
    elseif #structure.classes > 0 then
        analysis.code_type = "class_definition"
        analysis.execution_strategy = EXECUTION_STRATEGIES.TEMPLATE
        analysis.complexity = "moderate"
        
        -- Extract class name
        for _, class_decl in ipairs(structure.classes) do
            local class_match = class_decl:match("class%s+([%w_]+)")
            if class_match then
                analysis.class_name = class_match
                break
            end
        end
    elseif #structure.statements > 0 then
        analysis.code_type = "statements"
        analysis.execution_strategy = EXECUTION_STRATEGIES.TEMPLATE
        analysis.complexity = "simple"
    else
        analysis.code_type = "expressions"
        analysis.execution_strategy = EXECUTION_STRATEGIES.TEMPLATE
        analysis.complexity = "simple"
    end
    
    -- Analyze dependencies
    analysis.dependencies = M.analyze_dependencies(code, structure)
    
    -- Detect potential issues
    analysis.warnings = M.detect_warnings(code, structure)
    
    -- Suggest optimizations
    analysis.optimizations = M.suggest_optimizations(code, structure)
    
    -- Determine wrapper strategy
    analysis.suggested_wrapper = M.determine_wrapper_strategy(analysis)
    
    return analysis
end

-- Analyze code dependencies
function M.analyze_dependencies(code, structure)
    local dependencies = {
        imports = {},
        classes = {},
        methods = {},
        packages = {}
    }
    
    -- Extract imports
    for _, import in ipairs(structure.imports) do
        table.insert(dependencies.imports, import)
        
        -- Extract package from import
        local package_match = import:match("import%s+([%w%.]+)")
        if package_match then
            local package = package_match:match("^([%w%.]+)%.")
            if package then
                dependencies.packages[package] = true
            end
        end
    end
    
    -- Detect common Java classes that might be used
    local common_classes = {
        "ArrayList", "HashMap", "LinkedList", "HashSet", "TreeSet",
        "StringBuilder", "StringBuffer", "Scanner", "File", "FileReader",
        "BufferedReader", "PrintWriter", "SimpleDateFormat", "Calendar",
        "Date", "LocalDateTime", "LocalDate", "LocalTime", "DateTimeFormatter"
    }
    
    for _, class in ipairs(common_classes) do
        if code:find(class) then
            table.insert(dependencies.classes, class)
        end
    end
    
    return dependencies
end

-- Detect potential warnings
function M.detect_warnings(code, structure)
    local warnings = {}
    
    -- Check for common issues
    if code:find("System%.out%.println") and not code:find("import") then
        table.insert(warnings, "Using System.out.println without imports")
    end
    
    if code:find("new%s+%w+%(") and not code:find("import") then
        table.insert(warnings, "Creating objects without imports")
    end
    
    if code:find("public%s+class") and not structure.has_main then
        table.insert(warnings, "Class defined without main method")
    end
    
    if code:find("try%s*{") and not code:find("catch%s*%(") then
        table.insert(warnings, "Try block without catch")
    end
    
    return warnings
end

-- Suggest optimizations
function M.suggest_optimizations(code, structure)
    local optimizations = {}
    
    -- Suggest StringBuilder for string concatenation
    if code:find("%+") and code:find("String") then
        table.insert(optimizations, "Consider using StringBuilder for multiple string concatenations")
    end
    
    -- Suggest enhanced for loops
    if code:find("for%s*%(") and code:find("%w+%[%]") then
        table.insert(optimizations, "Consider using enhanced for loop for array iteration")
    end
    
    -- Suggest diamond operator
    if code:find("new%s+%w+%<%w+%>%(") then
        table.insert(optimizations, "Consider using diamond operator <> for generic instantiation")
    end
    
    return optimizations
end

-- Determine the best wrapper strategy
function M.determine_wrapper_strategy(analysis)
    if analysis.execution_strategy == EXECUTION_STRATEGIES.DIRECT then
        return "none"
    end
    
    if analysis.code_type == "class_definition" then
        return "main_method_with_class"
    elseif analysis.code_type == "statements" then
        return "main_method"
    elseif analysis.code_type == "expressions" then
        return "main_method_with_print"
    else
        return "main_method"
    end
end

-- Generate optimized wrapper based on analysis
function M.generate_optimized_wrapper(code, analysis)
    if analysis.execution_strategy == EXECUTION_STRATEGIES.DIRECT then
        return code
    end
    
    local wrapper_templates = {
        main_method = [[
public class ShiftyMain {
    public static void main(String[] args) {
        %s
    }
}
]],

        main_method_with_print = [[
public class ShiftyMain {
    public static void main(String[] args) {
        System.out.println(%s);
    }
}
]],

        main_method_with_class = [[
%s

public class ShiftyMain {
    public static void main(String[] args) {
        // Test the defined class
        %s
    }
}
]],

        with_imports = [[
%s

public class ShiftyMain {
    public static void main(String[] args) {
        %s
    }
}
]]
    }
    
    local template = wrapper_templates.main_method
    local imports = table.concat(analysis.dependencies.imports, "\n")
    
    -- Choose template based on wrapper strategy
    if analysis.suggested_wrapper == "main_method_with_print" then
        template = wrapper_templates.main_method_with_print
        return string.format(template, code)
    elseif analysis.suggested_wrapper == "main_method_with_class" then
        template = wrapper_templates.main_method_with_class
        return string.format(template, code, "// Class definition provided above")
    elseif #imports > 0 then
        template = wrapper_templates.with_imports
        return string.format(template, imports, code)
    else
        return string.format(template, code)
    end
end

-- Execute Java code with semantic analysis
function M.execute_with_semantics(context)
    local code = context.code
    local config = context.config or {}
    
    -- Perform semantic analysis
    local analysis = M.analyze_semantics(code)
    
    -- Log analysis results
    utils.log("Java semantic analysis:", "info")
    utils.log("  Code type: " .. analysis.code_type, "info")
    utils.log("  Complexity: " .. analysis.complexity, "info")
    utils.log("  Strategy: " .. analysis.execution_strategy, "info")
    
    if #analysis.warnings > 0 then
        utils.log("  Warnings: " .. table.concat(analysis.warnings, ", "), "warn")
    end
    
    if #analysis.optimizations > 0 then
        utils.log("  Optimizations: " .. table.concat(analysis.optimizations, ", "), "info")
    end
    
    -- Generate optimized code
    local optimized_code = M.generate_optimized_wrapper(code, analysis)
    
    -- Create temporary file with unique name
    local temp_dir = "/tmp"
    local class_name = analysis.class_name or "ShiftyMain"
    local java_file = temp_dir .. "/" .. class_name .. ".java"
    local class_file = temp_dir .. "/" .. class_name .. ".class"
    
    -- Write optimized code to file
    local file = io.open(java_file, "w")
    if not file then
        return {
            success = false,
            output = "Error: Could not create temporary Java file",
            error = "File creation failed"
        }
    end
    
    file:write(optimized_code)
    file:close()
    
    -- Compile the Java program
    local compile_cmd = string.format("%s %s -d %s %s",
        config.command or "javac",
        table.concat(config.args or {"-d", "/tmp"}, " "),
        temp_dir,
        java_file
    )
    
    local compile_result = utils.execute_command(compile_cmd, config.timeout or 10000)
    
    if not compile_result.success then
        -- Clean up
        os.remove(java_file)
        return {
            success = false,
            output = "Compilation failed:\n" .. compile_result.output,
            error = "Compilation error",
            analysis = analysis
        }
    end
    
    -- Run the compiled program
    local run_cmd = string.format("%s -cp %s %s",
        config.run_command or "java",
        temp_dir,
        class_name
    )
    
    local run_result = utils.execute_command(run_cmd, config.timeout or 10000)
    
    -- Clean up temporary files
    os.remove(java_file)
    os.remove(class_file)
    
    -- Add analysis information to output
    local output = run_result.output
    if #analysis.warnings > 0 then
        output = output .. "\n\n--- Warnings ---\n" .. table.concat(analysis.warnings, "\n")
    end
    
    if #analysis.optimizations > 0 then
        output = output .. "\n\n--- Optimization Suggestions ---\n" .. table.concat(analysis.optimizations, "\n")
    end
    
    return {
        success = run_result.success,
        output = output,
        error = run_result.error,
        analysis = analysis
    }
end

return M 
