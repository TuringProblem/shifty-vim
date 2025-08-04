local M = {}

local utils = require("shifty.utils")

local LANGUAGE_PATTERNS = {
    python = {
        keywords = {"def", "class", "import", "from", "as", "if", "elif", "else", "for", "while", "try", "except", "finally", "with", "lambda", "yield", "return", "pass", "break", "continue", "raise", "assert", "del", "global", "nonlocal"},
        imports = {"^%s*import%s+", "^%s*from%s+%w+%s+import", "^%s*from%s+%w+%s*%."},
        functions = {"^%s*def%s+%w+%s*%(", "^%s*async%s+def%s+%w+%s*%("},
        classes = {"^%s*class%s+%w+%s*%(", "^%s*class%s+%w+%s*%(.*%)%s*:"},
        decorators = {"^%s*@%w+", "^%s*@%w+%s*%("},
        variables = {"^%s*%w+%s*=", "^%s*%w+%s*:%s*%w+%s*="},
        syntax = {"^%s*if%s+.*:%s*$", "^%s*for%s+.*%s+in%s+.*:%s*$", "^%s*while%s+.*:%s*$", "^%s*try%s*:%s*$"},
        confidence_boosters = {"__init__", "self", "super()", "print(", "len(", "range(", "list(", "dict(", "set("},
        confidence_penalties = {"function", "var", "let", "const", "public", "private", "static", "void", "int", "String", "System.out.println"}
    },
    
    javascript = {
        keywords = {"function", "var", "let", "const", "if", "else", "for", "while", "try", "catch", "finally", "switch", "case", "default", "break", "continue", "return", "throw", "new", "delete", "typeof", "instanceof", "in", "of", "async", "await", "yield", "class", "extends", "super", "import", "export", "default"},
        imports = {"^%s*import%s+", "^%s*import%s+%{.*%}%s+from", "^%s*import%s+%w+%s+from", "^%s*const%s+%w+%s*=%s*require%("},
        functions = {"^%s*function%s+%w+%s*%(", "^%s*%w+%s*:%s*function%s*%(", "^%s*%w+%s*%(%[^%)]*%)%s*=>", "^%s*%w+%s*%(%[^%)]*%)%s*%{", "^%s*async%s+function%s+%w+%s*%("},
        classes = {"^%s*class%s+%w+%s*%{", "^%s*class%s+%w+%s+extends%s+%w+%s*%{"},
        variables = {"^%s*var%s+%w+", "^%s*let%s+%w+", "^%s*const%s+%w+", "^%s*%w+%s*="},
        syntax = {"^%s*if%s*%(", "^%s*for%s*%(", "^%s*while%s*%(", "^%s*try%s*%{"},
        confidence_boosters = {"console.log(", "document.", "window.", "JSON.", "Array.", "Object.", "Promise.", "fetch(", "setTimeout(", "setInterval("},
        confidence_penalties = {"def", "class", "import", "from", "as", "elif", "try", "except", "finally", "with", "lambda", "yield", "pass", "raise", "assert", "del", "global", "nonlocal", "public", "private", "static", "void", "int", "String", "System.out.println"}
    },
    
    java = {
        keywords = {"public", "private", "protected", "static", "final", "abstract", "class", "interface", "extends", "implements", "import", "package", "new", "if", "else", "for", "while", "do", "switch", "case", "default", "break", "continue", "return", "throw", "throws", "try", "catch", "finally", "synchronized", "volatile", "transient", "native", "strictfp", "enum", "assert", "super", "this"},
        imports = {"^%s*import%s+", "^%s*import%s+static%s+", "^%s*package%s+"},
        functions = {"^%s*public%s+static%s+void%s+main%s*%(", "^%s*public%s+%w+%s+%w+%s*%(", "^%s*private%s+%w+%s+%w+%s*%(", "^%s*protected%s+%w+%s+%w+%s*%("},
        classes = {"^%s*public%s+class%s+%w+", "^%s*class%s+%w+", "^%s*public%s+interface%s+%w+", "^%s*interface%s+%w+"},
        variables = {"^%s*%w+%s+%w+%s*=", "^%s*%w+%s+%w+%s*;", "^%s*final%s+%w+%s+%w+%s*="},
        syntax = {"^%s*if%s*%(", "^%s*for%s*%(", "^%s*while%s*%(", "^%s*try%s*%{"},
        confidence_boosters = {"System.out.println(", "System.out.print(", "Scanner", "ArrayList", "HashMap", "String", "Integer", "Double", "Boolean", "main(", "public static void"},
        confidence_penalties = {"def", "function", "var", "let", "const", "console.log", "document.", "window.", "import", "from", "as", "elif", "try", "except", "finally", "with", "lambda", "yield", "pass", "raise", "assert", "del", "global", "nonlocal"}
    },
    
    c = {
        keywords = {"auto", "break", "case", "char", "const", "continue", "default", "do", "double", "else", "enum", "extern", "float", "for", "goto", "if", "int", "long", "register", "return", "short", "signed", "sizeof", "static", "struct", "switch", "typedef", "union", "unsigned", "void", "volatile", "while"},
        imports = {"^%s*#include%s+", "^%s*#include%s+%<.*%>", "^%s*#include%s+\".*\""},
        functions = {"^%s*%w+%s+%w+%s*%(", "^%s*void%s+%w+%s*%(", "^%s*int%s+%w+%s*%(", "^%s*char%s+%w+%s*%(", "^%s*float%s+%w+%s*%(", "^%s*double%s+%w+%s*%("},
        variables = {"^%s*int%s+%w+", "^%s*char%s+%w+", "^%s*float%s+%w+", "^%s*double%s+%w+", "^%s*%w+%s+%w+%s*="},
        syntax = {"^%s*if%s*%(", "^%s*for%s*%(", "^%s*while%s*%(", "^%s*switch%s*%(", "^%s*struct%s+%w+%s*%{"},
        confidence_boosters = {"printf(", "scanf(", "malloc(", "free(", "strcpy(", "strcmp(", "strlen(", "main(", "stdio.h", "stdlib.h", "string.h"},
        confidence_penalties = {"def", "function", "var", "let", "const", "console.log", "document.", "window.", "import", "from", "as", "elif", "try", "except", "finally", "with", "lambda", "yield", "pass", "raise", "assert", "del", "global", "nonlocal", "public", "private", "static", "void", "String", "System.out.println"}
    },
    
    rust = {
        keywords = {"as", "break", "const", "continue", "crate", "else", "enum", "extern", "false", "fn", "for", "if", "impl", "in", "let", "loop", "match", "mod", "move", "mut", "pub", "ref", "return", "self", "Self", "static", "struct", "super", "trait", "true", "type", "unsafe", "use", "where", "while", "async", "await", "dyn"},
        imports = {"^%s*use%s+", "^%s*extern%s+crate%s+", "^%s*mod%s+"},
        functions = {"^%s*fn%s+%w+%s*%(", "^%s*pub%s+fn%s+%w+%s*%(", "^%s*unsafe%s+fn%s+%w+%s*%("},
        structs = {"^%s*struct%s+%w+%s*%{", "^%s*pub%s+struct%s+%w+%s*%{"},
        enums = {"^%s*enum%s+%w+%s*%{", "^%s*pub%s+enum%s+%w+%s*%{"},
        variables = {"^%s*let%s+%w+", "^%s*let%s+mut%s+%w+", "^%s*const%s+%w+", "^%s*static%s+%w+"},
        syntax = {"^%s*if%s+%w+%s*%{", "^%s*for%s+%w+%s+in%s+", "^%s*while%s+%w+%s*%{", "^%s*match%s+%w+%s*%{"},
        confidence_boosters = {"println!(", "print!(", "vec![", "String::from(", "to_string(", "main(", "Result", "Option", "Some(", "None", "Ok(", "Err("},
        confidence_penalties = {"def", "function", "var", "console.log", "document.", "window.", "import", "from", "as", "elif", "try", "except", "finally", "with", "lambda", "yield", "pass", "raise", "assert", "del", "global", "nonlocal", "public", "private", "static", "void", "String", "System.out.println"}
    },
    
    lua = {
        keywords = {"and", "break", "do", "else", "elseif", "end", "false", "for", "function", "if", "in", "local", "nil", "not", "or", "repeat", "return", "then", "true", "until", "while"},
        imports = {"^%s*require%s*%(", "^%s*local%s+%w+%s*=%s*require%("},
        functions = {"^%s*function%s+%w+%s*%(", "^%s*local%s+function%s+%w+%s*%(", "^%s*%w+%s*:%s*function%s*%("},
        variables = {"^%s*local%s+%w+", "^%s*%w+%s*="},
        syntax = {"^%s*if%s+%w+%s+then%s*$", "^%s*for%s+%w+%s+do%s*$", "^%s*while%s+%w+%s+do%s*$", "^%s*repeat%s*$"},
        confidence_boosters = {"print(", "io.write(", "table.insert(", "table.remove(", "string.format(", "pairs(", "ipairs(", "tonumber(", "tostring("},
        confidence_penalties = {"def", "var", "let", "const", "console.log", "document.", "window.", "import", "from", "as", "elif", "try", "except", "finally", "with", "lambda", "yield", "pass", "raise", "assert", "del", "global", "nonlocal", "public", "private", "static", "void", "String", "System.out.println"}
    }
}

