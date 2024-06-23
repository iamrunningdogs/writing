module Shared exposing (Data, Model, Msg(..), SharedMsg(..), template)

import BackendTask exposing (BackendTask)
import Browser.Dom
import Browser.Events
import Browser.Navigation
import Colors
import Effect exposing (Effect)
import Element as UI exposing (px, rgb255)
import Element.Background as UI_Background
import Element.Border as UI_Border
import Element.Events as UI_Events
import Element.Font as UI_Font
import FatalError exposing (FatalError)
import Html exposing (Html)
import LanguageTag.Region exposing (to)
import Pages.Flags
import Pages.PageUrl exposing (PageUrl)
import Platform.Cmd as Cmd
import Posts
import Random
import Route exposing (Route)
import SharedTemplate exposing (SharedTemplate)
import Task
import UrlPath exposing (UrlPath)
import View exposing (View)
import Widgets


template : SharedTemplate Msg Model Data msg
template =
    { init = init
    , update = update
    , view = view
    , data = data
    , subscriptions = subscriptions
    , onPageChange = Nothing
    }


type Msg
    = SharedMsg SharedMsg
    | Msg_ViewportSize (Maybe { width : Int, height : Int })
    | Msg_RandomPostClicked (List String)
    | Msg_RandomPostChosen (Maybe String)


type alias Data =
    { all_post_filenames : List String
    }


type SharedMsg
    = NoOp


type alias Model =
    { window : Maybe { width : Int, height : Int }
    }


init :
    Pages.Flags.Flags
    ->
        Maybe
            { path :
                { path : UrlPath
                , query : Maybe String
                , fragment : Maybe String
                }
            , metadata : route
            , pageUrl : Maybe PageUrl
            }
    -> ( Model, Effect Msg )
init flags maybePagePath =
    ( { window = Nothing }
    , Browser.Dom.getViewport
        |> Task.map (\viewport -> { width = floor viewport.viewport.width, height = floor viewport.viewport.height })
        |> Task.attempt identity
        |> Cmd.map Result.toMaybe
        |> Cmd.map Msg_ViewportSize
        |> Effect.Cmd
    )


random_uniform : List a -> Random.Generator (Maybe a)
random_uniform l =
    case l of
        [] ->
            Random.constant Nothing

        head :: tail ->
            Random.uniform head tail |> Random.map Just


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        SharedMsg globalMsg ->
            ( model, Effect.none )

        Msg_ViewportSize new_window ->
            ( { model | window = new_window }, Effect.none )

        Msg_RandomPostClicked all_articles ->
            ( model, random_uniform all_articles |> Random.generate Msg_RandomPostChosen |> Effect.Cmd )

        Msg_RandomPostChosen maybe_post_filename ->
            case maybe_post_filename of
                Nothing ->
                    ( model, Effect.none )

                Just post_filename ->
                    ( model, Posts.postUrl post_filename |> Browser.Navigation.load |> Effect.Cmd )


subscriptions : UrlPath -> Model -> Sub Msg
subscriptions _ _ =
    Browser.Events.onResize (\w h -> Msg_ViewportSize <| Just { width = w, height = h })


data : BackendTask FatalError Data
data =
    Posts.allBlogPosts
        |> BackendTask.map Data


view :
    Data
    ->
        { path : UrlPath
        , route : Maybe Route
        }
    -> Model
    -> (Msg -> msg)
    -> View msg
    -> { body : List (Html msg), title : String }
view sharedData page model toMsg pageView =
    { body =
        [ UI.layout
            [ UI_Background.color Colors.background
            , UI_Font.color Colors.text
            , UI_Font.size 18
            , UI_Font.family [ UI_Font.typeface "Helvetica", UI_Font.sansSerif ]
            ]
          <|
            UI.column
                [ UI.width UI.fill
                , UI.height UI.fill
                , UI.spacing 50
                ]
                [ UI.column
                    [ UI.centerX
                    , UI.width <| UI.maximum 750 UI.fill
                    , UI.paddingXY 10 0
                    ]
                    [ UI.map toMsg <| header { window_width = Maybe.map .width model.window, all_post_filenames = sharedData.all_post_filenames }
                    , pageView.body
                    ]
                , footer
                ]
        ]
    , title = pageView.title
    }


header : { window_width : Maybe Int, all_post_filenames : List String } -> UI.Element Msg
header { window_width, all_post_filenames } =
    let
        compact =
            case window_width of
                Nothing ->
                    False

                Just width ->
                    width < 700

        site_identifier =
            UI.row
                [ if compact then
                    UI.centerX

                  else
                    UI.alignLeft
                , UI_Font.size 25
                , UI.spacing 13
                , UI.centerY
                ]
                [ UI.link [] { url = "/", label = UI.image [ UI.width (px 70), UI.height (px 70), UI_Border.rounded 5, UI.clip ] { src = "/images/caricatura.png", description = "" } }
                , Widgets.link [] { url = "/", label = UI.text "Asier Elorz" }
                ]

        random_post_button attributes =
            UI.el
                ([ UI.pointer
                 , UI.mouseOver [ UI_Font.color Colors.linkBlue ]
                 , UI_Events.onClick (Msg_RandomPostClicked all_post_filenames)
                 ]
                    ++ attributes
                )
            <|
                UI.text "Aleatorio"

        links_row =
            UI.row
                [ UI.alignRight
                , UI.spacing 26
                , UI.centerY
                ]
                [ Widgets.link [] { url = "/", label = UI.text "Recientes" }
                , Widgets.link [] { url = "/archive", label = UI.text "Todos" }
                , random_post_button []
                , Widgets.link [] { url = "/tags", label = UI.text "Etiquetas" }
                , Widgets.link [] { url = "/about", label = UI.text "Sobre mí" }
                ]

        links_2x2 =
            UI.column [ UI.centerX, UI.spacing 10 ]
                [ UI.row [ UI.centerX, UI.centerY, UI.spacing 26 ]
                    [ UI.column [ UI.spacing 10 ]
                        [ Widgets.link [ UI.centerX ] { url = "/", label = UI.text "Recientes" }
                        , random_post_button [ UI.centerX ]
                        ]
                    , UI.column [ UI.spacing 10 ]
                        [ Widgets.link [ UI.centerX ] { url = "/archive", label = UI.text "Todos" }
                        , Widgets.link [ UI.centerX ] { url = "/tags", label = UI.text "Etiquetas" }
                        ]
                    ]
                , Widgets.link [ UI.centerX ] { url = "/about", label = UI.text "Sobre mí" }
                ]
    in
    UI.column
        [ UI.width UI.fill
        , UI.paddingEach { top = 0, left = 0, right = 0, bottom = 60 }
        ]
        [ if compact then
            UI.column
                [ UI.width UI.fill
                , UI.paddingXY 0 20
                , UI.spacing 20
                ]
                [ site_identifier
                , links_2x2
                ]

          else
            UI.wrappedRow
                [ UI.width UI.fill
                , UI.paddingXY 0 20
                ]
                [ site_identifier
                , links_row
                ]
        , Widgets.horizontalSeparator 1
        ]


footer : UI.Element msg
footer =
    UI.el
        [ UI_Background.color Colors.widgetBackground
        , UI_Border.widthXY 0 1
        , UI_Border.color Colors.footerBorder
        , UI.width UI.fill
        , UI.height (px 89)
        , UI.alignBottom
        ]
        UI.none
