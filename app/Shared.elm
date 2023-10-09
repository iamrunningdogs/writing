module Shared exposing (Data, Model, Msg(..), SharedMsg(..), template)

import BackendTask exposing (BackendTask)
import Browser.Dom
import Browser.Events
import Effect exposing (Effect)
import Element as UI exposing (px, rgb255)
import Element.Background as UI_Background
import Element.Border as UI_Border
import Element.Font as UI_Font
import FatalError exposing (FatalError)
import Html exposing (Html)
import Pages.Flags
import Pages.PageUrl exposing (PageUrl)
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


type alias Data =
    ()


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


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        SharedMsg globalMsg ->
            ( model, Effect.none )

        Msg_ViewportSize new_window ->
            ( { model | window = new_window }, Effect.none )


subscriptions : UrlPath -> Model -> Sub Msg
subscriptions _ _ =
    Browser.Events.onResize (\w h -> Msg_ViewportSize <| Just { width = w, height = h })


data : BackendTask FatalError Data
data =
    BackendTask.succeed ()


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
            [ UI_Background.color (UI.rgb255 24 26 27)
            , UI_Font.color (UI.rgb255 211 207 201)
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
                    [ header <| Maybe.map .width model.window
                    , pageView.body
                    ]
                , footer
                ]
        ]
    , title = pageView.title
    }


header : Maybe Int -> UI.Element msg
header window_width =
    let
        compact =
            case window_width of
                Nothing ->
                    False

                Just width ->
                    width < 600

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

        links_row =
            UI.row
                [ UI.alignRight
                , UI.spacing 26
                , UI.centerY
                ]
                [ Widgets.link [] { url = "/", label = UI.text "Recientes" }
                , Widgets.link [] { url = "/archive", label = UI.text "Todos" }
                , Widgets.link [] { url = "/tags", label = UI.text "Etiquetas" }
                , Widgets.link [] { url = "/about", label = UI.text "Sobre mí" }
                ]

        links_2x2 =
            UI.row [ UI.centerX, UI.centerY, UI.spacing 26 ]
                [ UI.column [ UI.spacing 10 ]
                    [ Widgets.link [ UI.centerX ] { url = "/", label = UI.text "Recientes" }
                    , Widgets.link [ UI.centerX ] { url = "/tags", label = UI.text "Etiquetas" }
                    ]
                , UI.column [ UI.spacing 10 ]
                    [ Widgets.link [ UI.centerX ] { url = "/archive", label = UI.text "Todos" }
                    , Widgets.link [ UI.centerX ] { url = "/about", label = UI.text "Sobre mí" }
                    ]
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
        [ UI_Background.color (rgb255 34 36 38)
        , UI_Border.widthXY 0 1
        , UI_Border.color (rgb255 58 62 65)
        , UI.width UI.fill
        , UI.height (px 89)
        , UI.alignBottom
        ]
        UI.none
