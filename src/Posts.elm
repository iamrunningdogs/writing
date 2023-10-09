module Posts exposing (Post, PostHeader, allBlogPosts, description, groupBy, loadPost, loadPostHeader)

import BackendTask exposing (BackendTask)
import BackendTask.File
import BackendTask.Glob as Glob
import DateTime exposing (Date)
import Dict
import FatalError exposing (FatalError)
import Json.Decode


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
loadPost post_name =
    BackendTask.File.bodyWithFrontmatter (postDecoder <| postUrl post_name) (postPath post_name)
        |> BackendTask.allowFatal


{-| Load the metadata but not the content
-}
loadPostHeader : String -> BackendTask FatalError PostHeader
loadPostHeader post_name =
    BackendTask.File.onlyFrontmatter (postHeaderDecoder <| postUrl post_name) (postPath post_name)
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
postPath post_name =
    "posts/" ++ post_name ++ ".md"


postUrl : String -> String
postUrl post_name =
    "/posts/" ++ post_name


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
