class AquaHotkey_String extends AquaHotkey {
/**
 * AquaHotkey-G - String.ahk
 * 
 * OriginalAuthor: 0w0Demonic
 * Author: GhostGlitch
 * 
 * https://www.github.com/GhostGlitch/AquaHotkey-G
 * - src/Builtins/String.ahk
 */
class String {
    /**
     * Is-functions (see AHK docs).
     * 
     * @return  {Boolean}
     */
    IsDigit  => IsDigit(this)
    IsHexit => IsXDigit(this)
    IsAlpha  => IsAlpha(this)
    IsUpper  => IsUpper(this)
    IsLower  => IsLower(this)
    IsAlnum  => IsAlnum(this)
    IsSpace  => IsSpace(this)
    IsTime   => IsTime(this)

    /**
     * Returns `true`, if this string is empty.
     * @example
     * 
     * "Hello, world!".IsEmpty ; false
     * "".IsEmpty              ; true
     * 
     * @return  {Boolean}
     */
    IsEmpty => (this == "")

    /**
     * Allows the enumeration of all characters in this string as a for-loop.
     * @example
     * 
     * for Character in "Hello, world!" {
     *     MsgBox(Character)
     * }
     * 
     * for Index, Character in "Hello, world!" {
     *     MsgBox(Index . ": " . Character)
     * }
     * 
     * @param   {Integer}  n  parameter length of the for-loop
     * @return  {Enumerator}
     */
    __Enum(n) {
        Position := 0
        Length   := StrLen(this)
        if (n == 1) {
            return Enumer1
        }
        return Enumer2
        
        ; for Character in ...
        Enumer1(&Out) {
            if (Position < Length) {
                Out := StrGet(StrPtr(this) + 2 * Position++, 1)
                return true
            }
            return false
        }
        
        ; for Index, Character in ...
        Enumer2(&OutIndex, &Out?) {
            if (Position < Length) {
                Out      := StrGet(StrPtr(this) + 2 * Position++, 1)
                OutIndex := Position
                return true
            }
            return false
        }
    }

    /**
     * Splits this string into an array of separate lines.
     * @example
     * 
     * "
     * (
     * Hello,
     * world!
     * )".Lines() ; ["Hello,", "world!"]
     * 
     * @return   {Array}
     */
    Lines() => StrSplit(this, "`n", "`r")

    /**
     * Returns a substring that ends just before a specified occurrence
     * of `Pattern`.
     * @example
     * 
     * "Hello, world!".Before("world") ; "Hello, "
     * "abcABCabc".Before("ABC", true) ; "abc"
     * 
     * @param   {String}      Pattern       the substring to search for
     * @param   {Primitive?}  CaseSense     case-sensitivity of the search
     * @param   {Integer?}    StartingPos   position to start searching from
     * @param   {Integer?}    Occurrence    n-th occurrence to find
     * @return  {String?}
     */
    Before(Pattern, CaseSense := false, StartingPos := 1, Occurrence := 1) {
        FoundPos := InStr(this, Pattern, CaseSense, StartingPos, Occurrence)
        if (FoundPos) {
            return SubStr(this, 1, FoundPos - 1)
        }
        return this
    }

    /**
     * Returns a substring that ends just before the first match of a
     * regex `Pattern`.
     * @example
     * 
     * "Test123Hello".BeforeRegex("\d++") ; "Test"
     * 
     * @param   {String}    Pattern       regular expression to search for
     * @param   {Integer?}  StartingPos   position to start searching from
     * @return  {String}
     */
    BeforeRegex(Pattern, StartingPos := 1) {
        if (IsObject(Pattern)) {
            throw TypeError("Expected a String",, Type(Pattern))
        }
        if (Pattern == "") {
            throw ValueError("Pattern is empty")
        }
        FoundPos := RegExMatch(this, Pattern,, StartingPos)
        if (FoundPos) {
            return SubStr(this, 1, FoundPos - 1)
        }
        return this
    }

