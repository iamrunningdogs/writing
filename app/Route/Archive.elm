module Route.Archive exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import DateTime
import Effect
import Element as UI
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import PagesMsg exposing (PagesMsg)
import Posts
import Route
import RouteBuilder exposing (App, StatefulRoute)
import SeoConfig exposing (defaultSeo)
import Shared
import UrlPath
import Utils exposing (..)
import View exposing (View)
import Widgets


type alias Model =
    { search_text : String
    }


type Msg
    = Msg_SearchTextChanged String


type alias RouteParams =
    {}


type alias Data =
    { posts : List Posts.PostHeader
    }


type alias ActionData =
    {}


route : StatefulRoute RouteParams Data ActionData Model Msg
route =
    RouteBuilder.single
        { head = head
        , data = data
        }
        |> RouteBuilder.buildWithLocalState
            { init = init
            , subscriptions = subscriptions
            , update = update
            , view = view
            }


data : BackendTask FatalError Data
data =
    Posts.allBlogPosts
        |> BackendTask.andThen (List.map Posts.loadPostHeader >> BackendTask.combine)
        |> BackendTask.map (List.sortWith <| \a b -> DateTime.compareNewer a.date b.date)
        |> BackendTask.map Data


title : String
title =
    "Todas las publicaciones — Asier Elorz"


head :
    App Data ActionData RouteParams
    -> List Head.Tag
head app =
    Seo.website { defaultSeo | title = title }


init : App Data ActionData RouteParams -> Shared.Model -> ( Model, Effect.Effect Msg )
init _ _ =
    ( { search_text = "" }, Effect.none )


subscriptions : RouteParams -> UrlPath.UrlPath -> Shared.Model -> Model -> Sub Msg
subscriptions _ _ _ _ =
    Sub.none


update : App Data ActionData RouteParams -> Shared.Model -> Msg -> Model -> ( Model, Effect.Effect Msg )
update _ _ msg model =
    case msg of
        Msg_SearchTextChanged new_search_text ->
            ( { model | search_text = new_search_text }, Effect.none )


view :
    App Data ActionData RouteParams
    -> Shared.Model
    -> Model
    -> View (PagesMsg Msg)
view app shared model =
    { title = title
    , body =
        let
            -- Posts grouped by month they were published
            grouped_posts =
                app.data.posts
                    |> List.filter (passesFilter model.search_text)
                    |> Posts.groupBy (\post -> [ ( post.date.year, DateTime.monthToInt post.date.month ) ])
                    |> List.sortWith (\( a, _ ) ( b, _ ) -> compare b a)

            year_month_to_string year month =
                (capitalize <| DateTime.monthToString <| DateTime.intToMonth month) ++ " de " ++ String.fromInt year

            view_grouped_posts : ( ( Int, Int ), List Posts.PostHeader ) -> UI.Element msg
            view_grouped_posts ( ( year, month ), posts_for_a_month ) =
                UI.column [ UI.spacing 10, UI.width UI.fill ]
                    (Widgets.heading [ UI.paddingEach { bottom = 10, top = 0, left = 0, right = 0 } ] 3 (year_month_to_string year month) :: List.map Widgets.postMenuEntry posts_for_a_month)

            search_box =
                Widgets.searchBox (PagesMsg.fromMsg << Msg_SearchTextChanged) model.search_text
        in
        UI.column
            [ UI.spacing 40 ]
            (search_box :: List.map view_grouped_posts grouped_posts)
    }


passesFilter : String -> Posts.PostHeader -> Bool
passesFilter filter post =
    let
        filter_lowercase =
            String.toLower filter

        post_title_lowercase =
            String.toLower post.title
    in
    String.isEmpty filter || String.contains filter_lowercase post_title_lowercase || List.any (String.contains filter) post.tags
