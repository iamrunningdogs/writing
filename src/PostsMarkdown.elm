module PostsMarkdown exposing (parseBody)

import Element as UI
import Element.Font as UI_Font
import Markdown.Block
import Markdown.Html
import Markdown.Parser
import Markdown.Renderer
import Markdown.Renderer.ElmUi as MarkdownRenderer exposing (Error(..))
import Parser
import Parser.Advanced
import Widgets


parseBody : String -> List (UI.Element msg)
parseBody body =
    let
        parsed_markdown =
            parseMarkdown body
    in
    case parsed_markdown of
        Ok value ->
            value

        Err error ->
            [ UI.text <| "Error at parsing markdown: " ++ markdownErrorToString error ]


parseMarkdown : String -> Result Error (List (UI.Element msg))
parseMarkdown markdown_source =
    Markdown.Parser.parse markdown_source
        |> Result.mapError ParseError
        |> Result.andThen
            (\blocks ->
                Markdown.Renderer.render markdownRenderer blocks
                    |> Result.mapError RenderError
            )


markdownRenderer : Markdown.Renderer.Renderer (UI.Element msg)
markdownRenderer =
    let
        defaultRenderer =
            MarkdownRenderer.renderer
    in
    { defaultRenderer
        | html =
            Markdown.Html.oneOf
                [ Markdown.Html.tag "youtube"
                    (\id _ ->
                        Widgets.embedYoutubeVideo [ UI.centerX ] id
                    )
                    |> Markdown.Html.withAttribute "id"
                , Markdown.Html.tag "ref"
                    (\id _ ->
                        Widgets.referenceSuperscript id
                    )
                    |> Markdown.Html.withAttribute "id"
                , Markdown.Html.tag "footnote"
                    (\id _ ->
                        Widgets.referenceFootnote id
                    )
                    |> Markdown.Html.withAttribute "id"
                ]
        , paragraph = UI.paragraph [ UI_Font.justify, UI.width UI.fill ]
        , unorderedList = unorderedList
        , link = \{ destination } body -> Widgets.blueLink [] { url = destination, label = UI.paragraph [] body }
        , heading = \{ level, rawText, children } -> Widgets.complexHeading [ UI.paddingEach { top = 10, left = 0, bottom = 0, right = 0 } ] (Markdown.Block.headingLevelToInt level) rawText children
    }


unorderedListItem : Markdown.Block.ListItem (UI.Element msg) -> UI.Element msg
unorderedListItem (Markdown.Block.ListItem _ children) =
    let
        bullet =
            UI.el
                [ UI.paddingEach { top = 4, bottom = 0, left = 2, right = 8 }
                , UI.alignTop
                ]
            <|
                UI.text "•"
    in
    UI.row []
        [ bullet
        , UI.paragraph [ UI.width UI.fill ] children
        ]


unorderedList : List (Markdown.Block.ListItem (UI.Element msg)) -> UI.Element msg
unorderedList items =
    List.map unorderedListItem items
        |> UI.column [ UI.spacing 5 ]


type alias MarkdownParserError =
    Parser.Advanced.DeadEnd String Parser.Problem


markdownErrorToString : MarkdownRenderer.Error -> String
markdownErrorToString error =
    case error of
        ParseError parser_error ->
            "Parse error: " ++ markdownParserErrorsToString parser_error

        RenderError error_message ->
            "Render error: " ++ error_message


markdownParserErrorsToString : List MarkdownParserError -> String
markdownParserErrorsToString errors =
    errors
        |> List.map markdownParserErrorToString
        |> String.join "\n\n"


markdownParserErrorToString : MarkdownParserError -> String
markdownParserErrorToString error =
    let
        context_stack_as_string =
            error.contextStack
                |> List.map contextStackFrameToString
                |> List.map (\s -> "\n - " ++ s)
                |> String.join ""
    in
    "(row: " ++ String.fromInt error.row ++ " col: " ++ String.fromInt error.col ++ ") " ++ parserProblemToString error.problem ++ context_stack_as_string


contextStackFrameToString : { row : Int, col : Int, context : String } -> String
contextStackFrameToString frame =
    "(row: " ++ String.fromInt frame.row ++ " col: " ++ String.fromInt frame.col ++ ") " ++ frame.context


parserProblemToString : Parser.Problem -> String
parserProblemToString problem =
    case problem of
        Parser.Expecting str ->
            "Expecting " ++ str

        Parser.ExpectingInt ->
            "Expecting int"

        Parser.ExpectingHex ->
            "Expecting hex"

        Parser.ExpectingOctal ->
            "Expecting octal"

        Parser.ExpectingBinary ->
            "Expecting binary"

        Parser.ExpectingFloat ->
            "Expecting float"

        Parser.ExpectingNumber ->
            "Expecting number"

        Parser.ExpectingVariable ->
            "Expecting variable"

        Parser.ExpectingSymbol str ->
            "Expecting symbol " ++ str

        Parser.ExpectingKeyword str ->
            "Expecting keyword " ++ str

        Parser.ExpectingEnd ->
            "Expecting end"

        Parser.UnexpectedChar ->
            "Unexpected char"

        Parser.Problem str ->
            "Problem: " ++ str

        Parser.BadRepeat ->
            "Bad repeat"