    /**
     * Returns a substring from the beginning to the end of a specified
     * occurrence of `Pattern`.
     * @example
     * 
     * "Hello, world!".Until(", ") ; "Hello, "
     * 
     * @param   {String}      Pattern      the substring to search for
     * @param   {Primitive?}  CaseSense    case-sensitivity of the search
     * @param   {Integer?}    StartingPos  position to start searching from
     * @param   {Integer?}    Occurrence   n-th occurrence to find
     * @param   {String}
     */
    Until(Pattern, CaseSense := false, StartingPos := 1, Occurrence := 1) {
        FoundPos := InStr(this, Pattern, CaseSense, StartingPos, Occurrence)
        if (FoundPos) {
            return SubStr(this, 1, FoundPos - 1 + StrLen(Pattern))
        }
        return this
    }

    /**
     * Returns a substring that ends on the end of the first match of a
     * regex `Pattern`.
     * @example
     * 
     * "Test123Hello".UntilRegex("\d++") ; "Test123"
     * 
     * @param   {String}    Pattern      regular expression to search for
     * @param   {Integer?}  StartingPos  position to start searching from
     * @return  {String}
     */
    UntilRegex(Pattern, StartingPos := 1) {
        if (IsObject(Pattern)) {
            throw TypeError("Expected a String",, Type(Pattern))
        }
        if (Pattern == "") {
            throw ValueError("Pattern is empty")
        }
        FoundPos := RegExMatch(this, Pattern, &MatchObject, StartingPos)
        if (FoundPos) {
            return SubStr(this, 1, FoundPos - 1 + MatchObject.Len[0])
        }
        return this
    }

    /**
     * Returns a substring that starts at a specified occurrence of `Pattern`.
     * @example
     * 
     * "Hello, world!".From(",") ; ", world!"
     * 
     * @param   {String}      Pattern      the substring to search for
     * @param   {Primitive?}  CaseSense    case-sensitivity of the search
     * @param   {Integer?}    StartingPos  position to start searching from
     * @param   {Integer?}    Occurrence   n-th occurrence to find
     * @param   {String}
     */
    From(Pattern, CaseSense := false, StartingPos := 1, Occurrence := 1) {
        FoundPos := InStr(this, Pattern, CaseSense, StartingPos, Occurrence)
        if (FoundPos) {
            return SubStr(this, FoundPos)
        }
        return this
    }

    /**
     * Returns a substring that starts at the first match of a regex `Pattern`.
     * @example
     * 
     * "Test123Hello".FromRegex("\d++") ; "123Hello"
     * 
     * @param   {String}    Pattern      regular expression to search for
     * @param   {Integer?}  StartingPos  position to start searching from
     * @return  {String}
     */
    FromRegex(Pattern, StartingPos := 1) {
        if (IsObject(Pattern)) {
            throw TypeError("Expected a String",, Type(Pattern))
        }
        if (Pattern == "") {
            throw ValueError("Pattern is empty")
        }
        FoundPos := RegExMatch(this, Pattern,, StartingPos)
        if (FoundPos) {
            return SubStr(this, FoundPos)
        }
        return this
    }

    /**
     * Returns a substring that starts after a specified occurrence of
     * `Pattern`.
     * @example
     * 
     * "Hello, world!".After(",") ; " world!"
     * 
     * @param   {String}      Pattern      the substring to search for
     * @param   {Primitive?}  CaseSense    case-sensitivity of the search
     * @param   {Integer?}    StartingPos  position to start searching from
     * @param   {Integer?}    Occurrence   n-th occurrence to find
     * @param   {String}
     */
    After(Pattern, CaseSense := false, StartingPos := 1, Occurrence := 1) {
        FoundPos := InStr(this, Pattern, CaseSense, StartingPos, Occurrence)
        if (FoundPos) {
            return SubStr(this, FoundPos + StrLen(Pattern))
        }
        return this
    }

    /**
     * Returns a substring that starts after the first match of a regex
     * `Pattern`.
     * @example
     * 
     * "Test123Hello".AfterRegex("\d++") ; "Hello"
     * 
     * @param   {String}    Pattern      regular expression to search for
     * @param   {Integer?}  StartingPos  position to start searching from
     * @return  {String}
     */
    AfterRegex(Pattern, StartingPos := 1) {
        if (IsObject(Pattern)) {
            throw TypeError("Expected a String",, Type(Pattern))
        }
        if (Pattern == "") {
            throw ValueError("Pattern is empty")
        }
        FoundPos := RegExMatch(this, Pattern, &MatchObject, StartingPos)
        if (FoundPos) {
            return SubStr(this, FoundPos + MatchObject.Len[0])
        }
        return this
    }

