module Posts exposing (Post, PostHeader, allBlogPosts, description, groupBy, loadPost, loadPostHeader, removeDateFromPostFilename)

import BackendTask exposing (BackendTask)
import BackendTask.File
import BackendTask.Glob as Glob
import DateTime exposing (Date)
import Dict
import FatalError exposing (FatalError)
import Json.Decode
import Parser exposing ((|.), (|=))


allBlogPosts : BackendTask FatalError (List String)
allBlogPosts =
    Glob.succeed (\x -> x)
        |> Glob.match (Glob.literal "posts/")
        |> Glob.capture Glob.wildcard
        |> Glob.match (Glob.literal ".md")
        |> Glob.toBackendTask


type alias PostHeader =
    { url : String
    , title : String
    , tags : List String
    , date : Date
    , description : Maybe String
    , image : Maybe String
    }


type alias Post =
    { header : PostHeader
    , body : String
    }


{-| Returns the bespoke description if its available, or the first paragraph if it's not.
-}
description : Post -> String
description post =
    case post.header.description of
        Just str ->
            str

        Nothing ->
            post.body |> String.lines |> List.head |> Maybe.withDefault ""


loadPost : String -> BackendTask FatalError Post
loadPost post_filename =
    BackendTask.File.bodyWithFrontmatter (postDecoder <| postUrl post_filename) (postPath post_filename)
        |> BackendTask.allowFatal


{-| Load the metadata but not the content
-}
loadPostHeader : String -> BackendTask FatalError PostHeader
loadPostHeader post_filename =
    BackendTask.File.onlyFrontmatter (postHeaderDecoder <| postUrl post_filename) (postPath post_filename)
        |> BackendTask.allowFatal


postDecoder : String -> String -> Json.Decode.Decoder Post
postDecoder url body =
    postHeaderDecoder url |> Json.Decode.map (\header -> { header = header, body = body })


postHeaderDecoder : String -> Json.Decode.Decoder PostHeader
postHeaderDecoder url =
    Json.Decode.map5 (PostHeader url)
        (Json.Decode.field "title" Json.Decode.string)
        (Json.Decode.field "tags" tagsDecoder)
        (Json.Decode.field "date" DateTime.jsonDecode)
        (Json.Decode.maybe <| Json.Decode.field "description" Json.Decode.string)
        (Json.Decode.maybe <| Json.Decode.field "image" Json.Decode.string)


postPath : String -> String
postPath post_filename =
    "posts/" ++ post_filename ++ ".md"


removeDateFromPostFilename : String -> String
removeDateFromPostFilename post_filename =
    let
        post_filename_parser =
            Parser.succeed identity
                |. Parser.int
                |. Parser.symbol "-"
                |. Parser.oneOf [ Parser.symbol "0", Parser.succeed () ]
                |. Parser.int
                |. Parser.symbol "-"
                |. Parser.oneOf [ Parser.symbol "0", Parser.succeed () ]
                |. Parser.int
                |. Parser.symbol "-"
                |= Parser.getChompedString (Parser.chompWhile (always True))
    in
    Parser.run post_filename_parser post_filename |> Result.withDefault post_filename


postUrl : String -> String
postUrl post_filename =
    "/posts/" ++ removeDateFromPostFilename post_filename


tagsDecoder : Json.Decode.Decoder (List String)
tagsDecoder =
    Json.Decode.map (String.split " ")
        Json.Decode.string


groupBy : (a -> List comparable) -> List a -> List ( comparable, List a )
groupBy get_keys list =
    let
        insert_once item key dict =
            dict
                |> Dict.update key
                    (\prev ->
                        case prev of
                            Nothing ->
                                Just [ item ]

                            Just curr ->
                                Just <| curr ++ [ item ]
                    )

        insert item dict =
            get_keys item |> List.foldl (insert_once item) dict
    in
    list
        |> List.foldl insert Dict.empty
        |> Dict.toList
