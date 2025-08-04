local M = {}

-- Java keywords from the language spec
local keywords = {
    "abstract", "assert", "boolean", "break", "byte", "case", "catch", "char",
    "class", "const", "continue", "default", "do", "double", "else", "enum",
    "extends", "final", "finally", "float", "for", "goto", "if", "implements",
    "import", "instanceof", "int", "interface", "long", "native", "new",
    "package", "private", "protected", "public", "return", "short", "static",
    "strictfp", "super", "switch", "synchronized", "this", "throw", "throws",
    "transient", "try", "void", "volatile", "while"
}

-- Java types
local types = {
    "boolean", "byte", "char", "double", "float", "int", "long", "short", "void",
    "String", "Object", "Integer", "Double", "Float", "Boolean", "Character"
}

-- Java operators
local operators = {
    "+", "-", "*", "/", "%", "&", "^", "~", "<<", ">>", ">>>",
    "==", "!=", "<", "<=", ">", ">=", "!", "&&", "||", "=", "+=", "-=", "*=", "/="
}

-- Create keyword set for fast lookup
local keyword_set = {}
for _, keyword in ipairs(keywords) do
    keyword_set[keyword] = true
end

local type_set = {}
for _, type_name in ipairs(types) do
    type_set[type_name] = true
end

-- Token types
local TOKEN_TYPES = {
    KEYWORD = "keyword",
    IDENTIFIER = "identifier",
    LITERAL = "literal",
    OPERATOR = "operator",
    DELIMITER = "delimiter",
    WHITESPACE = "whitespace",
    COMMENT = "comment"
}