    /**
     * Returns this string prepended by `Before`.
     * @example
     * 
     * "world!".Prepend("Hello, ") ; "Hello, world!"
     * 
     * @param   {String}  Before  the string to prepend
     * @return  {String}
     */ 
    Prepend(Before) => (Before . this)

    /**
     * Returns this string appended with `After`.
     * @example
     * 
     * "Hello, ".Append("world!") ; "Hello, world!"
     * 
     * @param   {String}  After  the string to append
     * @return  {String}
     */
    Append(After) => (this . After)
    
    /**
     * Returns a new string surrounded by `Before` and `After`.
     * @example
     * 
     * "foo".Surround("(", ")") ; "(foo)"
     * "foo".Surround("_")      ; "_foo_"
     * 
     * @param   {String}   Before  the string to prepend
     * @param   {String?}  After   the string to append
     * @return  {String}
     */
    Surround(Before, After := Before) => (Before . this . After)

    /**
     * Returns this string repeated `n` times.
     * @example
     * 
     * "foo".Repeat(3) ; "foofoofoo"
     * 
     * @param   {Integer}  n  amount of times to repeat the string
     * @return  {String}
     */
    Repeat(n) {
        if (!IsInteger(n)) {
            throw TypeError("Expected an Integer",, Type(n))
        }
        if (n < 0) {
            throw ValueError("n < 0",, n)
        }
        n_Amount_Of_Spaces := Format("{: " . n . "}", " ")
        return StrReplace(n_Amount_Of_Spaces, A_Space, this)
    }

    /**
     * Returns this string with all characters in reverse order.
     * @example
     * 
     * "foo".Reversed() ; "oof"
     * 
     * @return  {String}
     */
    Reversed() {
        DllCall("msvcrt.dll\_wcsrev", "Str", Str := this, "CDecl Str")
        return Str
    }
    
    /**
     * Reads the contents of the file this string leads to.
     * @example
     * 
     * "message.txt".FileRead()
     * 
     * @param   {String?}  Options  additional options for `FileRead()`
     * @return  {String}
     */ 
    FileRead(Options?) => FileRead(this, Options?)

    /**
     * Appends this string to the file `FileName`.
     * @example
     * 
     * "Hello, world!".FileAppend("message.txt")
     * 
     * @param   {String?}  FileName  name of the file to be appended
     * @param   {String?}  Options   additional options for `FileAppend()`
     * @return  {this}
     */
    FileAppend(FileName?, Options?) {
        FileAppend(this, FileName?, Options?)
        return this
    }
    
    /**
     * Overwrites the file `FileName` with this string (Previous file contents
     * are lost!).
     * @example
     * 
     * "Hello, world!".FileOverwrite("message.txt")
     * 
     * @param   {String}  FileName  name of the file to overwrite
     * @return  {this}
     */
    FileOverwrite(FileName) {
        OutputFile := FileOpen(FileName, "w")
        OutputFile.Write(this)
        OutputFile.Close()
        return this
    }

    /**
     * Opens a file with this string used as file name.
     * @example
     * 
     * FileObj := "message.txt".FileOpen("r")
     * 
     * @param   {Primitive}   Flags     desired access mode
     * @param   {Primitive?}  Encoding  file encoding
     * @return  {File}
     */
    FileOpen(Flags, Encoding?) => FileOpen(this, Flags, Encoding?)

    /**
     * Separates a file name or URL into its name, directory, extension,
     * and drive.
     * @example
     * 
     * ; {
     * ;     Name:      "Address List.txt",
     * ;     Dir:       "C:\My Documents",
     * ;     Ext:       "txt"
     * ;     NameNoExt: "Address List"
     * ;     Drive:     "C:"
     * ; }
     * "C:\My Documents\Address List.txt".SplitPath()
     * 
     * @return  {Object}
     */
    SplitPath() {
        SplitPath(this, &Name, &Dir, &Ext, &NameNoExt, &Drive)
        return {
            Name: Name,
            Dir: Dir,
            Ext: Ext,
            NameNoExt: NameNoExt,
            Drive: Drive
        }
    }

