module SyntaxHighlightTests exposing (..)

import SyntaxHighlight
import Expect
import Test exposing (..)

-- syntax_cpp

syntax_cpp__empty_string : Test
syntax_cpp__empty_string = test
    "Empty string returns an empty list"
    (\_ -> Expect.equal
        (SyntaxHighlight.highlight SyntaxHighlight.syntax_cpp "")
        []
    )

syntax_cpp__just_whitespace : Test
syntax_cpp__just_whitespace = test
    "A string with only whitespace"
    (\_ -> Expect.equal
        (SyntaxHighlight.highlight SyntaxHighlight.syntax_cpp "   ")
        [ { text = "   ", color = SyntaxHighlight.syntax_cpp.default_color } ]
    )


syntax_cpp__identifier : Test
syntax_cpp__identifier = test
    "A single identifier is colored with the default color"
    (\_ -> Expect.equal
        (SyntaxHighlight.highlight SyntaxHighlight.syntax_cpp "vector")
        [ { text = "vector", color = SyntaxHighlight.syntax_cpp.default_color } ]
    )

syntax_cpp__c_comment : Test
syntax_cpp__c_comment = test
    "A single C comment is colored with the comment color"
    (\_ -> Expect.equal
        (SyntaxHighlight.highlight SyntaxHighlight.syntax_cpp "/* comment */")
        [ { text = "/* comment */", color = SyntaxHighlight.syntax_cpp.comments.color } ]
    )

syntax_cpp__c_comment_unclosed : Test
syntax_cpp__c_comment_unclosed = test
    "A single C comment is colored with the comment color, even if we forgot to close it"
    (\_ -> Expect.equal
        (SyntaxHighlight.highlight SyntaxHighlight.syntax_cpp "/* comment")
        [ { text = "/* comment", color = SyntaxHighlight.syntax_cpp.comments.color } ]
    )

syntax_cpp__merge_c_comments : Test
syntax_cpp__merge_c_comments = test
    "Two C comments form a single element"
    (\_ -> Expect.equal
        (SyntaxHighlight.highlight SyntaxHighlight.syntax_cpp "/* comment */ /* other C comment */")
        [ { text = "/* comment */ /* other C comment */", color = SyntaxHighlight.syntax_cpp.comments.color } ]
    )
    
syntax_cpp__string_literal : Test
syntax_cpp__string_literal = test
    "A single string literal is colored with the string literal color"
    (\_ -> Expect.equal
        (SyntaxHighlight.highlight SyntaxHighlight.syntax_cpp "\"Hello, world!\"")
        [ { text = "\"Hello, world!\"", color = SyntaxHighlight.syntax_cpp.string_literals.color } ]
    )
    
syntax_cpp__char_literal : Test
syntax_cpp__char_literal = test
    "A single char literal is colored with the string literal color"
    (\_ -> Expect.equal
        (SyntaxHighlight.highlight SyntaxHighlight.syntax_cpp "'v'")
        [ { text = "'v'", color = SyntaxHighlight.syntax_cpp.string_literals.color } ]
    )
    
syntax_cpp__keyword : Test
syntax_cpp__keyword = test
    "A single keyword is colored with the keyword color"
    (\_ -> Expect.equal
        (SyntaxHighlight.highlight SyntaxHighlight.syntax_cpp "constexpr")
        [ { text = "constexpr", color = SyntaxHighlight.syntax_cpp.keyword_color } ]
    )
    
syntax_cpp__punctuation : Test
syntax_cpp__punctuation = test
    "A single punctuation character is colored with the punctuation color"
    (\_ -> Expect.equal
        (SyntaxHighlight.highlight SyntaxHighlight.syntax_cpp "<")
        [ { text = "<", color = SyntaxHighlight.syntax_cpp.punctuation_color } ]
    )
    
syntax_cpp__int_literal : Test
syntax_cpp__int_literal = test
    "A single integer literal is colored with the number literal color"
    (\_ -> Expect.equal
        (SyntaxHighlight.highlight SyntaxHighlight.syntax_cpp "27")
        [ { text = "27", color = SyntaxHighlight.syntax_cpp.number_literal_color } ]
    )

syntax_cpp__float_literal : Test
syntax_cpp__float_literal = test
    "A single float literal is colored with the number literal color"
    (\_ -> Expect.equal
        (SyntaxHighlight.highlight SyntaxHighlight.syntax_cpp "27.05")
        [ { text = "27.05", color = SyntaxHighlight.syntax_cpp.number_literal_color } ]
    )

syntax_cpp__exp_float_literal : Test
syntax_cpp__exp_float_literal = test
    "A float literal can be in exponential form"
    (\_ -> Expect.equal
        (SyntaxHighlight.highlight SyntaxHighlight.syntax_cpp "123.456e-67")
        [ { text = "123.456e-67", color = SyntaxHighlight.syntax_cpp.number_literal_color } ]
    )
    
