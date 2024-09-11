module Route.About exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import BackendTask.File
import Element as UI
import FatalError exposing (FatalError)
import Head
import PagesMsg exposing (PagesMsg)
import MarkdownText exposing (MarkdownText(..))
import Route
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
    {}


type alias Data =
    { text : MarkdownText
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
        |> BackendTask.map MarkdownText
        |> BackendTask.map Data


head :
    App Data ActionData RouteParams
    -> List Head.Tag
head _ =
    SeoConfig.makeHeadTags { defaultSeo | title = "Sobre mí — Asier Elorz" }


view :
    App Data ActionData RouteParams
    -> Shared.Model
    -> View (PagesMsg Msg)
view app _ =
    { title = "Sobre mí — Asier Elorz"
    , body =
        UI.column [ UI.spacing 15 ] <| Widgets.markdownBody app.data.text

    --, Route.Blog__Slug_ { slug = "hello" }
    --    |> Route.link [] [ Html.text "My blog post" ]
    }