    /**
     * Returns the contents of a file-loop using this string as file pattern.
     * Parameter `Pattern` refers to 0-parameter predicate function which has
     * access to the built-in file-loop variables such as `A_LoopFilePath`.
     * Parameter `ReturnValue` is the name of a file-loop variable to be
     * returned, or a zero-parameter function similar to `Pattern`.
     * @example
     * 
     * "C:\*".FindFiles("D") ; ["C:\Users", "C:\Windows", ...]
     * 
     * @param   {String?}       Mode         file-loop mode
     * @param   {Func?}         Pattern      function that evaluates condition
     * @param   {Func?/String}  ReturnValue  name of a file-loop variable or a
     *                                       function that returns a value
     * @return  {Array}
     */
    FindFiles(Mode := "FR", Pattern?, ReturnValue?) {
        if (!IsSet(Pattern)) {
            Pattern := (*) => True
        }
        if (!HasMethod(Pattern)) {
            throw TypeError("Expected a Function object",, Type(Pattern))
        }
        if (!IsSet(ReturnValue)) {
            ReturnValue := "A_LoopFilePath"
        }
        if (!(ReturnValue is String) && !HasMethod(ReturnValue)) {
            throw TypeError("invalid return value argument",, Type(ReturnValue))
        }
        Result := Array()
        if (HasMethod(ReturnValue)) {
            Loop Files, this, Mode {
                (Pattern() && Result.Push(ReturnValue()))
            }
        } else {
            Loop Files, this, Mode {
                (Pattern() && Result.Push(%ReturnValue%))
            }
        }
        return Result
    }

    /**
     * Determines whether this string contains a regular expression `Pattern`.
     * If present, the index of the first occurrence is returned.
     * @example
     * 
     * "Test123Hello".RegExMatch("\d++") ; 5
     * 
     * @param   {String}    Pattern      regular expression pattern
     * @param   {VarRef?}   MatchObj     output match object
     * @param   {Integer?}  StartingPos  position to start searching from
     * @return  {Integer} 
     */
    RegExMatch(Pattern, &MatchObj?, StartingPos := 1) {
        return RegExMatch(this, Pattern, &MatchObj, StartingPos)
    }

    /**
     * Replaces regular expression occurrence in this string.
     * @example
     * 
     * "Test123Hello".RegExReplace("\d++", "") ; "TestHello"
     * 
     * @param   {String}    Pattern  regular expression pattern
     * @param   {String?}   Replace  replacement string
     * @param   {VarRef?}   Count    output count
     * @param   {Integer?}  Limit    maximum number of replacements
     * @param   {Integer?}  Start    position to start searching from
     * @return  {String}
     */
    RegExReplace(Pattern, Replace?, &Count?, Limit?, Start?) {
        return RegExReplace(this, Pattern, Replace?, &Count, Limit?, Start?)
    }

    /**
     * Returns the match object for the first occurrence of a regular
     * expression `Pattern`.
     * @example
     * 
     * MatchObj := "Test123Hello".Match("\d++")
     * 
     * @param   {String}    Pattern      regular expression pattern
     * @param   {Integer?}  StartingPos  position to start searching from
     * @return  {RegExMatchInfo}
     */
    Match(Pattern, StartingPos := 1) {
        if (RegExMatch(this, Pattern, &MatchObj, StartingPos)) {
            return MatchObj
        }
        return false
    }

    /**
     * Returns an array of all match objects for occurrences of a regular
     * expression `Pattern`. Match objects do not overlap with each other.
     * @example
     * 
     * ; 1st iteration: "12"
     * ; 2nd iteration: "34"
     * for MatchObj in "12345".MatchAll("\d{2}+") {
     *     MsgBox(MatchObj[0])
     * }
     * 
     * @param   {String}    Pattern      regular expression pattern
     * @param   {Integer?}  StartingPos  position to start searching from
     * @return  {Array}
     */
    MatchAll(Pattern, StartingPos := 1) {
        Result := Array()
        while (FoundPos := RegExMatch(this, Pattern, &MatchObj, StartingPos)) {
            Result.Push(MatchObj)
            StartingPos := FoundPos + (MatchObj.Len[0] || 1)
        }
        return Result
    }

    /**
     * Returns the overall match of the first occurrence of a regular
     * expression `Pattern`.
     * @example
     * 
     * "Test123Hello".Capture("\d++") ; "123"
     * 
     * @param   {String}    Pattern      regular expression pattern
     * @param   {Integer?}  StartingPos  position to start searching from
     * @return  {String}
     */
    Capture(Pattern, StartingPos := 1) {
        if (RegExMatch(this, Pattern, &MatchObj, StartingPos)) {
            return MatchObj[0]
        }
        throw ValueError("no match found",, Pattern)
    }

