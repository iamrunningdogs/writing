module Widgets exposing (..)

import DateTime
import Element as UI exposing (px, rgb255)
import Element.Background as UI_Background
import Element.Border as UI_Border
import Element.Font as UI_Font
import Element.Input as UI_Input
import Element.Region as UI_Region
import Fontawesome
import Html
import Html.Attributes
import Posts
import Url


linkBlue : UI.Color
linkBlue =
    rgb255 83 149 202


link : List (UI.Attribute msg) -> { url : String, label : UI.Element msg } -> UI.Element msg
link attributes args =
    UI.link (UI.mouseOver [ UI_Font.color linkBlue ] :: attributes) args


blueLink : List (UI.Attribute msg) -> { url : String, label : UI.Element msg } -> UI.Element msg
blueLink attributes args =
    UI.link (UI_Font.color linkBlue :: attributes) args


tag : String -> UI.Element msg
tag tag_name =
    UI.link []
        { url = "/tags#" ++ Url.percentEncode tag_name
        , label =
            UI.row
                [ UI.paddingXY 7 2
                , UI_Background.color (rgb255 36 38 74)
                , UI_Font.color (rgb255 51 125 255)
                , UI_Font.size 14
                , UI_Border.rounded 5
                , UI.spacing 3
                , UI.mouseOver [ UI_Background.color (rgb255 27 73 88), UI_Font.color (rgb255 232 230 227) ]
                ]
                [ Fontawesome.text [] "\u{F02B}" -- fa-tag
                , UI.text tag_name
                ]
        }


heading : List (UI.Attribute msg) -> Int -> String -> UI.Element msg
heading attributes level label =
    complexHeading attributes level label [ UI.text label ]


complexHeading : List (UI.Attribute msg) -> Int -> String -> List (UI.Element msg) -> UI.Element msg
complexHeading attributes level label children =
    let
        id =
            label
                |> String.trim
                |> String.toLower
                |> String.replace " " "-"
                |> Url.percentEncode

        font_size =
            case level of
                1 ->
                    32

                2 ->
                    28

                3 ->
                    26

                4 ->
                    24

                5 ->
                    22

                _ ->
                    20
    in
    UI.el
        [ UI.width UI.fill
        ]
    <|
        UI.el
            ([ UI_Font.size font_size
             , UI_Region.heading level
             , UI.htmlAttribute <| Html.Attributes.id id
             , UI.width UI.fill
             , UI.inFront <|
                link
                    [ UI.paddingXY 10 0
                    , UI.centerY
                    , UI.alpha 0
                    , UI.mouseOver [ UI.alpha 1 ]
                    , UI.width UI.fill
                    , UI.moveLeft 50
                    ]
                    { url = "#" ++ id, label = Fontawesome.text [] "\u{F0C1}" }
             ]
                ++ attributes
            )
        <|
            UI.paragraph [ UI.width UI.fill, UI_Font.bold ] children


dateText : String -> DateTime.Date -> UI.Element msg
dateText prefix date =
    UI.paragraph [ UI_Font.italic, UI_Font.color (rgb255 168 160 149) ] [ UI.text <| prefix ++ DateTime.toStringText date ]


searchBox : (String -> msg) -> String -> UI.Element msg
searchBox make_message current_text =
    UI_Input.text
        [ UI.width UI.fill
        , UI_Background.color (rgb255 34 36 38)
        , UI_Border.color (rgb255 168 160 149)
        ]
        { onChange = make_message
        , text = current_text
        , placeholder = Just <| UI_Input.placeholder [] (UI.text "Buscar...")
        , label =
            UI_Input.labelLeft
                [ UI.centerY
                , UI_Font.size 30
                , UI.paddingEach { right = 10, top = 0, bottom = 0, left = 0 }
                ]
                (Fontawesome.text [] "\u{F002}" {- fa-magnifying-glass -})
        }


postMenuEntry : Posts.PostHeader -> UI.Element msg
postMenuEntry post =
    UI.row
        [ UI.spacing 10
        , UI.width UI.fill
        ]
        [ UI.el [ UI.alignTop ] <| UI.text "•"
        , UI.column [ UI.width UI.fill, UI.spacing 5 ]
            [ UI.paragraph [] [ link [] { url = post.url, label = UI.text post.title } ]
            , UI.wrappedRow [ UI.spacing 5 ]
                (dateText "" post.date :: List.map tag post.tags)
            ]
        ]


horizontalSeparator : Int -> UI.Element msg
horizontalSeparator width =
    UI.el
        [ UI.height (px width)
        , UI_Background.color (rgb255 53 57 59)
        , UI.width UI.fill
        ]
        UI.none


embedYoutubeVideo : List (UI.Attribute msg) -> String -> UI.Element msg
embedYoutubeVideo attributes youtube_video_id =
    UI.el attributes <|
        UI.html <|
            Html.iframe
                [ Html.Attributes.width 560
                , Html.Attributes.height 315
                , Html.Attributes.src <| "https://www.youtube.com/embed/" ++ youtube_video_id
                , Html.Attributes.attribute "allow" "accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture"
                , Html.Attributes.attribute "allowfullscreen" "true"
                ]
                []


referenceSuperscript : String -> UI.Element msg
referenceSuperscript id =
    blueLink []
        { url = "#footnote-" ++ id
        , label = UI.html <| Html.sup [ Html.Attributes.id <| "ref-" ++ id ] [ Html.text <| "[" ++ id ++ "]" ]
        }


referenceFootnote : String -> UI.Element msg
referenceFootnote id =
    blueLink [ UI.htmlAttribute <| Html.Attributes.id <| "footnote-" ++ id, UI.paddingEach { top = 0, bottom = 0, left = 0, right = 10 } ]
        { url = "#ref-" ++ id
        , label = UI.text <| "[" ++ id ++ "]"
        }
