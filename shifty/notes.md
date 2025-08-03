# Smarter language import appraoch

## better approach for `common_imports`

> current implementation:

```
local common_imports_example = {
    ["System.out.println"] = "import java.util.*;",
    ["Scanner"] = "import java.util.Scanner;",
    ["ArrayList"] = "import java.util.ArrayList;",
    ["HashMap"] = "import java.util.HashMap;"
}
```

### Why is this approach not good?

> Why:

- if we had multiple keywords with the same import then we would need to make a new line:

**_Example:_**

```
local common_imports_example = {
    ["ArrayList"] = "import java.util.ArrayList;",
    ["HashMap"] = "import java.util.HashMap;",
    ["System.out.println"] = "import java.util.*;",
    ["Scanner"] = "import java.util.Scanner;",
    ["ArrayList"] = "import java.util.ArrayList;",
    ["HashMap"] = "import java.util.HashMap;"
}
```

- instead, let's focus on what OBJECTs are conatined inside of util:

**_*Example:*_**

```
local common_imports_example = {
    [@java.util] = { hashMap = ".hashMap;", arrayList = ".arrayList;", scanner = ".scanner;", systemOut = ".systemOut;" }
```

---

## Why care about this approach?

> Their are multiple compiled languages that use common modules so we structure them easier to be destructured.

**_*Example (with C):*_**

```
local common_headers = {
    [@stdio] = { printf = ".printf;",scanf = ".scanf;", getchar = ".getchar;", putchar = ".putchar;", fgets = ".fgets;", sscanf = ".sscanf;", gets = ".gets;", puts = ".puts;", feof = ".feof;", ferror = ".ferror;", perror = ".perror;", remove = ".remove;", rename = ".rename;", rewind = ".rewind;", tmpfile = ".tmpfile;", tmpnam = ".tmpnam;", ungetc = ".ungetc;", vfprintf = ".vfprintf;", vprintf = ".vprintf;", vsprintf = ".vsprintf;"},
    [@stdlib] = { atoi = ".atoi;", atof = ".atof;", strtod = ".strtod;", strtol = ".strtol;", strtoul = ".strtoul;", calloc = ".calloc;", malloc = ".malloc;", realloc = ".realloc;", free = ".free;", exit = ".exit;", abort = ".abort;"},
}

```

> maybe even layout the code more efficient using the CFG of the language

**_ example:_**

have it check what file you are in, from the file extension we can determine the langaue:

.lua -> lua
.c -> c
.cpp -> c
.h -> c
.java -> java
.py -> python
.rs -> rust

^ This may allow us to just highlight the text we want to test and then run a hotkey:
**_ example: _**

> {highlight first}<leader>s+e -> shifty execute

Figure out how to keep both...