    /**
     * Returns an array of all occurrences of regular expression `Pattern`.
     * Matches do not overlap with each other.
     * @example
     * 
     * "12345".CaptureAll("\d{2}+") ; ["12", "34"]
     * 
     * @param   {String}    Pattern      regular expression pattern
     * @param   {Integer?}  StartingPos  position to start searching from
     * @return  {String}
     */
    CaptureAll(Pattern, StartingPos := 1) {
        Result := Array()
        while (FoundPos := RegExMatch(this, Pattern, &MatchObj, StartingPos)) {
            Result.Push(MatchObj[0])
            StartingPos := FoundPos + (MatchObj.Len[0] || 1)
        }
        return Result
    }

    /**
     * Inserts `Str` into this string at index `Position`.
     * @example
     * 
     * "Hello world!".Insert(",", 6) ; "Hello, world!"
     * "banaa".Insert("n", -1)       ; "banana"
     * 
     * @param   {String}    Str       string to insert
     * @param   {Integer?}  Position  index to insert string into
     * @param   {String}
     */
    Insert(Str, Position := 1) {
        if (IsObject(Str)) {
            throw TypeError("Expected a String",, Type(Str))
        }
        if (!IsInteger(Position)) {
            throw TypeError("Expected an Integer",, Type(Position))
        }
        tLen     := StrLen(this)
        if (Abs(Position) > tLen) {
            Msg     := "index out of bounds"
            Pattern := "index {} (length of this string: {})"
            Extra   := Format(Pattern, Position, tLen)
            throw ValueError(Msg,, Extra)
        }
        if (Position <= 0) {
            Position += tLen + 1
        }
        return SubStr(this, 1, Position - 1)
             . Str
             . SubStr(this, Position)
    }

    /**
     * Overwrites `Str` into this string at index `Position`.
     * @example
     * 
     * "banaaa".Overwrite("n", 5)  ; "banana"
     * "appll".Overwrite("e", -1)  ; "apple"
     * 
     * @param   {String}    Str       string to overwrite with
     * @param   {Integer?}  Position  index to place the new string
     * @return  {String}
     */
    Overwrite(Str, Position := 1) {
        if (IsObject(Str)) {
            throw TypeError("Expected a String",, Type(Str))
        }
        if (!IsInteger(Position)) {
            throw TypeError("Expected an Integer",, Type(Position))
        }
        tLen     := StrLen(this)
        if (Abs(Position) > tLen) {
            Pattern := "index {} (length of this string: {})"
            Extra   := Format(Pattern, Position, tLen)
            throw ValueError("index out of bounds",, Extra)
        }
        if (Position <= 0) {
            Position += tLen + 1
        }
        return SubStr(this, 1, Position - 1)
             . Str
             . SubStr(this, Position + StrLen(Str))
    }

    /**
     * Removes a section from this string at index `Position`,
     * `Length` characters long.
     * @example
     * 
     * "aapple".Delete(2)       ; "apple"
     * "banabana".Delete(-4, 2) ; "banana"
     * 
     * @param   {Integer}   Position  section start
     * @param   {Integer?}  Length    section length
     * @return  {String}
     */
    Delete(Position, Length := 1) {
        if (!IsInteger(Position) || !IsInteger(Length)) {
            throw TypeError("Expected an Integer",,
                            Type(Position) . " " . Type(Length))
        }
        if (!Position || !Length) {
            return this
        }
        tLen := StrLen(this)
        if (Abs(Position) > tLen) {
            Pattern := "index {} (string length {})"
            Extra   := Format(Pattern, Position, Length)
            throw ValueError("index out of bounds",, Extra)
        }
        if (Position <= 0) {
            Position += tLen + 1
        }
        if (Length < 0) {
            if ((Length += tLen - Position + 1) <= 0) {
                return this
            }
        }
        return SubStr(this, 1, Position - 1)
             . SubStr(this, Position + Length)
    }