syntax_cpp__math_expression : Test
syntax_cpp__math_expression = test
    "A math expression is formed by two number literals and a punctuation"
    (\_ -> Expect.equal
        (SyntaxHighlight.highlight SyntaxHighlight.syntax_cpp "5 + 6")
        [ { text = "5", color = SyntaxHighlight.syntax_cpp.number_literal_color }
        , { text = " +", color = SyntaxHighlight.syntax_cpp.punctuation_color }
        , { text = " 6", color = SyntaxHighlight.syntax_cpp.number_literal_color }
        ]
    )

preprocessor_color = SyntaxHighlight.rgb 155 155 155

syntax_cpp__preprocessor : Test
syntax_cpp__preprocessor = test
    "A single preprocessor directive is colored with the preprocessor color"
    (\_ -> Expect.equal
        (SyntaxHighlight.highlight SyntaxHighlight.syntax_cpp "#define TRUE 1")
        [ { text = "#define TRUE 1", color = preprocessor_color } ]
    )

syntax_cpp__preprocessor_lf : Test
syntax_cpp__preprocessor_lf = test
    "A single preprocessor directive followed by new line"
    (\_ -> Expect.equal
        (SyntaxHighlight.highlight SyntaxHighlight.syntax_cpp "#define TRUE 1\n")
        [ { text = "#define TRUE 1\n", color = preprocessor_color } ]
    )

syntax_cpp__preprocessor_crlf : Test
syntax_cpp__preprocessor_crlf = test
    "A single preprocessor directive followed by carriage returna and new line"
    (\_ -> Expect.equal
        (SyntaxHighlight.highlight SyntaxHighlight.syntax_cpp "#define TRUE 1\r\n")
        [ { text = "#define TRUE 1\r\n", color = preprocessor_color } ]
    )

syntax_cpp__preprocessor_crlf_others : Test
syntax_cpp__preprocessor_crlf_others = test
    "A single preprocessor directive followed by carriage returna and new line and an integer declaration"
    (\_ -> Expect.equal
        (SyntaxHighlight.highlight SyntaxHighlight.syntax_cpp "#define TRUE 1\r\nint count;")
        [ { text = "#define TRUE 1\r\n", color = preprocessor_color }
        , { text = "int", color = SyntaxHighlight.syntax_cpp.keyword_color }
        , { text = " count", color = SyntaxHighlight.syntax_cpp.default_color }
        , { text = ";", color = SyntaxHighlight.syntax_cpp.punctuation_color }
        ]
    )

syntax_cpp__comment_cpp_eof : Test
syntax_cpp__comment_cpp_eof = test
    "A single C++ comment followed by EOF"
    (\_ -> Expect.equal
        (SyntaxHighlight.highlight SyntaxHighlight.syntax_cpp "// This is a comment")
        [ { text = "// This is a comment", color = SyntaxHighlight.syntax_cpp.comments.color } ]
    )

syntax_cpp__comment_cpp_lf : Test
syntax_cpp__comment_cpp_lf = test
    "A single C++ comment followed by line end \\n"
    (\_ -> Expect.equal
        (SyntaxHighlight.highlight SyntaxHighlight.syntax_cpp "// This is a comment\n")
        [ { text = "// This is a comment\n", color = SyntaxHighlight.syntax_cpp.comments.color } ]
    )

syntax_cpp__comment_cpp_crlf : Test
syntax_cpp__comment_cpp_crlf = test
    "A single C++ comment followed by carriage return and line end \\r\\n"
    (\_ -> Expect.equal
        (SyntaxHighlight.highlight SyntaxHighlight.syntax_cpp "// This is a comment\r\n")
        [ { text = "// This is a comment\r\n", color = SyntaxHighlight.syntax_cpp.comments.color } ]
    )

syntax_cpp__comment_cpp_and_others : Test
syntax_cpp__comment_cpp_and_others = test
    "A single C++ comment followed by a new line with a variable declaration"
    (\_ -> Expect.equal
        (SyntaxHighlight.highlight SyntaxHighlight.syntax_cpp "// This is a comment\nint count;")
        [ { text = "// This is a comment\n", color = SyntaxHighlight.syntax_cpp.comments.color }
        , { text = "int", color = SyntaxHighlight.syntax_cpp.keyword_color }
        , { text = " count", color = SyntaxHighlight.syntax_cpp.default_color }
        , { text = ";", color = SyntaxHighlight.syntax_cpp.punctuation_color }
        ]
    )

syntax_cpp__comment_cpp_clrf_and_others : Test
syntax_cpp__comment_cpp_clrf_and_others = test
    "A single C++ comment followed by a carriage return and new line with a variable declaration"
    (\_ -> Expect.equal
        (SyntaxHighlight.highlight SyntaxHighlight.syntax_cpp "// This is a comment\r\nint count;")
        [ { text = "// This is a comment\r\n", color = SyntaxHighlight.syntax_cpp.comments.color }
        , { text = "int", color = SyntaxHighlight.syntax_cpp.keyword_color }
        , { text = " count", color = SyntaxHighlight.syntax_cpp.default_color }
        , { text = ";", color = SyntaxHighlight.syntax_cpp.punctuation_color }
        ]
    )

