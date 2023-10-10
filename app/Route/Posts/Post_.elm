module Route.Posts.Post_ exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import Element as UI exposing (px)
import Element.Font as UI_Font
import FatalError exposing (FatalError)
import Head
import PagesMsg exposing (PagesMsg)
import Posts
import PostsMarkdown
import RouteBuilder exposing (App, StatelessRoute)
import SeoConfig exposing (defaultSeo)
import Shared
import View exposing (View)
import Widgets


type alias Model =
    {}


type alias Msg =
    ()


type alias RouteParams =
    { post : String
    }


route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.preRender
        { head = head
        , pages = pages
        , data = data
        }
        |> RouteBuilder.buildNoState { view = view }


pages : BackendTask FatalError (List RouteParams)
pages =
    Posts.allBlogPosts
        |> BackendTask.map (List.map Posts.removeDateFromPostFilename)
        |> BackendTask.map (List.map RouteParams)


type alias Data =
    Posts.Post


type alias ActionData =
    {}


data :
    RouteParams
    -> BackendTask FatalError Data
data routeParams =
    Posts.allBlogPosts
        |> BackendTask.map (List.partition (String.contains routeParams.post) >> Tuple.first >> List.head >> Maybe.withDefault routeParams.post)
        |> BackendTask.andThen Posts.loadPost


head :
    App Data ActionData RouteParams
    -> List Head.Tag
head app =
    let
        post =
            app.data
    in
    SeoConfig.makeHeadTags
        { defaultSeo
            | title = post.header.title ++ " — Asier Elorz"
            , description = Posts.description post
            , image = post.header.image |> Maybe.map SeoConfig.imageFromUrl |> Maybe.withDefault defaultSeo.image
        }


view :
    App Data ActionData RouteParams
    -> Shared.Model
    -> View (PagesMsg Msg)
view app sharedModel =
    { title = app.data.header.title ++ " — Asier Elorz"
    , body =
        UI.column
            [ UI.spacing 10
            , UI.width UI.fill
            ]
            [ Widgets.link [] { url = "", label = UI.paragraph [ UI_Font.size 25, UI_Font.bold ] [ UI.text app.data.header.title ] }
            , Widgets.dateText "Publicado el " app.data.header.date
            , UI.wrappedRow [ UI.spacing 5 ] (List.map Widgets.tag app.data.header.tags)
            , UI.el [ UI.height (px 20) ] UI.none -- Dummy element to add spacing between the header and the text
            , UI.column [ UI.spacing 15, UI.width UI.fill ] <| PostsMarkdown.parseBody app.data.body
            ]
    }