    /**
     * Pads this string on the left using `PaddingStr` a total of `n` times.
     * @example
     * 
     * "foo".LPad(" ", 5) ; "     foo"
     * 
     * @param   {String?}   PaddingStr  string used for padding
     * @param   {Integer?}  n           amount of padding
     * @return  {String}
     */ 
    LPad(PaddingStr := " ", n := 1) {
        if (!IsInteger(n)) {
            throw TypeError("Expected an Integer",, Type(n))
        }
        if (n < 0) {
            throw ValueError("n < 0",, n)
        }
        if (n) {
            if (IsObject(PaddingStr)) {
                throw TypeError("Expected a String",, Type(PaddingStr))
            }
            return (PaddingStr.Repeat(n) . this)
        }
        return this
    }

    /**
     * Pads this string on the right using `PaddingStr` a total of `n` times.
     * @example
     * 
     * "foo".RPad(" ", 5) ; "foo     "
     * 
     * @param   {String?}   PaddingStr  string used for padding
     * @param   {Integer?}  n           amount of padding
     * @return  {String}
     */
    RPad(PaddingStr := " ", n := 1) {
        if (!IsInteger(n)) {
            throw TypeError("Expected an Integer",, Type(n))
        }
        if (n < 0) {
            throw ValueError("n < 0",, n)
        }
        if (n) {
            if (IsObject(PaddingStr)) {
                throw TypeError("Expected a String",, Type(PaddingStr))
            }
            return (this . PaddingStr.Repeat(n))
        }
        return this
    }

    /**
     * Strips all whitespace from this string and then formats words into lines
     * with a maximum length of `n` characters.
     * @example
     * 
     * ; (use a really small line length for demonstration purposes)
     * ; "hello,`nworld!"
     * "hello, world!".WordWrap(3)
     * 
     * @param   {Integer?}  n  maximum line length
     * @return  {String}
     */ 
    WordWrap(n := 80) {
        if (!IsInteger(n)) {
            throw TypeError("Expected an Integer",, Type(n))
        }
        if (n <= 0) {
            throw ValueError("n <= 0",, n)
        }
        Pos := 0
        VarSetStrCapacity(&Out, StrLen(this))
        Loop Parse this, "`n`s`t", "`r`n`s`t" {
            Len := StrLen(A_LoopField)
            if (Pos + Len > n) {
                Out .= "`n"
                Pos := 0
            } else if ((A_Index - 1) && Len && Pos) {
                Out .= " "
                Pos++
            }
            Out .= A_LoopField
            Pos += Len
        }
        return Out
    }

    /**
     * Trims characters `OmitChars` from the beginning and end of this string.
     * @example
     * 
     * " foo ".Trim() ; "foo"
     * 
     * @param   {String?}  OmitChars  characters to trim
     * @return  {String}
     */
    Trim(OmitChars?) => Trim(this, OmitChars?)

    /**
     * Trims characters `OmitChars` from the beginning of this string.
     * 
     * @param   {String?}  OmitChars  characters to trim
     * @return  {String}
     */
    LTrim(OmitChars?) => LTrim(this, OmitChars?)

    /**
     * Trims characters `OmitChars` from the end of this string.
     * 
     * @param   {String?}  OmitChars  characters to trim
     * @return  {String}
     */
    RTrim(OmitChars?) => RTrim(this, OmitChars?)

    /**
     * Returns a formatted string, using this as the format pattern.
     * 
     * If an object is passed, it is converted to a string by using its
     * `ToString() method`.
     * @example
     * 
     * "a: {}, b: {}".FormatWith(2, 42) ; "a: 2, b: 42"
     * 
     * @param   {Any*}  Args  zero or more additional arguments
     * @return  {String}
     */ 
    Format(Args*)     => Format(this, Args.Map(String)*)
    FormatWith(Args*) => Format(this, Args.Map(String)*)

    /**
     * Converts this string to lowercase.
     * @example
     * 
     * "FOO".ToLower() ; "foo"
     * 
     * @return  {String}
     */
    Lower() => StrLower(this)
    ToLower()  => StrLower(this)

    /**
     * Converts this string to uppercase.
     * @example
     * 
     * "foo".ToUpper() ; "FOO"
     * 
     * @return  {String}
     */
    Upper() => StrUpper(this)
    ToUpper()  => StrUpper(this)

    /**
     * Converts this string to title case.
     * @example
     * 
     * "foo".Title() ; "Foo"
     * 
     * @return  {String}
     */
    Title() => StrTitle(this)
    ToTitle()  => StrTitle(this)