local CONFIDENCE_THRESHOLDS = {
    DEFINITIVE = 90,    -- Very high confidence
    HIGH = 75,          -- High confidence
    MEDIUM = 60,        -- Medium confidence
    LOW = 40,           -- Low confidence
    MINIMUM = 20        -- Minimum confidence to consider
}

---@param code string The code to analyze
---@param context table|nil Additional context (file extension, buffer type, etc.)
---@return table detection_result Detection result with language and confidence
function M.detect_language(code, context)
    context = context or {}
    
    local results = {}
    local lines = vim.split(code, "\n")
    
    for language, patterns in pairs(LANGUAGE_PATTERNS) do
        local score = M.analyze_language_patterns(code, lines, patterns)
        table.insert(results, {
            language = language,
            score = score,
            confidence = M.calculate_confidence(score, patterns)
        })
    end
    
    table.sort(results, function(a, b) return a.confidence > b.confidence end)
    
    results = M.apply_context_adjustments(results, context)
    
    local best_match = results[1]
    local detection_result = {
        language = best_match.language,
        confidence = best_match.confidence,
        alternatives = {},
        analysis = {
            total_lines = #lines,
            code_length = #code,
            context_used = context.file_extension ~= nil or context.buffer_filetype ~= nil
        }
    }
    
    for i = 2, #results do
        if results[i].confidence >= CONFIDENCE_THRESHOLDS.LOW then
            table.insert(detection_result.alternatives, {
                language = results[i].language,
                confidence = results[i].confidence
            })
        end
    end
    
    utils.log(string.format("Language detection: %s (%.1f%% confidence)", 
             detection_result.language, detection_result.confidence), "info")
    
    if #detection_result.alternatives > 0 then
        local alt_str = ""
        for _, alt in ipairs(detection_result.alternatives) do
            alt_str = alt_str .. string.format("%s(%.1f%%) ", alt.language, alt.confidence)
        end
        utils.log("Alternatives: " .. alt_str, "info")
    end
    
    return detection_result
