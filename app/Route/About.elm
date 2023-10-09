module Route.About exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import BackendTask.File
import Element as UI
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import PagesMsg exposing (PagesMsg)
import Posts
import PostsMarkdown
import Route
import RouteBuilder exposing (App, StatelessRoute)
import SeoConfig exposing (defaultSeo)
import Shared
import View exposing (View)


type alias Model =
    {}


type alias Msg =
    ()


type alias RouteParams =
    {}


type alias Data =
    { text : String
    }


type alias ActionData =
    {}


route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.single
        { head = head
        , data = data
        }
        |> RouteBuilder.buildNoState { view = view }


data : BackendTask FatalError Data
data =
    BackendTask.File.bodyWithoutFrontmatter "about.md"
        |> BackendTask.allowFatal
        |> BackendTask.map Data


head :
    App Data ActionData RouteParams
    -> List Head.Tag
head app =
    { defaultSeo | title = "Sobre mí — Asier Elorz" }
        |> Seo.website


view :
    App Data ActionData RouteParams
    -> Shared.Model
    -> View (PagesMsg Msg)
view app shared =
    { title = "Sobre mí — Asier Elorz"
    , body =
        UI.column [ UI.spacing 15 ] <| PostsMarkdown.parseBody app.data.text

    --, Route.Blog__Slug_ { slug = "hello" }
    --    |> Route.link [] [ Html.text "My blog post" ]
    }