    /**
     * Replaces occurrences of `Pattern` in this string.
     * @example
     * 
     * "abz".Replace("z", "c") ; "abc"
     * 
     * @param   {String}      Pattern    string whose content is replaced
     * @param   {String?}     Rep        replacement string
     * @param   {Primitive?}  CaseSense  case-sensitivity of the search
     * @param   {VarRef?}     Out        output of replacements that occurred
     * @param   {Integer?}    Limit      maximum number of replacements
     * @return  {String}
     */
    Replace(Pattern, Rep := "", CaseSense := false, &Out?, Limit := -1) {
        return StrReplace(this, Pattern, Rep, CaseSense, &Out, Limit)
    }

    /**
     * Separates this string into an array of substrings using `Delimiter`.
     * @example
     * 
     * "a,b,c".Split(",") ; ["a", "b", "c"]
     * 
     * @param   {String?/Array?}  Delimiters  boundaries between substrings
     * @param   {String?}         OmitChars   list of characters to trim
     * @param   {Integer}         MaxParts    maximum number of substrings
     * @return  {Array}
     */
    Split(Delimiters := "", OmitChars?, MaxParts?) {
        return StrSplit(this, Delimiters?, OmitChars?, MaxParts?)
    }

    /**
     * Searches for a given occurrence of a string, from the left or the right.
     * @example
     * 
     * "foo bar".Contains("b") ; 5
     * 
     * @param   {String}      Pattern      string to search for 
     * @param   {Primitive?}  CaseSense    case-sensitivity of the search
     * @param   {Integer?}    StartingPos  position to start searching from
     * @param   {Integer?}    Occurrence   n-th occurrence to earch for
     * @return  {Integer}
     */
    Has(Pattern, CaseSense := false, StartingPos := 1, Occurrence := 1) {
        return InStr(this, Pattern, CaseSense, StartingPos, Occurrence)
    }
    Contains(Pattern, CaseSense := false, StartingPos := 1, Occurrence := 1) {
        return InStr(this, Pattern, CaseSense, StartingPos, Occurrence)
    }

    /**
     * Returns a substring at index `Start` and length `Length` in characters.
     * @example
     * 
     * "123abc789".SubStr(4, 3) ; "abc"
     * 
     * @param   {Integer}   Start   start index of the substring
     * @param   {Integer?}  Length  length in characters
     * @return  {String}
     */
    Sub(Start, Length?) => SubStr(this, Start, Length?)

    /**
     * Returns a substring at index `Start` and length `Length` in characters.
     * Unlike `SubStr()`, `Length` defaults to 1 when omitted.
     * @example
     * 
     * ("foo bar")[5] ; "b"
     * 
     * @param   {Integer}   Start   start index of the substring
     * @param   {Integer?}  Length  length in characters
     * @return  {String}
     */
    __Item[Start, Length := 1] {
        Get {
            if (Abs(Start) > StrLen(this)) {
                throw ValueError("index out of bounds",, Start)
            }
            return SubStr(this, Start, Length)
        }
    }

    /**
     * Returns the length of this string in characters.
     * @return  {Integer}
     */
    Len() => StrLen(this)
    Len   => StrLen(this)

    /**
     * Returns the length of this string in bytes with the specified encoding
     * `Encoding`.
     * @example
     * 
     * "Hello, world!".Size ; UTF-16: (13 + 1) * 2 = 28 bytes
     * "foo".Size["UTF-8"]  ; 4
     * 
     * @param   {String?/Integer?}  Encoding  target string encoding
     * @return  {Integer}
     */
    Size[Encoding?] {
        Get {
            if (!IsSet(Encoding)) {
                return StrPut(this)
            }
            if (IsObject(Encoding)) {
                throw TypeError("Expected a String or Integer",, Type(Encoding))
            }
            return StrPut(this, Encoding)
        }
    }

    /**
     * Lexicographically compares this string with `Other`.
     * @example
     * 
     * "a".Compare("b") ; -1
     * 
     * @param   {String}      Other      string to be compared
     * @param   {Primitive?}  CaseSense  case-sensitivity of the comparison
     * @return  {Integer}
     */
    Compare(Other, CaseSense := false)    => StrCompare(this, Other, CaseSense)
} ; class String
} ; class AquaHotkey_String extends AquaHotkey