end

---@param code string The code to analyze
---@param lines table Array of code lines
---@param patterns table Language patterns
---@return number score Raw pattern matching score
function M.analyze_language_patterns(code, lines, patterns)
    local score = 0
    local total_patterns = 0
    
    for _, keyword in ipairs(patterns.keywords) do
        local count = select(2, code:gsub(keyword, keyword))
        if count > 0 then
            score = score + (count * 2) -- Keywords are weighted heavily
            total_patterns = total_patterns + 1
        end
    end
    
    for _, pattern in ipairs(patterns.imports) do
        for _, line in ipairs(lines) do
            if line:match(pattern) then
                score = score + 10 -- Imports are very strong indicators
                total_patterns = total_patterns + 1
                break
            end
        end
    end
    
    for _, pattern in ipairs(patterns.functions) do
        for _, line in ipairs(lines) do
            if line:match(pattern) then
                score = score + 8 -- Function definitions are strong indicators
                total_patterns = total_patterns + 1
                break
            end
        end
    end
    
    for _, pattern in ipairs(patterns.classes or {}) do
        for _, line in ipairs(lines) do
            if line:match(pattern) then
                score = score + 8 -- Class definitions are strong indicators
                total_patterns = total_patterns + 1
                break
            end
        end
    end
    
    for _, pattern in ipairs(patterns.variables) do
        for _, line in ipairs(lines) do
            if line:match(pattern) then
                score = score + 3 -- Variable declarations are moderate indicators
                total_patterns = total_patterns + 1
                break
            end
        end
    end
    
    for _, pattern in ipairs(patterns.syntax) do
        for _, line in ipairs(lines) do
            if line:match(pattern) then
                score = score + 4 -- Syntax patterns are good indicators
                total_patterns = total_patterns + 1
                break
            end
        end
    end
    
    for _, booster in ipairs(patterns.confidence_boosters) do
        if code:find(booster) then
            score = score + 5 -- Language-specific features boost confidence
            total_patterns = total_patterns + 1
        end
    end
    
    for _, penalty in ipairs(patterns.confidence_penalties) do
        if code:find(penalty) then
            score = score - 3 -- Conflicting patterns reduce confidence
        end
    end
    
    if #lines > 0 then
        score = score / math.sqrt(#lines) -- Normalize for code length
    end
    
    return score
end

---@param score number Raw pattern matching score
---@param patterns table Language patterns
---@return number confidence Confidence percentage (0-100)
function M.calculate_confidence(score, patterns)
    local confidence = math.min(100, score * 10)
    
    local total_patterns = #patterns.keywords + #patterns.imports + #patterns.functions + 
                          #(patterns.classes or {}) + #patterns.variables + #patterns.syntax
    
    if total_patterns > 0 then
        confidence = confidence * (1 + (total_patterns / 100))
    end
    
    return math.max(0, math.min(100, confidence))
end

---@param results table Detection results
---@param context table Context information
---@return table adjusted_results Adjusted results
function M.apply_context_adjustments(results, context)
    local adjusted = vim.deepcopy(results)
    
    if context.file_extension then
        local extension_map = {
            [".py"] = "python",
            [".js"] = "javascript",
            [".ts"] = "typescript",
            [".java"] = "java",
            [".c"] = "c",
            [".h"] = "c",
            [".cpp"] = "cpp",
            [".cc"] = "cpp",
            [".rs"] = "rust",
            [".lua"] = "lua"
        }
        
        local expected_language = extension_map[context.file_extension:lower()]
        if expected_language then
            for _, result in ipairs(adjusted) do
                if result.language == expected_language then
                    result.confidence = result.confidence + 15 -- Significant boost for matching extension
                end
            end
        end
    end
    
    if context.buffer_filetype then
        local filetype_map = {
            python = "python",
            javascript = "javascript",
            typescript = "typescript",
            java = "java",
            c = "c",
            cpp = "cpp",
            rust = "rust",
            lua = "lua"
        }
        
        local expected_language = filetype_map[context.buffer_filetype]
        if expected_language then
            for _, result in ipairs(adjusted) do
                if result.language == expected_language then
                    result.confidence = result.confidence + 10 -- Boost for matching filetype
                end
            end
        end
    end
    
    table.sort(adjusted, function(a, b) return a.confidence > b.confidence end)
    
    return adjusted
end

---@param confidence number Confidence percentage
---@return string level Confidence level description
function M.get_confidence_level(confidence)
    if confidence >= CONFIDENCE_THRESHOLDS.DEFINITIVE then
        return "definitive"
    elseif confidence >= CONFIDENCE_THRESHOLDS.HIGH then
        return "high"
    elseif confidence >= CONFIDENCE_THRESHOLDS.MEDIUM then
        return "medium"
    elseif confidence >= CONFIDENCE_THRESHOLDS.LOW then
        return "low"
    else
        return "very_low"
    end
end

---@param confidence number Confidence percentage
---@return boolean sufficient Whether confidence is sufficient
function M.is_confidence_sufficient(confidence)
    return confidence >= CONFIDENCE_THRESHOLDS.MEDIUM
end

---@return table languages List of supported languages
function M.get_supported_languages()
    local languages = {}
    for language, _ in pairs(LANGUAGE_PATTERNS) do
        table.insert(languages, language)
    end
    table.sort(languages)
    return languages
end

return M 