-- Simple tokenizer
function M.tokenize(code)
    local tokens = {}
    local i = 1
    local len = #code
    
    while i <= len do
        local char = code:sub(i, i)
        
        -- Skip whitespace
        if char:match("%s") then
            local whitespace = ""
            while i <= len and code:sub(i, i):match("%s") do
                whitespace = whitespace .. code:sub(i, i)
                i = i + 1
            end
            table.insert(tokens, {type = TOKEN_TYPES.WHITESPACE, value = whitespace})
            
        -- Comments
        elseif char == "/" and i + 1 <= len then
            local next_char = code:sub(i + 1, i + 1)
            if next_char == "/" then
                -- Single line comment
                local comment = "//"
                i = i + 2
                while i <= len and code:sub(i, i) ~= "\n" do
                    comment = comment .. code:sub(i, i)
                    i = i + 1
                end
                table.insert(tokens, {type = TOKEN_TYPES.COMMENT, value = comment})
            elseif next_char == "*" then
                -- Multi-line comment
                local comment = "/*"
                i = i + 2
                while i <= len - 1 do
                    if code:sub(i, i + 1) == "*/" then
                        comment = comment .. "*/"
                        i = i + 2
                        break
                    end
                    comment = comment .. code:sub(i, i)
                    i = i + 1
                end
                table.insert(tokens, {type = TOKEN_TYPES.COMMENT, value = comment})
            else
                table.insert(tokens, {type = TOKEN_TYPES.OPERATOR, value = char})
                i = i + 1
            end
            
        -- String literals
        elseif char == '"' then
            local literal = '"'
            i = i + 1
            while i <= len and code:sub(i, i) ~= '"' do
                if code:sub(i, i) == "\\" and i + 1 <= len then
                    literal = literal .. code:sub(i, i + 1)
                    i = i + 2
                else
                    literal = literal .. code:sub(i, i)
                    i = i + 1
                end
            end
            if i <= len then
                literal = literal .. '"'
                i = i + 1
            end
            table.insert(tokens, {type = TOKEN_TYPES.LITERAL, value = literal})
            
        -- Character literals
        elseif char == "'" then
            local literal = "'"
            i = i + 1
            while i <= len and code:sub(i, i) ~= "'" do
                if code:sub(i, i) == "\\" and i + 1 <= len then
                    literal = literal .. code:sub(i, i + 1)
                    i = i + 2
                else
                    literal = literal .. code:sub(i, i)
                    i = i + 1
                end
            end
            if i <= len then
                literal = literal .. "'"
                i = i + 1
            end
            table.insert(tokens, {type = TOKEN_TYPES.LITERAL, value = literal})
            
        -- Numbers
        elseif char:match("%d") then
            local number = ""
            while i <= len and (code:sub(i, i):match("%d") or code:sub(i, i) == ".") do
                number = number .. code:sub(i, i)
                i = i + 1
            end
            table.insert(tokens, {type = TOKEN_TYPES.LITERAL, value = number})
            
        -- Identifiers and keywords
        elseif char:match("[%a_]") then
            local identifier = ""
            while i <= len and code:sub(i, i):match("[%w_]") do
                identifier = identifier .. code:sub(i, i)
                i = i + 1
            end
            
            if keyword_set[identifier] then
                table.insert(tokens, {type = TOKEN_TYPES.KEYWORD, value = identifier})
            elseif type_set[identifier] then
                table.insert(tokens, {type = TOKEN_TYPES.KEYWORD, value = identifier})
            else
                table.insert(tokens, {type = TOKEN_TYPES.IDENTIFIER, value = identifier})
            end
            
        -- Operators and delimiters
        else
            -- Try multi-character operators first
            local found = false
            for _, op in ipairs(operators) do
                if code:sub(i, i + #op - 1) == op then
                    table.insert(tokens, {type = TOKEN_TYPES.OPERATOR, value = op})
                    i = i + #op
                    found = true
                    break
                end
            end
            
            if not found then
                -- Single character delimiter
                table.insert(tokens, {type = TOKEN_TYPES.DELIMITER, value = char})
                i = i + 1
            end
        end
    end
    
    return tokens
end

-- Parse Java code structure
function M.parse_structure(code)
    local tokens = M.tokenize(code)
    local structure = {
        imports = {},
        classes = {},
        statements = {},
        has_main = false,
        is_complete_program = false
    }
    
    local i = 1
    while i <= #tokens do
        local token = tokens[i]
        
        -- Skip comments and whitespace
        if token.type == TOKEN_TYPES.COMMENT or token.type == TOKEN_TYPES.WHITESPACE then
            i = i + 1
            goto continue
        end
        
        -- Import statements
        if token.type == TOKEN_TYPES.KEYWORD and token.value == "import" then
            local import_statement = "import"
            i = i + 1
            while i <= #tokens and tokens[i].type ~= TOKEN_TYPES.DELIMITER do
                import_statement = import_statement .. tokens[i].value
                i = i + 1
            end
            if i <= #tokens and tokens[i].value == ";" then
                import_statement = import_statement .. ";"
                i = i + 1
            end
            table.insert(structure.imports, import_statement)
            
        -- Class declarations
        elseif token.type == TOKEN_TYPES.KEYWORD and token.value == "class" then
            local class_declaration = "class"
            local brace_count = 0
            local in_class = false
            
            i = i + 1
            while i <= #tokens do
                local t = tokens[i]
                class_declaration = class_declaration .. t.value
                
                if t.value == "{" then
                    brace_count = brace_count + 1
                    in_class = true
                elseif t.value == "}" then
                    brace_count = brace_count - 1
                    if brace_count == 0 and in_class then
                        i = i + 1
                        break
                    end
                end
                
                i = i + 1
            end
            
            table.insert(structure.classes, class_declaration)
            
        -- Check for main method
        elseif token.type == TOKEN_TYPES.KEYWORD and token.value == "public" then
            local next_token = tokens[i + 1]
            if next_token and next_token.type == TOKEN_TYPES.KEYWORD and next_token.value == "static" then
                local static_token = tokens[i + 2]
                if static_token and static_token.type == TOKEN_TYPES.KEYWORD and static_token.value == "void" then
                    local main_token = tokens[i + 3]
                    if main_token and main_token.type == TOKEN_TYPES.IDENTIFIER and main_token.value == "main" then
                        structure.has_main = true
                    end
                end
            end
            
            i = i + 1
            
        -- Other statements
        else
            local statement = ""
            local semicolon_found = false
            
            while i <= #tokens do
                local t = tokens[i]
                statement = statement .. t.value
                
                if t.value == ";" then
                    semicolon_found = true
                    i = i + 1
                    break
                end
                
                i = i + 1
            end
            
            if semicolon_found and statement:match("%S") then
                table.insert(structure.statements, statement)
            end
        end
        
        ::continue::
    end
    
    -- Determine if it's a complete program
    structure.is_complete_program = #structure.classes > 0 and structure.has_main
    
    return structure
end

-- Analyze code and determine the best execution strategy
function M.analyze_code(code)
    local structure = M.parse_structure(code)
    local analysis = {
        code_type = "unknown",
        needs_wrapping = true,
        suggested_wrapper = nil,
        class_name = nil,
        imports_needed = {},
        execution_strategy = "template"
    }
    
    -- Check if it's already a complete program
    if structure.is_complete_program then
        analysis.code_type = "complete_program"
        analysis.needs_wrapping = false
        analysis.execution_strategy = "direct"
        return analysis
    end
    
    -- Check if it's just statements
    if #structure.statements > 0 and #structure.classes == 0 then
        analysis.code_type = "statements"
        analysis.suggested_wrapper = "main_method"
        analysis.execution_strategy = "template"
        return analysis
    end
    
    -- Check if it's a class definition without main
    if #structure.classes > 0 and not structure.has_main then
        analysis.code_type = "class_definition"
        analysis.suggested_wrapper = "main_method"
        analysis.execution_strategy = "template"
        
        -- Extract class name
        for _, class_decl in ipairs(structure.classes) do
            local class_match = class_decl:match("class%s+([%w_]+)")
            if class_match then
                analysis.class_name = class_match
                break
            end
        end
        
        return analysis
    end
    
    -- Check if it's just expressions
    if #structure.statements == 0 and #structure.classes == 0 then
        analysis.code_type = "expressions"
        analysis.suggested_wrapper = "main_method"
        analysis.execution_strategy = "template"
        return analysis
    end
    
    return analysis
end

-- Generate appropriate wrapper based on analysis
function M.generate_wrapper(code, analysis)
    if not analysis.needs_wrapping then
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
    local imports = table.concat(analysis.imports_needed, "\n")
    
    if #imports > 0 then
        template = wrapper_templates.with_imports
        return string.format(template, imports, code)
    else
        return string.format(template, code)
    end
end

return M 