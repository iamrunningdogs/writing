module Route.Index exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import DateTime
import Element as UI exposing (px, rgba255)
import Element.Background as UI_Background
import Element.Border as UI_Border
import Element.Font as UI_Font
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import Html.Attributes
import Markdown.Block exposing (HtmlAttribute)
import PagesMsg exposing (PagesMsg)
import Posts
import PostsMarkdown
import Route
import RouteBuilder exposing (App, StatelessRoute)
import SeoConfig
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
    { posts : List Posts.Post
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
    Posts.allBlogPosts
        |> BackendTask.andThen (List.map Posts.loadPost >> BackendTask.combine)
        |> BackendTask.map (List.sortWith <| \a b -> DateTime.compareNewer a.header.date b.header.date)
        |> BackendTask.map (List.take 10)
        |> BackendTask.map Data


head :
    App Data ActionData RouteParams
    -> List Head.Tag
head _ =
    Seo.website SeoConfig.defaultSeo


view :
    App Data ActionData RouteParams
    -> Shared.Model
    -> View (PagesMsg Msg)
view app shared =
    { title = "Asier Elorz"
    , body =
        UI.column
            [ UI.spacing 10 ]
            ((app.data.posts |> List.map viewPost)
                ++ [ UI.paragraph []
                        [ UI.text "¿Buscas más artículos? Todas las publicaciones disponibles "
                        , Widgets.blueLink [] { url = "/archive", label = UI.text "aquí" }
                        , UI.text "."
                        ]
                   ]
            )
    }


viewPost : Posts.Post -> UI.Element msg
viewPost post =
    let
        image_widget =
            case post.header.image of
                Nothing ->
                    []

                Just image_url ->
                    [ UI.link []
                        { url = post.header.url
                        , label = Widgets.postBannerImage image_url
                        }
                    ]
    in
    UI.column
        [ UI.width UI.fill
        , UI.spacing 10
        ]
        (image_widget
            ++ [ Widgets.link [ UI_Font.size 25, UI_Font.bold ] { url = post.header.url, label = UI.paragraph [] [ UI.text post.header.title ] }
               , UI.wrappedRow [ UI.spacing 5 ] (Widgets.dateText "" post.header.date :: List.map Widgets.tag post.header.tags)
               , UI.el [ UI.height (px 5) ] UI.none -- Dummy element to add spacing between the header and the text
               , PostsMarkdown.parseBody (Posts.description post) |> List.head |> Maybe.withDefault UI.none
               , UI.el [ UI.height (px 10) ] UI.none -- Dummy element to add spacing around the separator
               , Widgets.horizontalSeparator 1
               , UI.el [ UI.height (px 10) ] UI.none -- Dummy element to add spacing around the separator
               ]
        )