syntax_cpp__include_directive_crlf : Test
syntax_cpp__include_directive_crlf = test
    "An include directive followed by carriage return and line feed"
    (\_ -> Expect.equal
        (SyntaxHighlight.highlight SyntaxHighlight.syntax_cpp "#include \"stdio.h\"\r\n")
        [ { text = "#include \"stdio.h\"\r\n", color = preprocessor_color } ]
    )

syntax_cpp__include_directive_crlf_and_others : Test
syntax_cpp__include_directive_crlf_and_others = test
    "An include directive followed by carriage return and line feed and a variable declaration"
    (\_ -> Expect.equal
        (SyntaxHighlight.highlight SyntaxHighlight.syntax_cpp "#include \"stdio.h\"\r\nint count;")
        [ { text = "#include \"stdio.h\"\r\n", color = preprocessor_color } 
        , { text = "int", color = SyntaxHighlight.syntax_cpp.keyword_color }
        , { text = " count", color = SyntaxHighlight.syntax_cpp.default_color }
        , { text = ";", color = SyntaxHighlight.syntax_cpp.punctuation_color }
        ]
    )

syntax_cpp__trailing_whitespace : Test
syntax_cpp__trailing_whitespace = test
    "Trailing whitespace at the end of the string is added to the last colored text"
    (\_ -> Expect.equal
        (SyntaxHighlight.highlight SyntaxHighlight.syntax_cpp "int   ")
        [ { text = "int   ", color = SyntaxHighlight.syntax_cpp.keyword_color } ]
    )


syntax_cpp__two_identifiers_between_an_operator : Test
syntax_cpp__two_identifiers_between_an_operator = test
    "Two identifiers between an operator, without whitespace"
    (\_ -> Expect.equal
        (SyntaxHighlight.highlight SyntaxHighlight.syntax_cpp "first + second")
        [ { text = "first", color = SyntaxHighlight.syntax_cpp.default_color } 
        , { text = " +", color = SyntaxHighlight.syntax_cpp.punctuation_color } 
        , { text = " second", color = SyntaxHighlight.syntax_cpp.default_color } 
        ]
    )


syntax_cpp__two_identifier_that_starts_with_e : Test
syntax_cpp__two_identifier_that_starts_with_e = test
    "An identifier that starts with 'e' is not misinterpreted as a number"
    (\_ -> Expect.equal
        (SyntaxHighlight.highlight SyntaxHighlight.syntax_cpp "energy + xyzw")
        [ { text = "energy", color = SyntaxHighlight.syntax_cpp.default_color } 
        , { text = " +", color = SyntaxHighlight.syntax_cpp.punctuation_color } 
        , { text = " xyzw", color = SyntaxHighlight.syntax_cpp.default_color } 
        ]
    )


syntax_cpp__code_snippet : Test
syntax_cpp__code_snippet =
    let
        source = """#include "stdio.h"

int main(void)
{
    // Print hello world to the console
    printf("Hello, world!\\n");
    return 0;
}
"""
    in test
        "Code snippet with realistic code that should be highlighted correctly"
        (\_ -> Expect.equal
            (SyntaxHighlight.highlight SyntaxHighlight.syntax_cpp source)
            [ { text = "#include \"stdio.h\"\r\n", color = preprocessor_color }
            , { text = "\r\nint", color = SyntaxHighlight.syntax_cpp.keyword_color }
            , { text = " main", color = SyntaxHighlight.syntax_cpp.default_color }
            , { text = "(", color = SyntaxHighlight.syntax_cpp.punctuation_color }
            , { text = "void", color = SyntaxHighlight.syntax_cpp.keyword_color }
            , { text = ")\r\n{", color = SyntaxHighlight.syntax_cpp.punctuation_color }
            , { text = "\r\n    // Print hello world to the console\r\n", color = SyntaxHighlight.syntax_cpp.comments.color }
            , { text = "    printf", color = SyntaxHighlight.syntax_cpp.default_color }
            , { text = "(", color = SyntaxHighlight.syntax_cpp.punctuation_color }
            , { text = "\"Hello, world!\\n\"", color = SyntaxHighlight.syntax_cpp.string_literals.color }
            , { text = ");", color = SyntaxHighlight.syntax_cpp.punctuation_color }
            , { text = "\r\n    return", color = SyntaxHighlight.syntax_cpp.keyword_color }
            , { text = " 0", color = SyntaxHighlight.syntax_cpp.number_literal_color }
            , { text = ";\r\n}\r\n", color = SyntaxHighlight.syntax_cpp.punctuation_color }
            ]
        )

syntax_elm__vertical_bar : Test
syntax_elm__vertical_bar = test
    "Vertical bar is parsed as punctuation"
    (\_ -> Expect.equal
            (SyntaxHighlight.highlight SyntaxHighlight.syntax_elm "|")
            [ { text = "|", color = SyntaxHighlight.syntax_elm.punctuation_color } ]
    )
